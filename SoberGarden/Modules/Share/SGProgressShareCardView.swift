//
//  SGProgressShareCardView.swift
//  SoberGarden
//

import UIKit

final class SGProgressShareCardView: UIView {

    struct Content {
        let cleanDays: Int
        let savedMoneyText: String
        let gardenStage: GardenStage
        let habitName: String
    }

    private let backgroundGradientLayer = CAGradientLayer()
    private let appNameLabel = UILabel()
    private let headlineLabel = UILabel()
    private let dayCountLabel = UILabel()
    private let dayCaptionLabel = UILabel()
    private let stageImageBackgroundView = UIView()
    private let stageImageView = UIImageView()
    private let statsStackView = UIStackView()
    private let moneyStatView = SGShareStatView()
    private let stageStatView = SGShareStatView()
    private let footerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = bounds
    }

    func configure(with content: Content) {
        headlineLabel.text = "I'm growing one clean day at a time."
        dayCountLabel.text = "\(content.cleanDays)"
        dayCaptionLabel.text = content.cleanDays == 1 ? "day clean from \(content.habitName)" : "days clean from \(content.habitName)"
        moneyStatView.configure(title: "Saved", value: content.savedMoneyText)
        stageStatView.configure(title: "Garden", value: content.gardenStage.title)
        stageImageView.image = UIImage(named: Self.assetName(for: content.gardenStage))
        footerLabel.text = "SoberGarden"
    }

    private func setupView() {
        backgroundColor = SGColor.background
        layer.cornerRadius = 28
        layer.masksToBounds = true

        backgroundGradientLayer.colors = [
            UIColor.hexString("#FFF8E8").cgColor,
            UIColor.hexString("#EEF5E9").cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.12, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.9, y: 1)
        layer.insertSublayer(backgroundGradientLayer, at: 0)

        appNameLabel.text = "SoberGarden"
        appNameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        appNameLabel.textColor = SGColor.primaryDark

        headlineLabel.font = .systemFont(ofSize: 30, weight: .bold)
        headlineLabel.textColor = SGColor.textDark
        headlineLabel.numberOfLines = 0

        dayCountLabel.font = .monospacedDigitSystemFont(ofSize: 88, weight: .bold)
        dayCountLabel.textColor = SGColor.textDark
        dayCountLabel.textAlignment = .center
        dayCountLabel.adjustsFontSizeToFitWidth = true
        dayCountLabel.minimumScaleFactor = 0.62

        dayCaptionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        dayCaptionLabel.textColor = SGColor.textSecondary
        dayCaptionLabel.textAlignment = .center
        dayCaptionLabel.numberOfLines = 2
        dayCaptionLabel.adjustsFontSizeToFitWidth = true
        dayCaptionLabel.minimumScaleFactor = 0.78

        stageImageBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.52)
        stageImageBackgroundView.layer.cornerRadius = 34
        stageImageBackgroundView.layer.masksToBounds = true

        stageImageView.contentMode = .scaleAspectFit

        statsStackView.axis = .horizontal
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 14

        footerLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        footerLabel.textColor = SGColor.primaryDark
        footerLabel.textAlignment = .center

        addSubview(appNameLabel)
        addSubview(headlineLabel)
        addSubview(stageImageBackgroundView)
        stageImageBackgroundView.addSubview(stageImageView)
        addSubview(dayCountLabel)
        addSubview(dayCaptionLabel)
        addSubview(statsStackView)
        statsStackView.addArrangedSubview(moneyStatView)
        statsStackView.addArrangedSubview(stageStatView)
        addSubview(footerLabel)

        appNameLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(30)
        }

        headlineLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(30)
        }

        stageImageBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(164)
        }

        stageImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(22)
        }

        dayCountLabel.snp.makeConstraints { make in
            make.top.equalTo(stageImageBackgroundView.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(30)
        }

        dayCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dayCountLabel.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(34)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(dayCaptionLabel.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(26)
            make.height.equalTo(86)
        }

        footerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(26)
        }
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

private final class SGShareStatView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.64)
        layer.cornerRadius = 18
        layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.textAlignment = .center

        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 2
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
    }
}
