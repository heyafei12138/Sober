//
//  RescueSession.swift
//  SoberGarden
//

import Foundation

struct RescueSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    var emotion: EmotionType
    var urgeBefore: Int?
    var urgeAfter: Int?
    var completedBreathing: Bool
    var completedDelay: Bool
}

enum EmotionType: String, Codable, CaseIterable {
    case urge
    case stress
    case lonely
    case bored
    case angry
    case tired
    case anxious
    case triggered

    var displayName: String {
        switch self {
        case .urge:
            return "Urge"
        case .stress:
            return "Stress"
        case .lonely:
            return "Lonely"
        case .bored:
            return "Bored"
        case .angry:
            return "Angry"
        case .tired:
            return "Tired"
        case .anxious:
            return "Anxious"
        case .triggered:
            return "Triggered"
        }
    }
}
