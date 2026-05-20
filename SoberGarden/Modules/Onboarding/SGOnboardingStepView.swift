//
//  SGOnboardingStepView.swift
//  SoberGarden
//

import UIKit

final class SGOnboardingStepView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
    }

    private func setupView() {
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left

        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left

        addSubview(titleLabel)
        addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
