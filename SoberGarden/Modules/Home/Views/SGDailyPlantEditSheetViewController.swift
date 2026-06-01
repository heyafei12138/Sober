//
//  SGDailyPlantEditSheetViewController.swift
//  SoberGarden
//

import UIKit

final class SGDailyPlantEditSheetViewController: UIViewController {

    enum Action {
        case planted
        case rainy
        case clear
    }

    private struct Option {
        let action: Action
        let title: String
        let subtitle: String
        let iconName: String
        let isDestructive: Bool
    }

    private let currentStatus: DailyRecordStatus
    private let onSelect: (Action) -> Void
    private let options: [Option] = [
        Option(
            action: .planted,
            title: "dailyPlant.card.planted.status".localized(),
            subtitle: "dailyPlant.editToday.plantedHint".localized(),
            iconName: "leaf.fill",
            isDestructive: false
        ),
        Option(
            action: .rainy,
            title: "dailyPlant.editToday.rainyDay".localized(),
            subtitle: "dailyPlant.editToday.rainyHint".localized(),
            iconName: "cloud.rain.fill",
            isDestructive: false
        ),
        Option(
            action: .clear,
            title: "dailyPlant.editToday.clearRecord".localized(),
            subtitle: "dailyPlant.editToday.clearHint".localized(),
            iconName: "trash.fill",
            isDestructive: true
        )
    ]

    private let dimmingView = UIView()
    private let sheetView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let optionsStackView = UIStackView()

    init(currentStatus: DailyRecordStatus, onSelect: @escaping (Action) -> Void) {
        self.currentStatus = currentStatus
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        buildOptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dimmingView.alpha = 0
        sheetView.transform = CGAffineTransform(translationX: 0, y: 28)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
            self.dimmingView.alpha = 1
            self.sheetView.transform = .identity
        }
    }

    private func setupView() {
        view.backgroundColor = .clear

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCloseTapped)))

        sheetView.backgroundColor = UIColor.hexString("#FBFDF8")
        sheetView.layer.cornerRadius = 28
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.layer.shadowColor = UIColor.black.cgColor
        sheetView.layer.shadowOpacity = 0.14
        sheetView.layer.shadowRadius = 24
        sheetView.layer.shadowOffset = CGSize(width: 0, height: -8)

        handleView.backgroundColor = UIColor.hexString("#D9DEDA")
        handleView.layer.cornerRadius = 2

        titleLabel.text = "dailyPlant.editToday.title".localized()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = "dailyPlant.editToday.subtitle".localized()
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0

        var closeConfiguration = UIButton.Configuration.plain()
        closeConfiguration.image = UIImage(systemName: "xmark")
        closeConfiguration.baseForegroundColor = SGColor.textSecondary
        closeConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        closeButton.configuration = closeConfiguration
        closeButton.accessibilityLabel = "common.close".localized()
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)

        optionsStackView.axis = .vertical
        optionsStackView.alignment = .fill
        optionsStackView.distribution = .fill
        optionsStackView.spacing = 10

        view.addSubview(dimmingView)
        view.addSubview(sheetView)
        sheetView.addSubview(handleView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(subtitleLabel)
        sheetView.addSubview(closeButton)
        sheetView.addSubview(optionsStackView)

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sheetView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.48)
        }

        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(42)
            make.height.equalTo(4)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-18)
            make.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(22)
            make.right.lessThanOrEqualTo(closeButton.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(22)
        }

        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(22)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    private func buildOptions() {
        options.forEach { option in
            let row = EditOptionRowView()
            row.configure(
                title: option.title,
                subtitle: option.subtitle,
                iconName: option.iconName,
                isSelected: isSelected(option.action),
                isDestructive: option.isDestructive
            )
            row.onTap = { [weak self] in
                self?.select(option.action)
            }
            optionsStackView.addArrangedSubview(row)
        }
    }

    private func isSelected(_ action: Action) -> Bool {
        switch (action, currentStatus) {
        case (.planted, .planted), (.rainy, .rainy):
            return true
        case (.clear, _):
            return false
        default:
            return false
        }
    }

    private func select(_ action: Action) {
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn]) {
            self.dimmingView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 28)
        } completion: { _ in
            self.dismiss(animated: false) {
                self.onSelect(action)
            }
        }
    }

    @objc private func handleCloseTapped() {
        dismiss(animated: true)
    }
}

private final class EditOptionRowView: UIControl {

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkImageView = UIImageView()
    var onTap: (() -> Void)?

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
        subtitle: String,
        iconName: String,
        isSelected: Bool,
        isDestructive: Bool
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: iconName)
        checkImageView.isHidden = isSelected == false

        let foregroundColor = isDestructive ? UIColor.systemRed : SGColor.primaryDark
        let selectedBorderColor = isDestructive ? UIColor.systemRed.withAlphaComponent(0.35) : UIColor.hexString("#A8D7A8")
        titleLabel.textColor = isDestructive ? UIColor.systemRed : SGColor.textDark
        subtitleLabel.textColor = SGColor.textSecondary
        iconImageView.tintColor = foregroundColor
        iconContainerView.backgroundColor = isDestructive ? UIColor.systemRed.withAlphaComponent(0.10) : UIColor.hexString("#EEF6EC")
        backgroundColor = isSelected ? UIColor.hexString("#EEF6EC") : .white
        layer.borderColor = (isSelected ? selectedBorderColor : UIColor.hexString("#E4E9E2")).cgColor

        accessibilityLabel = "\(title), \(subtitle)"
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }

    private func setupView() {
        layer.cornerRadius = 16
        layer.borderWidth = 1
        isAccessibilityElement = true

        iconContainerView.layer.cornerRadius = 16
        iconContainerView.isAccessibilityElement = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isAccessibilityElement = false

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.isAccessibilityElement = false

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.isAccessibilityElement = false

        checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkImageView.tintColor = SGColor.primary
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isAccessibilityElement = false

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(checkImageView)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(66)
        }

        iconContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(iconContainerView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(-12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-14)
            make.size.equalTo(20)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
