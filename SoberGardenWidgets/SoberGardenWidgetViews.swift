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
            VStack(alignment: .leading, spacing: family == .systemSmall ? 8 : 12) {
                SGWidgetHeader(title: "SoberGarden", icon: "leaf.fill")
                Spacer(minLength: 4)
                Text("\(entry.snapshot.cleanDays) Days Clean")
                    .font(family == .systemSmall ? .title2.bold() : .largeTitle.bold())
                    .foregroundStyle(SGWidgetPalette.text)
                    .minimumScaleFactor(0.72)
                Text(nextMilestoneText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SGWidgetPalette.secondary)
                if family == .systemMedium {
                    SGWidgetProgressLine(cleanDays: entry.snapshot.cleanDays, nextMilestone: entry.snapshot.nextMilestone)
                }
            }
        }
    }

    private var nextMilestoneText: String {
        guard let nextMilestone = entry.snapshot.nextMilestone else {
            return "Garden complete"
        }
        return "Next: \(nextMilestone) Days"
    }
}

struct SGGardenWidgetView: View {
    let entry: SGWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        SGWidgetContainer(url: URL(string: "sobergarden://garden")) {
            HStack(spacing: family == .systemSmall ? 0 : 16) {
                VStack(alignment: .leading, spacing: 8) {
                    SGWidgetHeader(title: "Garden", icon: "camera.macro")
                    Spacer(minLength: 4)
                    Text("Your garden is growing.")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SGWidgetPalette.text)
                        .lineLimit(2)
                    Text("Day \(entry.snapshot.cleanDays)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SGWidgetPalette.secondary)
                    if family == .systemMedium {
                        Text(entry.snapshot.gardenStage.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SGWidgetPalette.primary)
                    }
                }
                Spacer(minLength: 8)
                if family == .systemMedium {
                    SGGardenStageMark(stage: entry.snapshot.gardenStage, size: 82)
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
            VStack(alignment: .leading, spacing: 10) {
                SGWidgetHeader(title: "Rescue", icon: "lifepreserver.fill", tint: SGWidgetPalette.rescue)
                Spacer(minLength: 4)
                Text("Struggling?")
                    .font(family == .systemSmall ? .title2.bold() : .largeTitle.bold())
                    .foregroundStyle(SGWidgetPalette.text)
                    .minimumScaleFactor(0.75)
                Text("Open Rescue")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(SGWidgetPalette.rescue))
                if family == .systemMedium {
                    Text("Take a few steady minutes before choosing.")
                        .font(.caption)
                        .foregroundStyle(SGWidgetPalette.secondary)
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

struct SGGardenStageMark: View {
    let stage: SGWidgetGardenStage
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.65))
            Image(systemName: stage.symbolName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(SGWidgetPalette.primary)
        }
        .frame(width: size, height: size)
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

#Preview(as: .systemSmall) {
    SGStreakWidget()
} timeline: {
    SGWidgetEntry(date: .now, snapshot: SGWidgetSnapshot(cleanDays: 7, nextMilestone: 14, gardenStage: .youngPlant, habitDisplayName: "Smoking", updatedAt: .now))
}
