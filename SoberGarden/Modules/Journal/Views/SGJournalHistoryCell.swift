//
//  SGJournalHistoryCell.swift
//  SoberGarden
//

import UIKit

final class SGJournalHistoryCell: UIView {

    private let cardView = SGCardView()
    private let dateLabel = UILabel()
    private let summaryLabel = UILabel()
    private let triggersLabel = UILabel()
    private let noteLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(entry: JournalEntry) {
        dateLabel.text = Self.dateFormatter.string(from: entry.date)
        summaryLabel.text = "\(entry.mood.displayName) · \(entry.urgeLevel.displayName)"

        if entry.triggers.isEmpty {
            triggersLabel.text = "journal.history.noTriggers".localized()
        } else {
            triggersLabel.text = entry.triggers.map(\.displayName).joined(separator: ", ")
        }

        noteLabel.text = entry.note?.isEmpty == false ? entry.note : "journal.history.noReflection".localized()
        noteLabel.textColor = entry.note?.isEmpty == false ? SGColor.textDark : SGColor.textTertiary
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.cornerRadius = 14
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = SGColor.primaryDark

        summaryLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        summaryLabel.textColor = SGColor.textDark
        summaryLabel.numberOfLines = 0

        triggersLabel.font = .systemFont(ofSize: 14, weight: .medium)
        triggersLabel.textColor = SGColor.textSecondary
        triggersLabel.numberOfLines = 0

        noteLabel.font = .systemFont(ofSize: 14, weight: .regular)
        noteLabel.numberOfLines = 0

        addSubview(cardView)
        cardView.contentView.addSubview(dateLabel)
        cardView.contentView.addSubview(summaryLabel)
        cardView.contentView.addSubview(triggersLabel)
        cardView.contentView.addSubview(noteLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }

        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        triggersLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        noteLabel.snp.makeConstraints { make in
            make.top.equalTo(triggersLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
