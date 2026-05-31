//
//  SGNonMedicalDisclaimerViewController.swift
//  SoberGarden
//

import UIKit

final class SGNonMedicalDisclaimerViewController: BaseViewController {

    enum PresentationMode {
        case firstLaunch
        case settings
    }

    private let mode: PresentationMode
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let heroCardView = SGCardView()
    private let heroBannerView = UIImageView()
    private let heroOverlayView = UIView()
    private let heroBadgeLabel = UILabel()
    private let heroTitleLabel = UILabel()
    private let heroBodyLabel = UILabel()
    private let understandButton = SGPrimaryButton(title: "common.understand".localized())

    init(mode: PresentationMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        isCustomNavigationHidden = mode == .firstLaunch
        enablesInteractivePopGesture = mode == .settings
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = mode == .settings ? "settings.disclaimer.title".localized() : nil
    }

    override func setupSubviews() {
        setupLayout()
        buildContent()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        view.addSubview(understandButton)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        let topOffset: CGFloat = mode == .firstLaunch ? 16 : 44

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topOffset)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(understandButton.snp.top).offset(-18)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 18
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 28, right: 16)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        understandButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        understandButton.addTarget(self, action: #selector(handleUnderstandTapped), for: .touchUpInside)
    }

    private func buildContent() {
        contentStackView.addArrangedSubview(buildHeroCard())
        contentStackView.addArrangedSubview(buildWhatItIsCard())
        contentStackView.addArrangedSubview(buildWhatItIsNotCard())
        contentStackView.addArrangedSubview(buildHowToUseCard())
    }

    private func buildHeroCard() -> UIView {
        let card = SGCardView()
        card.setContentInsets(.zero)
        card.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 18, right: 16)

        heroBannerView.image = UIImage(named: "guider_icon_flower")
        heroBannerView.contentMode = .scaleAspectFill
        heroBannerView.clipsToBounds = true
        heroBannerView.layer.cornerRadius = 22
        heroBannerView.layer.masksToBounds = true

        let bannerContainer = UIView()
        bannerContainer.addSubview(heroBannerView)
        heroBannerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(172)
        }

        heroOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        heroBannerView.addSubview(heroOverlayView)
        heroOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let bannerContentStack = UIStackView()
        bannerContentStack.axis = .vertical
        bannerContentStack.alignment = .fill
        bannerContentStack.spacing = 8

        heroBadgeLabel.text = "settings.disclaimer.badge".localized()
        heroBadgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        heroBadgeLabel.textColor = SGColor.textDark
        heroBadgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        heroBadgeLabel.layer.cornerRadius = 10
        heroBadgeLabel.layer.masksToBounds = true
        heroBadgeLabel.textAlignment = .center
        heroBadgeLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }

        heroTitleLabel.text = "settings.disclaimer.hero.title".localized()
        heroTitleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        heroTitleLabel.textColor = SGColor.textDark
        heroTitleLabel.numberOfLines = 0

        heroBodyLabel.text = "settings.disclaimer.hero.body".localized()
        heroBodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        heroBodyLabel.textColor = SGColor.textSecondary
        heroBodyLabel.numberOfLines = 0
        heroBodyLabel.lineBreakMode = .byWordWrapping

        stack.addArrangedSubview(bannerContainer)
        stack.addArrangedSubview(heroBadgeLabel)
        stack.addArrangedSubview(heroTitleLabel)
        stack.addArrangedSubview(heroBodyLabel)
        card.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return card
    }

    private func buildWhatItIsCard() -> UIView {
        return makeInfoCard(
            title: "settings.disclaimer.is.title".localized(),
            subtitle: "settings.disclaimer.is.subtitle".localized(),
            icon: UIImage(named: "home_calm_coach_icon") ?? UIImage(systemName: "leaf.fill"),
            rows: [
                ("settings.disclaimer.is.selfReflection".localized(), "settings.disclaimer.is.selfReflection.body".localized(), "checkmark.circle.fill", SGColor.primaryDark),
                ("settings.disclaimer.is.urgeSupport".localized(), "settings.disclaimer.is.urgeSupport.body".localized(), "checkmark.circle.fill", SGColor.primaryDark),
                ("settings.disclaimer.is.gentleReminders".localized(), "settings.disclaimer.is.gentleReminders.body".localized(), "checkmark.circle.fill", SGColor.primaryDark),
                ("settings.disclaimer.is.progressTracking".localized(), "settings.disclaimer.is.progressTracking.body".localized(), "checkmark.circle.fill", SGColor.primaryDark)
            ]
        )
    }

    private func buildWhatItIsNotCard() -> UIView {
        return makeInfoCard(
            title: "settings.disclaimer.isNot.title".localized(),
            subtitle: "settings.disclaimer.isNot.subtitle".localized(),
            icon: UIImage(systemName: "slash.circle.fill"),
            rows: [
                ("settings.disclaimer.isNot.diagnosis".localized(), "settings.disclaimer.isNot.diagnosis.body".localized(), "xmark.circle.fill", UIColor.systemRed),
                ("settings.disclaimer.isNot.treatment".localized(), "settings.disclaimer.isNot.treatment.body".localized(), "xmark.circle.fill", UIColor.systemRed),
                ("settings.disclaimer.isNot.clinician".localized(), "settings.disclaimer.isNot.clinician.body".localized(), "xmark.circle.fill", UIColor.systemRed),
                ("settings.disclaimer.isNot.guarantee".localized(), "settings.disclaimer.isNot.guarantee.body".localized(), "xmark.circle.fill", UIColor.systemRed)
            ]
        )
    }

    private func buildHowToUseCard() -> UIView {
        let card = SGCardView()
        card.setContentInsets(.zero)
        card.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let header = SGSectionHeaderView(
            title: "settings.disclaimer.howToUse.title".localized(),
            subtitle: "settings.disclaimer.howToUse.subtitle".localized()
        )
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(makeStepRow(number: "1", title: "settings.disclaimer.howToUse.step1.title".localized(), body: "settings.disclaimer.howToUse.step1.body".localized(), accent: SGColor.primaryDark))
        stack.addArrangedSubview(makeStepRow(number: "2", title: "settings.disclaimer.howToUse.step2.title".localized(), body: "settings.disclaimer.howToUse.step2.body".localized(), accent: SGColor.rescue))
        stack.addArrangedSubview(makeStepRow(number: "3", title: "settings.disclaimer.howToUse.step3.title".localized(), body: "settings.disclaimer.howToUse.step3.body".localized(), accent: SGColor.flower))

        let noteRow = makeMediaRow(
            title: "settings.disclaimer.howToUse.note.title".localized(),
            body: "settings.disclaimer.howToUse.note.body".localized(),
            image: UIImage(named: "garden_stage_seed") ?? UIImage(named: "garden_stage_sprout")
        )
        stack.addArrangedSubview(noteRow)

        card.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return card
    }

    private func makeInfoCard(title: String, subtitle: String, icon: UIImage?, rows: [(String, String, String, UIColor)]) -> UIView {
        let card = SGCardView()
        card.setContentInsets(.zero)
        card.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = 12

        let iconContainer = UIView()
        iconContainer.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.28)
        iconContainer.layer.cornerRadius = 16
        iconContainer.layer.masksToBounds = true
        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        iconView.tintColor = SGColor.primaryDark
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        iconContainer.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        iconView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(9)
        }

        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.alignment = .fill
        titleStack.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0

        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subtitleLabel)
        headerRow.addArrangedSubview(iconContainer)
        headerRow.addArrangedSubview(titleStack)
        stack.addArrangedSubview(headerRow)

        rows.forEach { title, body, symbolName, tint in
            stack.addArrangedSubview(makePointRow(title: title, body: body, symbolName: symbolName, tint: tint))
        }

        card.contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        return card
    }

    private func makePointRow(title: String, body: String, symbolName: String, tint: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12

        let symbolContainer = UIView()
        symbolContainer.backgroundColor = tint.withAlphaComponent(0.14)
        symbolContainer.layer.cornerRadius = 12
        symbolContainer.layer.masksToBounds = true

        let symbolImageView = UIImageView(image: UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate))
        symbolImageView.tintColor = tint
        symbolImageView.contentMode = .scaleAspectFit
        symbolContainer.addSubview(symbolImageView)
        symbolContainer.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        symbolImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(bodyLabel)
        row.addArrangedSubview(symbolContainer)
        row.addArrangedSubview(textStack)
        return row
    }

    private func makeStepRow(number: String, title: String, body: String, accent: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12

        let badge = UILabel()
        badge.text = number
        badge.textAlignment = .center
        badge.font = .systemFont(ofSize: 13, weight: .bold)
        badge.textColor = .white
        badge.backgroundColor = accent
        badge.layer.cornerRadius = 13
        badge.layer.masksToBounds = true
        badge.snp.makeConstraints { make in
            make.size.equalTo(26)
        }

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(bodyLabel)
        row.addArrangedSubview(badge)
        row.addArrangedSubview(textStack)
        return row
    }

    private func makeMediaRow(title: String, body: String, image: UIImage?) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let imageContainer = UIView()
        imageContainer.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.22)
        imageContainer.layer.cornerRadius = 16
        imageContainer.layer.masksToBounds = true

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageContainer.addSubview(imageView)
        imageContainer.snp.makeConstraints { make in
            make.size.equalTo(52)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = SGColor.textSecondary
        bodyLabel.numberOfLines = 0

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(bodyLabel)
        row.addArrangedSubview(imageContainer)
        row.addArrangedSubview(textStack)
        return row
    }

    @objc private func handleUnderstandTapped() {
        if mode == .firstLaunch {
            SoberGardenStore.shared.updateSettings { settings in
                settings.hasAcknowledgedNonMedicalDisclaimer = true
            }
            dismiss(animated: true)
        } else {
            popCurrentController()
        }
    }
}
