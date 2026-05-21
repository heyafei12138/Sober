//
//  SGJournalViewController.swift
//  SoberGarden
//

import UIKit

/// 每日记录：心情、冲动、触发、反思
final class SGJournalViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = SGSectionHeaderView(
        title: "Journal",
        subtitle: "A small check-in helps you notice patterns without judging the day."
    )
    private let checkInStatsView = SGCheckInStatsView()
    private let checkInView = SGJournalCheckInView()
    private let historyHeaderView = SGSectionHeaderView(title: "Recent entries")
    private let historyStackView = UIStackView()

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadJournal()
    }

    override func setupSubviews() {
        setupScrollView()
        setupContent()
        reloadJournal()
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 18)
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
        contentStackView.layoutMargins = UIEdgeInsets(top: 4, left: 20, bottom: 28, right: 20)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupContent() {
        historyStackView.axis = .vertical
        historyStackView.alignment = .fill
        historyStackView.distribution = .fill
        historyStackView.spacing = 12

        checkInView.onSave = { [weak self] mood, urgeLevel, triggers, note in
            self?.saveTodayEntry(mood: mood, urgeLevel: urgeLevel, triggers: triggers, note: note)
        }

        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(checkInStatsView)
        contentStackView.addArrangedSubview(checkInView)
        contentStackView.addArrangedSubview(historyHeaderView)
        contentStackView.addArrangedSubview(historyStackView)
    }

    private func reloadJournal() {
        let state = SoberGardenStore.shared.state
        let entries = state.journalEntries
        let cleanStreakDays = state.habit.map {
            SGProgressCalculator.currentStreakDays(startDate: $0.startDate, now: Date())
        }
        checkInStatsView.configure(
            cleanStreakDays: cleanStreakDays,
            checkInStreakDays: state.checkIn.checkInStreakDays
        )
        checkInView.configure(entry: todayEntry(in: entries))
        renderHistory(entries)
    }

    private func saveTodayEntry(
        mood: MoodType,
        urgeLevel: UrgeLevel,
        triggers: [TriggerType],
        note: String?
    ) {
        let existingEntry = todayEntry(in: SoberGardenStore.shared.state.journalEntries)
        let entry = JournalEntry(
            id: existingEntry?.id ?? UUID(),
            date: existingEntry?.date ?? Date(),
            mood: mood,
            urgeLevel: urgeLevel,
            triggers: triggers.sorted { $0.rawValue < $1.rawValue },
            note: note
        )

        SoberGardenStore.shared.upsertJournalEntry(entry)
        view.endEditing(true)
        reloadJournal()
    }

    private func renderHistory(_ entries: [JournalEntry]) {
        historyStackView.arrangedSubviews.forEach { view in
            historyStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if entries.isEmpty {
            historyStackView.addArrangedSubview(makeEmptyHistoryLabel())
            return
        }

        entries.prefix(7).forEach { entry in
            let cell = SGJournalHistoryCell()
            cell.configure(entry: entry)
            historyStackView.addArrangedSubview(cell)
        }
    }

    private func todayEntry(in entries: [JournalEntry]) -> JournalEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    private func makeEmptyHistoryLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = SGColor.textSecondary
        label.numberOfLines = 0
        label.text = "No entries yet. Save today's check-in to start your journal."
        return label
    }
}
