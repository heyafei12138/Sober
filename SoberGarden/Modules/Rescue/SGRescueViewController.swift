//
//  SGRescueViewController.swift
//  SoberGarden
//

import UIKit

/// 急救流程：冲动状态选择、呼吸练习、延迟承诺
final class SGRescueViewController: BaseViewController {

    private enum Step: Int, CaseIterable {
        case urgeBefore
        case emotion
        case breathing
        case reasons
        case delay
        case urgeAfter
        case completion

        var title: String {
            switch self {
            case .urgeBefore:
                return "rescue.step.urgeBefore.title".localized()
            case .emotion:
                return "rescue.step.emotion.title".localized()
            case .breathing:
                return "rescue.step.breathing.title".localized()
            case .reasons:
                return "rescue.step.reasons.title".localized()
            case .delay:
                return "rescue.step.delay.title".localized()
            case .urgeAfter:
                return "rescue.step.urgeAfter.title".localized()
            case .completion:
                return "rescue.step.completion.title".localized()
            }
        }

        var subtitle: String {
            switch self {
            case .urgeBefore:
                return "rescue.step.urgeBefore.subtitle".localized()
            case .emotion:
                return "rescue.step.emotion.subtitle".localized()
            case .breathing:
                return "rescue.step.breathing.subtitle".localized()
            case .reasons:
                return "rescue.step.reasons.subtitle".localized()
            case .delay:
                return "rescue.step.delay.subtitle".localized()
            case .urgeAfter:
                return "rescue.step.urgeAfter.subtitle".localized()
            case .completion:
                return "rescue.step.completion.subtitle".localized()
            }
        }

        var primaryButtonTitle: String {
            switch self {
            case .urgeBefore, .emotion, .reasons:
                return "common.continue".localized()
            case .breathing:
                return "rescue.button.finishEarly".localized()
            case .delay:
                return "rescue.button.wait10".localized()
            case .urgeAfter:
                return "rescue.button.okayNow".localized()
            case .completion:
                return "rescue.button.complete".localized()
            }
        }

        var index: Int {
            rawValue + 1
        }
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = SGRescueStepHeaderView()
    private let stepCardView = SGCardView()
    private let stepTitleLabel = UILabel()
    private let stepContentContainerView = UIView()
    private let draftSummaryLabel = UILabel()
    private let footerStackView = UIStackView()
    private let backButton = UIButton(type: .system)
    private let primaryButton = SGPrimaryButton(title: "common.continue".localized())
    private let urgeValueLabel = UILabel()

    private var currentStep: Step = .urgeBefore
    private var draft = SGRescueDraft()
    private var coachPromptText: String?
    private var didSkipEmotion = false

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        showsRightNavigationActions = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if currentStep == .urgeBefore {
            renderCurrentStep()
        }
    }

    override func setupSubviews() {
        setupScrollView()
        setupStepCard()
        setupFooter()
        startNewSession()
    }

    func startNewSession() {
        coachPromptText = nil
        didSkipEmotion = false
        draft = SGRescueDraft()
        currentStep = .urgeBefore
        renderCurrentStep()
    }

    func renderCurrentStep() {
        headerView.configure(
            title: currentStep.title,
            subtitle: currentStep.subtitle,
            stepIndex: currentStep.index,
            totalSteps: Step.allCases.count
        )

        stepTitleLabel.text = stepTitle(for: currentStep)
        renderStepContent()
        draftSummaryLabel.text = draftSummaryText()
        backButton.isEnabled = currentStep != .urgeBefore
        backButton.alpha = backButton.isEnabled ? 1 : 0.38
        primaryButton.setTitle(currentStep.primaryButtonTitle, for: .normal)
        primaryButton.isEnabled = canAdvance(from: currentStep)
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 92)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 18
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 24, right: 20)
        contentStackView.addArrangedSubview(headerView)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupStepCard() {
        stepCardView.setContentInsets(.zero)
        stepCardView.contentView.backgroundColor = UIColor.hexString("#FFF9E8")

        stepTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        stepTitleLabel.textColor = SGColor.textDark
        stepTitleLabel.numberOfLines = 0

        draftSummaryLabel.font = .systemFont(ofSize: 13, weight: .medium)
        draftSummaryLabel.textColor = SGColor.primaryDark
        draftSummaryLabel.numberOfLines = 0

        stepCardView.contentView.addSubview(stepTitleLabel)
        stepCardView.contentView.addSubview(stepContentContainerView)
        stepCardView.contentView.addSubview(draftSummaryLabel)

        stepTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        stepContentContainerView.snp.makeConstraints { make in
            make.top.equalTo(stepTitleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(18)
        }

        draftSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(stepContentContainerView.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(18)
        }

        contentStackView.addArrangedSubview(stepCardView)
    }

    private func setupFooter() {
        view.addSubview(footerStackView)

        footerStackView.axis = .horizontal
        footerStackView.alignment = .fill
        footerStackView.distribution = .fill
        footerStackView.spacing = 12

        backButton.setTitle("common.back".localized(), for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        backButton.setTitleColor(SGColor.primaryDark, for: .normal)
        backButton.setTitleColor(SGColor.textTertiary, for: .disabled)
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        backButton.layer.cornerRadius = 18
        backButton.layer.masksToBounds = true
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)

        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)

        footerStackView.addArrangedSubview(backButton)
        footerStackView.addArrangedSubview(primaryButton)

        backButton.snp.makeConstraints { make in
            make.width.equalTo(104)
        }

        footerStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 16)
            make.height.equalTo(54)
        }
    }

    private func stepTitle(for step: Step) -> String {
        switch step {
        case .urgeBefore:
            return "rescue.card.urgeBefore".localized()
        case .emotion:
            return "rescue.card.emotion".localized()
        case .breathing:
            return "rescue.card.breathing".localized()
        case .reasons:
            return "rescue.card.reasons".localized()
        case .delay:
            return "rescue.card.delay".localized()
        case .urgeAfter:
            return "rescue.card.urgeAfter".localized()
        case .completion:
            return "rescue.card.completion".localized()
        }
    }

    private func draftSummaryText() -> String {
        let emotionText = draft.emotion?.displayName ?? "common.notSelected".localized()
        let urgeBeforeText = draft.urgeBefore.map(String.init) ?? "common.notSet".localized()
        let urgeAfterText = draft.urgeAfter.map(String.init) ?? "common.notSet".localized()
        let breathingText = draft.completedBreathing ? "common.done".localized() : "common.pending".localized()
        let delayText = draft.completedDelay ? "common.done".localized() : "common.pending".localized()

        return [
            "rescue.summary.emotionFormat".localizedFormat(emotionText),
            "rescue.summary.urgeBeforeFormat".localizedFormat(urgeBeforeText),
            "rescue.summary.breathingFormat".localizedFormat(breathingText),
            "rescue.summary.delayFormat".localizedFormat(delayText),
            "rescue.summary.urgeAfterFormat".localizedFormat(urgeAfterText)
        ].joined(separator: "  ·  ")
    }

    private func renderStepContent() {
        stepContentContainerView.subviews.forEach { $0.removeFromSuperview() }

        switch currentStep {
        case .urgeBefore:
            let urgeBeforeView = makeUrgeRatingView(
                titleKey: "rescue.urgeBefore.title",
                value: draft.urgeBefore,
                onChange: { [weak self] value in
                    self?.draft.urgeBefore = value
                    self?.updateUrgeValueLabel()
                    self?.primaryButton.isEnabled = self?.canAdvance(from: .urgeBefore) == true
                }
            )
            stepContentContainerView.addSubview(urgeBeforeView)
            urgeBeforeView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .emotion:
            let pickerView = SGEmotionPickerView()
            pickerView.configure(selectedEmotion: draft.emotion, didSelectSkip: didSkipEmotion)
            pickerView.onSelectEmotion = { [weak self] emotion in
                self?.handleEmotionSelected(emotion)
            }
            stepContentContainerView.addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .breathing:
            let breathingView = makeBreathingStepView()
            stepContentContainerView.addSubview(breathingView)
            breathingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .reasons:
            let reasonsView = makeReasonsView()
            stepContentContainerView.addSubview(reasonsView)
            reasonsView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .delay:
            let delayView = makeDelayView()
            stepContentContainerView.addSubview(delayView)
            delayView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .urgeAfter:
            let urgeAfterView = makeUrgeRatingView(
                titleKey: "rescue.urgeAfter.title",
                value: draft.urgeAfter,
                onChange: { [weak self] value in
                    self?.draft.urgeAfter = value
                    self?.updateUrgeValueLabel()
                    self?.primaryButton.isEnabled = self?.canAdvance(from: .urgeAfter) == true
                },
                secondaryActionTitleKey: "rescue.feedback.startAnother",
                secondaryAction: { [weak self] in
                    self?.saveCompletedRescueSession()
                    self?.startNewSession()
                }
            )
            stepContentContainerView.addSubview(urgeAfterView)
            urgeAfterView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .completion:
            let completionView = makeCompletionView()
            stepContentContainerView.addSubview(completionView)
            completionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    private func makeBreathingStepView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16

        let coachView = SGCoachMessageView()
        if coachPromptText == nil {
            coachPromptText = SGCalmCoachService.shared.promptText(
                for: coachContext(for: draft.emotion)
            )
        }
        coachView.showPrompt(coachPromptText ?? "")

        let breathingView = SGBreathingExerciseView()
            breathingView.onComplete = { [weak self] in
                self?.completeBreathingNaturally()
            }
        breathingView.start()

        stackView.addArrangedSubview(coachView)
        stackView.addArrangedSubview(breathingView)
        return stackView
    }

    private func makeUrgeRatingView(
        titleKey: String,
        value: Int?,
        onChange: @escaping (Int) -> Void,
        secondaryActionTitleKey: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.text = titleKey.localized()

        urgeValueLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        urgeValueLabel.textColor = SGColor.primaryDark
        urgeValueLabel.textAlignment = .center

        let slider = UISlider()
        let initialValue = value ?? 0
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = Float(initialValue)
        slider.minimumTrackTintColor = SGColor.primary
        slider.maximumTrackTintColor = SGColor.primaryLight
        slider.addAction(
            UIAction { _ in
                onChange(Int(slider.value.rounded()))
            },
            for: .valueChanged
        )

        updateUrgeValueLabel(for: value ?? initialValue)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(urgeValueLabel)
        stackView.addArrangedSubview(slider)

        if let secondaryActionTitleKey, let secondaryAction {
            let secondaryButton = UIButton(type: .system)
            secondaryButton.setTitle(secondaryActionTitleKey.localized(), for: .normal)
            secondaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            secondaryButton.setTitleColor(SGColor.primaryDark, for: .normal)
            secondaryButton.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.68)
            secondaryButton.layer.cornerRadius = 14
            secondaryButton.layer.masksToBounds = true
            secondaryButton.addAction(UIAction { _ in secondaryAction() }, for: .touchUpInside)
            stackView.addArrangedSubview(secondaryButton)
            secondaryButton.snp.makeConstraints { make in
                make.height.equalTo(46)
            }
        }

        return stackView
    }

    private func makeReasonsView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10

        let reasons = SoberGardenStore.shared.state.habit?.reasons
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        if reasons.isEmpty {
            stackView.addArrangedSubview(makeReasonLabel("rescue.reasons.fallback".localized()))
        } else {
            reasons.forEach { reason in
                stackView.addArrangedSubview(makeReasonLabel(reason))
            }
        }

        return stackView
    }

    private func makeReasonLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = SGColor.textDark
        label.numberOfLines = 0
        label.text = "rescue.reasons.bulletFormat".localizedFormat(text)
        return label
    }

    private func makeDelayView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.text = "rescue.delay.title".localized()

        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.text = "rescue.delay.body".localized()

        let strugglingButton = UIButton(type: .system)
        strugglingButton.setTitle("rescue.delay.stillStruggling".localized(), for: .normal)
        strugglingButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        strugglingButton.setTitleColor(SGColor.rescue, for: .normal)
        strugglingButton.backgroundColor = SGColor.rescue.withAlphaComponent(0.12)
        strugglingButton.layer.cornerRadius = 14
        strugglingButton.layer.masksToBounds = true
        strugglingButton.addTarget(self, action: #selector(handleStillStrugglingTapped), for: .touchUpInside)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(strugglingButton)

        strugglingButton.snp.makeConstraints { make in
            make.height.equalTo(46)
        }

        return stackView
    }

    private func makeCompletionView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.text = completionTitleText()

        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.text = completionBodyText()

        let scoreLabel = UILabel()
        scoreLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .semibold)
        scoreLabel.textColor = SGColor.primaryDark
        scoreLabel.textAlignment = .center
        scoreLabel.text = completionScoreText()

        let startAnotherButton = UIButton(type: .system)
        startAnotherButton.setTitle("rescue.feedback.startAnother".localized(), for: .normal)
        startAnotherButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        startAnotherButton.setTitleColor(SGColor.primaryDark, for: .normal)
        startAnotherButton.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.68)
        startAnotherButton.layer.cornerRadius = 14
        startAnotherButton.layer.masksToBounds = true
        startAnotherButton.addTarget(self, action: #selector(handleStartAnotherRescueTapped), for: .touchUpInside)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bodyLabel)
        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(startAnotherButton)

        startAnotherButton.snp.makeConstraints { make in
            make.height.equalTo(46)
        }

        return stackView
    }

    private func handleEmotionSelected(_ emotion: EmotionType?) {
        draft.emotion = emotion
        didSkipEmotion = emotion == nil
        coachPromptText = nil
        currentStep = .breathing
        renderCurrentStep()
    }

    private func coachContext(for emotion: EmotionType?) -> SGCalmCoachContext {
        if SoberGardenStore.shared.state.habit?.isSobrietyFocused == true {
            return .cravingMoment
        }
        guard let emotion, let context = SGCalmCoachContext(rawValue: emotion.rawValue) else {
            return .urge
        }
        return context
    }

    @objc private func handleBackTapped() {
        guard currentStep.rawValue > 0, let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStep
        renderCurrentStep()
    }

    @objc private func handlePrimaryTapped() {
        if currentStep == .breathing {
            finishBreathingEarly()
            return
        }

        if currentStep == .delay {
            completeDelayCommitment()
            return
        }

        if currentStep == .completion {
            saveCompletedRescueSession()
            startNewSession()
            SGReviewPromptCoordinator.shared.promptIfNeeded(trigger: .rescueCompleted, from: self)
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
        renderCurrentStep()
    }

    private func completeBreathingNaturally() {
        draft.completedBreathing = true
        currentStep = .reasons
        renderCurrentStep()
    }

    private func finishBreathingEarly() {
        draft.completedBreathing = false
        currentStep = .reasons
        renderCurrentStep()
    }

    private func completeDelayCommitment() {
        draft.completedDelay = true
        SGNotificationService.shared.scheduleRescueDelayReminder()
        currentStep = .urgeAfter
        renderCurrentStep()
    }

    private func saveCompletedRescueSession() {
        SoberGardenStore.shared.saveRescueSession(
            emotion: draft.emotion ?? .urge,
            startedAt: draft.startedAt,
            urgeBefore: draft.urgeBefore,
            urgeAfter: draft.urgeAfter,
            completedBreathing: draft.completedBreathing,
            completedDelay: draft.completedDelay
        )
    }

    private func updateUrgeValueLabel(for value: Int? = nil) {
        let value = value ?? {
            switch currentStep {
            case .urgeBefore:
                return draft.urgeBefore ?? 0
            case .urgeAfter:
                return draft.urgeAfter ?? 0
            default:
                return draft.urgeAfter ?? draft.urgeBefore ?? 0
            }
        }()
        urgeValueLabel.text = "rescue.feedback.valueFormat".localizedFormat(value)
    }

    @objc private func handleStillStrugglingTapped() {
        draft.completedBreathing = false
        currentStep = .breathing
        renderCurrentStep()
    }

    @objc private func handleStartAnotherRescueTapped() {
        saveCompletedRescueSession()
        startNewSession()
    }

    private func canAdvance(from step: Step) -> Bool {
        switch step {
        case .urgeBefore:
            return draft.urgeBefore != nil
        case .urgeAfter:
            return draft.urgeAfter != nil
        default:
            return true
        }
    }

    private func completionTitleText() -> String {
        guard let reduction = completedRescueSession().urgeReduction, reduction > 0 else {
            return "rescue.completion.title.paused".localized()
        }
        return "rescue.completion.title.reducedFormat".localizedFormat(reduction)
    }

    private func completionBodyText() -> String {
        guard let reduction = completedRescueSession().urgeReduction, reduction > 0 else {
            return "rescue.completion.body.paused".localized()
        }
        return "rescue.completion.body.reduced".localized()
    }

    private func completionScoreText() -> String {
        let before = draft.urgeBefore ?? 0
        let after = draft.urgeAfter ?? 0
        return "rescue.completion.scoreFormat".localizedFormat(before, after)
    }

    private func completedRescueSession() -> RescueSession {
        RescueSession(
            id: UUID(),
            date: draft.startedAt,
            emotion: draft.emotion ?? .urge,
            urgeBefore: draft.urgeBefore,
            urgeAfter: draft.urgeAfter,
            completedBreathing: draft.completedBreathing,
            completedDelay: draft.completedDelay
        )
    }
}
