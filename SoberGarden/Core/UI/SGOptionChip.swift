//
//  SGOptionChip.swift
//  SoberGarden
//

import UIKit

final class SGOptionChip: UIControl {

    private let titleLabel = UILabel()

    var title: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override var isHighlighted: Bool {
        didSet { updateAppearance() }
    }

    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    init(title: String) {
        super.init(frame: .zero)
        self.title = title
        setupView()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateAppearance()
    }

    private func setupView() {
        isAccessibilityElement = true
        accessibilityTraits = [.button]
        layer.cornerRadius = 12
        layer.borderWidth = 1

        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func updateAppearance() {
        let selectedBackground = SGColor.primaryLight
        let normalBackground = SGColor.surface
        backgroundColor = isSelected ? selectedBackground : normalBackground
        layer.borderColor = (isSelected ? SGColor.primary : SGColor.separator).cgColor
        titleLabel.textColor = isEnabled ? SGColor.textDark : SGColor.textTertiary
        alpha = isHighlighted ? 0.72 : (isEnabled ? 1 : 0.55)
        accessibilityLabel = title
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
}
