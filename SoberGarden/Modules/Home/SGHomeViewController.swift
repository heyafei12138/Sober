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
    private let coachSectionHeader = SGSectionHeaderView(title: "home.coach.title".localized())
    private let coachPromptLabel = UILabel()
    private let todayCheckInCardView = SGTodayCheckInCardView()
    private let dailyGardenGridView = SGDailyGardenGridView()
    private let dailyPlantStatsView = SGDailyPlantStatsView()
    private let plantReviewCardView = SGPlantReviewCardView()
    private let streakCardView = SGStreakCardView()
    private let savingsView = SGSavedStatsView()
    private let milestoneCardView = SGMilestoneCardView()
    private let gardenPreviewView = SGGardenPreviewView()
    private let logoImageView = UIImageView(image: UIImage(named: "logo_icon"))
    private let shareProgressControl = SGHomeActionRowControl(
        title: "home.shareProgress.title".localized(),
        subtitle: "home.shareProgress.subtitle".localized(),
        iconName: "paperplane.fill"
    )
    private let rescuePillControl = SGHomeRescuePillControl()
    private var didPresentNonMedicalDisclaimer = false
    private var isRescuePillHiddenForScroll = false

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        showsRightNavigationActions = true
        showsSettingsButton = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshRightNavigationActionsIfNeeded()
        renderContent()
        rescuePillControl.startBreathingAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rescuePillControl.stopBreathingAnimation()
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
        setupScrollView()
        setupLogoView()
        setupHeader()
        setupCoachCard()
        setupTodayCheckInCard()
        setupDailyGardenGrid()
        setupDailyPlantStats()
        setupPlantReviewCard()
        setupStreakCard()
        setupSavingsSection()
        setupMilestoneSection()
        setupGardenPreview()
        setupShareSection()
        setupFooter()
        renderContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 12)
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

    private func setupLogoView() {
        view.addSubview(logoImageView)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.accessibilityLabel = "SoberGarden"
        logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(1)
            make.size.equalTo(CGSizeMake(150, 25))
        }
        view.bringSubviewToFront(logoImageView)
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
            self?.recordTodayAsPlanted()
        }
        todayCheckInCardView.onSecondaryAction = { [weak self] in
            self?.recordTodayAsRainy()
        }
        todayCheckInCardView.onEditAction = { [weak self] in
            self?.presentTodayRecordEditor()
        }
        contentStackView.addArrangedSubview(todayCheckInCardView)
        contentStackView.setCustomSpacing(22, after: todayCheckInCardView)
    }

    private func setupDailyGardenGrid() {
        dailyGardenGridView.onRangeTap = { [weak self] in
            self?.presentDailyGardenRangeSelector()
        }
        contentStackView.addArrangedSubview(dailyGardenGridView)
        contentStackView.setCustomSpacing(12, after: dailyGardenGridView)
    }

    private func setupDailyPlantStats() {
        contentStackView.addArrangedSubview(dailyPlantStatsView)
    }

    private func setupPlantReviewCard() {
        plantReviewCardView.onDismiss = { [weak self] in
            self?.dismissPlantReview()
        }
        contentStackView.addArrangedSubview(plantReviewCardView)
    }

    private func setupStreakCard() {
        streakCardView.onShareTap = { [weak self] in
            guard let self else { return }
            self.shareProgress(sourceView: self.streakCardView)
        }
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
            guard let self else { return }
            self.shareProgress(sourceView: self.shareProgressControl)
        }
        contentStackView.addArrangedSubview(shareProgressControl)
    }

    private func setupFooter() {
        view.addSubview(rescuePillControl)
        view.bringSubviewToFront(rescuePillControl)
        rescuePillControl.addTarget(self, action: #selector(handleRescueButtonTapped), for: .touchUpInside)

        rescuePillControl.snp.makeConstraints { make in
            make.width.equalTo(84)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(64)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-(CustomTabBar.barHeight + 16))
        }
    }

    private func renderContent(now: Date = Date()) {
        let state = SoberGardenStore.shared.state
        let habit = state.habit
        let dailyPlantDisplayData = currentDailyPlantDisplayData(state: state, habit: habit, now: now)
        let todayRecord = dailyPlantDisplayData.todayRecord

        let cleanDays = habit.map { SGProgressCalculator.currentStreakDays(startDate: $0.startDate, now: now) } ?? 1
        let automaticDailyGardenDays = SGProgressCalculator.dailyGardenAutomaticDisplayDays(for: cleanDays)
        let usesAutomaticDailyGardenDays = state.dailyGardenDisplayDays.map { Self.dailyGardenDisplayOptions.contains($0) } != true
        let selectedDailyGardenDays = Self.normalizedDailyGardenDisplayDays(
            state.dailyGardenDisplayDays,
            automaticDays: automaticDailyGardenDays
        )
        let elapsedDays = habit.map { SGProgressCalculator.elapsedCleanDaysForSavings(startDate: $0.startDate, now: now) } ?? 0
        let currentHours = habit.map { max(Int(floor(now.timeIntervalSince($0.startDate) / 3600)), 0) } ?? 0
        let longestStreak = max(cleanDays, state.relapseRecords.map(\.previousStreakDays).max() ?? cleanDays)
        let nextMilestone = SGProgressCalculator.nextMilestone(for: cleanDays)
        let habitName = habit?.displayName ?? "habit.generic".localized()

        headerView.configure(
            dayCount: cleanDays,
            habitName: habitName
        )

        coachSectionHeader.configure(title: "home.coach.title".localized())
        coachPromptLabel.text = currentCoachText(cleanDays: cleanDays, todayStatus: todayRecord?.status, now: now)
        todayCheckInCardView.configure(state: currentTodayPlantState(for: todayRecord))
        let dailyGardenItems = currentDailyGardenItems(
            records: dailyPlantDisplayData.records,
            startDate: dailyPlantDisplayData.startDate,
            selectedDays: selectedDailyGardenDays,
            isAutomatic: usesAutomaticDailyGardenDays,
            now: now
        )
        dailyGardenGridView.configure(
            items: dailyGardenItems,
            selectedDays: selectedDailyGardenDays,
            rangeTitle: Self.dailyGardenRangeTitle(
                selectedDays: selectedDailyGardenDays,
                isAutomatic: usesAutomaticDailyGardenDays
            )
        )
        let dailyPlantStreak = SGProgressCalculator.dailyPlantStreak(records: dailyPlantDisplayData.records, now: now)
        let totalPlantedDays = SGProgressCalculator.totalPlantedDays(records: dailyPlantDisplayData.records)
        dailyPlantStatsView.configure(
            currentStreakDays: dailyPlantStreak,
            totalPlantedDays: totalPlantedDays
        )
        plantReviewCardView.configure(
            reviewType: currentPlantReviewType(totalPlantedDays: totalPlantedDays, state: state)
        )

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

    private struct DailyPlantDisplayData {
        let records: [DailyRecord]
        let startDate: Date
        let todayRecord: DailyRecord?
    }

    private func currentDailyPlantDisplayData(
        state: SoberGardenState,
        habit: Habit?,
        now: Date,
        calendar: Calendar = .current
    ) -> DailyPlantDisplayData {
        let startDate = habit?.startDate ?? now
        return DailyPlantDisplayData(
            records: state.dailyRecords,
            startDate: startDate,
            todayRecord: SoberGardenStore.shared.dailyRecord(for: now, calendar: calendar)
        )
    }

    private func currentTodayPlantState(for record: DailyRecord?) -> SGTodayCheckInCardView.State {
        switch record?.status {
        case .planted:
            return .todayPlanted
        case .rainy:
            return .todayRainy
        case nil:
            return .todayEmpty
        }
    }

    private func recordTodayAsPlanted() {
        let now = Date()
        guard SoberGardenStore.shared.dailyRecord(for: now) == nil else { return }
        SoberGardenStore.shared.recordTodayAsPlanted(now: now)
        renderContent(now: now)
        animateTodayCheckInFeedback()
    }

    private func recordTodayAsRainy() {
        let now = Date()
        guard SoberGardenStore.shared.dailyRecord(for: now) == nil else { return }
        SoberGardenStore.shared.recordTodayAsRainy(now: now)
        renderContent(now: now)
        animateTodayCheckInFeedback()
    }

    private func currentDailyGardenItems(
        records: [DailyRecord],
        startDate: Date,
        selectedDays: Int,
        isAutomatic: Bool,
        now: Date
    ) -> [DailyDayItem] {
        if isAutomatic {
            return SGProgressCalculator.journeyDailyItems(
                records: records,
                startDate: startDate,
                count: selectedDays,
                now: now
            )
        }

        return SGProgressCalculator.contextualDailyItems(
            records: records,
            startDate: startDate,
            count: selectedDays,
            now: now
        )
    }

    private func presentTodayRecordEditor() {
        let now = Date()
        let state = SoberGardenStore.shared.state
        let displayData = currentDailyPlantDisplayData(state: state, habit: state.habit, now: now)
        guard let todayRecord = displayData.todayRecord else { return }

        let sheetViewController = SGDailyPlantEditSheetViewController(currentStatus: todayRecord.status) { [weak self] action in
            switch action {
            case .planted:
                self?.updateTodayRecord(status: .planted)
            case .rainy:
                self?.updateTodayRecord(status: .rainy)
            case .clear:
                self?.clearTodayRecord()
            }
        }
        present(sheetViewController, animated: false)
    }

    private func presentDailyGardenRangeSelector() {
        let now = Date()
        let state = SoberGardenStore.shared.state
        let cleanDays = state.habit.map { SGProgressCalculator.currentStreakDays(startDate: $0.startDate, now: now) } ?? 1
        let automaticDays = SGProgressCalculator.dailyGardenAutomaticDisplayDays(for: cleanDays)
        let usesAutomaticDays = state.dailyGardenDisplayDays.map { Self.dailyGardenDisplayOptions.contains($0) } != true
        let selectedDays = Self.normalizedDailyGardenDisplayDays(state.dailyGardenDisplayDays, automaticDays: automaticDays)
        let options = [SGDailyGardenRangeSheetViewController.Option(
            days: nil,
            title: "home.dailyGardenGrid.rangeSelector.autoFormat".localizedFormat(automaticDays)
        )] + Self.dailyGardenDisplayOptions.map { days in
            SGDailyGardenRangeSheetViewController.Option(
                days: days,
                title: "home.dailyGardenGrid.rangeSelector.daysFormat".localizedFormat(days)
            )
        }

        let sheetViewController = SGDailyGardenRangeSheetViewController(
            options: options,
            selectedDays: selectedDays,
            isAutomatic: usesAutomaticDays
        ) { [weak self] days in
            SoberGardenStore.shared.setDailyGardenDisplayDays(days)
            self?.renderContent()
        }
        present(sheetViewController, animated: false)
    }

    private func updateTodayRecord(status: DailyRecordStatus) {
        let now = Date()
        SoberGardenStore.shared.updateDailyRecord(for: now, status: status, now: now)
        renderContent(now: now)
        animateTodayCheckInFeedback()
    }

    private func clearTodayRecord() {
        let now = Date()
        SoberGardenStore.shared.clearDailyRecord(for: now)
        renderContent(now: now)
        animateTodayCheckInFeedback()
    }

    private func currentPlantReviewType(
        totalPlantedDays: Int,
        state: SoberGardenState
    ) -> SGPlantReviewCardView.ReviewType? {
        if totalPlantedDays == 7,
           state.lastReviewShownType != SGPlantReviewCardView.ReviewType.totalPlanted7.rawValue {
            return .totalPlanted7
        }

        if totalPlantedDays == 30,
           state.lastReviewShownType != SGPlantReviewCardView.ReviewType.totalPlanted30.rawValue {
            return .totalPlanted30
        }

        return nil
    }

    private static var dailyGardenDisplayOptions: [Int] {
        Array(
            Set(Milestone.defaultMilestones.map(\.day) + [3])
        )
        .filter { $0 > 1 }
        .sorted()
    }

    private static func normalizedDailyGardenDisplayDays(_ days: Int?, automaticDays: Int) -> Int {
        guard let days, dailyGardenDisplayOptions.contains(days) else {
            return automaticDays
        }
        return days
    }

    private static func dailyGardenRangeTitle(selectedDays: Int, isAutomatic: Bool) -> String {
        if isAutomatic {
            return "home.dailyGardenGrid.range.autoFormat".localizedFormat(selectedDays)
        }
        return "home.dailyGardenGrid.range.manualFormat".localizedFormat(selectedDays)
    }

    private func dismissPlantReview() {
        let state = SoberGardenStore.shared.state
        let totalPlantedDays = SGProgressCalculator.totalPlantedDays(records: state.dailyRecords)
        guard let reviewType = currentPlantReviewType(totalPlantedDays: totalPlantedDays, state: state) else { return }

        SoberGardenStore.shared.markDailyPlantReviewShown(type: reviewType.rawValue)
        renderContent()
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

    private func currentCoachText(cleanDays: Int, todayStatus: DailyRecordStatus?, now: Date) -> String {
        let promptContext: SGCalmCoachContext
        if todayStatus == .planted {
            promptContext = .postCheckInEncouragement
        } else if todayStatus == .rainy {
            promptContext = .relapse
        } else if cleanDays == 7 {
            promptContext = .milestone7
        } else {
            promptContext = .notConfirmedToday
        }

        return SGCalmCoachService.shared.promptText(for: promptContext, now: now)
    }

    private func shareProgress(sourceView: UIView?) {
        guard let package = SGShareProgressService.shared.makeProgressSharePackage() else { return }

        let previewViewController = SGSharePreviewViewController(package: package)
        previewViewController.popoverPresentationController?.sourceView = sourceView ?? view
        previewViewController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
        present(previewViewController, animated: true)
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

    private func setRescuePillHiddenForScroll(_ hidden: Bool) {
        guard isRescuePillHiddenForScroll != hidden else { return }
        isRescuePillHiddenForScroll = hidden

        let horizontalOffset = rescuePillControl.bounds.width + 32
        let targetTransform = hidden ? CGAffineTransform(translationX: horizontalOffset, y: 0) : .identity
        let targetAlpha: CGFloat = hidden ? 0.82 : 1

        UIView.animate(
            withDuration: hidden ? 0.34 : 0.46,
            delay: hidden ? 0.04 : 0.18,
            usingSpringWithDamping: hidden ? 0.92 : 0.78,
            initialSpringVelocity: hidden ? 0.2 : 0.38,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]
        ) {
            self.rescuePillControl.transform = targetTransform
            self.rescuePillControl.alpha = hidden ? 0.72 : targetAlpha
        }
    }
}

extension SGHomeViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setRescuePillHiddenForScroll(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            setRescuePillHiddenForScroll(true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            setRescuePillHiddenForScroll(false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setRescuePillHiddenForScroll(false)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setRescuePillHiddenForScroll(false)
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
        setupView(title: "home.shareProgress.title".localized(), subtitle: "", iconName: "square.and.arrow.up")
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
            make.left.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
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

private final class SGHomeRescuePillControl: UIControl {

    private let pulseOuterView = UIView()
    private let pulseMiddleView = UIView()
    private let backgroundView = UIView()
    private let iconContainerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.14, delay: 0, options: [.curveEaseOut]) {
                self.backgroundView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
                self.backgroundView.backgroundColor = self.isHighlighted ? UIColor.hexString("#D95733") : UIColor.hexString("#F06A42")
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pulseOuterView.layer.cornerRadius = pulseOuterView.bounds.height / 2
        pulseMiddleView.layer.cornerRadius = pulseMiddleView.bounds.height / 2
        backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
        iconContainerView.layer.cornerRadius = iconContainerView.bounds.height / 2
    }

    func startBreathingAnimation() {
        guard pulseOuterView.layer.animation(forKey: "rescuePulseOuter") == nil else { return }

        addRippleAnimation(to: pulseOuterView, key: "rescuePulseOuter", delay: 0)
        addRippleAnimation(to: pulseMiddleView, key: "rescuePulseMiddle", delay: 0.55)

        let iconScale = CABasicAnimation(keyPath: "transform.scale")
        iconScale.fromValue = 1
        iconScale.toValue = 1.08
        iconScale.duration = 1.2
        iconScale.autoreverses = true
        iconScale.repeatCount = .infinity
        iconScale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        iconContainerView.layer.add(iconScale, forKey: "rescueIconPulse")
    }

    func stopBreathingAnimation() {
        pulseOuterView.layer.removeAnimation(forKey: "rescuePulseOuter")
        pulseMiddleView.layer.removeAnimation(forKey: "rescuePulseMiddle")
        iconContainerView.layer.removeAnimation(forKey: "rescueIconPulse")
    }

    private func addRippleAnimation(to view: UIView, key: String, delay: CFTimeInterval) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.86
        scale.toValue = 1.78

        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.62
        opacity.toValue = 0

        let group = CAAnimationGroup()
        group.animations = [scale, opacity]
        group.duration = 1.85
        group.beginTime = CACurrentMediaTime() + delay
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(group, forKey: key)
    }

    private func setupView() {
        accessibilityLabel = "home.help.accessibilityLabel".localized()
        accessibilityHint = "home.help.accessibilityHint".localized()
        accessibilityTraits = .button

        addSubview(pulseOuterView)
        addSubview(pulseMiddleView)
        addSubview(backgroundView)

        pulseOuterView.isUserInteractionEnabled = false
        pulseMiddleView.isUserInteractionEnabled = false
        pulseOuterView.backgroundColor = UIColor.hexString("#F06A42").withAlphaComponent(0.34)
        pulseMiddleView.backgroundColor = UIColor.hexString("#FF8A5B").withAlphaComponent(0.32)

        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = UIColor.hexString("#F06A42")
        backgroundView.layer.borderWidth = 1.5
        backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
        backgroundView.layer.shadowColor = UIColor.hexString("#B74E32").cgColor
        backgroundView.layer.shadowOpacity = 0.34
        backgroundView.layer.shadowRadius = 18
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)

        backgroundView.addSubview(iconContainerView)
        backgroundView.addSubview(titleLabel)

        iconContainerView.backgroundColor = .clear
        iconContainerView.layer.cornerRadius = 16
        iconContainerView.layer.masksToBounds = true
        iconContainerView.addSubview(iconView)

        iconView.image = UIImage(systemName: "hand.raised.fill")
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = "home.help.title".localized()
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.86

        pulseOuterView.snp.makeConstraints { make in
            make.center.equalTo(backgroundView)
            make.width.equalTo(backgroundView.snp.width).offset(10)
            make.height.equalTo(backgroundView.snp.height).offset(8)
        }

        pulseMiddleView.snp.makeConstraints { make in
            make.center.equalTo(backgroundView)
            make.width.equalTo(backgroundView.snp.width).offset(6)
            make.height.equalTo(backgroundView.snp.height).offset(4)
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(25)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(1)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().inset(7)
        }
    }
}
