//
//  SGCardView.swift
//  SoberGarden
//

import UIKit

final class SGCardView: UIView {

    let contentView = UIView()

    var cornerRadius: CGFloat = 16 {
        didSet {
            layer.cornerRadius = cornerRadius
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setContentInsets(_ insets: UIEdgeInsets) {
        contentView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }
    }

    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = cornerRadius
        layer.shadowColor = SGColor.softShadow.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.backgroundColor = SGColor.surface
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18))
        }
    }
}
