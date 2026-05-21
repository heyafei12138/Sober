//
//  SGWidgetSnapshotReader.swift
//  SoberGardenWidgets
//

import Foundation

enum SGWidgetGardenStage: String, Codable {
    case seed
    case sprout
    case youngPlant
    case flower
    case gardenBed
    case bloomingGarden
    case peacefulGarden
    case smallForest
    case sanctuary

    var title: String {
        switch self {
        case .seed:
            return "Seed"
        case .sprout:
            return "Sprout"
        case .youngPlant:
            return "Young Plant"
        case .flower:
            return "Flower"
        case .gardenBed:
            return "Garden Bed"
        case .bloomingGarden:
            return "Blooming Garden"
        case .peacefulGarden:
            return "Peaceful Garden"
        case .smallForest:
            return "Small Forest"
        case .sanctuary:
            return "Sanctuary"
        }
    }

    var symbolName: String {
        switch self {
        case .seed:
            return "circle.hexagongrid"
        case .sprout, .youngPlant:
            return "leaf"
        case .flower, .gardenBed, .bloomingGarden:
            return "camera.macro"
        case .peacefulGarden, .smallForest, .sanctuary:
            return "tree"
        }
    }
}

struct SGWidgetSnapshot: Codable {
    var cleanDays: Int
    var nextMilestone: Int?
    var gardenStage: SGWidgetGardenStage
    var habitDisplayName: String
    var updatedAt: Date

    static let placeholder = SGWidgetSnapshot(
        cleanDays: 0,
        nextMilestone: nil,
        gardenStage: .seed,
        habitDisplayName: "Habit",
        updatedAt: Date()
    )
}

final class SGWidgetSnapshotReader {

    static let shared = SGWidgetSnapshotReader()

    private static let appGroupIdentifier = "group.com.Sober.SoberGarden"
    private static let snapshotKey = "sober_garden_widget_snapshot"

    private let decoder: JSONDecoder
    private let appGroupDefaults: UserDefaults?
    private let fallbackDefaults: UserDefaults

    private init(
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: SGWidgetSnapshotReader.appGroupIdentifier),
        fallbackDefaults: UserDefaults = .standard
    ) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        self.appGroupDefaults = appGroupDefaults
        self.fallbackDefaults = fallbackDefaults
    }

    func readSnapshot() -> SGWidgetSnapshot {
        if let data = appGroupDefaults?.data(forKey: Self.snapshotKey),
           let snapshot = try? decoder.decode(SGWidgetSnapshot.self, from: data) {
            return snapshot
        }

        if let data = fallbackDefaults.data(forKey: Self.snapshotKey),
           let snapshot = try? decoder.decode(SGWidgetSnapshot.self, from: data) {
            return snapshot
        }

        return .placeholder
    }
}
