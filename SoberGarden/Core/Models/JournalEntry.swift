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
            return "mood.great".localized()
        case .calm:
            return "mood.calm".localized()
        case .okay:
            return "mood.okay".localized()
        case .low:
            return "mood.low".localized()
        case .stressed:
            return "mood.stressed".localized()
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
            return "urgeLevel.none".localized()
        case .mild:
            return "urgeLevel.mild".localized()
        case .strong:
            return "urgeLevel.strong".localized()
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
            return "trigger.stress".localized()
        case .boredom:
            return "trigger.boredom".localized()
        case .loneliness:
            return "trigger.loneliness".localized()
        case .socialMedia:
            return "trigger.socialMedia".localized()
        case .lateNight:
            return "trigger.lateNight".localized()
        case .conflict:
            return "trigger.conflict".localized()
        case .tiredness:
            return "trigger.tiredness".localized()
        case .custom:
            return "trigger.custom".localized()
        }
    }
}
