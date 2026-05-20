//
//  SGGardenPreviewView.swift
//  SoberGarden
//

import UIKit

final class SGGardenPreviewView: UIControl {

    var onTap: (() -> Void)?

    private let cardView = SGCardView()
    private let illustrationView = SGIllustrationPlaceholderView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let badgePill = UIView()
    private let badgeLabel = UILabel()
    private let chevronView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(gardenStage: GardenStage, nextMilestone: Milestone?, cleanDays: Int, habitName: String) {
        titleLabel.text = gardenStage.title
        badgeLabel.text = "\(cleanDays) days clean"

        if let nextMilestone {
            let remaining = max(nextMilestone.day - cleanDays, 0)
            subtitleLabel.text = remaining == 0
                ? "You are ready for the next bloom."
                : "Next bloom in \(remaining) days"
        } else {
            subtitleLabel.text = "Your garden is fully grown."
        }

        illustrationView.configure(
            assetName: Self.assetName(for: gardenStage),
            placeholderText: gardenStage.title,
            tintColor: SGColor.primaryLight
        )
        accessibilityLabel = "Garden preview for \(habitName)"
    }

    private func setupView() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        cardView.cornerRadius = 20
        cardView.setContentInsets(SGHomeLayout.cardPadding)

        badgePill.backgroundColor = SGColor.primaryLight
        badgePill.layer.cornerRadius = 10

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        badgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        badgeLabel.textColor = SGColor.primaryDark

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = SGColor.textTertiary
        chevronView.contentMode = .scaleAspectFit

        addSubview(cardView)
        cardView.isUserInteractionEnabled = false
        cardView.contentView.addSubview(illustrationView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(badgePill)
        badgePill.addSubview(badgeLabel)
        cardView.contentView.addSubview(chevronView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(120)
        }

        illustrationView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(SGHomeLayout.illustrationSize.width)
            make.height.equalTo(SGHomeLayout.illustrationSize.height)
        }

        chevronView.snp.makeConstraints { make in
            make.centerY.equalTo(illustrationView)
            make.right.equalToSuperview()
            make.size.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(illustrationView.snp.right).offset(16)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        badgePill.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview()
        }

        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
    }

    @objc private func handleTap() {
        onTap?()
    }

    private static func assetName(for stage: GardenStage) -> String {
        switch stage {
        case .seed: return "garden_stage_seed"
        case .sprout: return "garden_stage_sprout"
        case .youngPlant: return "guider_icon_tree"
        case .flower: return "guider_icon_singleFlower"
        case .gardenBed: return "garden_stage_garden_bed"
        case .bloomingGarden: return "guider_icon_flower"
        case .peacefulGarden: return "guider_icon_grass"
        case .smallForest: return "garden_stage_forest"
        case .sanctuary: return "garden_stage_sanctuary"
        }
    }
}
