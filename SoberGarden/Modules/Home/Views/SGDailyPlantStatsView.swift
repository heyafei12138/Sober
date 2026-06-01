//
//  SGDailyPlantStatsView.swift
//  SoberGarden
//

import UIKit

final class SGDailyPlantStatsView: UIView {

    private let stackView = UIStackView()
    private let currentStreakCard = SGDailyPlantStatCardView(
        title: "home.dailyPlantStats.currentStreak".localized(),
        iconName: "leaf.fill",
        accentColor: SGColor.primary,
        surfaceColor: UIColor.hexString("#F7FBF3")
    )
    private let totalPlantedCard = SGDailyPlantStatCardView(
        title: "home.dailyPlantStats.totalPlantedDays".localized(),
        iconName: "calendar.badge.checkmark",
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

    func configure(currentStreakDays: Int, totalPlantedDays: Int) {
        currentStreakCard.configure(value: Self.daysText(from: currentStreakDays))
        totalPlantedCard.configure(value: Self.daysText(from: totalPlantedDays))
    }

    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        addSubview(stackView)
        stackView.addArrangedSubview(currentStreakCard)
        stackView.addArrangedSubview(totalPlantedCard)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private static func daysText(from days: Int) -> String {
        "settings.stats.daysFormat".localizedFormat(max(days, 0))
    }
}

private final class SGDailyPlantStatCardView: UIView {

    private let cardView = SGCardView()
    private let iconContainerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let title: String
    private let iconName: String
    private let accentColor: UIColor
    private let surfaceColor: UIColor

    init(title: String, iconName: String, accentColor: UIColor, surfaceColor: UIColor) {
        self.title = title
        self.iconName = iconName
        self.accentColor = accentColor
        self.surfaceColor = surfaceColor
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.title = ""
        self.iconName = "leaf.fill"
        self.accentColor = SGColor.primary
        self.surfaceColor = SGColor.surface
        super.init(coder: coder)
        setupView()
    }

    func configure(value: String) {
        valueLabel.text = value

        let accessibilityText = "home.dailyPlantStats.valueAccessibilityFormat".localizedFormat(title, value)
        accessibilityLabel = accessibilityText
        valueLabel.accessibilityLabel = accessibilityText
    }

    private func setupView() {
        isAccessibilityElement = true
        accessibilityTraits = .staticText

        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = surfaceColor

        iconContainerView.backgroundColor = accentColor.withAlphaComponent(0.2)
        iconContainerView.layer.cornerRadius = 13
        iconContainerView.layer.masksToBounds = true

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.72
        valueLabel.isAccessibilityElement = true
        valueLabel.accessibilityTraits = .staticText

        addSubview(cardView)
        cardView.contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(valueLabel)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(104)
        }

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
            make.size.equalTo(30)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(15)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.left.equalTo(iconContainerView.snp.right).offset(9)
            make.right.equalToSuperview().inset(14)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview().inset(14)
        }
    }
}
