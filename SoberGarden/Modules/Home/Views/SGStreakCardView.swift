//
//  SGStreakCardView.swift
//  SoberGarden
//

import UIKit

final class SGStreakCardView: UIView {

    var onShareTap: (() -> Void)?

    private let cardView = SGCardView()
    private let titleLabel = UILabel()
    private let shareButton = UIButton(type: .system)
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
        titleLabel.text = "home.streak.titleFormat".localizedFormat(cleanDays)
        dayMetricView.configure(value: "\(cleanDays)", title: "home.streak.days".localized())
        hourMetricView.configure(value: "\(currentHours)", title: "home.streak.hours".localized())
        longestMetricView.configure(value: "\(longestStreakDays)", title: "home.streak.longest".localized())
        startMetricView.configure(value: Self.startedText(for: startedDate), title: "home.streak.started".localized())
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        shareButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        shareButton.setTitle("common.share".localized(), for: .normal)
        shareButton.tintColor = SGColor.primaryDark
        shareButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        shareButton.semanticContentAttribute = .forceLeftToRight
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        shareButton.backgroundColor = UIColor.hexString("#EEF5E9")
        shareButton.layer.cornerRadius = 16
        shareButton.layer.masksToBounds = true
        shareButton.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)

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
        cardView.contentView.addSubview(shareButton)
        cardView.contentView.addSubview(metricStackView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(18)
            make.right.lessThanOrEqualTo(shareButton.snp.left).offset(-12)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().inset(18)
            make.width.equalTo(86)
            make.height.equalTo(32)
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

    @objc private func handleShareTapped() {
        onShareTap?()
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
