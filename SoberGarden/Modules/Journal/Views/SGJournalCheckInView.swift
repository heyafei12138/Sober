//
//  SGJournalCheckInView.swift
//  SoberGarden
//

import UIKit

final class SGJournalCheckInView: UIView {

    var onSave: ((MoodType, UrgeLevel, [TriggerType], String?) -> Void)?

    private let cardView = SGCardView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let moodStackView = UIStackView()
    private let urgeStackView = UIStackView()
    private let triggerStackView = UIStackView()
    private let noteTextView = UITextView()
    private let notePlaceholderLabel = UILabel()
    private let saveButton = SGPrimaryButton(title: "journal.save".localized())

    private var moodChips: [MoodType: SGOptionChip] = [:]
    private var urgeChips: [UrgeLevel: SGOptionChip] = [:]
    private var triggerChips: [TriggerType: SGOptionChip] = [:]
    private var selectedMood: MoodType = .okay
    private var selectedUrge: UrgeLevel = .none
    private var selectedTriggers: Set<TriggerType> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        applySelection()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        applySelection()
    }

    func configure(entry: JournalEntry?) {
        selectedMood = entry?.mood ?? .okay
        selectedUrge = entry?.urgeLevel ?? .none
        selectedTriggers = Set(entry?.triggers ?? [])
        noteTextView.text = entry?.note ?? ""
        notePlaceholderLabel.isHidden = !noteTextView.text.isEmpty
        applySelection()
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FFFBED")

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.text = "journal.todayCheckIn".localized()

        [moodStackView, urgeStackView, triggerStackView].forEach {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 10
        }

        setupMoodSection()
        setupUrgeSection()
        setupTriggerSection()
        setupNoteTextView()

        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)

        addSubview(cardView)
        cardView.contentView.addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(moodStackView)
        stackView.addArrangedSubview(urgeStackView)
        stackView.addArrangedSubview(triggerStackView)
        stackView.addArrangedSubview(noteTextView)
        stackView.addArrangedSubview(saveButton)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(18)
        }

        noteTextView.snp.makeConstraints { make in
            make.height.equalTo(104)
        }
    }

    private func setupMoodSection() {
        moodStackView.addArrangedSubview(makeSectionLabel("journal.mood".localized()))
        addChips(MoodType.allCases, to: moodStackView) { [weak self] mood in
            let chip = SGOptionChip(title: mood.displayName)
            chip.addTarget(self, action: #selector(self?.handleMoodTapped(_:)), for: .touchUpInside)
            chip.tag = MoodType.allCases.firstIndex(of: mood) ?? 0
            self?.moodChips[mood] = chip
            return chip
        }
    }

    private func setupUrgeSection() {
        urgeStackView.addArrangedSubview(makeSectionLabel("journal.urge".localized()))
        addChips(UrgeLevel.allCases, to: urgeStackView) { [weak self] urge in
            let chip = SGOptionChip(title: urge.displayName)
            chip.addTarget(self, action: #selector(self?.handleUrgeTapped(_:)), for: .touchUpInside)
            chip.tag = UrgeLevel.allCases.firstIndex(of: urge) ?? 0
            self?.urgeChips[urge] = chip
            return chip
        }
    }

    private func setupTriggerSection() {
        triggerStackView.addArrangedSubview(makeSectionLabel("journal.triggers".localized()))
        addChips(TriggerType.allCases, to: triggerStackView) { [weak self] trigger in
            let chip = SGOptionChip(title: trigger.displayName)
            chip.addTarget(self, action: #selector(self?.handleTriggerTapped(_:)), for: .touchUpInside)
            chip.tag = TriggerType.allCases.firstIndex(of: trigger) ?? 0
            self?.triggerChips[trigger] = chip
            return chip
        }
    }

    private func setupNoteTextView() {
        noteTextView.delegate = self
        noteTextView.isEditable = true
        noteTextView.isSelectable = true
        noteTextView.isScrollEnabled = false
        noteTextView.font = .systemFont(ofSize: 15, weight: .regular)
        noteTextView.textColor = SGColor.textDark
        noteTextView.backgroundColor = .white.withAlphaComponent(0.78)
        noteTextView.layer.cornerRadius = 14
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = SGColor.separator.cgColor
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        noteTextView.textContainer.lineFragmentPadding = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNoteTapped))
        tapGesture.cancelsTouchesInView = false
        noteTextView.addGestureRecognizer(tapGesture)

        notePlaceholderLabel.text = "journal.note.placeholder".localized()
        notePlaceholderLabel.font = .systemFont(ofSize: 15, weight: .regular)
        notePlaceholderLabel.textColor = SGColor.textTertiary

        noteTextView.addSubview(notePlaceholderLabel)
        notePlaceholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = SGColor.textDark
        label.text = text
        return label
    }

    private func addChips<T>(_ items: [T], to stackView: UIStackView, makeChip: (T) -> SGOptionChip) {
        for rowItems in items.chunked(into: 2) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10

            rowItems.forEach { rowStackView.addArrangedSubview(makeChip($0)) }
            stackView.addArrangedSubview(rowStackView)
        }
    }

    private func applySelection() {
        moodChips.forEach { mood, chip in
            chip.isSelected = mood == selectedMood
        }
        urgeChips.forEach { urge, chip in
            chip.isSelected = urge == selectedUrge
        }
        triggerChips.forEach { trigger, chip in
            chip.isSelected = selectedTriggers.contains(trigger)
        }
    }

    @objc private func handleMoodTapped(_ sender: SGOptionChip) {
        selectedMood = MoodType.allCases[sender.tag]
        applySelection()
    }

    @objc private func handleUrgeTapped(_ sender: SGOptionChip) {
        selectedUrge = UrgeLevel.allCases[sender.tag]
        applySelection()
    }

    @objc private func handleTriggerTapped(_ sender: SGOptionChip) {
        let trigger = TriggerType.allCases[sender.tag]
        if selectedTriggers.contains(trigger) {
            selectedTriggers.remove(trigger)
        } else {
            selectedTriggers.insert(trigger)
        }
        applySelection()
    }

    @objc private func handleSaveTapped() {
        let note = noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave?(selectedMood, selectedUrge, Array(selectedTriggers), note.isEmpty ? nil : note)
    }

    @objc private func handleNoteTapped() {
        noteTextView.becomeFirstResponder()
    }
}

extension SGJournalCheckInView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        notePlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidChange(_ textView: UITextView) {
        notePlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        notePlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
