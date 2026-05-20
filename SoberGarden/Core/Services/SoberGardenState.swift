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

    init(
        dailyReminderEnabled: Bool = false,
        dailyReminderTime: DateComponents = DateComponents(hour: 9, minute: 0),
        milestoneNotificationsEnabled: Bool = true,
        nightReminderEnabled: Bool = false,
        nightReminderTime: DateComponents = DateComponents(hour: 22, minute: 0),
        rescueDelayReminderEnabled: Bool = true,
        appLockEnabled: Bool = false
    ) {
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderTime = dailyReminderTime
        self.milestoneNotificationsEnabled = milestoneNotificationsEnabled
        self.nightReminderEnabled = nightReminderEnabled
        self.nightReminderTime = nightReminderTime
        self.rescueDelayReminderEnabled = rescueDelayReminderEnabled
        self.appLockEnabled = appLockEnabled
    }
}

struct PromptDisplayRecord: Codable, Identifiable {
    let id: String
    let shownAt: Date
}
