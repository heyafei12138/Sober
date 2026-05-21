//
//  SGRescueViewController.swift
//  SoberGarden
//

import UIKit

/// 急救流程：冲动状态选择、呼吸练习、延迟承诺
final class SGRescueViewController: BaseViewController {

    private enum Step: Int, CaseIterable {
        case emotion
        case coach
        case breathing
        case reasons
        case delay
        case feedback

        var title: String {
            switch self {
            case .emotion:
                return "What are you feeling right now?"
            case .coach:
                return "Calm Coach is here."
            case .breathing:
                return "Take one steady breath."
            case .reasons:
                return "Return to your reasons."
            case .delay:
                return "Create a little distance."
            case .feedback:
                return "Check in before you go."
            }
        }

        var subtitle: String {
            switch self {
            case .emotion:
                return "Name the feeling first. You do not need to solve everything at once."
            case .coach:
                return "A short prompt will help you steady the next choice."
            case .breathing:
                return "Slow down your body before making any decision."
            case .reasons:
                return "Your reasons are here when the urge gets loud."
            case .delay:
                return "Set a small delay and let the peak pass."
            case .feedback:
                return "Notice whether the urge changed during the session."
            }
        }

        var placeholderText: String {
            switch self {
            case .emotion:
                return "Emotion picker will appear here in the next task."
            case .coach:
                return "Local Calm Coach prompt will appear here."
            case .breathing:
                return "Breathing exercise module will appear here."
            case .reasons:
                return "Personal reasons will appear here."
            case .delay:
                return "Delay commitment controls will appear here."
            case .feedback:
                return "Before and after urge check-in will appear here."
            }
        }

        var primaryButtonTitle: String {
            switch self {
            case .coach:
                return "Start Breathing"
            case .breathing:
                return "Finish Early"
            case .delay:
                return "I'll wait 10 minutes"
            case .feedback:
                return "I'm okay now"
            default:
                return "Continue"
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
    private let primaryButton = SGPrimaryButton(title: "Continue")
    private let feedbackValueLabel = UILabel()

    private var currentStep: Step = .emotion
    private var draft = SGRescueDraft()
    private var coachLoadWorkItem: DispatchWorkItem?
    private var coachPromptText: String?
    private var isCoachLoading = false
    private var didSkipEmotion = false

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if currentStep == .emotion {
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
        cancelCoachLoading()
        coachPromptText = nil
        didSkipEmotion = false
        draft = SGRescueDraft()
        currentStep = .emotion
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
        backButton.isEnabled = currentStep != .emotion
        backButton.alpha = backButton.isEnabled ? 1 : 0.38
        primaryButton.setTitle(currentStep.primaryButtonTitle, for: .normal)
        primaryButton.isEnabled = currentStep != .coach || !isCoachLoading
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

        backButton.setTitle("Back", for: .normal)
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
        case .emotion:
            return "Start by naming the moment."
        case .coach:
            return "Read one steadying thought."
        case .breathing:
            return "Let your body slow down."
        case .reasons:
            return "Remember what you are protecting."
        case .delay:
            return "Delay the decision."
        case .feedback:
            return "Close the loop."
        }
    }

    private func draftSummaryText() -> String {
        let emotionText = draft.emotion?.displayName ?? "Not selected"
        let urgeBeforeText = draft.urgeBefore.map(String.init) ?? "Not set"
        let urgeAfterText = draft.urgeAfter.map(String.init) ?? "Not set"
        let breathingText = draft.completedBreathing ? "Done" : "Pending"
        let delayText = draft.completedDelay ? "Done" : "Pending"

        return [
            "Emotion: \(emotionText)",
            "Urge before: \(urgeBeforeText)",
            "Breathing: \(breathingText)",
            "Delay: \(delayText)",
            "Urge after: \(urgeAfterText)"
        ].joined(separator: "  ·  ")
    }

    private func renderStepContent() {
        stepContentContainerView.subviews.forEach { $0.removeFromSuperview() }

        switch currentStep {
        case .emotion:
            cancelCoachLoading()
            let pickerView = SGEmotionPickerView()
            pickerView.configure(selectedEmotion: draft.emotion, didSelectSkip: didSkipEmotion)
            pickerView.onSelectEmotion = { [weak self] emotion in
                self?.handleEmotionSelected(emotion)
            }
            stepContentContainerView.addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .coach:
            let coachView = SGCoachMessageView()
            stepContentContainerView.addSubview(coachView)
            coachView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            if let coachPromptText {
                isCoachLoading = false
                coachView.showPrompt(coachPromptText)
            } else {
                coachView.showLoading()
                scheduleCoachPromptLoad()
            }

        case .breathing:
            cancelCoachLoading()
            let breathingView = SGBreathingExerciseView()
            breathingView.onComplete = { [weak self] in
                self?.completeBreathingNaturally()
            }
            stepContentContainerView.addSubview(breathingView)
            breathingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            breathingView.start()

        case .reasons:
            cancelCoachLoading()
            let reasonsView = makeReasonsView()
            stepContentContainerView.addSubview(reasonsView)
            reasonsView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .delay:
            cancelCoachLoading()
            let delayView = makeDelayView()
            stepContentContainerView.addSubview(delayView)
            delayView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

        case .feedback:
            cancelCoachLoading()
            let feedbackView = makeFeedbackView()
            stepContentContainerView.addSubview(feedbackView)
            feedbackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
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
            stackView.addArrangedSubview(makeReasonLabel("You chose this because your future matters more than this urge."))
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
        label.text = "- \(text)"
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
        titleLabel.text = "Can you wait 10 minutes?"

        let bodyLabel = UILabel()
        bodyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.text = "You are not promising forever. Just give this wave a little time to pass."

        let strugglingButton = UIButton(type: .system)
        strugglingButton.setTitle("I'm still struggling", for: .normal)
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

    private func makeFeedbackView() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.text = "How strong is the urge now?"

        feedbackValueLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        feedbackValueLabel.textColor = SGColor.primaryDark
        feedbackValueLabel.textAlignment = .center

        let slider = UISlider()
        if draft.urgeAfter == nil {
            draft.urgeAfter = 0
        }
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = Float(draft.urgeAfter ?? 0)
        slider.minimumTrackTintColor = SGColor.primary
        slider.maximumTrackTintColor = SGColor.primaryLight
        slider.addTarget(self, action: #selector(handleUrgeAfterChanged(_:)), for: .valueChanged)

        let startAnotherButton = UIButton(type: .system)
        startAnotherButton.setTitle("Start another rescue", for: .normal)
        startAnotherButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        startAnotherButton.setTitleColor(SGColor.primaryDark, for: .normal)
        startAnotherButton.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.68)
        startAnotherButton.layer.cornerRadius = 14
        startAnotherButton.layer.masksToBounds = true
        startAnotherButton.addTarget(self, action: #selector(handleStartAnotherRescueTapped), for: .touchUpInside)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(feedbackValueLabel)
        stackView.addArrangedSubview(slider)
        stackView.addArrangedSubview(startAnotherButton)

        startAnotherButton.snp.makeConstraints { make in
            make.height.equalTo(46)
        }

        updateFeedbackValueLabel()
        return stackView
    }

    private func handleEmotionSelected(_ emotion: EmotionType?) {
        draft.emotion = emotion
        didSkipEmotion = emotion == nil
        coachPromptText = nil
        currentStep = .coach
        renderCurrentStep()
    }

    private func scheduleCoachPromptLoad() {
        guard coachLoadWorkItem == nil else { return }
        isCoachLoading = true
        primaryButton.isEnabled = false
        coachLoadWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.coachPromptText = SGCalmCoachService.shared.promptText(
                for: self.coachContext(for: self.draft.emotion)
            )
            self.isCoachLoading = false
            self.coachLoadWorkItem = nil
            self.renderCurrentStep()
        }

        coachLoadWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: workItem)
    }

    private func cancelCoachLoading() {
        coachLoadWorkItem?.cancel()
        coachLoadWorkItem = nil
        isCoachLoading = false
    }

    private func coachContext(for emotion: EmotionType?) -> SGCalmCoachContext {
        guard let emotion, let context = SGCalmCoachContext(rawValue: emotion.rawValue) else {
            return .urge
        }
        return context
    }

    @objc private func handleBackTapped() {
        guard currentStep.rawValue > 0, let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        if currentStep == .coach {
            cancelCoachLoading()
            coachPromptText = nil
        }
        currentStep = previousStep
        renderCurrentStep()
    }

    @objc private func handlePrimaryTapped() {
        if currentStep == .coach, isCoachLoading {
            return
        }

        if currentStep == .breathing {
            finishBreathingEarly()
            return
        }

        if currentStep == .delay {
            completeDelayCommitment()
            return
        }

        if currentStep == .feedback {
            saveCompletedRescueSession()
            startNewSession()
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        if nextStep == .coach {
            coachPromptText = nil
        }
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
        currentStep = .feedback
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

    private func updateFeedbackValueLabel() {
        let value = draft.urgeAfter ?? 0
        feedbackValueLabel.text = "\(value) / 10"
    }

    @objc private func handleStillStrugglingTapped() {
        draft.completedBreathing = false
        currentStep = .breathing
        renderCurrentStep()
    }

    @objc private func handleUrgeAfterChanged(_ sender: UISlider) {
        draft.urgeAfter = Int(sender.value.rounded())
        updateFeedbackValueLabel()
    }

    @objc private func handleStartAnotherRescueTapped() {
        saveCompletedRescueSession()
        startNewSession()
    }
}
