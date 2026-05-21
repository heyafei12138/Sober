//
//  SGHomeViewController.swift
//  SoberGarden
//

import UIKit

/// 首页：Streak、Calm Coach、Garden 预览、I'm Struggling 入口
final class SGHomeViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = SGHomeHeaderView()
    private let coachCardView = SGCardView()
    private let coachContentStackView = UIStackView()
    private let coachTextStackView = UIStackView()
    private let coachImageContainerView = UIView()
    private let coachImageView = UIImageView()
    private let coachSectionHeader = SGSectionHeaderView(title: "Calm Coach")
    private let coachPromptLabel = UILabel()
    private let todayCheckInCardView = SGTodayCheckInCardView()
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
    private var didPresentNonMedicalDisclaimer = false

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNonMedicalDisclaimerIfNeeded()
    }

    override func bindViewModel() {
        renderContent()
    }

    override func onSettingsButtonPressed() {
        pushController(SGSettingsViewController())
    }

    override func setupSubviews() {
        setupFooter()
        setupScrollView()
        setupHeader()
        setupCoachCard()
        setupTodayCheckInCard()
        setupStreakCard()
        setupSavingsSection()
        setupMilestoneSection()
        setupGardenPreview()
        setupShareSection()
        renderContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(rescueSubtitleLabel.snp.top).offset(-20)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 2, left: 20, bottom: 32, right: 20)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupHeader() {
        contentStackView.addArrangedSubview(headerView)
        contentStackView.setCustomSpacing(22, after: headerView)
    }

    private func setupCoachCard() {
        coachCardView.setContentInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        coachCardView.contentView.backgroundColor = UIColor.hexString("#FFF9E8")

        coachContentStackView.axis = .horizontal
        coachContentStackView.alignment = .center
        coachContentStackView.spacing = 16

        coachTextStackView.axis = .vertical
        coachTextStackView.alignment = .fill
        coachTextStackView.spacing = 10

        coachImageContainerView.backgroundColor = UIColor.hexString("#FDE7B5")
        coachImageContainerView.layer.cornerRadius = 22
        coachImageContainerView.layer.masksToBounds = true

        coachImageView.image = UIImage(named: "home_calm_coach_icon") ?? UIImage(named: "guider_icon_singleFlower")
        coachImageView.contentMode = .scaleAspectFit

        coachPromptLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        coachPromptLabel.textColor = SGColor.textDark
        coachPromptLabel.numberOfLines = 0
        coachPromptLabel.lineBreakMode = .byWordWrapping
        coachPromptLabel.adjustsFontSizeToFitWidth = true
        coachPromptLabel.minimumScaleFactor = 0.88

        coachCardView.contentView.addSubview(coachContentStackView)
        coachTextStackView.addArrangedSubview(coachSectionHeader)
        coachTextStackView.addArrangedSubview(coachPromptLabel)
        coachContentStackView.addArrangedSubview(coachTextStackView)
        coachContentStackView.addArrangedSubview(coachImageContainerView)
        coachImageContainerView.addSubview(coachImageView)

        coachContentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        coachImageContainerView.snp.makeConstraints { make in
            make.size.equalTo(74)
        }

        coachImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(13)
        }

        contentStackView.addArrangedSubview(coachCardView)
    }

    private func setupTodayCheckInCard() {
        todayCheckInCardView.onPrimaryAction = { [weak self] in
            self?.presentTodayCheckInFlow()
        }
        todayCheckInCardView.onSecondaryAction = { [weak self] in
            self?.handleTodayCheckInSecondaryAction()
        }
        contentStackView.addArrangedSubview(todayCheckInCardView)
        contentStackView.setCustomSpacing(22, after: todayCheckInCardView)
    }

    private func setupStreakCard() {
        contentStackView.addArrangedSubview(streakCardView)
    }

    private func setupSavingsSection() {
        savingsView.onSavingsItemTap = { [weak self] in
            self?.openHabitEditor()
        }
        contentStackView.addArrangedSubview(savingsView)
    }

    private func setupMilestoneSection() {
        contentStackView.addArrangedSubview(milestoneCardView)
    }

    private func setupGardenPreview() {
        contentStackView.addArrangedSubview(gardenPreviewView)
    }

    private func setupShareSection() {
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
        rescueSubtitleLabel.numberOfLines = 1
        rescueSubtitleLabel.adjustsFontSizeToFitWidth = true
        rescueSubtitleLabel.minimumScaleFactor = 0.8

        rescueButton.addTarget(self, action: #selector(handleRescueButtonTapped), for: .touchUpInside)

        rescueSubtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(rescueButton.snp.top).offset(-10)
        }

        rescueButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
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

        headerView.configure(
            dayCount: cleanDays,
            habitName: habitName
        )

        coachPromptLabel.text = currentCoachText(for: state, habit: habit, cleanDays: cleanDays, now: now)
        todayCheckInCardView.configure(state: currentTodayCheckInState(from: state.checkIn))

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

        milestoneCardView.configure(
            cleanDays: cleanDays,
            nextMilestone: nextMilestone
        )

        gardenPreviewView.configure(
            gardenStage: SGProgressCalculator.currentGardenStage(for: cleanDays),
            nextMilestone: nextMilestone,
            cleanDays: cleanDays,
            habitName: habitName
        )
    }

    private func currentTodayCheckInState(from checkInState: SoberGardenCheckInState) -> SGTodayCheckInCardView.State {
        if checkInState.confirmedToday {
            return .todayConfirmed
        }

        if checkInState.needsYesterdayConfirmation {
            return .yesterdayPending
        }

        return .todayNotConfirmed
    }

    private func presentTodayCheckInFlow() {
        let checkInState = SoberGardenStore.shared.state.checkIn
        let flowState: SGTodayCheckInFlowViewController.State

        if checkInState.needsYesterdayConfirmation {
            flowState = .yesterdayPending
        } else if checkInState.confirmedToday {
            flowState = .todayConfirmed
        } else {
            flowState = .dailyFlow
        }

        let flowViewController = SGTodayCheckInFlowViewController(state: flowState)
        flowViewController.onComplete = { [weak self] result in
            self?.handleTodayCheckInResult(result)
        }
        flowViewController.onReset = { [weak self] in
            self?.handleTodayCheckInReset()
        }
        present(flowViewController, animated: true)
    }

    private func handleTodayCheckInSecondaryAction() {
        let checkInState = SoberGardenStore.shared.state.checkIn
        if checkInState.needsYesterdayConfirmation {
            presentTodayCheckInFlow()
            return
        }

        if let tabBarController = tabBarController as? MainTabBarController {
            tabBarController.setSelectedIndex(1)
        } else {
            navigationController?.pushViewController(SGRescueViewController(), animated: true)
        }
    }

    private func handleTodayCheckInResult(_ result: SGTodayCheckInFlowViewController.Result) {
        let store = SoberGardenStore.shared

        switch result.state {
        case .todayNotConfirmed, .dailyFlow:
            store.markTodayCheckInConfirmed(outcome: result.outcome)
        case .yesterdayPending:
            let yesterdayDate = store.state.checkIn.lastCheckInDate ?? Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            store.recordYesterdayCheckInConfirmed(
                outcome: result.outcome,
                yesterdayDate: yesterdayDate
            )
        case .todayConfirmed:
            break
        }

        dismiss(animated: true) { [weak self] in
            self?.renderContent()
            self?.animateTodayCheckInFeedback()
        }
    }

    private func handleTodayCheckInReset() {
        SoberGardenStore.shared.resetCleanStreakAfterCheckInReset()
        dismiss(animated: true) { [weak self] in
            self?.renderContent()
        }
    }

    private func animateTodayCheckInFeedback() {
        let animations = {
            self.todayCheckInCardView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            self.gardenPreviewView.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            self.todayCheckInCardView.alpha = 0.98
            self.gardenPreviewView.alpha = 0.98
        }

        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
                self.todayCheckInCardView.transform = .identity
                self.gardenPreviewView.transform = .identity
                self.todayCheckInCardView.alpha = 1
                self.gardenPreviewView.alpha = 1
            }
        }

        UIView.animate(withDuration: 0.14, delay: 0, options: [.curveEaseOut], animations: animations, completion: completion)
    }

    private func presentNonMedicalDisclaimerIfNeeded() {
        guard didPresentNonMedicalDisclaimer == false else { return }
        guard SoberGardenStore.shared.state.settings.hasAcknowledgedNonMedicalDisclaimer == false else { return }
        guard presentedViewController == nil else { return }

        didPresentNonMedicalDisclaimer = true

        let disclaimerViewController = SGNonMedicalDisclaimerViewController(mode: .firstLaunch)
        disclaimerViewController.modalPresentationStyle = .fullScreen
        present(disclaimerViewController, animated: true)
    }

    private func currentCoachText(for state: SoberGardenState, habit: Habit?, cleanDays: Int, now: Date) -> String {
        let promptContext: SGCalmCoachContext
        if state.checkIn.needsYesterdayConfirmation {
            promptContext = .yesterdayFollowUp
        } else if state.checkIn.confirmedToday {
            promptContext = .postCheckInEncouragement
        } else if cleanDays == 7 {
            promptContext = .milestone7
        } else {
            promptContext = .notConfirmedToday
        }

        return SGCalmCoachService.shared.promptText(for: promptContext, now: now)
    }

    private func shareProgress() {
        guard let activityItems = SGShareProgressService.shared.makeActivityItems() else { return }

        let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view
        activity.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
        present(activity, animated: true)
    }

    private func openHabitEditor() {
        guard let habit = SoberGardenStore.shared.state.habit else { return }
        let editViewController = SGEditHabitViewController(habit: habit)
        editViewController.onSave = { [weak self] in
            self?.renderContent()
        }
        pushController(editViewController)
    }

    @objc private func handleRescueButtonTapped() {
        (tabBarController as? MainTabBarController)?.setSelectedIndex(1)
    }
}

private final class SGHomeActionRowControl: UIControl {

    var onTap: (() -> Void)?

    private let cardView = SGCardView()
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

        addSubview(cardView)
        cardView.isUserInteractionEnabled = false
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FDF9EA")
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(88)
        }
        cardView.contentView.addSubview(iconView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(chevronView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

        iconView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(18)
            make.size.equalTo(24)
        }

        chevronView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
            make.bottom.equalToSuperview().inset(18)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
