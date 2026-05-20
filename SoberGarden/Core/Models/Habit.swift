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
            return "Smoking"
        case .vaping:
            return "Vaping"
        case .alcohol:
            return "Alcohol"
        case .porn:
            return "Porn"
        case .gambling:
            return "Gambling"
        case .sugar:
            return "Sugar"
        case .socialMedia:
            return "Social Media"
        case .weed:
            return "Weed"
        case .custom:
            return "Custom"
        }
    }
}
