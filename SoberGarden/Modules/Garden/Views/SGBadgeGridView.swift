//
//  SGBadgeGridView.swift
//  SoberGarden
//

import UIKit

final class SGBadgeGridView: UIView {

    private let titleLabel = UILabel()
    private let gridStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(milestones: [Milestone], unlockedCleanDays: Int) {
        gridStackView.arrangedSubviews.forEach { view in
            gridStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let rows = milestones.chunked(into: 3)
        rows.forEach { rowMilestones in
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10

            rowMilestones.forEach { milestone in
                let itemView = SGBadgeItemView()
                itemView.configure(
                    title: milestone.badgeName,
                    dayText: "garden.dayFormat".localizedFormat(milestone.day),
                    isUnlocked: unlockedCleanDays >= milestone.day
                )
                rowStackView.addArrangedSubview(itemView)
            }

            if rowMilestones.count < 3 {
                for _ in 0..<(3 - rowMilestones.count) {
                    let spacer = UIView()
                    spacer.alpha = 0
                    rowStackView.addArrangedSubview(spacer)
                }
            }

            gridStackView.addArrangedSubview(rowStackView)
        }
    }

    private func setupView() {
        titleLabel.text = "garden.badges.title".localized()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        gridStackView.axis = .vertical
        gridStackView.alignment = .fill
        gridStackView.distribution = .fill
        gridStackView.spacing = 10

        addSubview(titleLabel)
        addSubview(gridStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

private final class SGBadgeItemView: UIView {

    private let iconContainerView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let dayLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, dayText: String, isUnlocked: Bool) {
        titleLabel.text = title
        dayLabel.text = dayText
        iconLabel.text = isUnlocked ? "✓" : "•"
        iconContainerView.backgroundColor = isUnlocked ? SGColor.flower.withAlphaComponent(0.32) : UIColor.hexString("#E7E4D7")
        iconLabel.textColor = isUnlocked ? SGColor.primaryDark : SGColor.textTertiary
        titleLabel.textColor = isUnlocked ? SGColor.textDark : SGColor.textSecondary
        dayLabel.textColor = isUnlocked ? SGColor.primaryDark : SGColor.textTertiary
        backgroundColor = isUnlocked ? UIColor.hexString("#FFFBED") : UIColor.white.withAlphaComponent(0.62)
        layer.borderColor = (isUnlocked ? SGColor.flower.withAlphaComponent(0.34) : SGColor.separator.withAlphaComponent(0.45)).cgColor
    }

    private func setupView() {
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.masksToBounds = true

        iconContainerView.layer.cornerRadius = 14
        iconContainerView.layer.masksToBounds = true

        iconLabel.font = .systemFont(ofSize: 15, weight: .bold)
        iconLabel.textAlignment = .center

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.78

        dayLabel.font = .systemFont(ofSize: 11, weight: .medium)
        dayLabel.textAlignment = .center
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.minimumScaleFactor = 0.8

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconLabel)
        addSubview(titleLabel)
        addSubview(dayLabel)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(108)
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(28)
        }

        iconLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }

        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(8)
        }
    }
}

private extension Array {

    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        var chunks: [[Element]] = []
        var index = 0
        while index < count {
            chunks.append(Array(self[index..<Swift.min(index + size, count)]))
            index += size
        }
        return chunks
    }
}
