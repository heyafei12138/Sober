//
//  SGHomeHeaderView.swift
//  SoberGarden
//

import UIKit

final class SGHomeHeaderView: UIView {

    private let textStackView = UIStackView()
    private let dayLabel = UILabel()
    private let habitLabel = UILabel()
    private let captionLabel = UILabel()
    private let visualContainerView = UIView()
    private let visualImageView = UIImageView()

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
        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.spacing = 4

        dayLabel.font = .systemFont(ofSize: 34, weight: .bold)
        dayLabel.textColor = SGColor.textDark
        dayLabel.numberOfLines = 1
        dayLabel.adjustsFontSizeToFitWidth = true
        dayLabel.minimumScaleFactor = 0.82

        habitLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        habitLabel.textColor = SGColor.primaryDark
        habitLabel.numberOfLines = 1
        habitLabel.adjustsFontSizeToFitWidth = true
        habitLabel.minimumScaleFactor = 0.8

        captionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        captionLabel.textColor = SGColor.textSecondary

        visualContainerView.backgroundColor = UIColor.hexString("#FFF3D2")
        visualContainerView.layer.cornerRadius = 26
        visualContainerView.layer.masksToBounds = true

        visualImageView.image = UIImage(named: "garden_stage_sprout") ?? UIImage(named: "guider_icon_flowerpot")
        visualImageView.contentMode = .scaleAspectFit

        addSubview(textStackView)
        addSubview(visualContainerView)
        textStackView.addArrangedSubview(dayLabel)
        textStackView.addArrangedSubview(habitLabel)
        textStackView.addArrangedSubview(captionLabel)
        visualContainerView.addSubview(visualImageView)

        textStackView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(2)
            make.right.lessThanOrEqualTo(visualContainerView.snp.left).offset(-18)
        }

        visualContainerView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(94)
        }

        visualImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
}
