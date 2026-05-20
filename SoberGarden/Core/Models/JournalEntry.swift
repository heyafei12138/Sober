//
//  JournalEntry.swift
//  SoberGarden
//

import Foundation

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    var mood: MoodType
    var urgeLevel: UrgeLevel
    var triggers: [TriggerType]
    var note: String?
}

enum MoodType: String, Codable, CaseIterable {
    case great
    case calm
    case okay
    case low
    case stressed

    var displayName: String {
        switch self {
        case .great:
            return "Great"
        case .calm:
            return "Calm"
        case .okay:
            return "Okay"
        case .low:
            return "Low"
        case .stressed:
            return "Stressed"
        }
    }
}

enum UrgeLevel: String, Codable, CaseIterable {
    case none
    case mild
    case strong

    var displayName: String {
        switch self {
        case .none:
            return "No urge"
        case .mild:
            return "Mild urge"
        case .strong:
            return "Strong urge"
        }
    }
}

enum TriggerType: String, Codable, CaseIterable {
    case stress
    case boredom
    case loneliness
    case socialMedia
    case lateNight
    case conflict
    case tiredness
    case custom

    var displayName: String {
        switch self {
        case .stress:
            return "Stress"
        case .boredom:
            return "Boredom"
        case .loneliness:
            return "Loneliness"
        case .socialMedia:
            return "Social media"
        case .lateNight:
            return "Late night"
        case .conflict:
            return "Conflict"
        case .tiredness:
            return "Tiredness"
        case .custom:
            return "Custom"
        }
    }
}
