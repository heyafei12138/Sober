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
            return "emotion.urge".localized()
        case .stress:
            return "emotion.stress".localized()
        case .lonely:
            return "emotion.lonely".localized()
        case .bored:
            return "emotion.bored".localized()
        case .angry:
            return "emotion.angry".localized()
        case .tired:
            return "emotion.tired".localized()
        case .anxious:
            return "emotion.anxious".localized()
        case .triggered:
            return "emotion.triggered".localized()
        }
    }
}
