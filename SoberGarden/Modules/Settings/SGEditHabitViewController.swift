//
//  SGEditHabitViewController.swift
//  SoberGarden
//

import UIKit

final class SGEditHabitViewController: BaseViewController {

    var onSave: (() -> Void)?

    private let originalHabit: Habit
    private var selectedHabitType: HabitType
    private var selectedReasonTemplates: Set<String>
    private var customReasonsText: String

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let saveButton = SGPrimaryButton(title: "Save Changes")

    private let customHabitTextField = UITextField()
    private let startDatePicker = UIDatePicker()
    private let dailyCostTextField = UITextField()
    private let dailyMinutesTextField = UITextField()
    private let customReasonsTextView = UITextView()
    private var habitTypeChips: [SGOptionChip] = []

    init(habit: Habit) {
        self.originalHabit = habit
        self.selectedHabitType = habit.type
        let templates = Set(SGOnboardingDraft.reasonTemplates)
        self.selectedReasonTemplates = Set(habit.reasons.filter { templates.contains($0) })
        self.customReasonsText = habit.reasons
            .filter { !templates.contains($0) }
            .joined(separator: "\n")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Habit"
    }

    override func setupSubviews() {
        setupLayout()
        buildForm()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentInsetAdjustmentBehavior = .never

        contentStackView.axis = .vertical
        contentStackView.spacing = 18
        contentStackView.alignment = .fill
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 24, right: 20)

        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)

        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-14)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-12)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buildForm() {
        contentStackView.addArrangedSubview(SGSectionHeaderView(
            title: "Habit Details",
            subtitle: "Update the baseline used for streak, savings, time, and rescue reminders."
        ))

        contentStackView.addArrangedSubview(makeHabitTypeSection())
        contentStackView.addArrangedSubview(makeStartDateSection())
        contentStackView.addArrangedSubview(makeDailyNumbersSection())
        contentStackView.addArrangedSubview(makeReasonsSection())
    }

    private func makeHabitTypeSection() -> UIView {
        let (sectionStack, stack) = makeSectionStack(title: "Habit", subtitle: "Choose the closest match, or keep a custom name.")
        let gridStack = makeVerticalStack(spacing: 10)
        let allTypes = HabitType.allCases
        stride(from: 0, to: allTypes.count, by: 2).forEach { startIndex in
            let endIndex = min(startIndex + 2, allTypes.count)
            let rowTypes = Array(allTypes[startIndex..<endIndex])
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually

            rowTypes.forEach { type in
                let chip = SGOptionChip(title: type.displayName)
                chip.tag = HabitType.allCases.firstIndex(of: type) ?? 0
                chip.isSelected = selectedHabitType == type
                chip.addTarget(self, action: #selector(handleHabitTypeTapped(_:)), for: .touchUpInside)
                habitTypeChips.append(chip)
                rowStack.addArrangedSubview(chip)
            }
            if rowTypes.count == 1 {
                rowStack.addArrangedSubview(UIView())
            }
            gridStack.addArrangedSubview(rowStack)
        }
        stack.addArrangedSubview(gridStack)

        configureTextField(
            customHabitTextField,
            placeholder: "Custom habit name",
            text: originalHabit.customName,
            keyboardType: .default
        )
        customHabitTextField.isHidden = selectedHabitType != .custom
        stack.addArrangedSubview(customHabitTextField)

        return sectionStack
    }

    private func makeStartDateSection() -> UIView {
        let (sectionStack, stack) = makeSectionStack(title: "Start Date", subtitle: "Future dates are not allowed.")

        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .inline
        startDatePicker.maximumDate = Date()
        startDatePicker.date = min(originalHabit.startDate, Date())
        startDatePicker.addTarget(self, action: #selector(handleStartDateChanged(_:)), for: .valueChanged)
        stack.addArrangedSubview(startDatePicker)

        return sectionStack
    }

    private func makeDailyNumbersSection() -> UIView {
        let (sectionStack, stack) = makeSectionStack(title: "Savings Baseline", subtitle: "Leave a field blank if you do not want to track it.")

        configureTextField(
            dailyCostTextField,
            placeholder: "Daily cost",
            text: originalHabit.dailyCost.map { Self.numberFormatter.string(from: NSNumber(value: $0)) ?? "\($0)" },
            keyboardType: .decimalPad
        )
        stack.addArrangedSubview(dailyCostTextField)

        configureTextField(
            dailyMinutesTextField,
            placeholder: "Daily minutes",
            text: originalHabit.dailyMinutes.map { "\($0)" },
            keyboardType: .numberPad
        )
        stack.addArrangedSubview(dailyMinutesTextField)

        return sectionStack
    }

    private func makeReasonsSection() -> UIView {
        let (sectionStack, stack) = makeSectionStack(title: "Reasons", subtitle: "Keep a few reasons nearby for difficult moments.")

        let reasonStack = makeVerticalStack(spacing: 10)
        SGOnboardingDraft.reasonTemplates.enumerated().forEach { index, template in
            let chip = SGOptionChip(title: template)
            chip.tag = index
            chip.isSelected = selectedReasonTemplates.contains(template)
            chip.addTarget(self, action: #selector(handleReasonTapped(_:)), for: .touchUpInside)
            reasonStack.addArrangedSubview(chip)
        }
        stack.addArrangedSubview(reasonStack)

        customReasonsTextView.text = customReasonsText
        customReasonsTextView.backgroundColor = SGColor.surface
        customReasonsTextView.textColor = SGColor.textDark
        customReasonsTextView.font = .systemFont(ofSize: 16)
        customReasonsTextView.layer.cornerRadius = 12
        customReasonsTextView.layer.borderWidth = 1
        customReasonsTextView.layer.borderColor = SGColor.separator.cgColor
        customReasonsTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        customReasonsTextView.accessibilityLabel = "Custom reasons"
        customReasonsTextView.snp.makeConstraints { make in
            make.height.equalTo(112)
        }
        stack.addArrangedSubview(customReasonsTextView)

        return sectionStack
    }

    private func makeSectionStack(title: String, subtitle: String) -> (section: UIStackView, fields: UIStackView) {
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 12
        sectionStackView.alignment = .fill

        sectionStackView.addArrangedSubview(SGSectionHeaderView(title: title, subtitle: subtitle))

        let cardView = SGCardView()
        cardView.setContentInsets(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let fieldStackView = makeVerticalStack(spacing: 12)
        cardView.contentView.addSubview(fieldStackView)
        fieldStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sectionStackView.addArrangedSubview(cardView)
        return (sectionStackView, fieldStackView)
    }

    private func makeVerticalStack(spacing: CGFloat) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .fill
        return stack
    }

    private func configureTextField(
        _ textField: UITextField,
        placeholder: String,
        text: String?,
        keyboardType: UIKeyboardType
    ) {
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        textField.borderStyle = .none
        textField.backgroundColor = SGColor.surface
        textField.textColor = SGColor.textDark
        textField.font = .systemFont(ofSize: 16)
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = SGColor.separator.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField.leftViewMode = .always
        textField.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }

    @objc private func handleHabitTypeTapped(_ sender: SGOptionChip) {
        selectedHabitType = HabitType.allCases[sender.tag]
        customHabitTextField.isHidden = selectedHabitType != .custom
        habitTypeChips.forEach { chip in
            chip.isSelected = HabitType.allCases[chip.tag] == selectedHabitType
        }
    }

    @objc private func handleStartDateChanged(_ sender: UIDatePicker) {
        if sender.date > Date() {
            sender.date = Date()
            showAlert(title: "Invalid date", message: "Start date cannot be in the future.")
        }
    }

    @objc private func handleReasonTapped(_ sender: SGOptionChip) {
        let reason = SGOnboardingDraft.reasonTemplates[sender.tag]
        if selectedReasonTemplates.contains(reason) {
            selectedReasonTemplates.remove(reason)
            sender.isSelected = false
        } else {
            selectedReasonTemplates.insert(reason)
            sender.isSelected = true
        }
    }

    @objc private func handleSaveTapped() {
        view.endEditing(true)
        guard let updatedHabit = makeUpdatedHabit() else { return }
        SoberGardenStore.shared.setHabit(updatedHabit)
        onSave?()
        popCurrentController()
    }

    private func makeUpdatedHabit() -> Habit? {
        let trimmedCustomName = customHabitTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if selectedHabitType == .custom, trimmedCustomName?.isEmpty ?? true {
            showAlert(title: "Custom name required", message: "Please enter a custom habit name.")
            return nil
        }

        let startDate = min(startDatePicker.date, Date())
        if startDatePicker.date > Date() {
            showAlert(title: "Invalid date", message: "Start date cannot be in the future.")
            return nil
        }

        let dailyCost = Self.doubleValue(from: dailyCostTextField.text)
        let dailyMinutes = Self.intValue(from: dailyMinutesTextField.text)
        let reasons = resolvedReasons()

        return Habit(
            id: originalHabit.id,
            type: selectedHabitType,
            customName: selectedHabitType == .custom ? trimmedCustomName : nil,
            startDate: startDate,
            dailyCost: dailyCost,
            dailyMinutes: dailyMinutes,
            reasons: reasons,
            createdAt: originalHabit.createdAt,
            updatedAt: Date()
        )
    }

    private func resolvedReasons() -> [String] {
        var orderedReasons = SGOnboardingDraft.reasonTemplates.filter { selectedReasonTemplates.contains($0) }
        let customReasons = customReasonsTextView.text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        customReasons.forEach { reason in
            if !orderedReasons.contains(reason) {
                orderedReasons.append(reason)
            }
        }

        return orderedReasons
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private static func doubleValue(from text: String?) -> Double? {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        let value = Double(trimmed.replacingOccurrences(of: ",", with: "."))
        guard let value, value > 0 else { return nil }
        return value
    }

    private static func intValue(from text: String?) -> Int? {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let value = Int(trimmed), value > 0 else { return nil }
        return value
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
