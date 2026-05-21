//
//  SGGardenIllustrationView.swift
//  SoberGarden
//

import UIKit

final class SGGardenIllustrationView: UIView {

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(stage: GardenStage) {
        imageView.image = UIImage(named: stage.gardenImageName)
    }

    private func setupView() {
        backgroundColor = .clear
        isOpaque = false

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
    }
}

private extension GardenStage {

    var gardenImageName: String {
        switch self {
        case .seed:
            return "Day1"
        case .sprout:
            return "Day3"
        case .youngPlant:
            return "Day7"
        case .flower:
            return "Day14"
        case .gardenBed:
            return "Day30"
        case .bloomingGarden:
            return "Day60"
        case .peacefulGarden:
            return "Day90"
        case .smallForest:
            return "Day180"
        case .sanctuary:
            return "Day365"
        }
    }
}
