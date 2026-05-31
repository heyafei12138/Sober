//
//  SGWatchSnapshotReader.swift
//  SoberGardenWatch
//

import Foundation

func SGLoc(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: key, comment: "")
}

enum SGWatchGardenStage: String, Codable {
    case seed
    case sprout
    case youngPlant
    case flower
    case gardenBed
    case bloomingGarden
    case peacefulGarden
    case smallForest
    case sanctuary
}

struct SGWatchSnapshot: Codable {
    var cleanDays: Int
    var nextMilestone: Int?
    var gardenStage: SGWatchGardenStage
    var habitDisplayName: String
    var updatedAt: Date

    static let placeholder = SGWatchSnapshot(
        cleanDays: 0,
        nextMilestone: nil,
        gardenStage: .seed,
        habitDisplayName: SGLoc("habit.generic"),
        updatedAt: Date()
    )
}

final class SGWatchSnapshotReader {

    static let shared = SGWatchSnapshotReader()

    private static let appGroupIdentifier = "group.com.Sober.SoberGarden"
    private static let snapshotKey = "sober_garden_widget_snapshot"

    private let decoder: JSONDecoder
    private let appGroupDefaults: UserDefaults?
    private let fallbackDefaults: UserDefaults

    private init(
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: SGWatchSnapshotReader.appGroupIdentifier),
        fallbackDefaults: UserDefaults = .standard
    ) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        self.appGroupDefaults = appGroupDefaults
        self.fallbackDefaults = fallbackDefaults
    }

    func readSnapshot() -> SGWatchSnapshot {
        if let data = appGroupDefaults?.data(forKey: Self.snapshotKey),
           let snapshot = try? decoder.decode(SGWatchSnapshot.self, from: data) {
            return snapshot
        }

        if let data = fallbackDefaults.data(forKey: Self.snapshotKey),
           let snapshot = try? decoder.decode(SGWatchSnapshot.self, from: data) {
            return snapshot
        }

        return .placeholder
    }
}
