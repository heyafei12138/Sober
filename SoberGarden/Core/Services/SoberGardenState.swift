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
    var dailyRecords: [DailyRecord]
    var dailyGardenDisplayDays: Int?
    var lastReviewShownType: String?
    var lastMonthlyReviewShownMonth: String?
    var recentPromptIDs: [PromptDisplayRecord]
    var checkIn: SoberGardenCheckInState
    var settings: SoberGardenSettings

    init(
        habit: Habit? = nil,
        rescueSessions: [RescueSession] = [],
        journalEntries: [JournalEntry] = [],
        relapseRecords: [RelapseRecord] = [],
        dailyRecords: [DailyRecord] = [],
        dailyGardenDisplayDays: Int? = nil,
        lastReviewShownType: String? = nil,
        lastMonthlyReviewShownMonth: String? = nil,
        recentPromptIDs: [PromptDisplayRecord] = [],
        checkIn: SoberGardenCheckInState = SoberGardenCheckInState(),
        settings: SoberGardenSettings = SoberGardenSettings()
    ) {
        self.habit = habit
        self.rescueSessions = rescueSessions
        self.journalEntries = journalEntries
        self.relapseRecords = relapseRecords
        self.dailyRecords = dailyRecords
        self.dailyGardenDisplayDays = dailyGardenDisplayDays
        self.lastReviewShownType = lastReviewShownType
        self.lastMonthlyReviewShownMonth = lastMonthlyReviewShownMonth
        self.recentPromptIDs = recentPromptIDs
        self.checkIn = checkIn
        self.settings = settings
    }

    enum CodingKeys: String, CodingKey {
        case habit
        case rescueSessions
        case journalEntries
        case relapseRecords
        case dailyRecords
        case dailyGardenDisplayDays
        case lastReviewShownType
        case lastMonthlyReviewShownMonth
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
        dailyRecords = try container.decodeIfPresent([DailyRecord].self, forKey: .dailyRecords) ?? []
        dailyGardenDisplayDays = try container.decodeIfPresent(Int.self, forKey: .dailyGardenDisplayDays)
        lastReviewShownType = try container.decodeIfPresent(String.self, forKey: .lastReviewShownType)
        lastMonthlyReviewShownMonth = try container.decodeIfPresent(String.self, forKey: .lastMonthlyReviewShownMonth)
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
        try container.encode(dailyRecords, forKey: .dailyRecords)
        try container.encodeIfPresent(dailyGardenDisplayDays, forKey: .dailyGardenDisplayDays)
        try container.encodeIfPresent(lastReviewShownType, forKey: .lastReviewShownType)
        try container.encodeIfPresent(lastMonthlyReviewShownMonth, forKey: .lastMonthlyReviewShownMonth)
        try container.encode(recentPromptIDs, forKey: .recentPromptIDs)
        try container.encode(checkIn, forKey: .checkIn)
        try container.encode(settings, forKey: .settings)
    }
}

struct DailyRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let dayKey: String
    var status: DailyRecordStatus
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        date: Date,
        dayKey: String,
        status: DailyRecordStatus,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.date = date
        self.dayKey = dayKey
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case dayKey
        case status
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        dayKey = try container.decodeIfPresent(String.self, forKey: .dayKey) ?? Self.dayKey(for: date)
        status = try container.decode(DailyRecordStatus.self, forKey: .status)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(dayKey, forKey: .dayKey)
        try container.encode(status, forKey: .status)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }
}

enum DailyRecordStatus: String, Codable, Equatable {
    case planted
    case rainy
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
