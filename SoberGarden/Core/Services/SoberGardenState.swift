//
//  SoberGardenState.swift
//  SoberGarden
//

import Foundation

struct SoberGardenState: Codable {
    var habit: Habit?
    var rescueSessions: [RescueSession]
    var journalEntries: [JournalEntry]
    var relapseRecords: [RelapseRecord]
    var recentPromptIDs: [PromptDisplayRecord]
    var settings: SoberGardenSettings

    init(
        habit: Habit? = nil,
        rescueSessions: [RescueSession] = [],
        journalEntries: [JournalEntry] = [],
        relapseRecords: [RelapseRecord] = [],
        recentPromptIDs: [PromptDisplayRecord] = [],
        settings: SoberGardenSettings = SoberGardenSettings()
    ) {
        self.habit = habit
        self.rescueSessions = rescueSessions
        self.journalEntries = journalEntries
        self.relapseRecords = relapseRecords
        self.recentPromptIDs = recentPromptIDs
        self.settings = settings
    }
}

struct SoberGardenSettings: Codable {
    var dailyReminderEnabled: Bool
    var dailyReminderTime: DateComponents
    var milestoneNotificationsEnabled: Bool
    var nightReminderEnabled: Bool
    var nightReminderTime: DateComponents
    var rescueDelayReminderEnabled: Bool
    var appLockEnabled: Bool
    var hasAcknowledgedNonMedicalDisclaimer: Bool

    init(
        dailyReminderEnabled: Bool = true,
        dailyReminderTime: DateComponents = DateComponents(hour: 9, minute: 0),
        milestoneNotificationsEnabled: Bool = true,
        nightReminderEnabled: Bool = true,
        nightReminderTime: DateComponents = DateComponents(hour: 22, minute: 0),
        rescueDelayReminderEnabled: Bool = true,
        appLockEnabled: Bool = false,
        hasAcknowledgedNonMedicalDisclaimer: Bool = false
    ) {
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderTime = dailyReminderTime
        self.milestoneNotificationsEnabled = milestoneNotificationsEnabled
        self.nightReminderEnabled = nightReminderEnabled
        self.nightReminderTime = nightReminderTime
        self.rescueDelayReminderEnabled = rescueDelayReminderEnabled
        self.appLockEnabled = appLockEnabled
        self.hasAcknowledgedNonMedicalDisclaimer = hasAcknowledgedNonMedicalDisclaimer
    }

    enum CodingKeys: String, CodingKey {
        case dailyReminderEnabled
        case dailyReminderTime
        case milestoneNotificationsEnabled
        case nightReminderEnabled
        case nightReminderTime
        case rescueDelayReminderEnabled
        case appLockEnabled
        case hasAcknowledgedNonMedicalDisclaimer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dailyReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .dailyReminderEnabled) ?? true
        dailyReminderTime = try container.decodeIfPresent(DateComponents.self, forKey: .dailyReminderTime) ?? DateComponents(hour: 9, minute: 0)
        milestoneNotificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .milestoneNotificationsEnabled) ?? true
        nightReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .nightReminderEnabled) ?? true
        nightReminderTime = try container.decodeIfPresent(DateComponents.self, forKey: .nightReminderTime) ?? DateComponents(hour: 22, minute: 0)
        rescueDelayReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .rescueDelayReminderEnabled) ?? true
        appLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .appLockEnabled) ?? false
        hasAcknowledgedNonMedicalDisclaimer = try container.decodeIfPresent(Bool.self, forKey: .hasAcknowledgedNonMedicalDisclaimer) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dailyReminderEnabled, forKey: .dailyReminderEnabled)
        try container.encode(dailyReminderTime, forKey: .dailyReminderTime)
        try container.encode(milestoneNotificationsEnabled, forKey: .milestoneNotificationsEnabled)
        try container.encode(nightReminderEnabled, forKey: .nightReminderEnabled)
        try container.encode(nightReminderTime, forKey: .nightReminderTime)
        try container.encode(rescueDelayReminderEnabled, forKey: .rescueDelayReminderEnabled)
        try container.encode(appLockEnabled, forKey: .appLockEnabled)
        try container.encode(hasAcknowledgedNonMedicalDisclaimer, forKey: .hasAcknowledgedNonMedicalDisclaimer)
    }
}

struct PromptDisplayRecord: Codable, Identifiable {
    let id: String
    let shownAt: Date
}
