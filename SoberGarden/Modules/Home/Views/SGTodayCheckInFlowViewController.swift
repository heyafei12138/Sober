//
//  SGTodayCheckInFlowViewController.swift
//  SoberGarden
//

import UIKit

final class SGTodayCheckInFlowViewController: BaseViewController {

    enum State {
        case todayNotConfirmed
        case todayConfirmed
        case yesterdayPending
        case dailyFlow
    }

    private enum Step {
        case intro
        case mood
        case triggers
        case feedback
    }

    private enum MoodChoice: CaseIterable {
        case easy
        case okay
        case hard
        case urges

        var title: String {
            switch self {
            case .easy:
                return "checkin.mood.easy".localized()
            case .okay:
                return "checkin.mood.okay".localized()
            case .hard:
                return "checkin.mood.hard".localized()
            case .urges:
                return "checkin.mood.urges".localized()
            }
        }

        var outcome: SoberGardenCheckInOutcome {
            switch self {
            case .easy:
                return .easy
            case .okay:
                return .okay
            case .hard:
                return .hard
            case .urges:
                return .urges
            }
        }
    }

    struct Result {
        let state: State
        let outcome: SoberGardenCheckInOutcome
        let selectedTriggers: [TriggerType]
    }

    private let state: State
    private var currentStep: Step
    private var selectedMood: MoodChoice?
    private var selectedTriggers: Set<TriggerType> = []

    var onComplete: ((Result) -> Void)?
    var onReset: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let introCardView = SGTodayCheckInCardView()
    private let moodHeaderView = SGSectionHeaderView(
        title: "checkin.flow.mood.title".localized(),
        subtitle: "checkin.flow.mood.subtitle".localized()
    )
    private let moodStackView = UIStackView()
    private let triggerHeaderView = SGSectionHeaderView(
        title: "checkin.flow.triggers.title".localized(),
        subtitle: "checkin.flow.triggers.subtitle".localized()
    )
    private let triggerStackView = UIStackView()
    private let feedbackView = SGTodayCheckInFeedbackView()
    private let actionStackView = UIStackView()
    private let primaryButton = SGPrimaryButton(title: "common.continue".localized())
    private let secondaryButton = SGPrimaryButton(title: "common.back".localized(), style: .secondary)
    private var moodChips: [MoodChoice: SGOptionChip] = [:]
    private var triggerChips: [TriggerType: SGOptionChip] = [:]

    init(state: State = .dailyFlow) {
        self.state = state
        self.currentStep = state == .dailyFlow ? .mood : .intro
        super.init(nibName: nil, bundle: nil)
        isCustomNavigationHidden = true
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "checkin.card.badge".localized()
        configureSheetPresentation()
    }

    override func setupSubviews() {
        setupLayout()
        setupMoodOptions()
        setupTriggerOptions()
        setupFeedbackView()
        setupIntroCardActions()
        renderState()
    }

    private func configureSheetPresentation() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 16
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        actionStackView.axis = .horizontal
        actionStackView.alignment = .fill
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 12

        actionStackView.addArrangedSubview(secondaryButton)
        actionStackView.addArrangedSubview(primaryButton)

        primaryButton.addTarget(self, action: #selector(handlePrimaryButtonTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryButtonTapped), for: .touchUpInside)

        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        secondaryButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }

        contentStackView.addArrangedSubview(introCardView)
        contentStackView.addArrangedSubview(moodHeaderView)
        contentStackView.addArrangedSubview(moodStackView)
        contentStackView.addArrangedSubview(triggerHeaderView)
        contentStackView.addArrangedSubview(triggerStackView)
        contentStackView.addArrangedSubview(feedbackView)
        contentStackView.addArrangedSubview(actionStackView)
    }

    private func setupMoodOptions() {
        moodStackView.axis = .vertical
        moodStackView.alignment = .fill
        moodStackView.spacing = 10
        reloadMoodChips()
    }

    private func setupTriggerOptions() {
        triggerStackView.axis = .vertical
        triggerStackView.alignment = .fill
        triggerStackView.spacing = 10
    }

    private func setupFeedbackView() {
        feedbackView.configure(
            title: "checkin.feedback.protected.title".localized(),
            subtitle: "checkin.feedback.protected.subtitle".localized(),
            buttonTitle: "common.done".localized()
        )
        feedbackView.onButtonTap = { [weak self] in
            self?.finishFlow()
        }
    }

    private func setupIntroCardActions() {
        switch state {
        case .todayNotConfirmed, .dailyFlow:
            introCardView.onPrimaryAction = { [weak self] in
                self?.moveToMoodStep()
            }
            introCardView.onSecondaryAction = { [weak self] in
                self?.dismiss(animated: true)
            }
        case .yesterdayPending:
            introCardView.onPrimaryAction = { [weak self] in
                self?.completeYesterdayConfirmation()
            }
            introCardView.onSecondaryAction = { [weak self] in
                self?.onReset?()
            }
        case .todayConfirmed:
            introCardView.onPrimaryAction = nil
            introCardView.onSecondaryAction = nil
        }
    }

    private func renderState() {
        let cardState: SGTodayCheckInCardView.State
        switch state {
        case .todayNotConfirmed, .dailyFlow:
            cardState = .todayEmpty
        case .todayConfirmed:
            cardState = .todayPlanted
        case .yesterdayPending:
            cardState = .yesterdayPending
        }

        introCardView.isHidden = state == .todayConfirmed
        introCardView.configure(state: cardState)
        moodHeaderView.isHidden = currentStep != .mood
        moodStackView.isHidden = currentStep != .mood
        triggerHeaderView.isHidden = currentStep != .triggers
        triggerStackView.isHidden = currentStep != .triggers
        feedbackView.isHidden = currentStep != .feedback && state != .todayConfirmed
        actionStackView.isHidden = !(currentStep == .mood || currentStep == .triggers)

        primaryButton.setTitle(currentPrimaryTitle(), for: .normal)
        secondaryButton.setTitle(currentSecondaryTitle(), for: .normal)
        primaryButton.isHidden = actionStackView.isHidden
        secondaryButton.isHidden = actionStackView.isHidden
        primaryButton.isEnabled = currentPrimaryEnabled()

        if state == .todayConfirmed {
            feedbackView.isHidden = false
            feedbackView.configure(
                title: "checkin.card.confirmed.title".localized(),
                subtitle: "checkin.card.confirmed.subtitle".localized(),
                buttonTitle: "common.done".localized()
            )
        }
    }

    private func currentPrimaryTitle() -> String {
        switch currentStep {
        case .intro:
            return "common.continue".localized()
        case .mood:
            return "common.continue".localized()
        case .triggers:
            return "common.continue".localized()
        case .feedback:
            return "common.done".localized()
        }
    }

    private func currentSecondaryTitle() -> String {
        switch currentStep {
        case .mood, .triggers:
            return "common.back".localized()
        case .feedback:
            return "common.back".localized()
        case .intro:
            return "common.imStruggling".localized()
        }
    }

    private func currentPrimaryEnabled() -> Bool {
        switch currentStep {
        case .intro:
            return false
        case .mood:
            return selectedMood != nil
        case .triggers:
            return true
        case .feedback:
            return true
        }
    }

    private func moveToMoodStep() {
        currentStep = .mood
        renderState()
    }

    private func moveToTriggersStep() {
        currentStep = .triggers
        renderState()
    }

    private func moveToFeedbackStep() {
        currentStep = .feedback
        renderState()
        feedbackView.configure(
            title: "checkin.feedback.protected.title".localized(),
            subtitle: "checkin.feedback.protected.subtitle".localized(),
            buttonTitle: "common.done".localized()
        )
    }

    private func completeYesterdayConfirmation() {
        onComplete?(
            Result(
                state: state,
                outcome: .easy,
                selectedTriggers: []
            )
        )
    }

    private func finishFlow() {
        let outcome = selectedMood?.outcome ?? .easy
        onComplete?(
            Result(
                state: state,
                outcome: outcome,
                selectedTriggers: Array(selectedTriggers).sorted { $0.rawValue < $1.rawValue }
            )
        )
    }

    private func reloadMoodChips() {
        moodChips.removeAll()
        moodStackView.arrangedSubviews.forEach { view in
            moodStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let moods = MoodChoice.allCases
        for row in moods.chunked(into: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            rowStack.spacing = 10

            row.forEach { mood in
                let chip = SGOptionChip(title: mood.title)
                chip.isSelected = selectedMood == mood
                chip.addTarget(self, action: #selector(handleMoodChipTapped(_:)), for: .touchUpInside)
                moodChips[mood] = chip
                rowStack.addArrangedSubview(chip)
            }

            if row.count == 1 {
                rowStack.addArrangedSubview(UIView())
            }

            moodStackView.addArrangedSubview(rowStack)
        }
    }

    private func reloadTriggerChips() {
        triggerChips.removeAll()
        triggerStackView.arrangedSubviews.forEach { view in
            triggerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let triggers: [TriggerType] = [
            .stress, .boredom, .loneliness, .lateNight, .socialMedia, .tiredness, .conflict
        ]

        for row in triggers.chunked(into: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            rowStack.spacing = 10

            row.forEach { trigger in
                let chip = SGOptionChip(title: trigger.displayName)
                chip.isSelected = selectedTriggers.contains(trigger)
                chip.addTarget(self, action: #selector(handleTriggerChipTapped(_:)), for: .touchUpInside)
                triggerChips[trigger] = chip
                rowStack.addArrangedSubview(chip)
            }

            if row.count == 1 {
                rowStack.addArrangedSubview(UIView())
            }

            triggerStackView.addArrangedSubview(rowStack)
        }
    }

    @objc private func handlePrimaryButtonTapped() {
        switch currentStep {
        case .intro:
            moveToMoodStep()
        case .mood:
            guard let mood = selectedMood else { return }
            if mood == .hard || mood == .urges {
                moveToTriggersStep()
            } else {
                moveToFeedbackStep()
            }
        case .triggers:
            moveToFeedbackStep()
        case .feedback:
            finishFlow()
        }
    }

    @objc private func handleSecondaryButtonTapped() {
        switch currentStep {
        case .intro:
            onReset?()
        case .mood, .triggers:
            currentStep = .intro
            renderState()
        case .feedback:
            currentStep = .mood
            renderState()
        }
    }

    @objc private func handleMoodChipTapped(_ sender: SGOptionChip) {
        guard let mood = moodChips.first(where: { $0.value === sender })?.key else { return }
        selectedMood = mood
        moodChips.forEach { chipMood, chip in
            chip.isSelected = chipMood == mood
        }
        primaryButton.isEnabled = true
        if mood == .hard || mood == .urges {
            reloadTriggerChips()
            triggerHeaderView.isHidden = false
            triggerStackView.isHidden = false
        } else {
            selectedTriggers.removeAll()
            triggerHeaderView.isHidden = true
            triggerStackView.isHidden = true
        }
    }

    @objc private func handleTriggerChipTapped(_ sender: SGOptionChip) {
        guard let trigger = triggerChips.first(where: { $0.value === sender })?.key else { return }
        if selectedTriggers.contains(trigger) {
            selectedTriggers.remove(trigger)
        } else {
            selectedTriggers.insert(trigger)
        }
        triggerChips[trigger]?.isSelected = selectedTriggers.contains(trigger)
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        var result: [[Element]] = []
        var index = startIndex
        while index < endIndex {
            let end = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(Array(self[index..<end]))
            index = end
        }
        return result
    }
}
