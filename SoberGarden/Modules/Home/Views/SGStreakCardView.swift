//
//  SGStreakCardView.swift
//  SoberGarden
//

import UIKit

final class SGStreakCardView: UIView {

    private let cardView = SGCardView()
    private let titleLabel = UILabel()
    private let metricStackView = UIStackView()
    private let dayMetricView = SGStreakMetricView()
    private let hourMetricView = SGStreakMetricView()
    private let longestMetricView = SGStreakMetricView()
    private let startMetricView = SGStreakMetricView()

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
        titleLabel.text = "\(cleanDays) days clean"
        dayMetricView.configure(value: "\(cleanDays)", title: "Days")
        hourMetricView.configure(value: "\(currentHours)", title: "Hours")
        longestMetricView.configure(value: "\(longestStreakDays)", title: "Longest")
        startMetricView.configure(value: Self.startedText(for: startedDate), title: "Started")
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        metricStackView.axis = .horizontal
        metricStackView.alignment = .fill
        metricStackView.distribution = .fillEqually
        metricStackView.spacing = 11

        metricStackView.addArrangedSubview(dayMetricView)
        metricStackView.addArrangedSubview(hourMetricView)
        metricStackView.addArrangedSubview(longestMetricView)
        metricStackView.addArrangedSubview(startMetricView)

        addSubview(cardView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(metricStackView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        metricStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview().inset(18)
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

    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }

    private func setupView() {
        backgroundColor = UIColor.hexString("#EEF5E9")
        layer.cornerRadius = 12
        layer.masksToBounds = true

        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.72

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        addSubview(valueLabel)
        addSubview(titleLabel)

        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.right.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview().inset(10)
        }
    }
}
