//
//  SGDailyGardenGridView.swift
//  SoberGarden
//

import UIKit

final class SGDailyGardenGridView: UIView {

    private struct GridLayout: Equatable {
        let rowCount: Int
        let columnCount: Int
        let dotSize: CGFloat
        let cellSize: CGFloat
        let itemSpacing: CGFloat
        let isLeadingAligned: Bool

        var itemCount: Int {
            rowCount * columnCount
        }
    }

    private let cardView = SGCardView()
    private let headerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let rangeButton = UIButton(type: .system)
    private let subtitleLabel = UILabel()
    private let gridStackView = UIStackView()
    private var currentLayout: GridLayout?
    private var dayViews: [SGDailyGardenDayView] = []
    var onRangeTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(items: [DailyDayItem], selectedDays: Int, rangeTitle: String) {
        let layout = Self.gridLayout(for: selectedDays)
        rebuildGridIfNeeded(layout: layout)
        var attributedTitle = AttributedString(rangeTitle)
        attributedTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        rangeButton.configuration?.attributedTitle = attributedTitle
        rangeButton.accessibilityLabel = "home.dailyGardenGrid.rangeButton.accessibilityFormat".localizedFormat(rangeTitle)

        let displayItems = Array(items.prefix(layout.itemCount))

        for index in dayViews.indices {
            if index < displayItems.count {
                dayViews[index].configure(with: displayItems[index])
                dayViews[index].isHidden = false
            } else {
                dayViews[index].configureEmpty()
                dayViews[index].isHidden = true
            }
        }
    }

    private func setupView() {
        cardView.setContentInsets(.zero)
        cardView.contentView.backgroundColor = UIColor.hexString("#FBFDF8")

        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.distribution = .fill
        headerStackView.spacing = 12

        titleLabel.text = "home.dailyGardenGrid.title".localized()
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.86

        var rangeConfiguration = UIButton.Configuration.filled()
        rangeConfiguration.baseForegroundColor = SGColor.primary
        rangeConfiguration.baseBackgroundColor = UIColor.hexString("#EEF6EC")
        rangeConfiguration.cornerStyle = .capsule
        rangeConfiguration.image = UIImage(systemName: "chevron.down")
        rangeConfiguration.imagePlacement = .trailing
        rangeConfiguration.imagePadding = 4
        rangeConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        rangeButton.configuration = rangeConfiguration
        rangeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        rangeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        rangeButton.addTarget(self, action: #selector(handleRangeButtonTapped), for: .touchUpInside)

        subtitleLabel.text = "home.dailyGardenGrid.subtitle".localized()
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping

        gridStackView.axis = .vertical
        gridStackView.alignment = .fill
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 5

        addSubview(cardView)
        cardView.contentView.addSubview(headerStackView)
        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(rangeButton)
        cardView.contentView.addSubview(subtitleLabel)
        cardView.contentView.addSubview(gridStackView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(18)
        }

        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(18)
        }
        rebuildGridIfNeeded(layout: Self.gridLayout(for: 30))
    }

    @objc private func handleRangeButtonTapped() {
        onRangeTap?()
    }

    private func rebuildGridIfNeeded(layout: GridLayout) {
        guard currentLayout != layout else { return }
        currentLayout = layout
        gridStackView.arrangedSubviews.forEach { rowView in
            gridStackView.removeArrangedSubview(rowView)
            rowView.removeFromSuperview()
        }
        dayViews.removeAll()

        for _ in 0..<layout.rowCount {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .center
            rowStackView.distribution = layout.isLeadingAligned ? .fill : .fillEqually
            rowStackView.spacing = layout.itemSpacing
            gridStackView.addArrangedSubview(rowStackView)

            for _ in 0..<layout.columnCount {
                let dayView = SGDailyGardenDayView()
                dayView.setDotSize(layout.dotSize)
                dayView.configureEmpty()
                dayView.setContentHuggingPriority(.required, for: .horizontal)
                dayView.setContentCompressionResistancePriority(.required, for: .horizontal)
                rowStackView.addArrangedSubview(dayView)
                dayViews.append(dayView)

                dayView.snp.makeConstraints { make in
                    if layout.isLeadingAligned {
                        make.size.equalTo(layout.cellSize)
                    } else {
                        make.height.equalTo(dayView.snp.width)
                    }
                }
            }

            if layout.isLeadingAligned {
                let trailingSpacerView = UIView()
                trailingSpacerView.backgroundColor = .clear
                trailingSpacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                trailingSpacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                rowStackView.addArrangedSubview(trailingSpacerView)
            }
        }
    }

    private static func gridLayout(for days: Int) -> GridLayout {
        switch days {
        case ...3:
            return GridLayout(rowCount: 1, columnCount: 3, dotSize: 22, cellSize: 30, itemSpacing: 8, isLeadingAligned: true)
        case 4...7:
            return GridLayout(rowCount: 1, columnCount: 7, dotSize: 17, cellSize: 24, itemSpacing: 6, isLeadingAligned: false)
        case 8...14:
            return GridLayout(rowCount: 2, columnCount: 7, dotSize: 17, cellSize: 24, itemSpacing: 6, isLeadingAligned: false)
        case 15...30:
            return GridLayout(rowCount: 3, columnCount: 10, dotSize: 17, cellSize: 23, itemSpacing: 5, isLeadingAligned: false)
        case 31...60:
            return GridLayout(rowCount: 5, columnCount: 12, dotSize: 14, cellSize: 20, itemSpacing: 5, isLeadingAligned: false)
        case 61...90:
            return GridLayout(rowCount: 6, columnCount: 15, dotSize: 12, cellSize: 17, itemSpacing: 4, isLeadingAligned: false)
        case 91...180:
            return GridLayout(rowCount: 10, columnCount: 18, dotSize: 10, cellSize: 14, itemSpacing: 3, isLeadingAligned: false)
        default:
            return GridLayout(rowCount: 15, columnCount: 25, dotSize: 8, cellSize: 11, itemSpacing: 2, isLeadingAligned: false)
        }
    }
}

private final class SGDailyGardenDayView: UIView {

    private enum Color {
        static let planted = UIColor.hexString("#4CAF50")
        static let plantedBorder = UIColor.hexString("#2F8D34")
        static let rainy = UIColor.hexString("#5F7F95")
        static let rainyBorder = UIColor.hexString("#3F6378")
        static let empty = UIColor.hexString("#D9DEDA")
        static let future = UIColor.hexString("#ECEFEA")
        static let todayBorder = UIColor.hexString("#16291F")
    }

    private let dotView = UIView()
    private let todayLabel = UILabel()
    private var dotSizeConstraint: Constraint?

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
        dotView.layer.cornerRadius = min(dotView.bounds.width, dotView.bounds.height) / 2
    }

    func configure(with item: DailyDayItem) {
        dotView.backgroundColor = color(for: item.status)
        dotView.layer.borderWidth = borderWidth(for: item)
        dotView.layer.borderColor = borderColor(for: item).cgColor
        todayLabel.isHidden = item.isToday == false
        accessibilityLabel = accessibilityText(for: item)
    }

    func configureEmpty() {
        dotView.backgroundColor = Color.future
        dotView.layer.borderWidth = 0
        dotView.layer.borderColor = UIColor.clear.cgColor
        todayLabel.isHidden = true
        accessibilityLabel = nil
    }

    func setDotSize(_ size: CGFloat) {
        dotSizeConstraint?.update(offset: size)
        todayLabel.font = .systemFont(ofSize: max(size * 0.52, 5), weight: .bold)
    }

    private func setupView() {
        backgroundColor = .clear
        dotView.layer.masksToBounds = true
        isAccessibilityElement = true
        accessibilityTraits = .staticText

        todayLabel.text = "T"
        todayLabel.font = .systemFont(ofSize: 9, weight: .bold)
        todayLabel.textColor = .white
        todayLabel.textAlignment = .center
        todayLabel.isHidden = true
        todayLabel.isAccessibilityElement = false

        addSubview(dotView)
        dotView.addSubview(todayLabel)
        dotView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            dotSizeConstraint = make.size.equalTo(17).constraint
        }
        todayLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func color(for status: DailyDayItem.Status) -> UIColor {
        switch status {
        case .planted:
            return Color.planted
        case .rainy:
            return Color.rainy
        case .empty:
            return Color.empty
        case .future:
            return Color.future
        }
    }

    private func borderWidth(for item: DailyDayItem) -> CGFloat {
        if item.isToday {
            return 2
        }

        switch item.status {
        case .planted, .rainy:
            return 1.5
        case .empty, .future:
            return 0
        }
    }

    private func borderColor(for item: DailyDayItem) -> UIColor {
        if item.isToday {
            return Color.todayBorder
        }

        switch item.status {
        case .planted:
            return Color.plantedBorder
        case .rainy:
            return Color.rainyBorder
        case .empty, .future:
            return .clear
        }
    }

    private func accessibilityText(for item: DailyDayItem) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let status: String
        switch item.status {
        case .planted:
            status = "dailyPlant.dayStatus.planted".localized()
        case .rainy:
            status = "dailyPlant.dayStatus.rainy".localized()
        case .empty:
            status = "dailyPlant.dayStatus.empty".localized()
        case .future:
            status = "dailyPlant.dayStatus.future".localized()
        }

        if item.isToday {
            return "\(formatter.string(from: item.date)), \(status), \("common.today".localized())"
        }
        return "\(formatter.string(from: item.date)), \(status)"
    }
}
