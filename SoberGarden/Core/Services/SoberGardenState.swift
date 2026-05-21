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
    var checkIn: SoberGardenCheckInState
    var settings: SoberGardenSettings

    init(
        habit: Habit? = nil,
        rescueSessions: [RescueSession] = [],
        journalEntries: [JournalEntry] = [],
        relapseRecords: [RelapseRecord] = [],
        recentPromptIDs: [PromptDisplayRecord] = [],
        checkIn: SoberGardenCheckInState = SoberGardenCheckInState(),
        settings: SoberGardenSettings = SoberGardenSettings()
    ) {
        self.habit = habit
        self.rescueSessions = rescueSessions
        self.journalEntries = journalEntries
        self.relapseRecords = relapseRecords
        self.recentPromptIDs = recentPromptIDs
        self.checkIn = checkIn
        self.settings = settings
    }

    enum CodingKeys: String, CodingKey {
        case habit
        case rescueSessions
        case journalEntries
        case relapseRecords
        case recentPromptIDs
        case checkIn
        case settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        habit = try container.decodeIfPresent(Habit.self, forKey: .habit)
        rescueSessions = try container.decodeIfPresent([RescueSession].self, forKey: .rescueSessions) ?? []
        journalEntries = try container.decodeIfPresent([JournalEntry].self, forKey: .journalEntries) ?? []
        relapseRecords = try container.decodeIfPresent([RelapseRecord].self, forKey: .relapseRecords) ?? []
        recentPromptIDs = try container.decodeIfPresent([PromptDisplayRecord].self, forKey: .recentPromptIDs) ?? []
        checkIn = try container.decodeIfPresent(SoberGardenCheckInState.self, forKey: .checkIn) ?? SoberGardenCheckInState()
        settings = try container.decodeIfPresent(SoberGardenSettings.self, forKey: .settings) ?? SoberGardenSettings()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(habit, forKey: .habit)
        try container.encode(rescueSessions, forKey: .rescueSessions)
        try container.encode(journalEntries, forKey: .journalEntries)
        try container.encode(relapseRecords, forKey: .relapseRecords)
        try container.encode(recentPromptIDs, forKey: .recentPromptIDs)
        try container.encode(checkIn, forKey: .checkIn)
        try container.encode(settings, forKey: .settings)
    }
}

struct SoberGardenCheckInState: Codable, Equatable {
    var lastCheckInDate: Date?
    var confirmedToday: Bool
    var needsYesterdayConfirmation: Bool
    var checkInStreakDays: Int
    var lastOutcome: SoberGardenCheckInOutcome?
    var lastOutcomeDate: Date?

    init(
        lastCheckInDate: Date? = nil,
        confirmedToday: Bool = false,
        needsYesterdayConfirmation: Bool = false,
        checkInStreakDays: Int = 0,
        lastOutcome: SoberGardenCheckInOutcome? = nil,
        lastOutcomeDate: Date? = nil
    ) {
        self.lastCheckInDate = lastCheckInDate
        self.confirmedToday = confirmedToday
        self.needsYesterdayConfirmation = needsYesterdayConfirmation
        self.checkInStreakDays = checkInStreakDays
        self.lastOutcome = lastOutcome
        self.lastOutcomeDate = lastOutcomeDate
    }

    enum CodingKeys: String, CodingKey {
        case lastCheckInDate
        case confirmedToday
        case needsYesterdayConfirmation
        case checkInStreakDays
        case lastOutcome
        case lastOutcomeDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastCheckInDate = try container.decodeIfPresent(Date.self, forKey: .lastCheckInDate)
        confirmedToday = try container.decodeIfPresent(Bool.self, forKey: .confirmedToday) ?? false
        needsYesterdayConfirmation = try container.decodeIfPresent(Bool.self, forKey: .needsYesterdayConfirmation) ?? false
        checkInStreakDays = try container.decodeIfPresent(Int.self, forKey: .checkInStreakDays) ?? 0
        lastOutcome = try container.decodeIfPresent(SoberGardenCheckInOutcome.self, forKey: .lastOutcome)
        lastOutcomeDate = try container.decodeIfPresent(Date.self, forKey: .lastOutcomeDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lastCheckInDate, forKey: .lastCheckInDate)
        try container.encode(confirmedToday, forKey: .confirmedToday)
        try container.encode(needsYesterdayConfirmation, forKey: .needsYesterdayConfirmation)
        try container.encode(checkInStreakDays, forKey: .checkInStreakDays)
        try container.encodeIfPresent(lastOutcome, forKey: .lastOutcome)
        try container.encodeIfPresent(lastOutcomeDate, forKey: .lastOutcomeDate)
    }
}

enum SoberGardenCheckInOutcome: String, Codable, CaseIterable, Equatable {
    case easy
    case okay
    case hard
    case urges
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
