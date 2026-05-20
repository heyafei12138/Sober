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

    mutating func setCost(amount: Double?, mode: SGOnboardingCostMode) {
        guard let amount, amount > 0, mode != .skip else {
            dailyCost = nil
            return
        }

        switch mode {
        case .day:
            dailyCost = amount
        case .week:
            dailyCost = amount / 7
        case .month:
            dailyCost = amount / 30
        case .skip:
            dailyCost = nil
        }
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

enum SGOnboardingCostMode: Int, CaseIterable {
    case day
    case week
    case month
    case skip

    var title: String {
        switch self {
        case .day:
            return "Cost per day"
        case .week:
            return "Cost per week"
        case .month:
            return "Cost per month"
        case .skip:
            return "Skip"
        }
    }
}
