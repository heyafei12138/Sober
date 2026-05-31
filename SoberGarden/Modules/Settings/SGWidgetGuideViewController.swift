//
//  SGWidgetGuideViewController.swift
//  SoberGarden
//

import UIKit

final class SGWidgetGuideViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func setupSubviews() {
        setupLayout()
        setupCloseButton()
        buildContent()
    }
    private func setupCloseButton() {
        view.addSubview(closeButton)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = SGColor.textDark
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        closeButton.layer.cornerRadius = 18
        closeButton.layer.masksToBounds = true
        closeButton.accessibilityLabel = "common.close".localized()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(36)
        }
        view.bringSubviewToFront(closeButton)
    }
    
    @objc private func closeButtonTapped() {
        closeGuide()
    }

    private func closeGuide() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else if navigationController?.presentingViewController != nil {
            navigationController?.dismiss(animated: true)
        } else {
            popCurrentController()
        }
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(54)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 18
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 32, right: 20)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buildContent() {
        contentStackView.addArrangedSubview(makeHeroCard())
        contentStackView.addArrangedSubview(makeStepsCard())
    }

    private func makeHeroCard() -> UIView {
        let card = SGCardView()
        card.setContentInsets(.zero)
        card.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.hexString("#EEF5E9")
        imageContainer.layer.cornerRadius = 22
        imageContainer.layer.masksToBounds = true

        let imageView = UIImageView(image: UIImage(named: "garden_stage_sprout") ?? UIImage(named: "guider_icon_flowerpot"))
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "settings.widgetGuide.hero.title".localized()
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = "settings.widgetGuide.hero.body".localized()
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping

        imageContainer.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(22)
            make.height.equalTo(128)
        }

        stack.addArrangedSubview(imageContainer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bodyLabel)

        card.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return card
    }

    private func makeStepsCard() -> UIView {
        let card = SGCardView()
        card.setContentInsets(.zero)
        card.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)

        let header = SGSectionHeaderView(
            title: "settings.widgetGuide.steps.title".localized(),
            subtitle: "settings.widgetGuide.steps.subtitle".localized()
        )

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(makeStepRow(
            number: "1",
            iconName: "hand.tap.fill",
            title: "settings.widgetGuide.step1.title".localized(),
            body: "settings.widgetGuide.step1.body".localized()
        ))
        stack.addArrangedSubview(makeStepRow(
            number: "2",
            iconName: "plus.app.fill",
            title: "settings.widgetGuide.step2.title".localized(),
            body: "settings.widgetGuide.step2.body".localized()
        ))
        stack.addArrangedSubview(makeStepRow(
            number: "3",
            iconName: "magnifyingglass",
            title: "settings.widgetGuide.step3.title".localized(),
            body: "settings.widgetGuide.step3.body".localized()
        ))

        card.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return card
    }

    private func makeStepRow(number: String, iconName: String, title: String, body: String) -> UIView {
        let row = UIView()
        row.backgroundColor = UIColor.hexString("#F8FBF1")
        row.layer.cornerRadius = 14
        row.layer.masksToBounds = true

        let numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.font = .systemFont(ofSize: 14, weight: .bold)
        numberLabel.textColor = SGColor.primaryDark
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.65)
        numberLabel.layer.cornerRadius = 14
        numberLabel.layer.masksToBounds = true

        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.82)
        iconContainer.layer.cornerRadius = 15
        iconContainer.layer.masksToBounds = true

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = SGColor.primaryDark
        iconView.contentMode = .scaleAspectFit

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.distribution = .fill
        textStack.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping

        row.addSubview(numberLabel)
        row.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        row.addSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(bodyLabel)

        numberLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
            make.size.equalTo(28)
        }

        iconContainer.snp.makeConstraints { make in
            make.left.equalTo(numberLabel.snp.right).offset(10)
            make.centerY.equalTo(numberLabel)
            make.size.equalTo(30)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(15)
        }

        textStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(13)
            make.left.equalTo(iconContainer.snp.right).offset(12)
            make.right.bottom.equalToSuperview().inset(14)
        }

        return row
    }

    override func onNavigationBackPressed() {
        closeGuide()
    }
}
