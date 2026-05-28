//
//  SGMilestoneCardView.swift
//  SoberGarden
//

import UIKit

final class SGMilestoneCardView: UIView {

    private let cardView = SGCardView()
    private let headerLabel = UILabel()
    private let milestoneLabel = UILabel()
    private let countdownLabel = UILabel()
    private let progressBar = SGProgressBarView()
    private let badgeLabel = UILabel()
    private let badgeContainerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(cleanDays: Int, nextMilestone: Milestone?) {
        headerLabel.text = "home.milestone.header".localized()

        if let nextMilestone {
            let remaining = max(nextMilestone.day - cleanDays, 0)
            milestoneLabel.text = "home.milestone.nextFormat".localizedFormat(nextMilestone.day)
            countdownLabel.text = remaining == 0 ? "home.milestone.madeIt".localized() : "home.milestone.daysToGoFormat".localizedFormat(remaining)
            badgeLabel.text = nextMilestone.badgeName
            progressBar.setProgress(CGFloat(cleanDays) / CGFloat(nextMilestone.day), animated: false)
        } else {
            milestoneLabel.text = "home.milestone.allReached".localized()
            countdownLabel.text = "home.milestone.keepGrowing".localized()
            badgeLabel.text = GardenStage.sanctuary.title
            progressBar.setProgress(1, animated: false)
        }
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#F8FBF1")

        headerLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        headerLabel.textColor = SGColor.textDark

        milestoneLabel.font = .systemFont(ofSize: 23, weight: .bold)
        milestoneLabel.textColor = SGColor.textDark
        milestoneLabel.numberOfLines = 2

        countdownLabel.font = .systemFont(ofSize: 14, weight: .medium)
        countdownLabel.textColor = SGColor.textSecondary

        badgeLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        badgeLabel.textColor = SGColor.primaryDark
        badgeLabel.numberOfLines = 1

        badgeContainerView.backgroundColor = SGColor.flower.withAlphaComponent(0.28)
        badgeContainerView.layer.cornerRadius = 14
        badgeContainerView.layer.masksToBounds = true

        addSubview(cardView)
        cardView.contentView.addSubview(headerLabel)
        cardView.contentView.addSubview(milestoneLabel)
        cardView.contentView.addSubview(countdownLabel)
        cardView.contentView.addSubview(progressBar)
        cardView.contentView.addSubview(badgeContainerView)
        badgeContainerView.addSubview(badgeLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        milestoneLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(18)
        }

        countdownLabel.snp.makeConstraints { make in
            make.top.equalTo(milestoneLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(18)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(countdownLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(10)
        }

        badgeContainerView.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(10)
            make.left.bottom.equalToSuperview().inset(18)
            make.right.lessThanOrEqualToSuperview().inset(18)
        }

        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        }
    }
}
