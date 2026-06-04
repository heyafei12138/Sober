//
//  SGSubscriptionPaywallViewController.swift
//  SoberGarden
//

import UIKit

final class SGSubscriptionPaywallViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let closeButton = UIButton(type: .system)
    private let heroView = SGSubscriptionHeroView()
    private let benefitsView = SGSubscriptionBenefitsView()
    private let planStackView = UIStackView()
    private let appleNoticeView = SGSubscriptionAppleNoticeView()
    private let subscribeButton = SGSubscriptionContinueButton()
    private let linkStackView = UIStackView()
    private let privacyButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let restoreButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let legalTitleLabel = UILabel()
    private let legalLabel = UILabel()

    private let plans = SGSubscriptionProduct.allCases
    private var selectedPlan: SGSubscriptionProduct = .yearly
    private var planCards: [SGSubscriptionProduct: SGSubscriptionPlanCard] = [:]
    private var purchaseInFlight = false
    private var hasScheduledCloseButtonReveal = false
    private var hasClosedAfterSuccessfulPurchase = false
    private let privacyPolicyURL = URL(string: "https://sites.google.com/view/sober-privacy")!
    private let termsURL = URL(string: "https://sites.google.com/view/sober-termsofus")!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureModalPresentation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureModalPresentation()
    }

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        title = nil
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEntitlementChanged),
            name: SGSubscriptionManager.entitlementDidChangeNotification,
            object: nil
        )
        Task {
            await SGSubscriptionManager.shared.loadProductsIfNeeded()
            await SGSubscriptionManager.shared.refreshEntitlements()
            refreshPlanCards()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revealCloseButtonAfterDelay()
    }

    override func setupSubviews() {
        setupLayout()
        configureContent()
    }

    private func setupLayout() {
        view.backgroundColor = SGColor.background

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 18
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top:12, left: 20, bottom: 34, right: 20)

        planStackView.axis = .horizontal
        planStackView.alignment = .fill
        planStackView.distribution = .fillEqually
        planStackView.spacing = 10

        closeButton.alpha = 0
        closeButton.isUserInteractionEnabled = false
        closeButton.accessibilityElementsHidden = true
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        closeButton.tintColor = SGColor.textDark.withAlphaComponent(0.3)
        closeButton.layer.cornerRadius = 20
        closeButton.layer.cornerCurve = .continuous
      
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)

        linkStackView.axis = .horizontal
        linkStackView.alignment = .center
        linkStackView.distribution = .equalSpacing
        linkStackView.spacing = 12

        configureLinkButton(privacyButton, title: "subscription.link.privacy".localized(), action: #selector(handlePrivacyTapped))
        configureLinkButton(termsButton, title: "subscription.link.terms".localized(), action: #selector(handleTermsTapped))
        configureLinkButton(restoreButton, title: "subscription.link.restore".localized(), action: #selector(handleRestoreTapped))

        statusLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        statusLabel.textColor = SGColor.textSecondary
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        legalTitleLabel.text = "subscription.legal.title".localized()
        legalTitleLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        legalTitleLabel.textColor = SGColor.textDark
        legalTitleLabel.textAlignment = .left

        legalLabel.text = "subscription.legal.body".localized()
        legalLabel.font = .systemFont(ofSize: 12, weight: .medium)
        legalLabel.textColor = SGColor.textTertiary
        legalLabel.textAlignment = .left
        legalLabel.numberOfLines = 0

        subscribeButton.setTitle("common.continue".localized(), for: .normal)
        subscribeButton.addTarget(self, action: #selector(handleSubscribeTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        view.addSubview(closeButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        plans.forEach { plan in
            let card = SGSubscriptionPlanCard()
            card.addTarget(self, action: #selector(handlePlanTapped(_:)), for: .touchUpInside)
            card.configure(
                plan: plan,
                price: SGSubscriptionManager.shared.displayPrice(for: plan),
                selected: plan == selectedPlan
            )
            card.accessibilityIdentifier = plan.rawValue
            planCards[plan] = card
            planStackView.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.height.equalTo(172)
            }
        }

        stackView.addArrangedSubview(heroView)
        stackView.addArrangedSubview(benefitsView)
        stackView.addArrangedSubview(planStackView)
        stackView.addArrangedSubview(appleNoticeView)
        stackView.addArrangedSubview(subscribeButton)
        stackView.addArrangedSubview(linkStackView)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(legalTitleLabel)
        stackView.addArrangedSubview(legalLabel)

        linkStackView.addArrangedSubview(privacyButton)
        linkStackView.addArrangedSubview(termsButton)
        linkStackView.addArrangedSubview(restoreButton)

        heroView.snp.makeConstraints { make in
            make.height.equalTo(282)
        }
        benefitsView.snp.makeConstraints { make in
            make.height.equalTo(124)
        }
        appleNoticeView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        subscribeButton.snp.makeConstraints { make in
            make.height.equalTo(58)
        }
        linkStackView.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        statusLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(18)
        }

        stackView.setCustomSpacing(16, after: heroView)
        stackView.setCustomSpacing(20, after: benefitsView)
        stackView.setCustomSpacing(10, after: planStackView)
        stackView.setCustomSpacing(8, after: appleNoticeView)
        stackView.setCustomSpacing(4, after: subscribeButton)
        stackView.setCustomSpacing(6, after: linkStackView)
        stackView.setCustomSpacing(18, after: statusLabel)
        stackView.setCustomSpacing(6, after: legalTitleLabel)
    }

    private func configureContent() {
        heroView.configure(
            eyebrow: "subscription.hero.eyebrow".localized(),
            title: "subscription.hero.title".localized(),
            message: "subscription.hero.message".localized()
        )
        benefitsView.configure(
            benefits: [
                ("chart.line.uptrend.xyaxis", "subscription.benefit.trends".localized()),
                ("leaf.fill", "subscription.benefit.garden".localized()),
                ("square.and.pencil", "subscription.benefit.reflection".localized())
            ]
        )
        appleNoticeView.configure(text: "subscription.appleNotice".localized())
        refreshPlanCards()
    }

    private func configureModalPresentation() {
        modalPresentationStyle = .fullScreen
    }

    private func refreshPlanCards() {
        plans.forEach { plan in
            planCards[plan]?.configure(
                plan: plan,
                price: SGSubscriptionManager.shared.displayPrice(for: plan),
                selected: plan == selectedPlan
            )
        }

        subscribeButton.setTitle("common.continue".localized(), for: .normal)
    }

    private func revealCloseButtonAfterDelay() {
        guard hasScheduledCloseButtonReveal == false else { return }
        hasScheduledCloseButtonReveal = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self, self.view.window != nil else { return }
            self.closeButton.isUserInteractionEnabled = true
            self.closeButton.accessibilityElementsHidden = false
            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut]
            ) {
                self.closeButton.alpha = 1
            }
        }
    }

    @objc private func handlePlanTapped(_ sender: SGSubscriptionPlanCard) {
        guard let rawValue = sender.accessibilityIdentifier,
              let plan = SGSubscriptionProduct(rawValue: rawValue) else {
            return
        }

        selectedPlan = plan
        statusLabel.text = nil
        refreshPlanCards()
    }

    @objc private func handleSubscribeTapped() {
        guard !purchaseInFlight else { return }
        purchaseInFlight = true
        subscribeButton.isEnabled = false
        restoreButton.isEnabled = false
        statusLabel.text = "subscription.status.processing".localized()

        Task {
            let result = await SGSubscriptionManager.shared.purchase(selectedPlan)
            await MainActor.run {
                self.handlePurchaseResult(result)
            }
        }
    }

    @objc private func handlePrivacyTapped() {
        openWebPageInSafari(privacyPolicyURL)
    }

    @objc private func handleTermsTapped() {
        openWebPageInSafari(termsURL)
    }

    @objc private func handleCloseTapped() {
        closePaywall()
    }

    @objc private func handleRestoreTapped() {
        guard !purchaseInFlight else { return }
        purchaseInFlight = true
        subscribeButton.isEnabled = false
        restoreButton.isEnabled = false
        statusLabel.text = "subscription.status.restoring".localized()

        Task {
            let result = await SGSubscriptionManager.shared.restorePurchases()
            await MainActor.run {
                self.handlePurchaseResult(result)
            }
        }
    }

    private func handlePurchaseResult(_ result: SGSubscriptionPurchaseResult) {
        purchaseInFlight = false
        subscribeButton.isEnabled = true
        restoreButton.isEnabled = true

        switch result {
        case .purchased:
            statusLabel.text = "subscription.status.active".localized()
            closePaywallAfterSuccess()
        case .cancelled:
            statusLabel.text = nil
        case .pending:
            statusLabel.text = "subscription.status.pending".localized()
        case .failed(let message):
            statusLabel.text = message
        }
    }

    private func closePaywallAfterSuccess() {
        guard hasClosedAfterSuccessfulPurchase == false else { return }
        hasClosedAfterSuccessfulPurchase = true
        closePaywall()
    }

    private func closePaywall() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            popCurrentController()
        }
    }

    @objc private func handleEntitlementChanged() {
        guard SGSubscriptionManager.shared.isPlus else { return }
        closePaywallAfterSuccess()
    }

    private func configureLinkButton(_ button: UIButton, title: String, action: Selector) {
        button.setAttributedTitle(
            NSAttributedString(
                string: title,
                attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: SGColor.primaryDark,
                    .font: UIFont.systemFont(ofSize: 13, weight: .bold)
                ]
            ),
            for: .normal
        )
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.78
        button.addTarget(self, action: action, for: .touchUpInside)
    }
}

private final class SGSubscriptionContinueButton: UIButton {

    private let gradientLayer = CAGradientLayer()
    private var isAnimatingAttention = false

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.72
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

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
        gradientLayer.cornerRadius = bounds.height / 2
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? stopAttentionMotion() : startAttentionMotion()
    }

    private func setupView() {
        setTitle("common.continue".localized(), for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.hexString("#FF3D3D").cgColor
        layer.shadowOpacity = 0.32
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)

        gradientLayer.colors = [
            UIColor.hexString("#FF8A1D").cgColor,
            UIColor.hexString("#FF3D3D").cgColor,
            UIColor.hexString("#F01873").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func startAttentionMotion() {
        guard !isAnimatingAttention else { return }
        isAnimatingAttention = true

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, 0, -5, 5, -3, 3, 0, 0]
        animation.keyTimes = [0, 0.48, 0.56, 0.64, 0.72, 0.8, 0.88, 1]
        animation.duration = 2.4
        animation.beginTime = CACurrentMediaTime() + 0.65
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "sg.subscription.continue.shake")
    }

    private func stopAttentionMotion() {
        isAnimatingAttention = false
        layer.removeAnimation(forKey: "sg.subscription.continue.shake")
    }
}

private final class SGSubscriptionHeroView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let iconContainerView = UIView()
    private let iconView = UIImageView(image: UIImage(systemName: "leaf.circle.fill"))
    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let bloomView = UIImageView(image: UIImage(named: GardenStage.flower.gardenImageName))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func configure(eyebrow: String, title: String, message: String) {
        eyebrowLabel.text = eyebrow.uppercased()
        titleLabel.text = title
        messageLabel.text = message
    }

    private func setupView() {
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        layer.masksToBounds = true

        gradientLayer.colors = [
            UIColor.hexString("#EEF5E9").cgColor,
            UIColor.hexString("#FFF6DA").cgColor,
            UIColor.hexString("#DDE8D2").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.12, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        iconContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.56)
        iconContainerView.layer.cornerRadius = 28
        iconContainerView.layer.borderWidth = 1
        iconContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.64).cgColor

        iconView.tintColor = SGColor.primaryDark
        iconView.contentMode = .scaleAspectFit

        eyebrowLabel.font = .systemFont(ofSize: 12, weight: .heavy)
        eyebrowLabel.textColor = SGColor.primaryDark.withAlphaComponent(0.74)

        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        messageLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        messageLabel.textColor = SGColor.textSecondary
        messageLabel.numberOfLines = 0

        bloomView.contentMode = .scaleAspectFit
        bloomView.alpha = 0.96

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        addSubview(bloomView)
        addSubview(eyebrowLabel)
        addSubview(titleLabel)
        addSubview(messageLabel)

        iconContainerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.width.height.equalTo(56)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }

        bloomView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(128)
        }

        eyebrowLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(titleLabel.snp.top).offset(-12)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(96)
            make.bottom.equalTo(messageLabel.snp.top).offset(-12)
        }

        messageLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-22)
        }
    }
}

private final class SGSubscriptionBenefitsView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let benefitsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(benefits: [(String, String)]) {
        benefitsStackView.arrangedSubviews.forEach { view in
            benefitsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        benefits.forEach { symbolName, title in
            benefitsStackView.addArrangedSubview(SGSubscriptionBenefitPill(symbolName: symbolName, title: title))
        }
    }

    private func setupView() {
        backgroundColor = UIColor.hexString("#FBFDF8")
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = SGColor.primaryLight.withAlphaComponent(0.82).cgColor

        titleLabel.text = "subscription.benefits.title".localized()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = "subscription.benefits.subtitle".localized()
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 2

        benefitsStackView.axis = .horizontal
        benefitsStackView.alignment = .fill
        benefitsStackView.distribution = .fillEqually
        benefitsStackView.spacing = 8

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(benefitsStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(14)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(14)
        }

        benefitsStackView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(12)
            make.height.equalTo(36)
        }
    }
}

private final class SGSubscriptionBenefitPill: UIView {

    init(symbolName: String, title: String) {
        super.init(frame: .zero)
        setupView(symbolName: symbolName, title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(symbolName: String, title: String) {
        backgroundColor = SGColor.primaryLight.withAlphaComponent(0.62)
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous

        let iconView = UIImageView(image: UIImage(systemName: symbolName))
        iconView.tintColor = SGColor.primaryDark
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.72

        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }

        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
    }
}

private final class SGSubscriptionAppleNoticeView: UIView {

    private let iconView = UIImageView(image: UIImage(systemName: "apple.logo"))
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(text: String) {
        titleLabel.text = text
    }

    private func setupView() {
        iconView.tintColor = SGColor.primaryDark.withAlphaComponent(0.78)
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = SGColor.primaryDark.withAlphaComponent(0.78)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }

        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(15)
        }
    }
}

private final class SGSubscriptionPlanCard: UIControl {

    private let contentCardView = UIView()
    private let badgeLabel = SGSubscriptionPaddingLabel()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let cadenceLabel = UILabel()
    private let discountLabel = SGSubscriptionPaddingLabel()
    private let highlightLabel = UILabel()
    private let checkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(plan: SGSubscriptionProduct, price: String, selected: Bool) {
        titleLabel.text = plan.title
        priceLabel.text = price
        cadenceLabel.text = plan.cadence
        discountLabel.text = plan.discount
        badgeLabel.text = plan.badge
        highlightLabel.text = plan.highlight
        checkImageView.isHidden = !selected

        contentCardView.layer.borderWidth = selected ? 2 : 1
        contentCardView.layer.borderColor = selected
            ? SGColor.primaryDark.withAlphaComponent(0.78).cgColor
            : SGColor.primaryLight.withAlphaComponent(0.9).cgColor
        contentCardView.backgroundColor = selected
            ? UIColor.hexString("#FFF9E8")
            : UIColor.white.withAlphaComponent(0.86)
        discountLabel.backgroundColor = selected
            ? SGColor.rescue
            : SGColor.primaryDark.withAlphaComponent(0.72)
        badgeLabel.backgroundColor = selected
            ? SGColor.primaryDark
            : SGColor.primary.withAlphaComponent(0.86)

        let scale = selected ? CGAffineTransform(scaleX: 1.025, y: 1.025) : .identity
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.6,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.contentCardView.transform = scale
            self.badgeLabel.transform = scale
        }

        accessibilityLabel = "\(plan.title), \(price) \(plan.cadence), \(plan.discount), \(plan.highlight)"
        accessibilityTraits = selected ? [.button, .selected] : .button
    }

    private func setupView() {
        clipsToBounds = false
        isExclusiveTouch = true

        contentCardView.backgroundColor = UIColor.white.withAlphaComponent(0.86)
        contentCardView.layer.cornerRadius = 20
        contentCardView.layer.cornerCurve = .continuous
        contentCardView.layer.borderWidth = 1
        contentCardView.layer.borderColor = SGColor.primaryLight.cgColor
        contentCardView.layer.masksToBounds = true
        contentCardView.isUserInteractionEnabled = false

        badgeLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMaxXMaxYCorner
        ]
        badgeLabel.clipsToBounds = true
        badgeLabel.isUserInteractionEnabled = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .heavy)
        titleLabel.textColor = SGColor.textDark
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.72
        titleLabel.isUserInteractionEnabled = false

        priceLabel.font = .systemFont(ofSize: 22, weight: .heavy)
        priceLabel.textColor = SGColor.primaryDark
        priceLabel.textAlignment = .center
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.minimumScaleFactor = 0.66
        priceLabel.isUserInteractionEnabled = false

        cadenceLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        cadenceLabel.textColor = SGColor.textSecondary
        cadenceLabel.textAlignment = .center
        cadenceLabel.adjustsFontSizeToFitWidth = true
        cadenceLabel.minimumScaleFactor = 0.72
        cadenceLabel.isUserInteractionEnabled = false

        discountLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        discountLabel.textColor = .white
        discountLabel.textAlignment = .center
        discountLabel.layer.cornerRadius = 11
        discountLabel.clipsToBounds = true
        discountLabel.isUserInteractionEnabled = false

        highlightLabel.font = .systemFont(ofSize: 11, weight: .bold)
        highlightLabel.textColor = SGColor.textDark.withAlphaComponent(0.76)
        highlightLabel.textAlignment = .center
        highlightLabel.adjustsFontSizeToFitWidth = true
        highlightLabel.minimumScaleFactor = 0.72
        highlightLabel.isUserInteractionEnabled = false

        checkImageView.tintColor = SGColor.rescue
        checkImageView.isUserInteractionEnabled = false

        addSubview(contentCardView)
        addSubview(badgeLabel)
        contentCardView.addSubview(titleLabel)
        contentCardView.addSubview(priceLabel)
        contentCardView.addSubview(cadenceLabel)
        contentCardView.addSubview(discountLabel)
        contentCardView.addSubview(highlightLabel)
        contentCardView.addSubview(checkImageView)

        contentCardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }

        badgeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(24)
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }

        checkImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-9)
            make.width.height.equalTo(19)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview().inset(8)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.left.right.equalToSuperview().inset(7)
        }

        cadenceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(7)
        }

        discountLabel.snp.makeConstraints { make in
            make.top.equalTo(cadenceLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.left.greaterThanOrEqualToSuperview().offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-8)
        }

        highlightLabel.snp.makeConstraints { make in
            make.top.equalTo(discountLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(8)
        }
    }
}

private final class SGSubscriptionPaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 9)

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
