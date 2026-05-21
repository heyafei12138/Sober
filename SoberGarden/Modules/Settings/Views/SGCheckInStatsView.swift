//
//  SGCheckInStatsView.swift
//  SoberGarden
//

import UIKit

final class SGCheckInStatsView: UIView {

    private let cardView = SGCardView()
    private let stackView = UIStackView()
    private let headerView = SGSectionHeaderView(
        title: "Secondary stats",
        subtitle: "Check-in streak stays separate from clean streak."
    )
    private let rowsStackView = UIStackView()
    private let checkInRow = SGCheckInStatRowView(
        title: "Check-in streak",
        accentColor: SGColor.primaryDark,
        surfaceColor: UIColor.hexString("#F4F8FF")
    )
    private let cleanRow = SGCheckInStatRowView(
        title: "Clean streak",
        accentColor: SGColor.flower,
        surfaceColor: UIColor.hexString("#FFF8EE")
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(cleanStreakDays: Int?, checkInStreakDays: Int) {
        checkInRow.configure(value: "\(max(checkInStreakDays, 0)) days")
        if let cleanStreakDays {
            cleanRow.configure(value: "\(max(cleanStreakDays, 0)) days")
        } else {
            cleanRow.configure(value: "Not set")
        }
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12

        rowsStackView.axis = .vertical
        rowsStackView.alignment = .fill
        rowsStackView.distribution = .fill
        rowsStackView.spacing = 10

        rowsStackView.addArrangedSubview(checkInRow)
        rowsStackView.addArrangedSubview(cleanRow)

        addSubview(cardView)
        cardView.contentView.addSubview(stackView)

        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(rowsStackView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}

private final class SGCheckInStatRowView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let accentView = UIView()
    private let accentColor: UIColor
    private let surfaceColor: UIColor

    init(title: String, accentColor: UIColor, surfaceColor: UIColor) {
        self.accentColor = accentColor
        self.surfaceColor = surfaceColor
        super.init(frame: .zero)
        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        self.accentColor = SGColor.primaryDark
        self.surfaceColor = SGColor.surface
        super.init(coder: coder)
        setupView(title: "")
    }

    func configure(value: String) {
        valueLabel.text = value
    }

    private func setupView(title: String) {
        backgroundColor = surfaceColor
        layer.cornerRadius = 14
        layer.masksToBounds = true

        accentView.backgroundColor = accentColor.withAlphaComponent(0.18)
        accentView.layer.cornerRadius = 10
        accentView.layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.text = title
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85

        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = SGColor.textSecondary
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75

        addSubview(accentView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        accentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(accentView.snp.right).offset(10)
            make.top.bottom.equalToSuperview().inset(12)
            make.right.lessThanOrEqualTo(valueLabel.snp.left).offset(-10)
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(14)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(46)
        }
    }
}
