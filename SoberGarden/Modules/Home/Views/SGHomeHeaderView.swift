//
//  SGHomeHeaderView.swift
//  SoberGarden
//

import UIKit

final class SGHomeHeaderView: UIView {

    private let dayLabel = UILabel()
    private let habitLabel = UILabel()
    private let captionLabel = UILabel()

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

        addSubview(dayLabel)
        addSubview(habitLabel)
        addSubview(captionLabel)

        dayLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        habitLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(habitLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
