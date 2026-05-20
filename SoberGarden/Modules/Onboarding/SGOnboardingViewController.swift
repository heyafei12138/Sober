//
//  SGOnboardingViewController.swift
//  SoberGarden
//

import UIKit

final class SGOnboardingViewController: BaseViewController {

    enum Step: Int, CaseIterable {
        case welcome
        case habit
        case startDate
        case cost
        case time
        case reasons
        case notifications
        case complete

        var title: String {
            switch self {
            case .welcome:
                return "Break the habit. Grow a calmer life."
            case .habit:
                return "What do you want to quit?"
            case .startDate:
                return "When did your clean streak begin?"
            case .cost:
                return "How much did this habit cost you?"
            case .time:
                return "How much time did this habit take?"
            case .reasons:
                return "Why do you want to quit?"
            case .notifications:
                return "Let us support you at the right moments."
            case .complete:
                return "Your recovery garden is ready."
            }
        }

        var subtitle: String? {
            switch self {
            case .welcome:
                return "Track clean days, survive urges, and grow your recovery garden."
            case .habit:
                return "First version supports one habit so the experience stays focused."
            case .startDate:
                return "Choose today, yesterday, or a date you already started."
            case .cost:
                return "Optional. You can skip this and add it later from Settings."
            case .time:
                return "Optional. We will use it to show time saved."
            case .reasons:
                return "Keep a few reasons nearby for difficult moments."
            case .notifications:
                return "We'll send gentle reminders, milestone celebrations, and urge support prompts."
            case .complete:
                return "Start Growing"
            }
        }

        var primaryButtonTitle: String {
            switch self {
            case .welcome:
                return "Get Started"
            case .complete:
                return "Start Growing"
            default:
                return "Next"
            }
        }
    }

    private var currentStep: Step = .welcome {
        didSet { renderCurrentStep() }
    }
    private var draft = SGOnboardingDraft()

    private let progressBarView = SGProgressBarView()
    private let stepView = SGOnboardingStepView()
    private let backButton = UIButton(type: .system)
    private let primaryButton = SGPrimaryButton(title: "Get Started", style: .primary)

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func setupSubviews() {
        setupLayout()
        renderCurrentStep()
    }

    private func setupLayout() {
        view.addSubview(progressBarView)
        view.addSubview(stepView)
        view.addSubview(backButton)
        view.addSubview(primaryButton)

        progressBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.left.right.equalToSuperview().inset(24)
        }

        stepView.snp.makeConstraints { make in
            make.top.equalTo(progressBarView.snp.bottom).offset(72)
            make.left.right.equalToSuperview().inset(28)
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(primaryButton.snp.top).offset(-16)
            make.height.equalTo(44)
        }

        backButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backButton.setTitleColor(SGColor.textSecondary, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
    }

    private func renderCurrentStep() {
        stepView.configure(title: currentStep.title, subtitle: currentStep.subtitle)
        primaryButton.setTitle(currentStep.primaryButtonTitle, for: .normal)
        backButton.isHidden = currentStep == .welcome

        let stepCount = CGFloat(Step.allCases.count)
        let currentIndex = CGFloat(currentStep.rawValue + 1)
        progressBarView.setProgress(currentIndex / stepCount, animated: true)
    }

    @objc private func handleBackTapped() {
        guard let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStep
    }

    @objc private func handlePrimaryTapped() {
        if currentStep == .complete {
            finishOnboardingIfPossible()
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }

    private func finishOnboardingIfPossible() {
        if let habit = draft.makeHabit() {
            SoberGardenStore.shared.setHabit(habit)
        }
        showMainApp()
    }

    private func showMainApp() {
        guard let windowScene = view.window?.windowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()

        if let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window = window
        }
    }
}
