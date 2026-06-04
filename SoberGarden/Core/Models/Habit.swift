//
//  Habit.swift
//  SoberGarden
//

import Foundation

struct Habit: Codable, Identifiable {
    let id: UUID
    var type: HabitType
    var customName: String?
    var startDate: Date
    var dailyCost: Double?
    var dailyMinutes: Int?
    var reasons: [String]
    var createdAt: Date
    var updatedAt: Date

    var displayName: String {
        if type == .custom, let customName, !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return customName
        }
        return type.displayName
    }
}

enum HabitType: String, Codable, CaseIterable {
    case smoking
    case vaping
    case alcohol
    case porn
    case gambling
    case sugar
    case socialMedia
    case weed
    case custom

    var displayName: String {
        switch self {
        case .smoking:
            return "habit.smoking".localized()
        case .vaping:
            return "habit.vaping".localized()
        case .alcohol:
            return "habit.alcohol".localized()
        case .porn:
            return "habit.porn".localized()
        case .gambling:
            return "habit.gambling".localized()
        case .sugar:
            return "habit.sugar".localized()
        case .socialMedia:
            return "habit.socialMedia".localized()
        case .weed:
            return "habit.weed".localized()
        case .custom:
            return "habit.custom".localized()
        }
    }

    var isSobrietyFocused: Bool {
        self == .alcohol
    }

    var recoveryLanguage: SGRecoveryLanguage {
        isSobrietyFocused ? .sobriety : .generic
    }

    static var onboardingSelectionOrder: [HabitType] {
        [
            .alcohol,
            .smoking,
            .vaping,
            .porn,
            .gambling,
            .sugar,
            .socialMedia,
            .weed,
            .custom
        ]
    }
}

extension Habit {
    var isSobrietyFocused: Bool {
        type.isSobrietyFocused
    }

    var recoveryLanguage: SGRecoveryLanguage {
        type.recoveryLanguage
    }
}
