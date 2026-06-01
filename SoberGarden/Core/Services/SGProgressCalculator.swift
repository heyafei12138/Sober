//
//  SGProgressCalculator.swift
//  SoberGarden
//

import Foundation

struct DailyDayItem: Equatable {
    enum Status: Equatable {
        case planted
        case rainy
        case empty
        case future
    }

    let date: Date
    let status: Status
    let isToday: Bool
}

enum SGProgressCalculator {

    private static let secondsPerDay: TimeInterval = 86_400

    static func currentStreakDays(
        startDate: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard startDate <= now else { return 1 }

        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfNow = calendar.startOfDay(for: now)
        let elapsedCalendarDays = calendar.dateComponents([.day], from: startOfStartDate, to: startOfNow).day ?? 0

        return max(elapsedCalendarDays + 1, 1)
    }

    static func elapsedCleanDaysForSavings(startDate: Date, now: Date = Date()) -> Int {
        guard startDate <= now else { return 0 }

        let elapsedSeconds = now.timeIntervalSince(startDate)
        return max(Int(floor(elapsedSeconds / secondsPerDay)), 0)
    }

    static func nextMilestone(for cleanDays: Int) -> Milestone? {
        Milestone.defaultMilestones.first { milestone in
            milestone.day > cleanDays
        }
    }

    static func currentGardenStage(for cleanDays: Int) -> GardenStage {
        let effectiveCleanDays = max(cleanDays, 1)

        return Milestone.defaultMilestones
            .last { milestone in
                milestone.day <= effectiveCleanDays
            }?
            .gardenStage ?? .seed
    }

    static func dailyGardenAutomaticDisplayDays(for cleanDays: Int) -> Int {
        let effectiveCleanDays = max(cleanDays, 1)

        return nextMilestone(for: effectiveCleanDays)?.day ?? Milestone.defaultMilestones.last?.day ?? 30
    }

    static func moneySaved(dailyCost: Double, cleanDays: Int) -> Double {
        guard dailyCost > 0, cleanDays > 0 else { return 0 }
        return dailyCost * Double(cleanDays)
    }

    static func timeSavedMinutes(dailyMinutes: Int, cleanDays: Int) -> Int {
        guard dailyMinutes > 0, cleanDays > 0 else { return 0 }
        return dailyMinutes * cleanDays
    }

    static func recentDailyItems(
        records: [DailyRecord],
        count: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [DailyDayItem] {
        guard count > 0 else { return [] }

        let today = calendar.startOfDay(for: now)
        let startOffset = 1 - count

        return (startOffset...0).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                return nil
            }

            return DailyDayItem(
                date: date,
                status: dailyItemStatus(for: date, records: records, today: today, calendar: calendar),
                isToday: calendar.isDate(date, inSameDayAs: today)
            )
        }
    }

    static func journeyDailyItems(
        records: [DailyRecord],
        startDate: Date,
        count: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [DailyDayItem] {
        guard count > 0 else { return [] }

        let journeyStartDate = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: now)

        return (0..<count).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: journeyStartDate) else {
                return nil
            }

            return DailyDayItem(
                date: date,
                status: dailyItemStatus(for: date, records: records, today: today, calendar: calendar),
                isToday: calendar.isDate(date, inSameDayAs: today)
            )
        }
    }

    static func contextualDailyItems(
        records: [DailyRecord],
        startDate: Date,
        count: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [DailyDayItem] {
        guard count > 0 else { return [] }

        let journeyStartDate = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: now)
        let recentStartDate = calendar.date(byAdding: .day, value: 1 - count, to: today) ?? today
        let displayStartDate = max(journeyStartDate, recentStartDate)

        return (0..<count).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: displayStartDate) else {
                return nil
            }

            return DailyDayItem(
                date: date,
                status: dailyItemStatus(for: date, records: records, today: today, calendar: calendar),
                isToday: calendar.isDate(date, inSameDayAs: today)
            )
        }
    }

    static func dailyPlantStreak(
        records: [DailyRecord],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let today = calendar.startOfDay(for: now)

        switch dailyRecordStatus(for: today, records: records, calendar: calendar) {
        case .planted:
            return countBackwardPlantedDays(from: today, records: records, calendar: calendar)
        case .rainy:
            return 0
        case nil:
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  dailyRecordStatus(for: yesterday, records: records, calendar: calendar) == .planted else {
                return 0
            }
            return countBackwardPlantedDays(from: yesterday, records: records, calendar: calendar)
        }
    }

    static func totalPlantedDays(records: [DailyRecord]) -> Int {
        totalDays(records: records, matching: .planted)
    }

    static func totalRainyDays(records: [DailyRecord]) -> Int {
        totalDays(records: records, matching: .rainy)
    }

    private static func dailyItemStatus(
        for date: Date,
        records: [DailyRecord],
        today: Date,
        calendar: Calendar
    ) -> DailyDayItem.Status {
        if date > today {
            return .future
        }

        switch dailyRecordStatus(for: date, records: records, calendar: calendar) {
        case .planted:
            return .planted
        case .rainy:
            return .rainy
        case nil:
            return .empty
        }
    }

    private static func countBackwardPlantedDays(
        from anchorDate: Date,
        records: [DailyRecord],
        calendar: Calendar
    ) -> Int {
        var count = 0
        var cursor = calendar.startOfDay(for: anchorDate)

        while dailyRecordStatus(for: cursor, records: records, calendar: calendar) == .planted {
            count += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previousDay
        }

        return count
    }

    private static func dailyRecordStatus(
        for date: Date,
        records: [DailyRecord],
        calendar: Calendar
    ) -> DailyRecordStatus? {
        let dayKey = DailyRecord.dayKey(for: date, calendar: calendar)
        return canonicalRecordByDay(records: records, calendar: calendar)[dayKey]?.status
    }

    private static func totalDays(records: [DailyRecord], matching status: DailyRecordStatus) -> Int {
        canonicalRecordByDay(records: records, calendar: .current)
            .values
            .filter { $0.status == status }
            .count
    }

    private static func canonicalRecordByDay(
        records: [DailyRecord],
        calendar: Calendar
    ) -> [String: DailyRecord] {
        records.reduce(into: [:]) { result, record in
            let key = DailyRecord.dayKey(for: record.date, calendar: calendar)
            guard let existingRecord = result[key] else {
                result[key] = record
                return
            }

            if record.updatedAt >= existingRecord.updatedAt {
                result[key] = record
            }
        }
    }
}

#if DEBUG
extension SGProgressCalculator {

    static func runDebugAssertions() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let sameDayStart = calendar.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 8))!
        let sameDayNow = calendar.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 20))!
        assert(
            currentStreakDays(startDate: sameDayStart, now: sameDayNow, calendar: calendar) == 1,
            "Same-day streak should display as Day 1."
        )

        let yesterdayStart = calendar.date(from: DateComponents(year: 2026, month: 5, day: 19, hour: 23))!
        let todayNow = calendar.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 1))!
        assert(
            currentStreakDays(startDate: yesterdayStart, now: todayNow, calendar: calendar) == 2,
            "Crossing a calendar day should display as the next positive streak day."
        )

        assert(
            currentGardenStage(for: 7) == .youngPlant,
            "Seven clean days should map to Young Plant."
        )

        assert(
            nextMilestone(for: 7)?.day == 14,
            "The next milestone after day 7 should be day 14."
        )

        let today = calendar.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: today)!

        let records = [
            debugDailyRecord(date: today, status: .planted, calendar: calendar),
            debugDailyRecord(date: yesterday, status: .planted, calendar: calendar),
            debugDailyRecord(date: twoDaysAgo, status: .rainy, calendar: calendar),
            debugDailyRecord(date: fourDaysAgo, status: .planted, calendar: calendar)
        ]

        let dailyItems = recentDailyItems(records: records, count: 5, now: today, calendar: calendar)
        assert(dailyItems.map(\.status) == [.empty, .planted, .rainy, .planted, .planted])
        assert(dailyItems.last?.isToday == true)
        assert(dailyItems.first?.isToday == false)

        let journeyItems = journeyDailyItems(records: records, startDate: fourDaysAgo, count: 5, now: today, calendar: calendar)
        assert(journeyItems.map(\.status) == [.planted, .empty, .rainy, .planted, .planted])
        assert(journeyItems.first?.date == calendar.startOfDay(for: fourDaysAgo))
        assert(journeyItems.last?.isToday == true)

        let firstDayContextItems = contextualDailyItems(records: records, startDate: today, count: 3, now: today, calendar: calendar)
        assert(firstDayContextItems.map(\.status) == [.planted, .future, .future])
        assert(firstDayContextItems.first?.isToday == true)

        let matureContextItems = contextualDailyItems(records: records, startDate: fourDaysAgo, count: 3, now: today, calendar: calendar)
        assert(matureContextItems.map(\.status) == [.rainy, .planted, .planted])
        assert(matureContextItems.last?.isToday == true)

        assert(dailyPlantStreak(records: records, now: today, calendar: calendar) == 2)
        assert(dailyPlantStreak(records: Array(records.dropFirst()), now: today, calendar: calendar) == 1)
        assert(
            dailyPlantStreak(records: [debugDailyRecord(date: today, status: .rainy, calendar: calendar)], now: today, calendar: calendar) == 0
        )
        assert(totalPlantedDays(records: records) == 3)
        assert(totalRainyDays(records: records) == 1)

        let duplicateDayRecords = [
            debugDailyRecord(
                date: today,
                status: .planted,
                calendar: calendar,
                updatedAt: today
            ),
            debugDailyRecord(
                date: today,
                status: .rainy,
                calendar: calendar,
                updatedAt: today.addingTimeInterval(60)
            )
        ]
        assert(dailyPlantStreak(records: duplicateDayRecords, now: today, calendar: calendar) == 0)
        assert(totalPlantedDays(records: duplicateDayRecords) == 0)
        assert(totalRainyDays(records: duplicateDayRecords) == 1)
    }

    private static func debugDailyRecord(
        date: Date,
        status: DailyRecordStatus,
        calendar: Calendar,
        updatedAt: Date? = nil
    ) -> DailyRecord {
        DailyRecord(
            id: UUID(),
            date: calendar.startOfDay(for: date),
            dayKey: DailyRecord.dayKey(for: date, calendar: calendar),
            status: status,
            createdAt: date,
            updatedAt: updatedAt ?? date
        )
    }
}
#endif
