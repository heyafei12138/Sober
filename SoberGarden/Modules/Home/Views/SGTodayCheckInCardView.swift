//
//  SGTodayCheckInCardView.swift
//  SoberGarden
//

import UIKit

final class SGTodayCheckInCardView: UIView {

    enum State {
        case todayEmpty
        case todayPlanted
        case todayRainy
        case yesterdayPending

        var badgeTitle: String {
            "dailyPlant.card.badge".localized()
        }

        var title: String {
            switch self {
            case .todayEmpty:
                return "dailyPlant.card.empty.title".localized()
            case .todayPlanted:
                return "dailyPlant.card.planted.title".localized()
            case .todayRainy:
                return "dailyPlant.card.rainy.title".localized()
            case .yesterdayPending:
                return "checkin.card.yesterday.title".localized()
            }
        }

        var subtitle: String {
            switch self {
            case .todayEmpty:
                return "dailyPlant.card.empty.subtitle".localized()
            case .todayPlanted:
                return "dailyPlant.card.planted.subtitle".localized()
            case .todayRainy:
                return "dailyPlant.card.rainy.subtitle".localized()
            case .yesterdayPending:
                return "checkin.card.yesterday.subtitle".localized()
            }
        }

        var detail: String? {
            switch self {
            case .todayEmpty:
                return nil
            case .todayPlanted:
                return nil
            case .todayRainy:
                return nil
            case .yesterdayPending:
                return nil
            }
        }

        var primaryButtonTitle: String? {
            switch self {
            case .todayEmpty:
                return "dailyPlant.card.empty.primary".localized()
            case .todayPlanted:
                return "dailyPlant.card.planted.status".localized()
            case .todayRainy:
                return nil
            case .yesterdayPending:
                return "checkin.card.yesterday.primary".localized()
            }
        }

        var isPrimaryButtonEnabled: Bool {
            switch self {
            case .todayEmpty, .yesterdayPending:
                return true
            case .todayPlanted, .todayRainy:
                return false
            }
        }

        var secondaryButtonTitle: String? {
            switch self {
            case .todayEmpty:
                return "dailyPlant.card.empty.secondary".localized()
            case .yesterdayPending:
                return "checkin.card.yesterday.secondary".localized()
            case .todayPlanted, .todayRainy:
                return nil
            }
        }

        var editButtonTitle: String? {
            switch self {
            case .todayPlanted, .todayRainy:
                return "dailyPlant.card.editToday".localized()
            case .todayEmpty, .yesterdayPending:
                return nil
            }
        }
    }

    var onPrimaryAction: (() -> Void)?
    var onSecondaryAction: (() -> Void)?
    var onEditAction: (() -> Void)?

    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let detailLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let primaryButton = SGPrimaryButton(title: "common.continue".localized())
    private let secondaryButton = SGPrimaryButton(title: "common.imStruggling".localized(), style: .secondary)
    private let editButton = UIButton(type: .system)

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
            primaryButton.isEnabled = state.isPrimaryButtonEnabled
        } else {
            primaryButton.isHidden = true
            primaryButton.isEnabled = false
        }

        if let secondaryTitle = state.secondaryButtonTitle {
            secondaryButton.setTitle(secondaryTitle, for: .normal)
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }

        if let editTitle = state.editButtonTitle {
            editButton.setTitle(editTitle, for: .normal)
            editButton.isHidden = false
        } else {
            editButton.isHidden = true
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

        editButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        editButton.setTitleColor(SGColor.primaryDark, for: .normal)
        editButton.contentHorizontalAlignment = .left

        primaryButton.addTarget(self, action: #selector(handlePrimaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(handleEditTapped), for: .touchUpInside)

        contentStackView.addArrangedSubview(eyebrowLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(detailLabel)
        contentStackView.addArrangedSubview(buttonStackView)
        contentStackView.addArrangedSubview(editButton)

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
        case .todayEmpty:
            eyebrowLabel.textColor = SGColor.primaryDark
            titleLabel.textColor = SGColor.textDark
        case .todayPlanted:
            eyebrowLabel.textColor = SGColor.primaryDark
            titleLabel.textColor = SGColor.primaryDark
        case .todayRainy, .yesterdayPending:
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

    @objc private func handleEditTapped() {
        onEditAction?()
    }
}
