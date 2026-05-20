//
//  SGRescueDraft.swift
//  SoberGarden
//

import Foundation

struct SGRescueDraft {
    var startedAt: Date
    var emotion: EmotionType?
    var urgeBefore: Int?
    var urgeAfter: Int?
    var completedBreathing: Bool
    var completedDelay: Bool

    init(
        startedAt: Date = Date(),
        emotion: EmotionType? = nil,
        urgeBefore: Int? = nil,
        urgeAfter: Int? = nil,
        completedBreathing: Bool = false,
        completedDelay: Bool = false
    ) {
        self.startedAt = startedAt
        self.emotion = emotion
        self.urgeBefore = urgeBefore
        self.urgeAfter = urgeAfter
        self.completedBreathing = completedBreathing
        self.completedDelay = completedDelay
    }
}
