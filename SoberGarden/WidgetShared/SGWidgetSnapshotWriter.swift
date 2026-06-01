//
//  SGWidgetSnapshotWriter.swift
//  SoberGarden
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

final class SGWidgetSnapshotWriter {

    static let shared = SGWidgetSnapshotWriter()

    static let appGroupIdentifier = "group.com.Sober.SoberGarden"
    static let snapshotKey = "sober_garden_widget_snapshot"

    private let encoder: JSONEncoder
    private let appGroupDefaults: UserDefaults?
    private let fallbackDefaults: UserDefaults

    private init(
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: SGWidgetSnapshotWriter.appGroupIdentifier),
        fallbackDefaults: UserDefaults = .standard
    ) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        self.appGroupDefaults = appGroupDefaults
        self.fallbackDefaults = fallbackDefaults
    }

    func writeSnapshot(for state: SoberGardenState, now: Date = Date(), calendar: Calendar = .current) {
        guard let habit = state.habit else {
            clearSnapshot()
            return
        }

        let cleanDays = SGProgressCalculator.currentStreakDays(
            startDate: habit.startDate,
            now: now,
            calendar: calendar
        )
        let snapshot = WidgetSnapshot(
            cleanDays: cleanDays,
            nextMilestone: SGProgressCalculator.nextMilestone(for: cleanDays)?.day,
            gardenStage: SGProgressCalculator.currentGardenStage(for: cleanDays),
            habitDisplayName: habit.displayName,
            updatedAt: now,
            todayStatus: Self.todayStatus(from: state.dailyRecords, now: now, calendar: calendar)
        )

        do {
            let data = try encoder.encode(snapshot)
            write(data)
        } catch {
            debugPrint("Failed to encode widget snapshot: \(error)")
        }
    }

    func clearSnapshot() {
        fallbackDefaults.removeObject(forKey: Self.snapshotKey)
        appGroupDefaults?.removeObject(forKey: Self.snapshotKey)
        reloadWidgetTimelines()
    }

    private func write(_ data: Data) {
        fallbackDefaults.set(data, forKey: Self.snapshotKey)
        appGroupDefaults?.set(data, forKey: Self.snapshotKey)
        reloadWidgetTimelines()
    }

    private func reloadWidgetTimelines() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private static func todayStatus(
        from records: [DailyRecord],
        now: Date,
        calendar: Calendar
    ) -> DailyRecordStatus? {
        let normalizedDate = calendar.startOfDay(for: now)
        let dayKey = DailyRecord.dayKey(for: now, calendar: calendar)

        return records
            .filter { record in
                record.dayKey == dayKey || calendar.isDate(record.date, inSameDayAs: normalizedDate)
            }
            .max { lhs, rhs in
                lhs.updatedAt < rhs.updatedAt
            }?
            .status
    }
}
