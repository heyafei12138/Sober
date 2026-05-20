//
//  SGOnboardingDraft.swift
//  SoberGarden
//

import Foundation

struct SGOnboardingDraft {

    static let reasonTemplates: [String] = [
        "I want to feel in control again.",
        "I want to protect my health.",
        "I want to stop feeling regret.",
        "I want to become someone I respect.",
        "I want more time and energy.",
        "I want to build a better future.",
    ]

    var habitType: HabitType?
    var customHabitName: String?
    var startDate: Date = Date()
    var dailyCost: Double?
    var dailyMinutes: Int?
    var selectedReasonTemplates: Set<String> = []
    var customReasonText: String?

    var canComplete: Bool {
        habitType != nil
    }

    var resolvedReasons: [String] {
        var items = selectedReasonTemplates.sorted()
        let custom = customReasonText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !custom.isEmpty {
            items.append(custom)
        }
        return items
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

    mutating func setTime(amount: Double?, mode: SGOnboardingTimeMode) {
        guard let amount, amount > 0, mode != .skip else {
            dailyMinutes = nil
            return
        }

        switch mode {
        case .day:
            dailyMinutes = max(1, Int(amount.rounded()))
        case .week:
            dailyMinutes = max(1, Int(((amount * 60) / 7).rounded()))
        case .skip:
            dailyMinutes = nil
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
            reasons: resolvedReasons,
            createdAt: now,
            updatedAt: now
        )
    }
}

enum SGOnboardingTimeMode: Int, CaseIterable {
    case day
    case week
    case skip

    var title: String {
        switch self {
        case .day:
            return "Minutes per day"
        case .week:
            return "Hours per week"
        case .skip:
            return "Skip"
        }
    }

    var placeholder: String {
        switch self {
        case .day:
            return "Minutes"
        case .week:
            return "Hours"
        case .skip:
            return ""
        }
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
