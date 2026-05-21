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
    private let understandButton = SGPrimaryButton(title: "Understand")

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
        title = mode == .settings ? "Non-medical disclaimer" : nil
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

        heroBadgeLabel.text = "Non-medical"
        heroBadgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        heroBadgeLabel.textColor = SGColor.textDark
        heroBadgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        heroBadgeLabel.layer.cornerRadius = 10
        heroBadgeLabel.layer.masksToBounds = true
        heroBadgeLabel.textAlignment = .center
        heroBadgeLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }

        heroTitleLabel.text = "A recovery companion, not a clinician."
        heroTitleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        heroTitleLabel.textColor = SGColor.textDark
        heroTitleLabel.numberOfLines = 0

        heroBodyLabel.text = "SoberGarden is built for self-reflection, urge support, calming exercises, gentle reminders, and progress tracking."
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
            title: "What this app is",
            subtitle: "A calm place to notice what you feel and choose the next useful step.",
            icon: UIImage(named: "home_calm_coach_icon") ?? UIImage(systemName: "leaf.fill"),
            rows: [
                ("Self-reflection", "Use the journal and home screen to notice patterns without judging the day.", "checkmark.circle.fill", SGColor.primaryDark),
                ("Urge support", "Use Rescue when you need a minute of breathing, delay, or a reason to pause.", "checkmark.circle.fill", SGColor.primaryDark),
                ("Gentle reminders", "Keep nudges soft and predictable so the app stays supportive, not noisy.", "checkmark.circle.fill", SGColor.primaryDark),
                ("Progress tracking", "See clean days, savings, garden growth, and milestones at a glance.", "checkmark.circle.fill", SGColor.primaryDark)
            ]
        )
    }

    private func buildWhatItIsNotCard() -> UIView {
        return makeInfoCard(
            title: "What this app is not",
            subtitle: "These boundaries are part of the product, not a footnote.",
            icon: UIImage(systemName: "slash.circle.fill"),
            rows: [
                ("Not diagnosis", "The app does not assess, label, or diagnose a condition.", "xmark.circle.fill", UIColor.systemRed),
                ("Not treatment", "It does not provide medical treatment or replace professional care.", "xmark.circle.fill", UIColor.systemRed),
                ("Not a doctor or therapist", "It does not act as a clinician, emergency service, or licensed provider.", "xmark.circle.fill", UIColor.systemRed),
                ("Not a guarantee", "The app supports your effort, but it cannot promise outcomes or permanence.", "xmark.circle.fill", UIColor.systemRed)
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
            title: "How to use it",
            subtitle: "Keep the app close to the moment, not as a substitute for care."
        )
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(makeStepRow(number: "1", title: "Open Home", body: "Read the Calm Coach card, streak, and garden preview first.", accent: SGColor.primaryDark))
        stack.addArrangedSubview(makeStepRow(number: "2", title: "Use Rescue", body: "When the urge climbs, slow down with breath, delay, and reasons.", accent: SGColor.rescue))
        stack.addArrangedSubview(makeStepRow(number: "3", title: "Record or reflect", body: "Journal what happened, then come back later and notice what changed.", accent: SGColor.flower))

        let noteRow = makeMediaRow(
            title: "Garden language is symbolic",
            body: "The seed, sprout, and bloom stages are progress markers for motivation and reflection.",
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
