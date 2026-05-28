//
//  SGCoachMessageView.swift
//  SoberGarden
//

import UIKit

final class SGCoachMessageView: UIView {

    private let stackView = UIStackView()
    private let iconContainerView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func showLoading() {
        titleLabel.text = "rescue.coach.loadingTitle".localized()
        messageLabel.text = "rescue.coach.loadingMessage".localized()
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        iconLabel.text = "..."
    }

    func showPrompt(_ prompt: String) {
        titleLabel.text = "home.coach.title".localized()
        messageLabel.text = prompt
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        iconLabel.text = "\""
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12

        iconContainerView.backgroundColor = SGColor.flower.withAlphaComponent(0.34)
        iconContainerView.layer.cornerRadius = 24
        iconContainerView.layer.masksToBounds = true

        iconLabel.font = .systemFont(ofSize: 22, weight: .bold)
        iconLabel.textColor = SGColor.primaryDark
        iconLabel.textAlignment = .center

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
        messageLabel.textColor = SGColor.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        activityIndicatorView.color = SGColor.primaryDark

        addSubview(stackView)
        iconContainerView.addSubview(iconLabel)
        stackView.addArrangedSubview(iconContainerView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(activityIndicatorView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }

        iconLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
