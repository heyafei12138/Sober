//
//  SGOnboardingViewController.swift
//  SoberGarden
//

import UIKit

final class SGOnboardingViewController: BaseViewController {

    private enum Layout {
        static let pageInset: CGFloat = 24
        static let compactRadius: CGFloat = 12
        static let contentSpacing: CGFloat = 14
    }

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
                return "Your habit, garden, and gentle reminders are ready whenever you need them."
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
    private var selectedStartDateOption: Int = 0
    private var selectedCostMode: SGOnboardingCostMode = .skip
    private var selectedTimeMode: SGOnboardingTimeMode = .skip

    private let progressBarView = SGProgressBarView()
    private let stepView = SGOnboardingStepView()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let backButton = UIButton(type: .system)
    private let primaryButton = SGPrimaryButton(title: "Get Started", style: .primary)
    private let customHabitTextField = UITextField()
    private let costTextField = UITextField()
    private let timeTextField = UITextField()
    private let customReasonTextField = UITextField()
    private let notificationActionsStack = UIStackView()
    private let enableNotificationsButton = SGPrimaryButton(title: "Enable Notifications", style: .primary)
    private let maybeLaterButton = SGPrimaryButton(title: "Maybe Later", style: .secondary)

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
        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(primaryButton)
        view.addSubview(notificationActionsStack)
        scrollView.addSubview(contentStackView)

        notificationActionsStack.axis = .vertical
        notificationActionsStack.spacing = 12
        notificationActionsStack.addArrangedSubview(enableNotificationsButton)
        notificationActionsStack.addArrangedSubview(maybeLaterButton)
        notificationActionsStack.isHidden = true

        progressBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(Layout.pageInset)
        }

        stepView.snp.makeConstraints { make in
            make.top.equalTo(progressBarView.snp.bottom).offset(46)
            make.left.right.equalToSuperview().inset(Layout.pageInset)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(stepView.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(backButton.snp.top).offset(-12)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 0, left: Layout.pageInset, bottom: 20, right: Layout.pageInset))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-Layout.pageInset * 2)
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Layout.pageInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }

        notificationActionsStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Layout.pageInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Layout.pageInset)
            make.bottom.equalTo(primaryButton.snp.top).offset(-16)
            make.height.equalTo(44)
        }

        backButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backButton.setTitleColor(SGColor.textSecondary, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        enableNotificationsButton.addTarget(self, action: #selector(handleEnableNotificationsTapped), for: .touchUpInside)
        maybeLaterButton.addTarget(self, action: #selector(handleMaybeLaterTapped), for: .touchUpInside)

        contentStackView.axis = .vertical
        contentStackView.spacing = Layout.contentSpacing
        contentStackView.alignment = .fill
    }

    private func renderCurrentStep() {
        stepView.configure(title: currentStep.title, subtitle: currentStep.subtitle)
        primaryButton.setTitle(currentStep.primaryButtonTitle, for: .normal)
        backButton.isHidden = currentStep == .welcome
        updateFooterButtons()

        let stepCount = CGFloat(Step.allCases.count)
        let currentIndex = CGFloat(currentStep.rawValue + 1)
        progressBarView.setProgress(currentIndex / stepCount, animated: true)
        renderStepContent()
        updatePrimaryButtonState()
    }

    private func renderStepContent() {
        contentStackView.removeAllArrangedSubviews()

        switch currentStep {
        case .welcome:
            addWelcomeContent()
        case .habit:
            addHabitPickerContent()
        case .startDate:
            addStartDateContent()
        case .cost:
            addCostContent()
        case .time:
            addTimeContent()
        case .reasons:
            addReasonsContent()
        case .notifications:
            addNotificationsContent()
        case .complete:
            addCompleteContent()
        }
    }

    private func updateFooterButtons() {
        let showsNotificationActions = currentStep == .notifications
        notificationActionsStack.isHidden = !showsNotificationActions
        primaryButton.isHidden = showsNotificationActions
        backButton.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(Layout.pageInset)
            if showsNotificationActions {
                make.bottom.equalTo(notificationActionsStack.snp.top).offset(-16)
            } else {
                make.bottom.equalTo(primaryButton.snp.top).offset(-16)
            }
            make.height.equalTo(44)
        }
    }

    private func addWelcomeContent() {
        let card = SGCardView()
        card.cornerRadius = 16
        card.setContentInsets(UIEdgeInsets(top: 20, left: 28, bottom: 20, right: 28))
        let label = UILabel()
        label.text = "A calm place to track your clean days, prepare for difficult moments, and see your garden grow."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = SGColor.textSecondary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)

        card.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(124)
        }
        contentStackView.addArrangedSubview(card)
    }

    private func addHabitPickerContent() {
        let gridStack = makeVerticalStack(spacing: 10)
        let rows = HabitType.allCases.chunked(into: 2)

        rows.forEach { rowTypes in
            let rowStack = makeHorizontalStack()
            rowTypes.forEach { type in
                let chip = SGOptionChip(title: type.displayName)
                chip.tag = HabitType.allCases.firstIndex(of: type) ?? 0
                chip.isSelected = draft.habitType == type
                chip.addTarget(self, action: #selector(handleHabitChipTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(chip)
            }
            if rowTypes.count == 1 {
                rowStack.addArrangedSubview(UIView())
            }
            gridStack.addArrangedSubview(rowStack)
        }

        contentStackView.addArrangedSubview(gridStack)

        customHabitTextField.placeholder = "Enter your habit"
        customHabitTextField.text = draft.customHabitName
        customHabitTextField.borderStyle = .none
        customHabitTextField.backgroundColor = SGColor.surface
        customHabitTextField.textColor = SGColor.textDark
        customHabitTextField.font = .systemFont(ofSize: 16)
        customHabitTextField.layer.cornerRadius = Layout.compactRadius
        customHabitTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        customHabitTextField.leftViewMode = .always
        customHabitTextField.isHidden = draft.habitType != .custom
        customHabitTextField.removeTarget(nil, action: nil, for: .editingChanged)
        customHabitTextField.addTarget(self, action: #selector(handleCustomHabitChanged(_:)), for: .editingChanged)
        customHabitTextField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentStackView.addArrangedSubview(customHabitTextField)
    }

    private func addStartDateContent() {
        let optionStack = makeVerticalStack(spacing: 10)
        let todayChip = makeStartDateChip(title: "Today", tag: 0)
        let yesterdayChip = makeStartDateChip(title: "Yesterday", tag: 1)
        let pickDateChip = makeStartDateChip(title: "Pick a date", tag: 2)
        optionStack.addArrangedSubview(todayChip)
        optionStack.addArrangedSubview(yesterdayChip)
        optionStack.addArrangedSubview(pickDateChip)
        contentStackView.addArrangedSubview(optionStack)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.maximumDate = Date()
        datePicker.date = min(draft.startDate, Date())
        datePicker.addTarget(self, action: #selector(handleStartDatePicked(_:)), for: .valueChanged)
        datePicker.isHidden = !isCustomStartDateSelected()
        contentStackView.addArrangedSubview(datePicker)
    }

    private func addCostContent() {
        let modeStack = makeVerticalStack(spacing: 10)
        SGOnboardingCostMode.allCases.forEach { mode in
            let chip = SGOptionChip(title: mode.title)
            chip.tag = mode.rawValue
            chip.isSelected = selectedCostMode == mode
            chip.addTarget(self, action: #selector(handleCostModeTapped(_:)), for: .touchUpInside)
            modeStack.addArrangedSubview(chip)
        }
        contentStackView.addArrangedSubview(modeStack)

        costTextField.placeholder = "Amount"
        costTextField.keyboardType = .decimalPad
        costTextField.borderStyle = .none
        costTextField.backgroundColor = SGColor.surface
        costTextField.textColor = SGColor.textDark
        costTextField.font = .systemFont(ofSize: 16)
        costTextField.layer.cornerRadius = Layout.compactRadius
        costTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        costTextField.leftViewMode = .always
        costTextField.isHidden = selectedCostMode == .skip
        costTextField.removeTarget(nil, action: nil, for: .editingChanged)
        costTextField.addTarget(self, action: #selector(handleCostAmountChanged(_:)), for: .editingChanged)
        costTextField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentStackView.addArrangedSubview(costTextField)
    }

    private func addTimeContent() {
        let modeStack = makeVerticalStack(spacing: 10)
        SGOnboardingTimeMode.allCases.forEach { mode in
            let chip = SGOptionChip(title: mode.title)
            chip.tag = mode.rawValue
            chip.isSelected = selectedTimeMode == mode
            chip.addTarget(self, action: #selector(handleTimeModeTapped(_:)), for: .touchUpInside)
            modeStack.addArrangedSubview(chip)
        }
        contentStackView.addArrangedSubview(modeStack)

        timeTextField.placeholder = selectedTimeMode.placeholder
        timeTextField.keyboardType = .decimalPad
        timeTextField.borderStyle = .none
        timeTextField.backgroundColor = SGColor.surface
        timeTextField.textColor = SGColor.textDark
        timeTextField.font = .systemFont(ofSize: 16)
        timeTextField.layer.cornerRadius = Layout.compactRadius
        timeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        timeTextField.leftViewMode = .always
        timeTextField.isHidden = selectedTimeMode == .skip
        timeTextField.removeTarget(nil, action: nil, for: .editingChanged)
        timeTextField.addTarget(self, action: #selector(handleTimeAmountChanged(_:)), for: .editingChanged)
        timeTextField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentStackView.addArrangedSubview(timeTextField)
    }

    private func addReasonsContent() {
        let hintLabel = UILabel()
        hintLabel.text = "Select any that resonate. You can skip and add reasons later."
        hintLabel.font = .systemFont(ofSize: 14, weight: .regular)
        hintLabel.textColor = SGColor.textSecondary
        hintLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(hintLabel)

        let reasonStack = makeVerticalStack(spacing: 10)
        SGOnboardingDraft.reasonTemplates.enumerated().forEach { index, template in
            let chip = SGOptionChip(title: template)
            chip.tag = index
            chip.isSelected = draft.selectedReasonTemplates.contains(template)
            chip.addTarget(self, action: #selector(handleReasonChipTapped(_:)), for: .touchUpInside)
            reasonStack.addArrangedSubview(chip)
        }
        contentStackView.addArrangedSubview(reasonStack)

        customReasonTextField.placeholder = "Add your own reason"
        customReasonTextField.text = draft.customReasonText
        customReasonTextField.borderStyle = .none
        customReasonTextField.backgroundColor = SGColor.surface
        customReasonTextField.textColor = SGColor.textDark
        customReasonTextField.font = .systemFont(ofSize: 16)
        customReasonTextField.layer.cornerRadius = Layout.compactRadius
        customReasonTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        customReasonTextField.leftViewMode = .always
        customReasonTextField.removeTarget(nil, action: nil, for: .editingChanged)
        customReasonTextField.addTarget(self, action: #selector(handleCustomReasonChanged(_:)), for: .editingChanged)
        customReasonTextField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        contentStackView.addArrangedSubview(customReasonTextField)
    }

    private func addNotificationsContent() {
        let card = SGCardView()
        card.cornerRadius = 16
        card.setContentInsets(UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20))
        let label = UILabel()
        label.text = "We'll send gentle reminders, milestone celebrations, and urge support prompts. You can change this anytime in Settings."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = SGColor.textSecondary
        label.numberOfLines = 0
        card.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStackView.addArrangedSubview(card)
    }

    private func addCompleteContent() {
        let card = SGCardView()
        card.cornerRadius = 16
        card.setContentInsets(UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24))
        let label = UILabel()
        label.text = "Tap Start Growing to open your Home tab, track clean days, and reach for Rescue whenever you need support."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = SGColor.textSecondary
        label.numberOfLines = 0
        card.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStackView.addArrangedSubview(card)
    }

    private func updatePrimaryButtonState() {
        switch currentStep {
        case .habit:
            if draft.habitType == .custom {
                primaryButton.isEnabled = !(draft.customHabitName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            } else {
                primaryButton.isEnabled = draft.habitType != nil
            }
        default:
            primaryButton.isEnabled = true
        }
    }

    @objc private func handleBackTapped() {
        guard let previousStep = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStep
    }

    @objc private func handlePrimaryTapped() {
        view.endEditing(true)
        syncDraftFromInputs()

        if currentStep == .complete {
            finishOnboardingIfPossible()
            return
        }

        guard let nextStep = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }

    @objc private func handleEnableNotificationsTapped() {
        SGNotificationService.shared.requestAuthorization { [weak self] granted in
            guard let self else { return }
            SoberGardenStore.shared.updateSettings { settings in
                settings.dailyReminderEnabled = granted
                settings.milestoneNotificationsEnabled = granted || settings.milestoneNotificationsEnabled
            }
            self.advanceFromNotificationsStep()
        }
    }

    @objc private func handleMaybeLaterTapped() {
        advanceFromNotificationsStep()
    }

    private func advanceFromNotificationsStep() {
        guard currentStep == .notifications else { return }
        currentStep = .complete
    }

    @objc private func handleHabitChipTapped(_ sender: SGOptionChip) {
        let selectedType = HabitType.allCases[sender.tag]
        draft.habitType = selectedType
        if selectedType != .custom {
            draft.customHabitName = nil
        }
        renderCurrentStep()
    }

    @objc private func handleCustomHabitChanged(_ sender: UITextField) {
        draft.customHabitName = sender.text
        updatePrimaryButtonState()
    }

    @objc private func handleStartDateChipTapped(_ sender: SGOptionChip) {
        selectedStartDateOption = sender.tag
        let calendar = Calendar.current
        switch sender.tag {
        case 0:
            draft.startDate = Date()
        case 1:
            draft.startDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        default:
            draft.startDate = min(draft.startDate, Date())
        }
        renderCurrentStep()
    }

    @objc private func handleStartDatePicked(_ sender: UIDatePicker) {
        selectedStartDateOption = 2
        draft.startDate = min(sender.date, Date())
        renderCurrentStep()
    }

    @objc private func handleCostModeTapped(_ sender: SGOptionChip) {
        selectedCostMode = SGOnboardingCostMode(rawValue: sender.tag) ?? .skip
        updateDraftCost()
        renderCurrentStep()
    }

    @objc private func handleCostAmountChanged(_ sender: UITextField) {
        updateDraftCost()
    }

    private func updateDraftCost() {
        let amountText = costTextField.text ?? ""
        let amount = Double(amountText.replacingOccurrences(of: ",", with: "."))
        draft.setCost(amount: amount, mode: selectedCostMode)
    }

    @objc private func handleTimeModeTapped(_ sender: SGOptionChip) {
        selectedTimeMode = SGOnboardingTimeMode(rawValue: sender.tag) ?? .skip
        updateDraftTime()
        renderCurrentStep()
    }

    @objc private func handleTimeAmountChanged(_ sender: UITextField) {
        updateDraftTime()
    }

    private func updateDraftTime() {
        let amountText = timeTextField.text ?? ""
        let amount = Double(amountText.replacingOccurrences(of: ",", with: "."))
        draft.setTime(amount: amount, mode: selectedTimeMode)
    }

    @objc private func handleReasonChipTapped(_ sender: SGOptionChip) {
        let template = SGOnboardingDraft.reasonTemplates[sender.tag]
        if draft.selectedReasonTemplates.contains(template) {
            draft.selectedReasonTemplates.remove(template)
            sender.isSelected = false
        } else {
            draft.selectedReasonTemplates.insert(template)
            sender.isSelected = true
        }
    }

    @objc private func handleCustomReasonChanged(_ sender: UITextField) {
        draft.customReasonText = sender.text
    }

    private func syncDraftFromInputs() {
        if currentStep == .cost || selectedCostMode != .skip {
            updateDraftCost()
        }
        if currentStep == .time || selectedTimeMode != .skip {
            updateDraftTime()
        }
        if currentStep == .reasons {
            draft.customReasonText = customReasonTextField.text
        }
    }

    private func makeStartDateChip(title: String, tag: Int) -> SGOptionChip {
        let chip = SGOptionChip(title: title)
        chip.tag = tag
        chip.isSelected = isStartDateChipSelected(tag: tag)
        chip.addTarget(self, action: #selector(handleStartDateChipTapped(_:)), for: .touchUpInside)
        return chip
    }

    private func isStartDateChipSelected(tag: Int) -> Bool {
        selectedStartDateOption == tag
    }

    private func isCustomStartDateSelected() -> Bool {
        selectedStartDateOption == 2
    }

    private func makeVerticalStack(spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        return stack
    }

    private func makeHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }

    private func finishOnboardingIfPossible() {
        syncDraftFromInputs()
        guard let habit = draft.makeHabit() else { return }
        SoberGardenStore.shared.setHabit(habit)

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showMainInterface(animated: true)
        } else {
            showMainAppFallback()
        }
    }

    private func showMainAppFallback() {
        guard let windowScene = view.window?.windowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        if let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window = window
        }
    }
}

private extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
