//
//  SoberGardenWidgetViews.swift
//  SoberGardenWidgets
//

import SwiftUI
import WidgetKit

struct SGStreakWidgetView: View {
    let entry: SGWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        SGWidgetContainer(url: URL(string: "sobergarden://home")) {
            ZStack(alignment: .bottomTrailing) {
                SGWidgetDecorativeImage(
                    name: entry.snapshot.gardenStage.treeAssetName,
                    size: family == .systemSmall ? 76 : 102,
                    opacity: 0.28
                )
                .offset(x: family == .systemSmall ? 20 : 28, y: family == .systemSmall ? 18 : 20)

                VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 12) {
                    SGWidgetHeader(title: "SoberGarden", icon: "leaf.fill")
                    Spacer(minLength: 4)
                    Text(String(format: SGLoc("widget.cleanDaysFormat"), entry.snapshot.cleanDays))
                        .font(family == .systemSmall ? .title2.bold() : .largeTitle.bold())
                        .foregroundStyle(SGWidgetPalette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                        .layoutPriority(2)
                    Text(nextMilestoneText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SGWidgetPalette.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    if family == .systemMedium {
                        SGWidgetProgressLine(cleanDays: entry.snapshot.cleanDays, nextMilestone: entry.snapshot.nextMilestone)
                    }
                }
            }
        }
    }

    private var nextMilestoneText: String {
        guard let nextMilestone = entry.snapshot.nextMilestone else {
            return SGLoc("widget.gardenComplete")
        }
        return String(format: SGLoc("widget.nextMilestoneFormat"), nextMilestone)
    }
}

struct SGGardenWidgetView: View {
    let entry: SGWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        SGWidgetContainer(url: URL(string: "sobergarden://garden")) {
            if family == .systemSmall {
                VStack(alignment: .leading, spacing: 6) {
                    SGWidgetHeader(title: SGLoc("tab.garden"), icon: "camera.macro")
                    Text(SGLoc("widget.gardenGrowing"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(SGWidgetPalette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                        .layoutPriority(2)
                    Spacer(minLength: 0)
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(String(format: SGLoc("garden.dayFormat"), entry.snapshot.cleanDays))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SGWidgetPalette.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Spacer(minLength: 0)
                        SGGardenStageArtwork(stage: entry.snapshot.gardenStage, size: 64)
                    }
                }
            } else {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 7) {
                        SGWidgetHeader(title: SGLoc("tab.garden"), icon: "camera.macro")
                        Text(SGLoc("widget.gardenGrowingBody"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(SGWidgetPalette.text)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .layoutPriority(2)
                        Text(String(format: SGLoc("widget.gardenDetailFormat"), entry.snapshot.cleanDays, entry.snapshot.gardenStage.title))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SGWidgetPalette.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                    Spacer(minLength: 0)
                    SGGardenStageArtwork(stage: entry.snapshot.gardenStage, size: 108)
                }
            }
        }
    }
}

struct SGRescueWidgetView: View {
    let entry: SGWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        SGWidgetContainer(url: URL(string: "sobergarden://rescue")) {
            ZStack(alignment: .bottomTrailing) {
                SGWidgetDecorativeImage(
                    name: "guider_icon_kittle",
                    size: family == .systemSmall ? 68 : 90,
                    opacity: 0.34
                )
                .offset(x: family == .systemSmall ? 20 : 18, y: family == .systemSmall ? 12 : 14)

                VStack(alignment: .leading, spacing: 10) {
                    SGWidgetHeader(title: SGLoc("tab.rescue"), icon: "lifepreserver.fill", tint: SGWidgetPalette.rescue)
                    Spacer(minLength: 4)
                    Text(SGLoc("widget.rescue.question"))
                        .font(family == .systemSmall ? .title2.bold() : .largeTitle.bold())
                        .foregroundStyle(SGWidgetPalette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(SGLoc("common.open"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(SGWidgetPalette.rescue))
                    if family == .systemMedium {
                        Text(SGLoc("widget.rescue.body"))
                            .font(.caption)
                            .foregroundStyle(SGWidgetPalette.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                }
            }
        }
    }
}

struct SGWidgetContainer<Content: View>: View {
    let url: URL?
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [
                        SGWidgetPalette.background,
                        SGWidgetPalette.greenWash
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .widgetURL(url)
    }
}

struct SGWidgetHeader: View {
    let title: String
    let icon: String
    var tint: Color = SGWidgetPalette.primary

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(SGWidgetPalette.secondary)
        }
    }
}

struct SGGardenStageArtwork: View {
    let stage: SGWidgetGardenStage
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.78),
                            SGWidgetPalette.greenWash.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: SGWidgetPalette.primary.opacity(0.12), radius: 8, x: 0, y: 4)

            Image("guider_icon_grass")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.76, height: size * 0.28)
                .offset(y: size * 0.25)

            Image(stage.baseAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: size * stage.assetScale, height: size * stage.assetScale)
                .offset(y: stage.assetYOffset(for: size))

            if let accentAssetName = stage.accentAssetName {
                Image(accentAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.36, height: size * 0.36)
                    .offset(x: -size * 0.24, y: size * 0.16)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SGWidgetDecorativeImage: View {
    let name: String
    let size: CGFloat
    let opacity: Double

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .opacity(opacity)
            .accessibilityHidden(true)
    }
}

struct SGWidgetProgressLine: View {
    let cleanDays: Int
    let nextMilestone: Int?

    var body: some View {
        GeometryReader { proxy in
            let progress = progressValue
            ZStack(alignment: .leading) {
                Capsule().fill(SGWidgetPalette.primary.opacity(0.18))
                Capsule()
                    .fill(SGWidgetPalette.primary)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 8)
    }

    private var progressValue: CGFloat {
        guard let nextMilestone, nextMilestone > 0 else { return 1 }
        return min(max(CGFloat(cleanDays) / CGFloat(nextMilestone), 0), 1)
    }
}

enum SGWidgetPalette {
    static let background = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let greenWash = Color(red: 0.90, green: 0.94, blue: 0.86)
    static let primary = Color(red: 0.37, green: 0.49, blue: 0.27)
    static let rescue = Color(red: 0.91, green: 0.61, blue: 0.36)
    static let text = Color(red: 0.19, green: 0.25, blue: 0.17)
    static let secondary = text.opacity(0.66)
}

private extension SGWidgetGardenStage {

    var baseAssetName: String {
        switch self {
        case .seed:
            return "guider_icon_flowerpot"
        case .sprout:
            return "guider_icon_singleFlower"
        case .youngPlant:
            return "guider_icon_flower"
        case .flower, .gardenBed:
            return "guider_icon_flower1"
        case .bloomingGarden:
            return "guider_icon_tree"
        case .peacefulGarden, .smallForest, .sanctuary:
            return "guider_icon_tree1"
        }
    }

    var accentAssetName: String? {
        switch self {
        case .seed, .sprout, .youngPlant:
            return nil
        case .flower, .gardenBed:
            return "guider_icon_singleFlower"
        case .bloomingGarden, .peacefulGarden:
            return "guider_icon_flower"
        case .smallForest, .sanctuary:
            return "guider_icon_flower1"
        }
    }

    var treeAssetName: String {
        switch self {
        case .seed, .sprout, .youngPlant, .flower, .gardenBed:
            return "guider_icon_flower"
        case .bloomingGarden:
            return "guider_icon_tree"
        case .peacefulGarden, .smallForest, .sanctuary:
            return "guider_icon_tree1"
        }
    }

    var assetScale: CGFloat {
        switch self {
        case .seed:
            return 0.52
        case .sprout, .youngPlant:
            return 0.62
        case .flower, .gardenBed:
            return 0.7
        case .bloomingGarden, .peacefulGarden, .smallForest, .sanctuary:
            return 0.78
        }
    }

    func assetYOffset(for size: CGFloat) -> CGFloat {
        switch self {
        case .seed:
            return size * 0.08
        case .sprout, .youngPlant, .flower, .gardenBed:
            return size * 0.02
        case .bloomingGarden, .peacefulGarden, .smallForest, .sanctuary:
            return -size * 0.02
        }
    }
}

#Preview(as: .systemSmall) {
    SGStreakWidget()
} timeline: {
    SGWidgetEntry(date: .now, snapshot: SGWidgetSnapshot(cleanDays: 7, nextMilestone: 14, gardenStage: .youngPlant, habitDisplayName: "Smoking", updatedAt: .now))
}
