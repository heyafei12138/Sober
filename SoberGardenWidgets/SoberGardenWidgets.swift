//
//  SoberGardenWidgets.swift
//  SoberGardenWidgets
//

import SwiftUI
import WidgetKit

struct SGWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SGWidgetSnapshot
}

struct SGWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SGWidgetEntry {
        SGWidgetEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SGWidgetEntry) -> Void) {
        completion(SGWidgetEntry(date: Date(), snapshot: SGWidgetSnapshotReader.shared.readSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SGWidgetEntry>) -> Void) {
        let entry = SGWidgetEntry(date: Date(), snapshot: SGWidgetSnapshotReader.shared.readSnapshot())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct SGStreakWidget: Widget {
    let kind = "SGStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SGWidgetProvider()) { entry in
            SGStreakWidgetView(entry: entry)
        }
        .configurationDisplayName(SGLoc("widget.streak.name"))
        .description(SGLoc("widget.streak.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SGGardenWidget: Widget {
    let kind = "SGGardenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SGWidgetProvider()) { entry in
            SGGardenWidgetView(entry: entry)
        }
        .configurationDisplayName(SGLoc("widget.garden.name"))
        .description(SGLoc("widget.garden.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SGRescueWidget: Widget {
    let kind = "SGRescueWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SGWidgetProvider()) { entry in
            SGRescueWidgetView(entry: entry)
        }
        .configurationDisplayName(SGLoc("widget.rescue.name"))
        .description(SGLoc("widget.rescue.description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct SoberGardenWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SGStreakWidget()
        SGGardenWidget()
        SGRescueWidget()
    }
}
