//
//  SGDailyGardenRangeSheetViewController.swift
//  SoberGarden
//

import UIKit

final class SGDailyGardenRangeSheetViewController: UIViewController {

    struct Option: Equatable {
        let days: Int?
        let title: String
    }

    private let options: [Option]
    private let selectedDays: Int
    private let isAutomatic: Bool
    private let onSelect: (Int?) -> Void

    private let dimmingView = UIView()
    private let sheetView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let optionsStackView = UIStackView()

    init(
        options: [Option],
        selectedDays: Int,
        isAutomatic: Bool,
        onSelect: @escaping (Int?) -> Void
    ) {
        self.options = options
        self.selectedDays = selectedDays
        self.isAutomatic = isAutomatic
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

        titleLabel.text = "home.dailyGardenGrid.rangeSelector.title".localized()
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = "home.dailyGardenGrid.rangeSelector.subtitle".localized()
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
        optionsStackView.spacing = 8

        view.addSubview(dimmingView)
        view.addSubview(sheetView)
        sheetView.addSubview(handleView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(subtitleLabel)
        sheetView.addSubview(closeButton)
        sheetView.addSubview(scrollView)
        scrollView.addSubview(optionsStackView)

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sheetView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.58)
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

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        optionsStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-44)
        }
    }

    private func buildOptions() {
        options.forEach { option in
            let row = OptionRowView()
            row.configure(
                title: option.title,
                isSelected: isSelected(option),
                isAutomatic: option.days == nil
            )
            row.onTap = { [weak self] in
                self?.select(option)
            }
            optionsStackView.addArrangedSubview(row)
        }
    }

    private func isSelected(_ option: Option) -> Bool {
        switch option.days {
        case nil:
            return isAutomatic
        case let days?:
            return isAutomatic == false && days == selectedDays
        }
    }

    private func select(_ option: Option) {
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn]) {
            self.dimmingView.alpha = 0
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: 28)
        } completion: { _ in
            self.dismiss(animated: false) {
                self.onSelect(option.days)
            }
        }
    }

    @objc private func handleCloseTapped() {
        dismiss(animated: true)
    }
}

private final class OptionRowView: UIControl {

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
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

    func configure(title: String, isSelected: Bool, isAutomatic: Bool) {
        titleLabel.text = title
        detailLabel.text = isAutomatic ? "home.dailyGardenGrid.rangeSelector.autoHint".localized() : nil
        detailLabel.isHidden = isAutomatic == false
        checkImageView.isHidden = isSelected == false
        backgroundColor = isSelected ? UIColor.hexString("#EEF6EC") : .white
        layer.borderColor = (isSelected ? UIColor.hexString("#A8D7A8") : UIColor.hexString("#E4E9E2")).cgColor
        accessibilityLabel = title
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }

    private func setupView() {
        layer.cornerRadius = 14
        layer.borderWidth = 1
        isAccessibilityElement = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.isAccessibilityElement = false

        detailLabel.font = .systemFont(ofSize: 12, weight: .medium)
        detailLabel.textColor = SGColor.textSecondary
        detailLabel.isAccessibilityElement = false

        checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkImageView.tintColor = SGColor.primary
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.isAccessibilityElement = false

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(checkImageView)

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(54)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(14)
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(-12)
        }

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(checkImageView.snp.left).offset(-12)
            make.bottom.equalToSuperview().offset(-10)
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
