//
//  SGGardenViewController.swift
//  SoberGarden
//

import UIKit
import FLAnimatedImage
import ImageIO

/// 成长花园：阶段插画、进度、已解锁徽章
final class SGGardenViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()

    private let illustrationCardView = SGCardView()
    private let illustrationView = SGGardenIllustrationView()
    private let stageTitleLabel = UILabel()
    private let cleanDaysLabel = UILabel()
    private let shareButton = UIButton(type: .system)

    private let progressCardView = SGCardView()
    private let progressHeaderLabel = UILabel()
    private let progressDetailLabel = UILabel()
    private let progressRewardLabel = SGGardenInsetLabel()
    private let progressBarView = SGProgressBarView()

    private let growthPathView = SGGrowthPathView()
    private let badgeGridView = SGBadgeGridView()

    private let copyCardView = SGCardView()
    private let copyLabel = UILabel()
    private let subscriptionOverlayView = SGGardenSubscriptionOverlayView()

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSubscriptionEntitlementChanged),
            name: SGSubscriptionManager.entitlementDidChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderContent()
        updateSubscriptionOverlayVisibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSubscriptionOverlayVisibility()
    }

    override func bindViewModel() {
        renderContent()
    }

    override func setupSubviews() {
        setupScrollView()
        setupIllustrationCard()
        setupProgressCard()
        setupGrowthPath()
        setupBadgeGrid()
        setupCopyCard()
        setupSubscriptionOverlay()
        renderContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 12)
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
        contentStackView.layoutMargins = UIEdgeInsets(top: 2, left: 16, bottom: 28, right: 16)

        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupIllustrationCard() {
        illustrationCardView.setContentInsets(.zero)
        illustrationCardView.contentView.backgroundColor = UIColor.hexString("#FFF9E8")

        stageTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        stageTitleLabel.textColor = SGColor.textDark
        stageTitleLabel.numberOfLines = 1
        stageTitleLabel.adjustsFontSizeToFitWidth = true
        stageTitleLabel.minimumScaleFactor = 0.78
        stageTitleLabel.textAlignment = .center

        cleanDaysLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        cleanDaysLabel.textColor = SGColor.primaryDark
        cleanDaysLabel.textAlignment = .center

        shareButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        shareButton.setTitle("Share", for: .normal)
        shareButton.tintColor = SGColor.primaryDark
        shareButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        shareButton.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        shareButton.layer.cornerRadius = 16
        shareButton.layer.masksToBounds = true
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        shareButton.accessibilityLabel = "Share garden progress"
        shareButton.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)

        illustrationCardView.contentView.addSubview(illustrationView)
        illustrationCardView.contentView.addSubview(shareButton)
        illustrationCardView.contentView.addSubview(stageTitleLabel)
        illustrationCardView.contentView.addSubview(cleanDaysLabel)

        illustrationView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
            make.height.equalTo(230)
        }

        shareButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16)
            make.width.equalTo(86)
            make.height.equalTo(32)
        }

        stageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationView.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(22)
        }

        cleanDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(stageTitleLabel.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview().inset(22)
        }

        contentStackView.addArrangedSubview(illustrationCardView)
    }

    private func setupProgressCard() {
        progressCardView.setContentInsets(.zero)
        progressCardView.contentView.backgroundColor = UIColor.hexString("#F8FBF1")

        progressHeaderLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        progressHeaderLabel.textColor = SGColor.textDark
        progressHeaderLabel.numberOfLines = 1

        progressDetailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        progressDetailLabel.textColor = SGColor.textSecondary
        progressDetailLabel.numberOfLines = 2

        progressRewardLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        progressRewardLabel.textColor = SGColor.primaryDark
        progressRewardLabel.numberOfLines = 0
        progressRewardLabel.lineBreakMode = .byWordWrapping
        progressRewardLabel.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.3)
        progressRewardLabel.layer.cornerRadius = 12
        progressRewardLabel.layer.masksToBounds = true
        progressRewardLabel.textInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

        progressCardView.contentView.addSubview(progressHeaderLabel)
        progressCardView.contentView.addSubview(progressDetailLabel)
        progressCardView.contentView.addSubview(progressRewardLabel)
        progressCardView.contentView.addSubview(progressBarView)

        progressHeaderLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        progressDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(progressHeaderLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(18)
        }

        progressRewardLabel.snp.makeConstraints { make in
            make.top.equalTo(progressDetailLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(18)
        }

        progressBarView.snp.makeConstraints { make in
            make.top.equalTo(progressRewardLabel.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview().inset(18)
            make.height.equalTo(10)
        }

        contentStackView.addArrangedSubview(progressCardView)
    }

    private func setupGrowthPath() {
        contentStackView.addArrangedSubview(growthPathView)
    }

    private func setupBadgeGrid() {
        contentStackView.addArrangedSubview(badgeGridView)
    }

    private func setupCopyCard() {
        copyCardView.setContentInsets(.zero)
        copyCardView.contentView.backgroundColor = UIColor.hexString("#FDF9EA")

        copyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        copyLabel.textColor = SGColor.textDark
        copyLabel.numberOfLines = 0
        copyLabel.lineBreakMode = .byWordWrapping

        copyCardView.contentView.addSubview(copyLabel)

        copyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(18)
        }

        contentStackView.addArrangedSubview(copyCardView)
    }

    private func setupSubscriptionOverlay() {
        subscriptionOverlayView.onSubscribeTapped = { [weak self] in
            let paywallViewController = SGSubscriptionPaywallViewController()
            self?.presentController(paywallViewController)
        }
        view.addSubview(subscriptionOverlayView)
        subscriptionOverlayView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-CustomTabBar.barHeight - 12)
        }
        updateSubscriptionOverlayVisibility()
    }

    private func renderContent() {
        let state = SoberGardenStore.shared.state
        let habit = state.habit
        let cleanDays = habit.map { SGProgressCalculator.currentStreakDays(startDate: $0.startDate) } ?? 1
        let stage = SGProgressCalculator.currentGardenStage(for: cleanDays)
        let nextMilestone = SGProgressCalculator.nextMilestone(for: cleanDays)
        let retainedBadgeDays = max(cleanDays, state.relapseRecords.map(\.previousStreakDays).max() ?? cleanDays)

        illustrationView.configure(stage: stage)
        stageTitleLabel.text = stage.title
        cleanDaysLabel.text = "\(cleanDays) days clean"

        if let nextMilestone {
            let previousMilestoneDay = previousMilestoneDay(before: nextMilestone.day)
            let stageSpan = max(nextMilestone.day - previousMilestoneDay, 1)
            let currentStageProgress = max(cleanDays - previousMilestoneDay, 0)
            let remainingDays = max(nextMilestone.day - cleanDays, 0)

            progressHeaderLabel.text = "Next reward: \(nextMilestone.title)"
            progressDetailLabel.text = "\(remainingDays) days to go until your garden reaches \(nextMilestone.title)."
            progressRewardLabel.text = "Unlocks: \(nextMilestone.rewardDescription)"
            progressBarView.setProgress(CGFloat(currentStageProgress) / CGFloat(stageSpan), animated: false)
        } else {
            progressHeaderLabel.text = "Sanctuary reached"
            progressDetailLabel.text = "Your garden is fully grown. Keep tending it one day at a time."
            progressRewardLabel.text = "Unlocked: The full sanctuary with sunlight, trees, and a quiet path."
            progressBarView.setProgress(1, animated: false)
        }

        growthPathView.configure(
            milestones: Milestone.defaultMilestones,
            cleanDays: cleanDays,
            unlockedCleanDays: retainedBadgeDays
        )
        badgeGridView.configure(milestones: Milestone.defaultMilestones, unlockedCleanDays: retainedBadgeDays)
        copyLabel.text = growthCopy(cleanDays: cleanDays, state: state)
    }

    private func updateSubscriptionOverlayVisibility() {
        let shouldHideOverlay = SGSubscriptionManager.shared.isPlus
        subscriptionOverlayView.isHidden = shouldHideOverlay
        subscriptionOverlayView.setAnimationActive(!shouldHideOverlay)
        if shouldHideOverlay == false {
            view.bringSubviewToFront(subscriptionOverlayView)
        }
    }

    private func previousMilestoneDay(before day: Int) -> Int {
        Milestone.defaultMilestones
            .last { $0.day < day }?
            .day ?? 0
    }

    private func growthCopy(cleanDays: Int, state: SoberGardenState) -> String {
        if state.relapseRecords.isEmpty == false, cleanDays <= 1 {
            return "Your garden remembers your effort.\nA new seed has been planted."
        }

        switch cleanDays {
        case 0...2:
            return "A seed does not need to become a forest today. It only needs care, light, and one more clean day."
        case 3...6:
            return "Small choices are beginning to show. Keep returning to what helps you feel steady."
        case 7...13:
            return "Your first week has roots now. The progress is real, even on days that feel quiet."
        case 14...29:
            return "This garden is learning your rhythm. Keep protecting the space you have made."
        case 30...89:
            return "Your clean days are becoming a place you can return to. Let the momentum stay gentle."
        default:
            return "Your garden holds the work you have already done. Keep tending it at your own pace."
        }
    }

    @objc private func handleShareTapped() {
        guard let package = SGShareProgressService.shared.makeProgressSharePackage() else { return }
        let previewViewController = SGSharePreviewViewController(package: package)
        previewViewController.popoverPresentationController?.sourceView = shareButton
        previewViewController.popoverPresentationController?.sourceRect = shareButton.bounds
        present(previewViewController, animated: true)
    }

    @objc private func handleSubscriptionEntitlementChanged() {
        updateSubscriptionOverlayVisibility()
    }
}

private final class SGGardenSubscriptionOverlayView: UIView {

    var onSubscribeTapped: (() -> Void)?

    private let posterImageView = UIImageView()
    private let animatedImageView = FLAnimatedImageView()
    private let tintOverlayView = UIView()
    private let buttonWrapView = UIView()
    private let subscribeButton = UIButton(type: .system)
    private var shouldPlayAnimation = false

    override var isHidden: Bool {
        didSet {
            syncAnimationPlayback()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        loadAnimatedBackground()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        loadAnimatedBackground()
    }

    func setAnimationActive(_ isActive: Bool) {
        shouldPlayAnimation = isActive
        syncAnimationPlayback()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        syncAnimationPlayback()
    }

    private func syncAnimationPlayback() {
        guard shouldPlayAnimation, isHidden == false, window != nil else {
            animatedImageView.stopAnimating()
            posterImageView.stopAnimating()
            return
        }

        if animatedImageView.animatedImage != nil, animatedImageView.isAnimating == false {
            animatedImageView.startAnimating()
        }

        if let animationImages = posterImageView.animationImages,
           animationImages.isEmpty == false,
           posterImageView.isAnimating == false {
            posterImageView.startAnimating()
        }
    }

    private func setupView() {
        clipsToBounds = true
        accessibilityViewIsModal = false

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true

        animatedImageView.contentMode = .scaleAspectFill
        animatedImageView.clipsToBounds = true
        animatedImageView.runLoopMode = .common

        tintOverlayView.backgroundColor = UIColor.white.withAlphaComponent(0.32)
        tintOverlayView.isUserInteractionEnabled = false

        buttonWrapView.backgroundColor = UIColor.white.withAlphaComponent(0.34)
        buttonWrapView.layer.cornerRadius = 26
        buttonWrapView.layer.cornerCurve = .continuous
        buttonWrapView.layer.shadowColor = SGColor.textDark.cgColor
        buttonWrapView.layer.shadowOpacity = 0.18
        buttonWrapView.layer.shadowRadius = 22
        buttonWrapView.layer.shadowOffset = CGSize(width: 0, height: 12)

        subscribeButton.setTitle("Unlock Garden Plus", for: .normal)
        subscribeButton.setImage(UIImage(systemName: "leaf.fill"), for: .normal)
        subscribeButton.tintColor = .white
        subscribeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        subscribeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        subscribeButton.titleLabel?.minimumScaleFactor = 0.82
        subscribeButton.backgroundColor = SGColor.primaryDark
        subscribeButton.layer.cornerRadius = 22
        subscribeButton.layer.cornerCurve = .continuous
        subscribeButton.layer.masksToBounds = true
        subscribeButton.semanticContentAttribute = .forceLeftToRight
        subscribeButton.accessibilityLabel = "Unlock Garden Plus"
        subscribeButton.addTarget(self, action: #selector(handleSubscribeTapped), for: .touchUpInside)

        addSubview(posterImageView)
        addSubview(animatedImageView)
        addSubview(tintOverlayView)
        addSubview(buttonWrapView)
        buttonWrapView.addSubview(subscribeButton)

        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        animatedImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tintOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buttonWrapView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-74)
            make.left.greaterThanOrEqualToSuperview().offset(34)
            make.right.lessThanOrEqualToSuperview().offset(-34)
            make.height.equalTo(64)
        }

        subscribeButton.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
            make.width.greaterThanOrEqualTo(218)
        }
    }

    private func loadAnimatedBackground() {
        guard let url = Bundle.main.url(forResource: "graden", withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            posterImageView.image = UIImage(named: GardenStage.flower.gardenImageName)
            return
        }

        if let fallback = Self.makeAnimatedFallbackImage(from: data) {
            posterImageView.image = fallback.poster
            posterImageView.animationImages = fallback.frames
            posterImageView.animationDuration = fallback.duration
            posterImageView.animationRepeatCount = 0
        } else {
            posterImageView.image = UIImage(contentsOfFile: url.path)
        }

        if let animatedImage = FLAnimatedImage(animatedGIFData: data) {
            animatedImageView.animatedImage = animatedImage
        }
        syncAnimationPlayback()
    }

    @objc private func handleSubscribeTapped() {
        onSubscribeTapped?()
    }

    private static func makeAnimatedFallbackImage(from data: Data) -> (poster: UIImage, frames: [UIImage], duration: TimeInterval)? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else { return nil }

        var frames: [UIImage] = []
        frames.reserveCapacity(frameCount)
        var duration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up))
            duration += frameDelay(at: index, source: source)
        }

        guard let poster = frames.first else { return nil }
        return (poster, frames, max(duration, 0.1))
    }

    private static func frameDelay(at index: Int, source: CGImageSource) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }

        let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        let clampedDelay = gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval
        let delay = unclampedDelay ?? clampedDelay ?? 0.1
        return delay < 0.02 ? 0.1 : delay
    }
}

private final class SGGardenInsetLabel: UILabel {

    var textInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
