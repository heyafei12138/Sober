//
//  SGTodayCheckInCardView.swift
//  SoberGarden
//

import UIKit

final class SGTodayCheckInCardView: UIView {

    enum State {
        case todayNotConfirmed
        case todayConfirmed
        case yesterdayPending

        var badgeTitle: String {
            "checkin.card.badge".localized()
        }

        var title: String {
            switch self {
            case .todayNotConfirmed:
                return "checkin.card.today.title".localized()
            case .todayConfirmed:
                return "checkin.card.confirmed.title".localized()
            case .yesterdayPending:
                return "checkin.card.yesterday.title".localized()
            }
        }

        var subtitle: String {
            switch self {
            case .todayNotConfirmed:
                return "checkin.card.today.subtitle".localized()
            case .todayConfirmed:
                return "checkin.card.confirmed.subtitle".localized()
            case .yesterdayPending:
                return "checkin.card.yesterday.subtitle".localized()
            }
        }

        var detail: String? {
            switch self {
            case .todayNotConfirmed:
                return nil
            case .todayConfirmed:
                return "checkin.card.confirmed.detail".localized()
            case .yesterdayPending:
                return nil
            }
        }

        var primaryButtonTitle: String? {
            switch self {
            case .todayNotConfirmed:
                return "checkin.card.today.primary".localized()
            case .todayConfirmed:
                return nil
            case .yesterdayPending:
                return "checkin.card.yesterday.primary".localized()
            }
        }

        var secondaryButtonTitle: String? {
            switch self {
            case .todayNotConfirmed, .yesterdayPending:
                return self == .todayNotConfirmed ? "common.imStruggling".localized() : "checkin.card.yesterday.secondary".localized()
            case .todayConfirmed:
                return nil
            }
        }
    }

    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?

    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let detailLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let primaryButton = SGPrimaryButton(title: "common.continue".localized())
    private let secondaryButton = SGPrimaryButton(title: "common.imStruggling".localized(), style: .secondary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(state: State) {
        eyebrowLabel.text = state.badgeTitle
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        detailLabel.text = state.detail
        detailLabel.isHidden = state.detail == nil

        if let primaryTitle = state.primaryButtonTitle {
            primaryButton.setTitle(primaryTitle, for: .normal)
            primaryButton.isHidden = false
        } else {
            primaryButton.isHidden = true
        }

        if let secondaryTitle = state.secondaryButtonTitle {
            secondaryButton.setTitle(secondaryTitle, for: .normal)
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }

        buttonStackView.isHidden = primaryButton.isHidden && secondaryButton.isHidden

        updateAppearance(for: state)
    }

    private func setupView() {
        let cardView = SGCardView()
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 12
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

        eyebrowLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        eyebrowLabel.textColor = SGColor.primaryDark
        eyebrowLabel.numberOfLines = 1
        eyebrowLabel.textAlignment = .left

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        detailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        detailLabel.textColor = SGColor.primaryDark
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byWordWrapping

        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually

        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryTapped), for: .touchUpInside)

        contentStackView.addArrangedSubview(eyebrowLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(detailLabel)
        contentStackView.addArrangedSubview(buttonStackView)

        buttonStackView.addArrangedSubview(primaryButton)
        buttonStackView.addArrangedSubview(secondaryButton)

        cardView.contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        primaryButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        secondaryButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }

    private func updateAppearance(for state: State) {
        eyebrowLabel.text = state.badgeTitle
        switch state {
        case .todayNotConfirmed:
            eyebrowLabel.textColor = SGColor.primaryDark
            titleLabel.textColor = SGColor.textDark
        case .todayConfirmed:
            eyebrowLabel.textColor = SGColor.primaryDark
            titleLabel.textColor = SGColor.primaryDark
        case .yesterdayPending:
            eyebrowLabel.textColor = SGColor.primaryDark
            titleLabel.textColor = SGColor.textDark
        }
    }

    @objc private func handlePrimaryTapped() {
        onPrimaryAction?()
    }

    @objc private func handleSecondaryTapped() {
        onSecondaryAction?()
    }
}
