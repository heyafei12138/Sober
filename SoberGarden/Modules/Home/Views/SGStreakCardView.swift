//
//  SGStreakCardView.swift
//  SoberGarden
//

import UIKit

final class SGStreakCardView: UIView {

    private let cardView = SGCardView()
    private let countLabel = UILabel()
    private let unitLabel = UILabel()
    private let metricStackView = UIStackView()
    private let dayMetricView = SGStreakMetricView(accent: SGColor.primary)
    private let hourMetricView = SGStreakMetricView(accent: SGColor.primaryDark)
    private let longestMetricView = SGStreakMetricView(accent: SGColor.flower)
    private let startMetricView = SGStreakMetricView(accent: SGColor.textSecondary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(
        cleanDays: Int,
        currentHours: Int,
        longestStreakDays: Int,
        startedDate: Date?,
        habitName: String
    ) {
        countLabel.text = "\(cleanDays)"
        unitLabel.text = cleanDays == 1 ? "day clean" : "days clean"
        dayMetricView.configure(value: "\(cleanDays)", title: "Days")
        hourMetricView.configure(value: "\(currentHours)", title: "Hours")
        longestMetricView.configure(value: "\(longestStreakDays)", title: "Longest")
        startMetricView.configure(value: Self.startedText(for: startedDate), title: "Started")
        _ = habitName
    }

    private func setupView() {
        cardView.cornerRadius = 20

        countLabel.font = .systemFont(ofSize: 44, weight: .bold)
        countLabel.textColor = SGColor.primary

        unitLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        unitLabel.textColor = SGColor.textDark

        metricStackView.axis = .horizontal
        metricStackView.alignment = .fill
        metricStackView.distribution = .fillEqually
        metricStackView.spacing = 10

        metricStackView.addArrangedSubview(dayMetricView)
        metricStackView.addArrangedSubview(hourMetricView)
        metricStackView.addArrangedSubview(longestMetricView)
        metricStackView.addArrangedSubview(startMetricView)

        addSubview(cardView)
        cardView.contentView.addSubview(countLabel)
        cardView.contentView.addSubview(unitLabel)
        cardView.contentView.addSubview(metricStackView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        countLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }

        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(countLabel.snp.right).offset(8)
            make.bottom.equalTo(countLabel).offset(-6)
            make.right.lessThanOrEqualToSuperview()
        }

        metricStackView.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(18)
            make.left.right.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(76)
        }
    }

    private static func startedText(for startedDate: Date?) -> String {
        guard let startedDate else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMM d"
        return formatter.string(from: startedDate)
    }
}

private final class SGStreakMetricView: UIView {

    private let accentColor: UIColor
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    init(accent: UIColor) {
        self.accentColor = accent
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.accentColor = SGColor.primary
        super.init(coder: coder)
        setupView()
    }

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }

    private func setupView() {
        backgroundColor = SGColor.background.withAlphaComponent(0.7)
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = SGColor.separator.cgColor

        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = accentColor
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.72

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.textAlignment = .center

        addSubview(valueLabel)
        addSubview(titleLabel)

        let pad = SGHomeLayout.metricPadding
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(pad.top)
            make.left.right.equalToSuperview().inset(pad.left)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(pad.left)
            make.bottom.equalToSuperview().offset(-pad.bottom)
        }
    }
}
