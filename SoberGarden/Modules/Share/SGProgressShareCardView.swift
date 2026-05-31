//
//  SGProgressShareCardView.swift
//  SoberGarden
//

import UIKit

final class SGProgressShareCardView: UIView {

    struct Content {
        let cleanDays: Int
        let savedMoneyText: String
        let savedTimeText: String
        let gardenStage: GardenStage
        let habitName: String
        let generatedAt: Date
        let style: SGSharePosterStyle
    }

    private let backgroundGradientLayer = CAGradientLayer()
    private let textureLayer = CAShapeLayer()
    private let posterPanelView = UIView()
    private let appNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let headlineLabel = UILabel()
    private let dayCountLabel = UILabel()
    private let dayCaptionLabel = UILabel()
    private let stageImageBackgroundView = UIView()
    private let stageImageView = UIImageView()
    private let statsStackView = UIStackView()
    private let moneyStatView = SGShareStatView()
    private let timeStatView = SGShareStatView()
    private let stageStatView = SGShareStatView()
    private let quoteLabel = UILabel()
    private let footerLabel = UILabel()

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
        backgroundGradientLayer.frame = bounds
        textureLayer.frame = bounds
        updateTexturePath()
    }

    func configure(with content: Content) {
        applyStyle(content.style)
        dateLabel.text = Self.displayDateFormatter.string(from: content.generatedAt)
        headlineLabel.text = content.style.headline
        dayCountLabel.text = "\(content.cleanDays)"
        dayCaptionLabel.text = content.style.dayCaption(cleanDays: content.cleanDays, habitName: content.habitName)
        configureStats(with: content)
        stageImageView.image = UIImage(named: content.gardenStage.gardenImageName)
        quoteLabel.text = content.style.quote
        footerLabel.text = "SoberGarden"
    }

    private func setupView() {
        backgroundColor = SGColor.background
        layer.cornerRadius = 28
        layer.masksToBounds = true

        backgroundGradientLayer.startPoint = CGPoint(x: 0.12, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.9, y: 1)
        layer.insertSublayer(backgroundGradientLayer, at: 0)

        textureLayer.fillColor = UIColor.clear.cgColor
        textureLayer.lineWidth = 3
        textureLayer.lineCap = .round
        layer.insertSublayer(textureLayer, above: backgroundGradientLayer)

        posterPanelView.layer.cornerRadius = 44
        posterPanelView.layer.shadowOpacity = 0.16
        posterPanelView.layer.shadowRadius = 34
        posterPanelView.layer.shadowOffset = CGSize(width: 0, height: 20)

        appNameLabel.text = "SoberGarden"
        appNameLabel.font = .systemFont(ofSize: 34, weight: .bold)
        appNameLabel.textColor = SGColor.primaryDark

        dateLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        dateLabel.textColor = SGColor.textSecondary
        dateLabel.textAlignment = .right

        headlineLabel.font = .systemFont(ofSize: 54, weight: .bold)
        headlineLabel.textColor = SGColor.textDark
        headlineLabel.numberOfLines = 0

        dayCountLabel.font = .monospacedDigitSystemFont(ofSize: 196, weight: .bold)
        dayCountLabel.textColor = SGColor.textDark
        dayCountLabel.textAlignment = .center
        dayCountLabel.adjustsFontSizeToFitWidth = true
        dayCountLabel.minimumScaleFactor = 0.62

        dayCaptionLabel.font = .systemFont(ofSize: 36, weight: .semibold)
        dayCaptionLabel.textColor = SGColor.textSecondary
        dayCaptionLabel.textAlignment = .center
        dayCaptionLabel.numberOfLines = 2
        dayCaptionLabel.adjustsFontSizeToFitWidth = true
        dayCaptionLabel.minimumScaleFactor = 0.78

        stageImageBackgroundView.layer.cornerRadius = 54
        stageImageBackgroundView.layer.masksToBounds = true

        stageImageView.contentMode = .scaleAspectFit

        statsStackView.axis = .horizontal
        statsStackView.alignment = .fill
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 18

        quoteLabel.font = .systemFont(ofSize: 34, weight: .bold)
        quoteLabel.textColor = SGColor.textDark
        quoteLabel.textAlignment = .center
        quoteLabel.numberOfLines = 2

        footerLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        footerLabel.textColor = SGColor.primaryDark
        footerLabel.textAlignment = .center

        addSubview(posterPanelView)
        addSubview(appNameLabel)
        addSubview(dateLabel)
        posterPanelView.addSubview(headlineLabel)
        posterPanelView.addSubview(stageImageBackgroundView)
        stageImageBackgroundView.addSubview(stageImageView)
        posterPanelView.addSubview(dayCountLabel)
        posterPanelView.addSubview(dayCaptionLabel)
        posterPanelView.addSubview(statsStackView)
        statsStackView.addArrangedSubview(moneyStatView)
        statsStackView.addArrangedSubview(timeStatView)
        statsStackView.addArrangedSubview(stageStatView)
        posterPanelView.addSubview(quoteLabel)
        addSubview(footerLabel)

        appNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.left.equalToSuperview().offset(70)
            make.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-24)
        }

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(appNameLabel)
            make.right.equalToSuperview().offset(-70)
        }

        posterPanelView.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(48)
            make.left.right.equalToSuperview().inset(58)
            make.bottom.equalTo(footerLabel.snp.top).offset(-40)
        }

        headlineLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(58)
            make.left.right.equalToSuperview().inset(58)
        }

        stageImageBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(46)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(286)
        }

        stageImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(38)
        }

        dayCountLabel.snp.makeConstraints { make in
            make.top.equalTo(stageImageBackgroundView.snp.bottom).offset(26)
            make.left.right.equalToSuperview().inset(58)
        }

        dayCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dayCountLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(72)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(dayCaptionLabel.snp.bottom).offset(48)
            make.left.right.equalToSuperview().inset(44)
            make.height.equalTo(138)
        }

        quoteLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(44)
            make.left.right.equalToSuperview().inset(66)
        }

        footerLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(70)
            make.bottom.equalToSuperview().inset(54)
        }
    }

    private func updateTexturePath() {
        let path = UIBezierPath()
        let baseY = bounds.height * 0.19
        path.move(to: CGPoint(x: -80, y: baseY))
        path.addCurve(
            to: CGPoint(x: bounds.width + 80, y: baseY + 70),
            controlPoint1: CGPoint(x: bounds.width * 0.25, y: baseY - 68),
            controlPoint2: CGPoint(x: bounds.width * 0.66, y: baseY + 142)
        )

        let lowerY = bounds.height * 0.82
        path.move(to: CGPoint(x: -60, y: lowerY))
        path.addCurve(
            to: CGPoint(x: bounds.width + 60, y: lowerY - 56),
            controlPoint1: CGPoint(x: bounds.width * 0.28, y: lowerY + 90),
            controlPoint2: CGPoint(x: bounds.width * 0.7, y: lowerY - 146)
        )
        textureLayer.path = path.cgPath
    }

    private func applyStyle(_ style: SGSharePosterStyle) {
        backgroundGradientLayer.colors = style.gradientColors.map(\.cgColor)
        textureLayer.strokeColor = style.textureColor.cgColor
        posterPanelView.backgroundColor = style.panelColor
        posterPanelView.layer.shadowColor = style.shadowColor.cgColor
        stageImageBackgroundView.backgroundColor = style.imageBackgroundColor
        appNameLabel.textColor = style.brandColor
        footerLabel.textColor = style.brandColor
        dayCountLabel.textColor = style.dayColor
        headlineLabel.textAlignment = style.headlineAlignment
        dayCountLabel.textAlignment = style.dayAlignment
        dayCaptionLabel.textAlignment = style.dayAlignment
        quoteLabel.textAlignment = style.quoteAlignment
        statsStackView.axis = style.statsAxis
        statsStackView.spacing = style.statsSpacing
        dayCountLabel.font = .monospacedDigitSystemFont(ofSize: style.dayFontSize, weight: .bold)
        applyLayout(for: style)
    }

    private func configureStats(with content: Content) {
        statsStackView.arrangedSubviews.forEach { view in
            statsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        switch content.style {
        case .garden:
            moneyStatView.configure(title: "share.card.saved".localized(), value: content.savedMoneyText)
            timeStatView.configure(title: "share.card.timeBack".localized(), value: content.savedTimeText)
            stageStatView.configure(title: "share.card.garden".localized(), value: content.gardenStage.title)
            [moneyStatView, timeStatView, stageStatView].forEach(statsStackView.addArrangedSubview)

        case .fresh:
            moneyStatView.configure(title: "share.card.saved".localized(), value: content.savedMoneyText)
            timeStatView.configure(title: "share.card.timeBack".localized(), value: content.savedTimeText)
            stageStatView.configure(title: "share.card.stage".localized(), value: content.gardenStage.title)
            [timeStatView, moneyStatView, stageStatView].forEach(statsStackView.addArrangedSubview)

        case .sunrise:
            moneyStatView.configure(title: "share.card.cleanDays".localized(), value: "\(content.cleanDays)")
            timeStatView.configure(title: "share.card.saved".localized(), value: content.savedMoneyText)
            stageStatView.configure(title: "share.card.garden".localized(), value: content.gardenStage.title)
            [moneyStatView, timeStatView, stageStatView].forEach(statsStackView.addArrangedSubview)
        }
    }

    private func applyLayout(for style: SGSharePosterStyle) {
        posterPanelView.snp.remakeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(style.panelTopOffset)
            make.left.right.equalToSuperview().inset(58)
            make.bottom.equalTo(footerLabel.snp.top).offset(-40)
        }

        switch style {
        case .garden:
            applyGardenLayout()
        case .fresh:
            applyFreshLayout()
        case .sunrise:
            applySunriseLayout()
        }
    }

    private func applyGardenLayout() {
        headlineLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(58)
            make.left.right.equalToSuperview().inset(58)
        }

        stageImageBackgroundView.snp.remakeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(46)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(286)
        }

        dayCountLabel.snp.remakeConstraints { make in
            make.top.equalTo(stageImageBackgroundView.snp.bottom).offset(26)
            make.left.right.equalToSuperview().inset(58)
        }

        dayCaptionLabel.snp.remakeConstraints { make in
            make.top.equalTo(dayCountLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(72)
        }

        statsStackView.snp.remakeConstraints { make in
            make.top.equalTo(dayCaptionLabel.snp.bottom).offset(48)
            make.left.right.equalToSuperview().inset(44)
            make.height.equalTo(138)
        }

        quoteLabel.snp.remakeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(44)
            make.left.right.equalToSuperview().inset(66)
        }
    }

    private func applyFreshLayout() {
        headlineLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(58)
            make.left.equalToSuperview().offset(58)
            make.right.equalTo(stageImageBackgroundView.snp.left).offset(-34)
        }

        stageImageBackgroundView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(72)
            make.right.equalToSuperview().inset(58)
            make.width.height.equalTo(238)
        }

        dayCountLabel.snp.remakeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(58)
            make.right.equalTo(stageImageBackgroundView.snp.left).offset(-34)
        }

        dayCaptionLabel.snp.remakeConstraints { make in
            make.top.equalTo(dayCountLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(62)
            make.right.equalTo(stageImageBackgroundView.snp.left).offset(-34)
        }

        statsStackView.snp.remakeConstraints { make in
            make.top.equalTo(dayCaptionLabel.snp.bottom).offset(38)
            make.top.greaterThanOrEqualTo(stageImageBackgroundView.snp.bottom).offset(52)
            make.left.right.equalToSuperview().inset(52)
            make.height.equalTo(138)
        }

        quoteLabel.snp.remakeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(48)
            make.left.right.equalToSuperview().inset(72)
        }
    }

    private func applySunriseLayout() {
        headlineLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(54)
            make.left.right.equalToSuperview().inset(66)
        }

        dayCountLabel.snp.remakeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(54)
        }

        dayCaptionLabel.snp.remakeConstraints { make in
            make.top.equalTo(dayCountLabel.snp.bottom).offset(-8)
            make.left.right.equalToSuperview().inset(72)
        }

        statsStackView.snp.remakeConstraints { make in
            make.top.equalTo(dayCaptionLabel.snp.bottom).offset(34)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(132)
        }

        stageImageBackgroundView.snp.remakeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(38)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(250)
        }

        quoteLabel.snp.remakeConstraints { make in
            make.top.equalTo(stageImageBackgroundView.snp.bottom).offset(34)
            make.left.right.equalToSuperview().inset(70)
        }
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

}

private final class SGShareStatView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.72)
        layer.cornerRadius = 24
        layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = SGColor.textSecondary
        titleLabel.textAlignment = .center

        valueLabel.font = .systemFont(ofSize: 30, weight: .bold)
        valueLabel.textColor = SGColor.textDark
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 2
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(22)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview().inset(18)
        }
    }
}

private extension SGSharePosterStyle {

    var headline: String {
        switch self {
        case .garden:
            return "share.card.headline.garden".localized()
        case .fresh:
            return "share.card.headline.fresh".localized()
        case .sunrise:
            return "share.card.headline.sunrise".localized()
        }
    }

    var quote: String {
        switch self {
        case .garden:
            return "share.card.quote.garden".localized()
        case .fresh:
            return "share.card.quote.fresh".localized()
        case .sunrise:
            return "share.card.quote.sunrise".localized()
        }
    }

    func dayCaption(cleanDays: Int, habitName: String) -> String {
        switch self {
        case .garden:
            return cleanDays == 1 ? "share.card.caption.garden.one".localizedFormat(habitName) : "share.card.caption.garden.many".localizedFormat(habitName)
        case .fresh:
            return cleanDays == 1 ? "share.card.caption.fresh.one".localizedFormat(habitName) : "share.card.caption.fresh.many".localizedFormat(habitName)
        case .sunrise:
            return cleanDays == 1 ? "share.card.caption.sunrise.one".localizedFormat(habitName) : "share.card.caption.sunrise.many".localizedFormat(habitName)
        }
    }

    var gradientColors: [UIColor] {
        switch self {
        case .garden:
            return [
                UIColor.hexString("#FFF5DD"),
                UIColor.hexString("#F4FAEF"),
                UIColor.hexString("#E6F2E3")
            ]
        case .fresh:
            return [
                UIColor.hexString("#EEF9F4"),
                UIColor.hexString("#E7F3F7"),
                UIColor.hexString("#F8FDF9")
            ]
        case .sunrise:
            return [
                UIColor.hexString("#FFF0D6"),
                UIColor.hexString("#FFE8C8"),
                UIColor.hexString("#F3F8E7")
            ]
        }
    }

    var textureColor: UIColor {
        switch self {
        case .garden:
            return UIColor.hexString("#D8E7CC").withAlphaComponent(0.38)
        case .fresh:
            return UIColor.hexString("#BFDCD6").withAlphaComponent(0.42)
        case .sunrise:
            return UIColor.hexString("#EEC28C").withAlphaComponent(0.36)
        }
    }

    var panelColor: UIColor {
        switch self {
        case .garden:
            return UIColor.white.withAlphaComponent(0.58)
        case .fresh:
            return UIColor.hexString("#FCFFFD").withAlphaComponent(0.72)
        case .sunrise:
            return UIColor.hexString("#FFFDF7").withAlphaComponent(0.68)
        }
    }

    var imageBackgroundColor: UIColor {
        switch self {
        case .garden:
            return UIColor.hexString("#FFF2C7").withAlphaComponent(0.78)
        case .fresh:
            return UIColor.hexString("#DFF3EC").withAlphaComponent(0.88)
        case .sunrise:
            return UIColor.hexString("#FFE0AE").withAlphaComponent(0.8)
        }
    }

    var shadowColor: UIColor {
        switch self {
        case .garden:
            return UIColor.hexString("#8DA67B")
        case .fresh:
            return UIColor.hexString("#74A89E")
        case .sunrise:
            return UIColor.hexString("#C89058")
        }
    }

    var brandColor: UIColor {
        switch self {
        case .garden:
            return SGColor.primaryDark
        case .fresh:
            return UIColor.hexString("#2F655C")
        case .sunrise:
            return UIColor.hexString("#6B5734")
        }
    }

    var dayColor: UIColor {
        switch self {
        case .garden:
            return SGColor.textDark
        case .fresh:
            return UIColor.hexString("#2F655C")
        case .sunrise:
            return UIColor.hexString("#9A632D")
        }
    }

    var headlineAlignment: NSTextAlignment {
        switch self {
        case .garden, .sunrise:
            return .center
        case .fresh:
            return .left
        }
    }

    var dayAlignment: NSTextAlignment {
        switch self {
        case .garden, .sunrise:
            return .center
        case .fresh:
            return .left
        }
    }

    var quoteAlignment: NSTextAlignment {
        switch self {
        case .garden, .sunrise:
            return .center
        case .fresh:
            return .left
        }
    }

    var statsAxis: NSLayoutConstraint.Axis {
        .horizontal
    }

    var statsSpacing: CGFloat {
        switch self {
        case .garden:
            return 18
        case .fresh:
            return 16
        case .sunrise:
            return 14
        }
    }

    var dayFontSize: CGFloat {
        switch self {
        case .garden:
            return 196
        case .fresh:
            return 142
        case .sunrise:
            return 244
        }
    }

    var panelTopOffset: CGFloat {
        switch self {
        case .garden:
            return 48
        case .fresh, .sunrise:
            return 42
        }
    }
}
