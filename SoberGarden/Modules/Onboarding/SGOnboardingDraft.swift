//
//  SGOnboardingDraft.swift
//  SoberGarden
//

import Foundation

struct SGOnboardingDraft {
    var habitType: HabitType?
    var customHabitName: String?
    var startDate: Date = Date()
    var dailyCost: Double?
    var dailyMinutes: Int?
    var reasons: [String] = []

    var canComplete: Bool {
        habitType != nil
    }

    func makeHabit(now: Date = Date()) -> Habit? {
        guard let habitType else { return nil }

        return Habit(
            id: UUID(),
            type: habitType,
            customName: customHabitName,
            startDate: startDate,
            dailyCost: dailyCost,
            dailyMinutes: dailyMinutes,
            reasons: reasons,
            createdAt: now,
            updatedAt: now
        )
    }
}
