//
//  SGPlantReviewCardView.swift
//  SoberGarden
//

import UIKit

final class SGPlantReviewCardView: UIView {

    enum ReviewType: String {
        case totalPlanted7 = "total_planted_7"
        case totalPlanted30 = "total_planted_30"

        var title: String {
            switch self {
            case .totalPlanted7:
                return "dailyPlant.review.7.title".localized()
            case .totalPlanted30:
                return "dailyPlant.review.30.title".localized()
            }
        }
    }

    var onDismiss: (() -> Void)?

    private let cardView = SGCardView()
    private let contentStackView = UIStackView()
    private let iconContainerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let keepGrowingButton = UIButton(type: .system)
    private var reviewType: ReviewType?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(reviewType: ReviewType?) {
        self.reviewType = reviewType

        guard let reviewType else {
            isHidden = true
            return
        }

        isHidden = false
        titleLabel.text = reviewType.title
        accessibilityLabel = reviewType.title
    }

    private func setupView() {
        isAccessibilityElement = false

        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#F7FBF3")

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 14
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

        iconContainerView.backgroundColor = SGColor.primary.withAlphaComponent(0.18)
        iconContainerView.layer.cornerRadius = 18
        iconContainerView.layer.masksToBounds = true

        iconView.image = UIImage(systemName: "leaf.circle.fill")
        iconView.tintColor = SGColor.primary
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = .staticText

        keepGrowingButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        keepGrowingButton.setTitle("dailyPlant.review.keepGrowing".localized(), for: .normal)
        keepGrowingButton.setTitleColor(SGColor.primaryDark, for: .normal)
        keepGrowingButton.contentHorizontalAlignment = .left
        keepGrowingButton.addTarget(self, action: #selector(handleKeepGrowingTapped), for: .touchUpInside)

        addSubview(cardView)
        cardView.contentView.addSubview(contentStackView)
        iconContainerView.addSubview(iconView)

        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(keepGrowingButton)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.size.equalTo(36)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }

        keepGrowingButton.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(36)
        }

        isHidden = true
    }

    @objc private func handleKeepGrowingTapped() {
        onDismiss?()
    }
}
