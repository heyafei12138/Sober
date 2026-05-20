//
//  SGSavedStatsView.swift
//  SoberGarden
//

import UIKit

final class SGSavedStatsView: UIView {

    private let titleLabel = UILabel()
    private let cardStackView = UIStackView()
    private let moneyCard = SGHomeSavingsCardView(title: "Money Saved")
    private let timeCard = SGHomeSavingsCardView(title: "Time Saved")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(dailyCost: Double?, dailyMinutes: Int?, cleanDays: Int) {
        if let dailyCost, dailyCost > 0 {
            let saved = SGProgressCalculator.moneySaved(dailyCost: dailyCost, cleanDays: cleanDays)
            moneyCard.configure(value: Self.currencyString(from: saved), subtitle: "Keep the momentum visible.")
        } else {
            moneyCard.configure(value: "Add cost", subtitle: "Add cost to see your savings.")
        }

        if let dailyMinutes, dailyMinutes > 0 {
            let minutes = SGProgressCalculator.timeSavedMinutes(dailyMinutes: dailyMinutes, cleanDays: cleanDays)
            timeCard.configure(value: Self.timeString(from: minutes), subtitle: "Time you got back.")
        } else {
            timeCard.configure(value: "Add time", subtitle: "Add time to see your time saved.")
        }
    }

    private func setupView() {
        titleLabel.text = "Savings"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        cardStackView.axis = .horizontal
        cardStackView.spacing = 12
        cardStackView.alignment = .fill
        cardStackView.distribution = .fillEqually
        cardStackView.addArrangedSubview(moneyCard)
        cardStackView.addArrangedSubview(timeCard)

        addSubview(titleLabel)
        addSubview(cardStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        cardStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private static func currencyString(from value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value.rounded()))"
    }

    private static func timeString(from minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes) min" }
        let hours = minutes / 60
        let leftover = minutes % 60
        if leftover == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(leftover)m"
    }
}

private final class SGHomeSavingsCardView: UIView {

    private let cardView = SGCardView()
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        setupView(title: title)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(title: "")
    }

    func configure(value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }

    private func setupView(title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = SGColor.textSecondary

        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        addSubview(cardView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(valueLabel)
        cardView.contentView.addSubview(subtitleLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
