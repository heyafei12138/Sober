//
//  SGReviewPromptViewController.swift
//  SoberGarden
//

import UIKit

final class SGReviewPromptViewController: UIViewController {

    private let dimView = UIView()
    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let primaryButton = SGPrimaryButton(title: "reviewPrompt.rate".localized())
    private let feedbackButton = SGPrimaryButton(title: "reviewPrompt.feedback".localized(), style: .secondary)
    private let closeButton = UIButton(type: .system)

    private let onRate: () -> Void
    private let onFeedback: () -> Void
    private let onDismiss: () -> Void
    private var didChooseAction = false

    init(onRate: @escaping () -> Void, onFeedback: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.onRate = onRate
        self.onFeedback = onFeedback
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupView() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        dimView.alpha = 0

        cardView.backgroundColor = UIColor.hexString("#FBFDF8")
        cardView.layer.cornerRadius = 28
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = SGColor.textDark.cgColor
        cardView.layer.shadowOpacity = 0.18
        cardView.layer.shadowRadius = 24
        cardView.layer.shadowOffset = CGSize(width: 0, height: 14)
        cardView.transform = CGAffineTransform(translationX: 0, y: 28).scaledBy(x: 0.96, y: 0.96)
        cardView.alpha = 0

        iconContainerView.backgroundColor = SGColor.flower.withAlphaComponent(0.22)
        iconContainerView.layer.cornerRadius = 28
        iconContainerView.layer.cornerCurve = .continuous

        iconImageView.image = UIImage(systemName: "leaf.fill")
        iconImageView.tintColor = SGColor.primaryDark
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = "reviewPrompt.title".localized()
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.text = "reviewPrompt.message".localized()
        messageLabel.font = .systemFont(ofSize: 15, weight: .medium)
        messageLabel.textColor = SGColor.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        ratingStackView.axis = .horizontal
        ratingStackView.alignment = .center
        ratingStackView.distribution = .equalSpacing
        ratingStackView.spacing = 6

        (0..<5).forEach { _ in
            let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
            imageView.tintColor = SGColor.flower
            imageView.contentMode = .scaleAspectFit
            ratingStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
        }

        primaryButton.addTarget(self, action: #selector(handleRateTapped), for: .touchUpInside)
        feedbackButton.addTarget(self, action: #selector(handleFeedbackTapped), for: .touchUpInside)

        closeButton.setTitle("reviewPrompt.notNow".localized(), for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        closeButton.setTitleColor(SGColor.textSecondary, for: .normal)
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)

        view.addSubview(dimView)
        view.addSubview(cardView)
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(ratingStackView)
        cardView.addSubview(primaryButton)
        cardView.addSubview(feedbackButton)
        cardView.addSubview(closeButton)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(26)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(26)
        }

        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(28)
        }

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(ratingStackView.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(22)
        }

        feedbackButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(22)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(feedbackButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().inset(18)
            make.height.equalTo(36)
        }
    }

    private func animateIn() {
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    private func dismissPrompt(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 18).scaledBy(x: 0.98, y: 0.98)
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    @objc private func handleRateTapped() {
        didChooseAction = true
        dismissPrompt { self.onRate() }
    }

    @objc private func handleFeedbackTapped() {
        didChooseAction = true
        dismissPrompt { self.onFeedback() }
    }

    @objc private func handleCloseTapped() {
        dismissPrompt { self.onDismiss() }
    }

    deinit {
        if !didChooseAction {
            onDismiss()
        }
    }
}
