//
//  SGProgressCalculator.swift
//  SoberGarden
//

import Foundation

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

    static func moneySaved(dailyCost: Double, cleanDays: Int) -> Double {
        guard dailyCost > 0, cleanDays > 0 else { return 0 }
        return dailyCost * Double(cleanDays)
    }

    static func timeSavedMinutes(dailyMinutes: Int, cleanDays: Int) -> Int {
        guard dailyMinutes > 0, cleanDays > 0 else { return 0 }
        return dailyMinutes * cleanDays
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
    }
}
#endif
