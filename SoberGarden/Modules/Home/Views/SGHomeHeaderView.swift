//
//  SGHomeHeaderView.swift
//  SoberGarden
//

import UIKit

final class SGHomeHeaderView: UIView {

    private let dayBadgeView = UIView()
    private let dayLabel = UILabel()
    private let habitLabel = UILabel()
    private let captionLabel = UILabel()
    private let headerIllustration = SGIllustrationPlaceholderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(dayCount: Int, habitName: String) {
        dayLabel.text = "Day \(dayCount)"
        habitLabel.text = "Clean from \(habitName)"
        captionLabel.text = "Recovery companion"
    }

    private func setupView() {
        dayBadgeView.backgroundColor = SGColor.primaryLight
        dayBadgeView.layer.cornerRadius = 14

        dayLabel.font = .systemFont(ofSize: 15, weight: .bold)
        dayLabel.textColor = SGColor.primaryDark

        habitLabel.font = .systemFont(ofSize: 28, weight: .bold)
        habitLabel.textColor = SGColor.textDark
        habitLabel.numberOfLines = 2
        habitLabel.lineBreakMode = .byWordWrapping

        captionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        captionLabel.textColor = SGColor.textSecondary

        headerIllustration.configure(
            assetName: "home_header_garden",
            placeholderText: "Header",
            tintColor: SGColor.flowerSoft
        )

        addSubview(dayBadgeView)
        dayBadgeView.addSubview(dayLabel)
        addSubview(habitLabel)
        addSubview(captionLabel)
        addSubview(headerIllustration)

        headerIllustration.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.size.equalTo(56)
        }

        dayBadgeView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }

        dayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }

        habitLabel.snp.makeConstraints { make in
            make.top.equalTo(dayBadgeView.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(headerIllustration.snp.left).offset(-12)
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(habitLabel.snp.bottom).offset(6)
            make.left.bottom.equalToSuperview()
            make.right.lessThanOrEqualTo(headerIllustration.snp.left).offset(-12)
        }
    }
}
