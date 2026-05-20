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
            case .feedback:
                return "Finish"
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
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

        default:
            cancelCoachLoading()
            let label = UILabel()
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = SGColor.textSecondary
            label.numberOfLines = 0
            label.text = currentStep.placeholderText
            stepContentContainerView.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
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
        if currentStep == .feedback {
            startNewSession()
            return
        }

        if currentStep == .coach, isCoachLoading {
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        if nextStep == .coach {
            coachPromptText = nil
        }
        currentStep = nextStep
        renderCurrentStep()
    }
}
