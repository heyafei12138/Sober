//
//  SGHomeViewController.swift
//  SoberGarden
//

import UIKit

/// 首页：Streak、Calm Coach、Garden 预览、I'm Struggling 入口
final class SGHomeViewController: BaseViewController {

    private let atmosphereView = SGHomeAtmosphereView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = SGHomeHeaderView()
    private let coachCardView = SGHomeCoachCardView()
    private let streakCardView = SGStreakCardView()
    private let savingsView = SGSavedStatsView()
    private let milestoneCardView = SGMilestoneCardView()
    private let gardenPreviewView = SGGardenPreviewView()
    private let shareProgressControl = SGHomeActionRowControl(
        title: "Share Progress",
        subtitle: "Make your progress easy to share.",
        iconName: "square.and.arrow.up"
    )
    private let rescueButton = SGPrimaryButton(title: "I'm Struggling", style: .rescue)
    private let rescueSubtitleLabel = UILabel()

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        showsRightNavigationActions = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rightActionContainerView.isHidden = false
        renderContent()
    }

    override func bindViewModel() {
        renderContent()
    }

    override func setupSubviews() {
        setupAtmosphere()
        setupFooter()
        setupScrollView()
        setupSections()
        renderContent()
    }

    private func setupAtmosphere() {
        view.insertSubview(atmosphereView, at: 0)
        atmosphereView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(rescueSubtitleLabel.snp.top).offset(-16)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.spacing = SGHomeLayout.sectionSpacing
        contentStackView.alignment = .fill
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(
            top: 8,
            left: SGHomeLayout.screenHorizontal,
            bottom: 24,
            right: SGHomeLayout.screenHorizontal
        )

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSections() {
        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(coachCardView)
        contentStackView.addArrangedSubview(streakCardView)
        contentStackView.addArrangedSubview(savingsView)
        contentStackView.addArrangedSubview(milestoneCardView)
        contentStackView.addArrangedSubview(gardenPreviewView)

        gardenPreviewView.onTap = { [weak self] in
            (self?.tabBarController as? MainTabBarController)?.setSelectedIndex(2)
        }

        shareProgressControl.onTap = { [weak self] in
            self?.shareProgress()
        }
        contentStackView.addArrangedSubview(shareProgressControl)
    }

    private func setupFooter() {
        view.addSubview(rescueSubtitleLabel)
        view.addSubview(rescueButton)

        rescueSubtitleLabel.text = "Get through the next few minutes."
        rescueSubtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rescueSubtitleLabel.textColor = SGColor.textSecondary
        rescueSubtitleLabel.textAlignment = .center
        rescueSubtitleLabel.numberOfLines = 2

        rescueButton.addTarget(self, action: #selector(handleRescueButtonTapped), for: .touchUpInside)

        rescueSubtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.right.equalToSuperview().offset(-28)
            make.bottom.equalTo(rescueButton.snp.top).offset(-12)
        }

        rescueButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(SGHomeLayout.screenHorizontal)
            make.right.equalToSuperview().offset(-SGHomeLayout.screenHorizontal)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-(CustomTabBar.barHeight + 16))
        }
    }

    private func renderContent() {
        let state = SoberGardenStore.shared.state
        let habit = state.habit
        let now = Date()

        let cleanDays = habit.map { SGProgressCalculator.currentStreakDays(startDate: $0.startDate, now: now) } ?? 1
        let elapsedDays = habit.map { SGProgressCalculator.elapsedCleanDaysForSavings(startDate: $0.startDate, now: now) } ?? 0
        let currentHours = habit.map { max(Int(floor(now.timeIntervalSince($0.startDate) / 3600)), 0) } ?? 0
        let longestStreak = max(cleanDays, state.relapseRecords.map(\.previousStreakDays).max() ?? cleanDays)
        let nextMilestone = SGProgressCalculator.nextMilestone(for: cleanDays)
        let habitName = habit?.displayName ?? "Habit"

        headerView.configure(dayCount: cleanDays, habitName: habitName)
        coachCardView.configure(prompt: currentCoachText(for: state, habit: habit, cleanDays: cleanDays, now: now))

        streakCardView.configure(
            cleanDays: cleanDays,
            currentHours: currentHours,
            longestStreakDays: longestStreak,
            startedDate: habit?.startDate,
            habitName: habitName
        )

        savingsView.configure(
            dailyCost: habit?.dailyCost,
            dailyMinutes: habit?.dailyMinutes,
            cleanDays: elapsedDays
        )

        milestoneCardView.configure(cleanDays: cleanDays, nextMilestone: nextMilestone)

        gardenPreviewView.configure(
            gardenStage: SGProgressCalculator.currentGardenStage(for: cleanDays),
            nextMilestone: nextMilestone,
            cleanDays: cleanDays,
            habitName: habitName
        )
    }

    private func currentCoachText(for state: SoberGardenState, habit: Habit?, cleanDays: Int, now: Date) -> String {
        let promptContext: SGCalmCoachContext
        if cleanDays == 7 {
            promptContext = .milestone7
        } else {
            let hour = Calendar.current.component(.hour, from: now)
            if hour >= 22 || hour < 6 {
                promptContext = .lateNight
            } else if !state.relapseRecords.isEmpty {
                promptContext = .stress
            } else {
                promptContext = .home
            }
        }
        return SGCalmCoachService.shared.promptText(for: promptContext, now: now)
    }

    private func shareProgress() {
        guard let habit = SoberGardenStore.shared.state.habit else { return }
        let cleanDays = SGProgressCalculator.currentStreakDays(startDate: habit.startDate)
        let savedMoney = SGProgressCalculator.moneySaved(dailyCost: habit.dailyCost ?? 0, cleanDays: cleanDays)
        let nextMilestone = SGProgressCalculator.nextMilestone(for: cleanDays)?.day
        let stage = SGProgressCalculator.currentGardenStage(for: cleanDays)
        let summary = [
            "I'm growing one clean day at a time.",
            "\(cleanDays) days clean from \(habit.displayName).",
            stage.title,
            nextMilestone.map { "Next milestone: \($0) days." } ?? nil,
            savedMoney > 0 ? "Saved \(NumberFormatter.localizedString(from: NSNumber(value: savedMoney), number: .currency))." : nil
        ]
        .compactMap { $0 }
        .joined(separator: "\n")

        let activity = UIActivityViewController(activityItems: [summary], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view
        activity.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
        present(activity, animated: true)
    }

    @objc private func handleRescueButtonTapped() {
        (tabBarController as? MainTabBarController)?.setSelectedIndex(1)
    }
}

// MARK: - 背景氛围

private final class SGHomeAtmosphereView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = SGColor.background

        let topOrb = makeOrb(color: SGColor.primaryLight.withAlphaComponent(0.55), size: 220)
        let bottomOrb = makeOrb(color: SGColor.flowerSoft.withAlphaComponent(0.45), size: 180)
        addSubview(topOrb)
        addSubview(bottomOrb)

        topOrb.snp.makeConstraints { make in
            make.width.height.equalTo(220)
            make.top.equalToSuperview().offset(-60)
            make.right.equalToSuperview().offset(40)
        }
        bottomOrb.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.bottom.equalToSuperview().offset(120)
            make.left.equalToSuperview().offset(-50)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeOrb(color: UIColor, size: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = size / 2
        return view
    }
}

// MARK: - Share 行

private final class SGHomeActionRowControl: UIControl {

    var onTap: (() -> Void)?

    private let cardView = SGCardView()
    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronView = UIImageView()

    init(title: String, subtitle: String, iconName: String) {
        super.init(frame: .zero)
        setupView(title: title, subtitle: subtitle, iconName: iconName)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(title: "Share Progress", subtitle: "", iconName: "square.and.arrow.up")
    }

    private func setupView(title: String, subtitle: String, iconName: String) {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        cardView.cornerRadius = 18
        cardView.setContentInsets(SGHomeLayout.cardPaddingCompact)

        iconBackground.backgroundColor = SGColor.primaryLight
        iconBackground.layer.cornerRadius = 14

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = SGColor.primaryDark
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = SGColor.textTertiary
        chevronView.contentMode = .scaleAspectFit

        addSubview(cardView)
        cardView.isUserInteractionEnabled = false
        cardView.contentView.addSubview(iconBackground)
        iconBackground.addSubview(iconView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(chevronView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(88)
        }

        iconBackground.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }

        chevronView.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.size.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(iconBackground.snp.right).offset(14)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
            make.bottom.equalToSuperview()
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
