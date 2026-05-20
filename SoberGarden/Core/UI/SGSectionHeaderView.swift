//
//  SGSectionHeaderView.swift
//  SoberGarden
//

import UIKit

final class SGSectionHeaderView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    var onAction: (() -> Void)?

    init(title: String, subtitle: String? = nil, actionTitle: String? = nil) {
        super.init(frame: .zero)
        setupView()
        configure(title: title, subtitle: subtitle, actionTitle: actionTitle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, subtitle: String? = nil, actionTitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle?.isEmpty ?? true
    }

    private func setupView() {
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.setTitleColor(SGColor.primaryDark, for: .normal)
        actionButton.addTarget(self, action: #selector(handleActionTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(actionButton)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.right.lessThanOrEqualTo(actionButton.snp.left).offset(-12)
        }

        actionButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.height.equalTo(36)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func handleActionTapped() {
        onAction?()
    }
}
