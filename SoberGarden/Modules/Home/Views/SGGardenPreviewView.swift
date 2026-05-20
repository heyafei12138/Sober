//
//  SGGardenPreviewView.swift
//  SoberGarden
//

import UIKit

final class SGGardenPreviewView: UIControl {

    var onTap: (() -> Void)?

    private let cardView = SGCardView()
    private let illustrationBackgroundView = UIView()
    private let illustrationView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let badgeLabel = UILabel()
    private let badgeContainerView = UIView()
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
            subtitleLabel.text = remaining == 0 ? "You are ready for the next bloom." : "Next bloom in \(remaining) days"
        } else {
            subtitleLabel.text = "Your garden is fully grown."
        }

        illustrationView.image = UIImage(named: Self.assetName(for: gardenStage))
        accessibilityLabel = "Garden preview for \(habitName)"
    }

    private func setupView() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#F6FAF7")

        illustrationBackgroundView.backgroundColor = UIColor.hexString("#E5F0EC")
        illustrationBackgroundView.layer.cornerRadius = 20
        illustrationBackgroundView.layer.masksToBounds = true

        illustrationView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 23, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        badgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        badgeLabel.textColor = SGColor.primaryDark

        badgeContainerView.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.62)
        badgeContainerView.layer.cornerRadius = 13
        badgeContainerView.layer.masksToBounds = true

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = SGColor.textTertiary
        chevronView.contentMode = .scaleAspectFit

        addSubview(cardView)
        cardView.isUserInteractionEnabled = false
        cardView.contentView.addSubview(illustrationBackgroundView)
        illustrationBackgroundView.addSubview(illustrationView)
        cardView.contentView.addSubview(titleLabel)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(badgeContainerView)
        badgeContainerView.addSubview(badgeLabel)
        cardView.contentView.addSubview(chevronView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        illustrationBackgroundView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(16)
            make.width.equalTo(116)
        }

        illustrationView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        chevronView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(illustrationBackgroundView.snp.right).offset(16)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        badgeContainerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.left.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
            make.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }

        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
        }
    }

    @objc private func handleTap() {
        onTap?()
    }

    private static func assetName(for stage: GardenStage) -> String {
        switch stage {
        case .seed:
            return "guider_icon_flowerpot"
        case .sprout:
            return "guider_icon_tree1"
        case .youngPlant:
            return "guider_icon_tree"
        case .flower:
            return "guider_icon_singleFlower"
        case .gardenBed:
            return "guider_icon_flower1"
        case .bloomingGarden:
            return "guider_icon_flower"
        case .peacefulGarden:
            return "guider_icon_grass"
        case .smallForest:
            return "guider_icon_tree1"
        case .sanctuary:
            return "guider_icon_tree"
        }
    }
}
