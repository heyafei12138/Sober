//
//  SGGrowthPathView.swift
//  SoberGarden
//

import UIKit

final class SGGrowthPathView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pathStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(milestones: [Milestone], cleanDays: Int, unlockedCleanDays: Int) {
        pathStackView.arrangedSubviews.forEach { view in
            pathStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let nextMilestoneDay = milestones.first { cleanDays < $0.day }?.day
        milestones.enumerated().forEach { index, milestone in
            let row = SGGrowthPathRowView()
            let rowState = state(
                for: milestone,
                cleanDays: cleanDays,
                unlockedCleanDays: unlockedCleanDays,
                nextMilestoneDay: nextMilestoneDay
            )
            row.configure(
                milestone: milestone,
                state: rowState,
                connector: connectorState(
                    after: milestone,
                    isLast: index == milestones.count - 1,
                    unlockedCleanDays: unlockedCleanDays
                )
            )
            pathStackView.addArrangedSubview(row)
        }
    }

    private func setupView() {
        titleLabel.text = "Growth Path"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = SGColor.textDark

        subtitleLabel.text = "Each milestone adds something visible to your garden."
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0

        pathStackView.axis = .vertical
        pathStackView.alignment = .fill
        pathStackView.distribution = .fill
        pathStackView.spacing = 0

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(pathStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }

        pathStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func state(
        for milestone: Milestone,
        cleanDays: Int,
        unlockedCleanDays: Int,
        nextMilestoneDay: Int?
    ) -> SGGrowthPathRowView.State {
        if unlockedCleanDays >= milestone.day {
            return .unlocked
        }

        if nextMilestoneDay == milestone.day {
            return .next(remainingDays: max(milestone.day - cleanDays, 0))
        }

        return .locked
    }

    private func connectorState(
        after milestone: Milestone,
        isLast: Bool,
        unlockedCleanDays: Int
    ) -> SGGrowthPathRowView.ConnectorState {
        guard isLast == false else { return .hidden }
        return unlockedCleanDays >= milestone.day ? .unlocked : .locked
    }
}

private final class SGGrowthPathRowView: UIView {

    enum State {
        case unlocked
        case next(remainingDays: Int)
        case locked
    }

    enum ConnectorState {
        case unlocked
        case locked
        case hidden
    }

    private let connectorView = SGGrowthPathConnectorView()
    private let cardView = UIView()
    private let thumbnailView = SGGrowthStageThumbnailView()
    private let textStackView = UIStackView()
    private let topRowStackView = UIStackView()
    private let statusTagRowView = UIStackView()
    private let titleLabel = UILabel()
    private let dayLabel = SGGrowthPathInsetLabel()
    private let rewardLabel = UILabel()
    private let statusLabel = SGGrowthPathInsetLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(milestone: Milestone, state: State, connector: ConnectorState) {
        titleLabel.text = milestone.title
        dayLabel.text = "Day \(milestone.day)"
        rewardLabel.text = shortRewardText(for: milestone.gardenStage)
        statusLabel.text = statusText(for: state)
        thumbnailView.configure(imageName: "Day\(milestone.day)", state: state.thumbnailState)
        connectorView.configure(state: connector)

        let colors = colors(for: state)
        cardView.backgroundColor = colors.background
        cardView.layer.borderColor = colors.border.cgColor
        thumbnailView.backgroundColor = colors.thumbnailBackground
        titleLabel.textColor = colors.title
        rewardLabel.textColor = colors.body
        dayLabel.textColor = colors.dayText
        dayLabel.backgroundColor = colors.dayBackground
        statusLabel.textColor = colors.statusText
        statusLabel.backgroundColor = colors.statusBackground
    }

    private func setupView() {
        addSubview(connectorView)
        addSubview(cardView)

        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.masksToBounds = true

        thumbnailView.layer.cornerRadius = 18
        thumbnailView.layer.masksToBounds = true

        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.distribution = .fill
        textStackView.spacing = 6

        topRowStackView.axis = .horizontal
        topRowStackView.alignment = .center
        topRowStackView.distribution = .fill
        topRowStackView.spacing = 8

        statusTagRowView.axis = .horizontal
        statusTagRowView.alignment = .leading
        statusTagRowView.distribution = .fill
        statusTagRowView.spacing = 0

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        dayLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        dayLabel.textAlignment = .center
        dayLabel.layer.cornerRadius = 11
        dayLabel.layer.masksToBounds = true
        dayLabel.textInsets = UIEdgeInsets(top: 4, left: 9, bottom: 4, right: 9)
        dayLabel.setContentHuggingPriority(.required, for: .horizontal)
        dayLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        rewardLabel.font = .systemFont(ofSize: 13, weight: .medium)
        rewardLabel.numberOfLines = 1
        rewardLabel.adjustsFontSizeToFitWidth = true
        rewardLabel.minimumScaleFactor = 0.82

        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.numberOfLines = 1
        statusLabel.layer.cornerRadius = 11
        statusLabel.layer.masksToBounds = true
        statusLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        cardView.addSubview(thumbnailView)
        cardView.addSubview(textStackView)
        topRowStackView.addArrangedSubview(titleLabel)
        topRowStackView.addArrangedSubview(dayLabel)
        statusTagRowView.addArrangedSubview(statusLabel)
        statusTagRowView.addArrangedSubview(UIView())
        textStackView.addArrangedSubview(topRowStackView)
        textStackView.addArrangedSubview(rewardLabel)
        textStackView.addArrangedSubview(statusTagRowView)

        snp.makeConstraints { make in
            make.height.equalTo(118)
        }

        cardView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(92)
        }

        connectorView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom)
            make.bottom.equalToSuperview()
            make.centerX.equalTo(thumbnailView)
            make.width.equalTo(22)
        }

        thumbnailView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(64)
        }

        textStackView.snp.makeConstraints { make in
            make.left.equalTo(thumbnailView.snp.right).offset(14)
            make.right.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }

        dayLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(22)
        }
    }

    private func shortRewardText(for stage: GardenStage) -> String {
        switch stage {
        case .seed:
            return "Seed planted"
        case .sprout:
            return "Tiny sprout"
        case .youngPlant:
            return "Fresh leaves"
        case .flower:
            return "First flower"
        case .gardenBed:
            return "Flower bed"
        case .bloomingGarden:
            return "Tree takes root"
        case .peacefulGarden:
            return "Quiet path"
        case .smallForest:
            return "Small forest"
        case .sanctuary:
            return "Full sanctuary"
        }
    }

    private func statusText(for state: State) -> String {
        switch state {
        case .unlocked:
            return "Unlocked"
        case .next(let remainingDays):
            return remainingDays == 0 ? "Ready" : "\(remainingDays)d left"
        case .locked:
            return "Locked"
        }
    }

    private func colors(for state: State) -> (
        background: UIColor,
        border: UIColor,
        thumbnailBackground: UIColor,
        title: UIColor,
        body: UIColor,
        dayText: UIColor,
        dayBackground: UIColor,
        statusText: UIColor,
        statusBackground: UIColor
    ) {
        switch state {
        case .unlocked:
            return (
                UIColor.hexString("#FFFBED"),
                SGColor.flower.withAlphaComponent(0.34),
                UIColor.hexString("#FFF5DC"),
                SGColor.textDark,
                SGColor.textSecondary,
                SGColor.primaryDark,
                UIColor.hexString("#E6F0D8"),
                SGColor.primaryDark,
                UIColor.hexString("#F0E2B4")
            )
        case .next:
            return (
                UIColor.hexString("#F8FBF1"),
                SGColor.primary.withAlphaComponent(0.52),
                SGColor.primaryLight.withAlphaComponent(0.44),
                SGColor.textDark,
                SGColor.textDark.withAlphaComponent(0.76),
                SGColor.primaryDark,
                UIColor.hexString("#FFF6DA"),
                .white,
                SGColor.primary
            )
        case .locked:
            return (
                UIColor.white.withAlphaComponent(0.62),
                SGColor.separator.withAlphaComponent(0.5),
                UIColor.hexString("#EFEEE6"),
                SGColor.textSecondary,
                SGColor.textSecondary,
                SGColor.textTertiary,
                UIColor.hexString("#EEEDE2"),
                SGColor.textSecondary,
                UIColor.hexString("#ECEADF")
            )
        }
    }
}

private extension SGGrowthPathRowView.State {

    var thumbnailState: SGGrowthStageThumbnailView.State {
        switch self {
        case .unlocked:
            return .unlocked
        case .next:
            return .next
        case .locked:
            return .locked
        }
    }
}

private final class SGGrowthPathConnectorView: UIView {

    private var state: SGGrowthPathRowView.ConnectorState = .hidden

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(state: SGGrowthPathRowView.ConnectorState) {
        self.state = state
        isHidden = state == .hidden
        setNeedsDisplay()
    }

    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard state != .hidden else { return }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 2))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 2))

        switch state {
        case .unlocked:
            SGColor.primary.withAlphaComponent(0.34).setStroke()
            path.setLineDash(nil, count: 0, phase: 0)
        case .locked:
            UIColor.hexString("#BFC8B2").withAlphaComponent(0.82).setStroke()
            path.setLineDash([2, 4], count: 2, phase: 0)
        case .hidden:
            return
        }

        path.lineWidth = state == .unlocked ? 1.6 : 1.8
        path.lineCapStyle = .round
        path.stroke()
    }
}

private final class SGGrowthStageThumbnailView: UIView {

    enum State {
        case unlocked
        case next
        case locked
    }

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(imageName: String, state: State) {
        imageView.image = UIImage(named: imageName)
        imageView.alpha = state == .locked ? 0.48 : 1
        imageView.contentMode = .scaleAspectFit
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(7)
        }
    }
}

private final class SGGrowthPathInsetLabel: UILabel {

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
