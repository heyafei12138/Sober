//
//  SGCardView.swift
//  SoberGarden
//

import UIKit

final class SGCardView: UIView {

    let contentView = UIView()

    var cornerRadius: CGFloat = 20 {
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
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 8)

        contentView.backgroundColor = SGColor.surface
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
    }
}
