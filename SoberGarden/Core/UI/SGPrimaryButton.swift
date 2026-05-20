//
//  SGPrimaryButton.swift
//  SoberGarden
//

import UIKit

final class SGPrimaryButton: UIButton {

    enum Style {
        case primary
        case rescue
        case secondary
    }

    private let buttonStyle: Style

    init(title: String, style: Style = .primary) {
        self.buttonStyle = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupButton()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        self.buttonStyle = .primary
        super.init(coder: coder)
        setupButton()
        updateAppearance()
    }

    override var isEnabled: Bool {
        didSet { updateAppearance() }
    }

    override var isHighlighted: Bool {
        didSet { updateAppearance() }
    }

    private func setupButton() {
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 18
        layer.masksToBounds = true
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(54)
        }
    }

    private func updateAppearance() {
        let colors = resolvedColors()
        backgroundColor = isEnabled ? colors.background : colors.background.withAlphaComponent(0.35)
        setTitleColor(isEnabled ? colors.title : colors.title.withAlphaComponent(0.45), for: .normal)
        alpha = isHighlighted ? 0.86 : 1
    }

    private func resolvedColors() -> (background: UIColor, title: UIColor) {
        switch buttonStyle {
        case .primary:
            return (SGColor.primaryDark, .white)
        case .rescue:
            return (SGColor.rescue, .white)
        case .secondary:
            return (SGColor.primaryLight, SGColor.textDark)
        }
    }
}
