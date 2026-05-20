//
//  SGIllustrationPlaceholderView.swift
//  SoberGarden
//

import UIKit

/// 插画/图标占位：有素材时显示图片，无素材时显示虚线框与提示文案
final class SGIllustrationPlaceholderView: UIView {

    private let imageView = UIImageView()
    private let placeholderContainer = UIView()
    private let placeholderIcon = UIImageView()
    private let placeholderLabel = UILabel()

    var assetName: String? {
        didSet { reloadAsset() }
    }

    var placeholderText: String = "Asset" {
        didSet { placeholderLabel.text = placeholderText }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(assetName: String?, placeholderText: String, tintColor: UIColor = SGColor.primaryLight) {
        self.assetName = assetName
        self.placeholderText = placeholderText
        placeholderContainer.backgroundColor = tintColor.withAlphaComponent(0.65)
        reloadAsset()
    }

    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 18

        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        placeholderContainer.layer.cornerRadius = 18
        placeholderContainer.layer.borderWidth = 1
        placeholderContainer.layer.borderColor = SGColor.primary.withAlphaComponent(0.28).cgColor
        addSubview(placeholderContainer)

        placeholderIcon.image = UIImage(systemName: "photo")
        placeholderIcon.tintColor = SGColor.primaryDark.withAlphaComponent(0.55)
        placeholderIcon.contentMode = .scaleAspectFit

        placeholderLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        placeholderLabel.textColor = SGColor.textTertiary
        placeholderLabel.textAlignment = .center
        placeholderLabel.numberOfLines = 2
        placeholderLabel.text = placeholderText

        placeholderContainer.addSubview(placeholderIcon)
        placeholderContainer.addSubview(placeholderLabel)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        placeholderContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        placeholderIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
            make.size.equalTo(22)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(placeholderIcon.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(6)
        }
    }

    private func reloadAsset() {
        if let assetName, let image = UIImage(named: assetName) {
            imageView.image = image
            imageView.isHidden = false
            placeholderContainer.isHidden = true
        } else {
            imageView.image = nil
            imageView.isHidden = true
            placeholderContainer.isHidden = false
        }
    }
}
