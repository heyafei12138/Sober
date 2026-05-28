//
//  SGOnboardingDraft.swift
//  SoberGarden
//

import Foundation

struct SGOnboardingDraft {

    static let reasonTemplates: [String] = [
        "onboarding.reason.control".localized(),
        "onboarding.reason.health".localized(),
        "onboarding.reason.regret".localized(),
        "onboarding.reason.respect".localized(),
        "onboarding.reason.energy".localized(),
        "onboarding.reason.future".localized(),
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
            return "onboarding.time.minutesPerDay".localized()
        case .week:
            return "onboarding.time.hoursPerWeek".localized()
        case .skip:
            return "common.skip".localized()
        }
    }

    var placeholder: String {
        switch self {
        case .day:
            return "common.minutes".localized()
        case .week:
            return "common.hours".localized()
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
            return "onboarding.cost.perDay".localized()
        case .week:
            return "onboarding.cost.perWeek".localized()
        case .month:
            return "onboarding.cost.perMonth".localized()
        case .skip:
            return "common.skip".localized()
        }
    }
}
