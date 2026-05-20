//
//  SGSavedStatsView.swift
//  SoberGarden
//

import UIKit

final class SGSavedStatsView: UIView {

    private let titleLabel = UILabel()
    private let cardStackView = UIStackView()
    private let moneyCard = SGHomeSavingsCardView(
        title: "Money Saved",
        iconName: "leaf.fill",
        accentColor: SGColor.flower,
        surfaceColor: UIColor.hexString("#FFFBED")
    )
    private let timeCard = SGHomeSavingsCardView(
        title: "Time Saved",
        iconName: "clock.fill",
        accentColor: UIColor.hexString("#86B8B0"),
        surfaceColor: UIColor.hexString("#F2FAF8")
    )

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
            moneyCard.configure(value: Self.currencyString(from: saved), subtitle: "Visible progress.")
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
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
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
    private let iconContainerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let accentColor: UIColor
    private let surfaceColor: UIColor

    init(title: String, iconName: String, accentColor: UIColor, surfaceColor: UIColor) {
        self.accentColor = accentColor
        self.surfaceColor = surfaceColor
        super.init(frame: .zero)
        setupView(title: title, iconName: iconName)
    }

    required init?(coder: NSCoder) {
        self.accentColor = SGColor.primary
        self.surfaceColor = SGColor.surface
        super.init(coder: coder)
        setupView(title: "", iconName: "leaf.fill")
    }

    func configure(value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }

    private func setupView(title: String, iconName: String) {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = surfaceColor

        iconContainerView.backgroundColor = accentColor.withAlphaComponent(0.24)
        iconContainerView.layer.cornerRadius = 14
        iconContainerView.layer.masksToBounds = true

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.86

        addSubview(cardView)
        cardView.contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(valueLabel)
        cardView.contentView.addSubview(subtitleLabel)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(128)
        }

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.size.equalTo(34)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(17)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.left.equalTo(iconContainerView.snp.right).offset(10)
            make.right.equalToSuperview().inset(16)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(6)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }
}
