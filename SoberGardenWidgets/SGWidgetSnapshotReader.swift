//
//  SGWidgetSnapshotReader.swift
//  SoberGardenWidgets
//

import Foundation

func SGLoc(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: key, comment: "")
}

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
            return SGLoc("garden.stage.seed")
        case .sprout:
            return SGLoc("garden.stage.sprout")
        case .youngPlant:
            return SGLoc("garden.stage.youngPlant")
        case .flower:
            return SGLoc("garden.stage.flower")
        case .gardenBed:
            return SGLoc("garden.stage.gardenBed")
        case .bloomingGarden:
            return SGLoc("garden.stage.bloomingGarden")
        case .peacefulGarden:
            return SGLoc("garden.stage.peacefulGarden")
        case .smallForest:
            return SGLoc("garden.stage.smallForest")
        case .sanctuary:
            return SGLoc("garden.stage.sanctuary")
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
        habitDisplayName: SGLoc("habit.generic"),
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
