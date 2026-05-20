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
    private let stepBodyLabel = UILabel()
    private let draftSummaryLabel = UILabel()
    private let footerStackView = UIStackView()
    private let backButton = UIButton(type: .system)
    private let primaryButton = SGPrimaryButton(title: "Continue")

    private var currentStep: Step = .emotion
    private var draft = SGRescueDraft()

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
        stepBodyLabel.text = currentStep.placeholderText
        draftSummaryLabel.text = draftSummaryText()
        backButton.isEnabled = currentStep != .emotion
        backButton.alpha = backButton.isEnabled ? 1 : 0.38
        primaryButton.setTitle(currentStep.primaryButtonTitle, for: .normal)
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

        stepBodyLabel.font = .systemFont(ofSize: 15, weight: .medium)
        stepBodyLabel.textColor = SGColor.textSecondary
        stepBodyLabel.numberOfLines = 0

        draftSummaryLabel.font = .systemFont(ofSize: 13, weight: .medium)
        draftSummaryLabel.textColor = SGColor.primaryDark
        draftSummaryLabel.numberOfLines = 0

        stepCardView.contentView.addSubview(stepTitleLabel)
        stepCardView.contentView.addSubview(stepBodyLabel)
        stepCardView.contentView.addSubview(draftSummaryLabel)

        stepTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        stepBodyLabel.snp.makeConstraints { make in
            make.top.equalTo(stepTitleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(18)
        }

        draftSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(stepBodyLabel.snp.bottom).offset(16)
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

    @objc private func handleBackTapped() {
        guard currentStep.rawValue > 0, let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStep
        renderCurrentStep()
    }

    @objc private func handlePrimaryTapped() {
        if currentStep == .feedback {
            startNewSession()
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
        renderCurrentStep()
    }
}
