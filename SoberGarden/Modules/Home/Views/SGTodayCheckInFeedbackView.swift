//
//  SGTodayCheckInFeedbackView.swift
//  SoberGarden
//

import UIKit

final class SGTodayCheckInFeedbackView: UIView {

    private let cardView = SGCardView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let button = SGPrimaryButton(title: "common.done".localized())

    var onButtonTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, subtitle: String, buttonTitle: String = "common.done".localized()) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        button.setTitle(buttonTitle, for: .normal)
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 12
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 16, bottom: 16, right: 16)

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = SGColor.primaryDark
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(button)

        cardView.contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }

    @objc private func handleButtonTapped() {
        onButtonTap?()
    }
}
