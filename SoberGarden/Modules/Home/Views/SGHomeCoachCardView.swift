//
//  SGHomeCoachCardView.swift
//  SoberGarden
//

import UIKit

final class SGHomeCoachCardView: UIView {

    private let cardView = SGCardView()
    private let accentBar = UIView()
    private let iconPlaceholder = SGIllustrationPlaceholderView()
    private let titleLabel = UILabel()
    private let promptLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(prompt: String) {
        promptLabel.text = prompt
    }

    private func setupView() {
        cardView.cornerRadius = 20
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = SGColor.coachTint

        accentBar.backgroundColor = SGColor.primary
        accentBar.layer.cornerRadius = 2

        titleLabel.text = "CALM COACH"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = SGColor.primaryDark

        promptLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        promptLabel.textColor = SGColor.textDark
        promptLabel.numberOfLines = 0
        promptLabel.lineBreakMode = .byWordWrapping

        iconPlaceholder.configure(
            assetName: "home_calm_coach_icon",
            placeholderText: "Coach",
            tintColor: SGColor.primaryLight
        )

        addSubview(cardView)
        cardView.contentView.addSubview(accentBar)
        cardView.contentView.addSubview(iconPlaceholder)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(promptLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        accentBar.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        iconPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(SGHomeLayout.cardPadding.top)
            make.left.equalTo(accentBar.snp.right).offset(16)
            make.size.equalTo(SGHomeLayout.coachIconSize)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconPlaceholder)
            make.left.equalTo(iconPlaceholder.snp.right).offset(14)
            make.right.equalToSuperview().inset(SGHomeLayout.cardPadding.right)
        }

        promptLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(SGHomeLayout.blockSpacing)
            make.left.equalTo(iconPlaceholder.snp.right).offset(14)
            make.right.equalToSuperview().inset(SGHomeLayout.cardPadding.right)
            make.bottom.equalToSuperview().inset(SGHomeLayout.cardPadding.bottom)
        }
    }
}
