//
//  SGLanguageSelectionViewController.swift
//  SoberGarden
//

import UIKit

final class SGLanguageSelectionViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let headerView = SGSectionHeaderView(title: "", subtitle: "")
    private let cardView = SGCardView()
    private let rowsStackView = UIStackView()

    var onLanguageChanged: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "settings.language.title".localized()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChanged),
            name: Notification.Name(rawValue: LCLLanguageChangeNotification),
            object: nil
        )
    }

    override func setupSubviews() {
        setupLayout()
        reloadContent()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            make.left.right.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 18
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 28, right: 20)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        rowsStackView.axis = .vertical
        rowsStackView.alignment = .fill
        rowsStackView.spacing = 0

        cardView.contentView.addSubview(rowsStackView)
        rowsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(cardView)
    }

    private func reloadContent() {
        title = "settings.language.title".localized()
        headerView.configure(
            title: "settings.language.title".localized(),
            subtitle: "settings.language.subtitle".localized()
        )

        rowsStackView.arrangedSubviews.forEach { view in
            rowsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let currentCode = SGAppLanguage.current.code
        let languages = SGAppLanguage.available
        languages.enumerated().forEach { index, language in
            let rowView = SGLanguageRowView()
            rowView.configure(
                language: language,
                isSelected: language.code == currentCode,
                showsSeparator: index < languages.count - 1
            )
            rowView.onTap = { [weak self] in
                self?.select(language)
            }
            rowsStackView.addArrangedSubview(rowView)
        }
    }

    private func select(_ language: SGAppLanguage) {
        guard language.code != SGAppLanguage.current.code else { return }
        Localize.setCurrentLanguage(language.code)
        onLanguageChanged?()
    }

    @objc private func handleLanguageChanged() {
        reloadContent()
    }
}

private final class SGLanguageRowView: UIControl {

    var onTap: (() -> Void)?

    private let contentStackView = UIStackView()
    private let labelsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let checkmarkContainerView = UIView()
    private let checkmarkImageView = UIImageView()
    private let separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(language: SGAppLanguage, isSelected: Bool, showsSeparator: Bool) {
        titleLabel.text = language.nativeName
        detailLabel.text = language.detailName
        checkmarkContainerView.isHidden = !isSelected
        separatorView.isHidden = !showsSeparator

        accessibilityLabel = "\(language.nativeName), \(language.detailName)"
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
        accessibilityValue = isSelected ? "settings.language.selected".localized() : nil
    }

    override func accessibilityActivate() -> Bool {
        handleTap()
        return true
    }

    private func setupView() {
        backgroundColor = .clear
        isAccessibilityElement = true

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 14
        contentStackView.isUserInteractionEnabled = false

        labelsStackView.axis = .vertical
        labelsStackView.alignment = .fill
        labelsStackView.spacing = 4

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        detailLabel.font = .systemFont(ofSize: 13, weight: .regular)
        detailLabel.textColor = SGColor.textSecondary
        detailLabel.numberOfLines = 1
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.minimumScaleFactor = 0.82

        checkmarkContainerView.backgroundColor = SGColor.primaryDark
        checkmarkContainerView.layer.cornerRadius = 13
        checkmarkContainerView.layer.cornerCurve = .continuous

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit

        separatorView.backgroundColor = SGColor.separator.withAlphaComponent(0.8)

        addSubview(contentStackView)
        addSubview(separatorView)
        contentStackView.addArrangedSubview(labelsStackView)
        contentStackView.addArrangedSubview(checkmarkContainerView)
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(detailLabel)
        checkmarkContainerView.addSubview(checkmarkImageView)

        contentStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(15)
            make.left.right.equalToSuperview().inset(16)
        }

        checkmarkContainerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 26, height: 26))
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 13, height: 13))
        }

        separatorView.snp.makeConstraints { make in
            make.left.equalTo(contentStackView.snp.left)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() {
        onTap?()
    }
}
