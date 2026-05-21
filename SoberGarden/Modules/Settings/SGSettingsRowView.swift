//
//  SGSettingsRowView.swift
//  SoberGarden
//

import UIKit

final class SGSettingsRowView: UIControl {

    enum Accessory {
        case none
        case disclosure
        case toggle(Bool)
    }

    var onTap: (() -> Void)?
    var onToggleChanged: ((Bool) -> Void)?

    private let containerView = UIView()
    private let contentStackView = UIStackView()
    private let leadingStackView = UIStackView()
    private let trailingStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let toggleSwitch = UISwitch()
    private let separatorView = UIView()

    private var accessory: Accessory = .none
    private var isDestructiveRow = false

    var showsSeparator: Bool = true {
        didSet {
            separatorView.isHidden = !showsSeparator
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

    func configure(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        accessory: Accessory = .disclosure,
        isDestructive: Bool = false
    ) {
        self.accessory = accessory
        self.isDestructiveRow = isDestructive

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true

        valueLabel.text = value
        valueLabel.isHidden = value?.isEmpty ?? true

        let titleColor = isDestructive ? UIColor.systemRed : SGColor.textDark
        let subtitleColor = isDestructive ? UIColor.systemRed.withAlphaComponent(0.72) : SGColor.textSecondary
        let valueColor = isDestructive ? UIColor.systemRed : SGColor.textSecondary
        let chevronColor = isDestructive ? UIColor.systemRed : SGColor.textTertiary

        titleLabel.textColor = titleColor
        subtitleLabel.textColor = subtitleColor
        valueLabel.textColor = valueColor
        chevronImageView.tintColor = chevronColor
        toggleSwitch.onTintColor = isDestructive ? UIColor.systemRed : SGColor.primaryDark

        updateAccessory()
        updateAccessibility()
    }

    func setToggleState(_ isOn: Bool, animated: Bool = false) {
        guard case .toggle = accessory else { return }
        toggleSwitch.setOn(isOn, animated: animated)
    }

    override func accessibilityActivate() -> Bool {
        handleTap()
        return true
    }

    private func setupView() {
        backgroundColor = .clear
        isAccessibilityElement = true

        containerView.backgroundColor = .clear
        containerView.isUserInteractionEnabled = false

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 12

        leadingStackView.axis = .vertical
        leadingStackView.alignment = .fill
        leadingStackView.spacing = 4

        trailingStackView.axis = .horizontal
        trailingStackView.alignment = .center
        trailingStackView.spacing = 8

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.numberOfLines = 0

        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 1

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.contentMode = .scaleAspectFit

        toggleSwitch.addTarget(self, action: #selector(handleToggleChanged(_:)), for: .valueChanged)

        separatorView.backgroundColor = SGColor.separator.withAlphaComponent(0.8)

        addSubview(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(separatorView)

        contentStackView.addArrangedSubview(leadingStackView)
        contentStackView.addArrangedSubview(trailingStackView)

        leadingStackView.addArrangedSubview(titleLabel)
        leadingStackView.addArrangedSubview(subtitleLabel)

        trailingStackView.addArrangedSubview(valueLabel)
        trailingStackView.addArrangedSubview(chevronImageView)
        trailingStackView.addArrangedSubview(toggleSwitch)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.left.right.equalToSuperview().inset(16)
        }

        separatorView.snp.makeConstraints { make in
            make.left.equalTo(contentStackView.snp.left)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        chevronImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 10, height: 16))
        }

        toggleSwitch.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(51)
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        showsSeparator = true
        updateAccessory()
        updateAccessibility()
    }

    private func updateAccessory() {
        switch accessory {
        case .none:
            trailingStackView.isHidden = valueLabel.text?.isEmpty ?? true
            valueLabel.isHidden = valueLabel.text?.isEmpty ?? true
            chevronImageView.isHidden = true
            toggleSwitch.isHidden = true
        case .disclosure:
            trailingStackView.isHidden = false
            valueLabel.isHidden = valueLabel.text?.isEmpty ?? true
            chevronImageView.isHidden = false
            toggleSwitch.isHidden = true
        case .toggle(let isOn):
            trailingStackView.isHidden = false
            valueLabel.isHidden = true
            toggleSwitch.isHidden = false
            toggleSwitch.setOn(isOn, animated: false)
            chevronImageView.isHidden = true
        }
        updateAccessibility()
    }

    private func updateAccessibility() {
        let parts = [
            titleLabel.text,
            subtitleLabel.isHidden ? nil : subtitleLabel.text,
            valueLabel.isHidden ? nil : valueLabel.text
        ].compactMap { $0 }.filter { !$0.isEmpty }

        accessibilityLabel = parts.joined(separator: ", ")
        switch accessory {
        case .toggle:
            accessibilityTraits = [.button]
            accessibilityValue = toggleSwitch.isOn ? "On" : "Off"
        case .disclosure:
            accessibilityTraits = [.button]
            accessibilityValue = nil
        case .none:
            accessibilityTraits = []
            accessibilityValue = nil
        }
    }

    @objc private func handleTap() {
        guard isEnabled else { return }

        switch accessory {
        case .toggle:
            let next = !toggleSwitch.isOn
            toggleSwitch.setOn(next, animated: true)
            onToggleChanged?(next)
            updateAccessibility()
        case .disclosure, .none:
            onTap?()
        }
    }

    @objc private func handleToggleChanged(_ sender: UISwitch) {
        onToggleChanged?(sender.isOn)
    }
}
