//
//  SoberGardenStore.swift
//  SoberGarden
//

import Foundation

final class SoberGardenStore {

    static let shared = SoberGardenStore()

    enum StoreError: Error {
        case documentsDirectoryUnavailable
    }

    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let stateURL: URL
    private let sideEffectsEnabled: Bool

    private(set) var state: SoberGardenState

    convenience init() {
        self.init(fileManager: .default)
    }

    convenience init(fileManager: FileManager) {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let stateURL = (documentsURL ?? fileManager.temporaryDirectory).appendingPathComponent("sober_garden_state.json")
        self.init(fileManager: fileManager, stateURL: stateURL)
    }

    private init(fileManager: FileManager, stateURL: URL, sideEffectsEnabled: Bool = true) {
        self.fileManager = fileManager
        self.encoder = Self.makeEncoder()
        self.decoder = Self.makeDecoder()
        self.stateURL = stateURL
        self.sideEffectsEnabled = sideEffectsEnabled
        self.state = SoberGardenState()
        self.state = load()
    }

    @discardableResult
    func load() -> SoberGardenState {
        guard fileManager.fileExists(atPath: stateURL.path) else {
            var defaultState = SoberGardenState()
            Self.reconcileCheckInState(&defaultState)
            state = defaultState
            if sideEffectsEnabled {
                SGWidgetSnapshotWriter.shared.clearSnapshot()
            }
            return state
        }

        do {
            let data = try Data(contentsOf: stateURL)
            let decodedState = try decoder.decode(SoberGardenState.self, from: data)
            var migratedState = decodedState
            let checkInChanged = Self.reconcileCheckInState(&migratedState)
            if migratedState.settings.dailyReminderEnabled == false,
               migratedState.settings.nightReminderEnabled == false {
                migratedState.settings.dailyReminderEnabled = true
                migratedState.settings.nightReminderEnabled = true
            }

            if checkInChanged ||
                migratedState.settings.dailyReminderEnabled != decodedState.settings.dailyReminderEnabled ||
                migratedState.settings.nightReminderEnabled != decodedState.settings.nightReminderEnabled {
                save(migratedState)
                return migratedState
            }

            state = migratedState
            if sideEffectsEnabled {
                SGWidgetSnapshotWriter.shared.writeSnapshot(for: migratedState)
            }
            return migratedState
        } catch {
            debugPrint("Failed to load sober garden state: \(error)")
            var fallbackState = SoberGardenState()
            Self.reconcileCheckInState(&fallbackState)
            state = fallbackState
            if sideEffectsEnabled {
                SGWidgetSnapshotWriter.shared.clearSnapshot()
            }
            return state
        }
    }

    func save(_ state: SoberGardenState) {
        do {
            try ensureStorageDirectoryExists()
            var normalizedState = state
            Self.reconcileCheckInState(&normalizedState)
            let data = try encoder.encode(normalizedState)
            try data.write(to: stateURL, options: [.atomic])
            self.state = normalizedState
            if sideEffectsEnabled {
                SGNotificationService.shared.rescheduleNotifications(for: normalizedState)
                SGWidgetSnapshotWriter.shared.writeSnapshot(for: normalizedState)
            }
        } catch {
            debugPrint("Failed to save sober garden state: \(error)")
        }
    }

    func update(_ transform: (inout SoberGardenState) -> Void) {
        var nextState = state
        transform(&nextState)
        save(nextState)
    }

    func setHabit(_ habit: Habit?) {
        update { state in
            state.habit = habit
        }
    }

    func updateHabit(_ transform: (inout Habit) -> Void) {
        update { state in
            guard var habit = state.habit else { return }
            transform(&habit)
            habit.updatedAt = Date()
            state.habit = habit
        }
    }

    func appendRescueSession(_ session: RescueSession) {
        update { state in
            state.rescueSessions.append(session)
            state.rescueSessions.sort { $0.date > $1.date }
        }
    }

    func saveRescueSession(
        emotion: EmotionType,
        startedAt: Date,
        urgeBefore: Int?,
        urgeAfter: Int?,
        completedBreathing: Bool,
        completedDelay: Bool
    ) {
        let session = RescueSession(
            id: UUID(),
            date: startedAt,
            emotion: emotion,
            urgeBefore: urgeBefore,
            urgeAfter: urgeAfter,
            completedBreathing: completedBreathing,
            completedDelay: completedDelay
        )
        appendRescueSession(session)
    }

    func upsertJournalEntry(_ entry: JournalEntry, calendar: Calendar = .current) {
        update { state in
            if let index = state.journalEntries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }) {
                state.journalEntries[index] = entry
            } else {
                state.journalEntries.append(entry)
            }
            state.journalEntries.sort { $0.date > $1.date }
        }
    }

    func appendRelapseRecord(_ record: RelapseRecord) {
        update { state in
            state.relapseRecords.append(record)
            state.relapseRecords.sort { $0.date > $1.date }
        }
    }

    func recordTodayAsPlanted(now: Date = Date(), calendar: Calendar = .current) {
        updateDailyRecord(for: now, status: .planted, now: now, calendar: calendar)
    }

    func recordTodayAsRainy(now: Date = Date(), calendar: Calendar = .current) {
        updateDailyRecord(for: now, status: .rainy, now: now, calendar: calendar)
    }

    func updateDailyRecord(
        for date: Date,
        status: DailyRecordStatus,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        let normalizedDate = calendar.startOfDay(for: date)
        let dayKey = DailyRecord.dayKey(for: date, calendar: calendar)
        update { state in
            if let index = state.dailyRecords.firstIndex(where: { Self.dailyRecord($0, matches: dayKey, normalizedDate: normalizedDate, calendar: calendar) }) {
                let existingRecord = state.dailyRecords[index]
                state.dailyRecords[index] = DailyRecord(
                    id: existingRecord.id,
                    date: normalizedDate,
                    dayKey: dayKey,
                    status: status,
                    createdAt: existingRecord.createdAt,
                    updatedAt: now
                )
            } else {
                let record = DailyRecord(
                    id: UUID(),
                    date: normalizedDate,
                    dayKey: dayKey,
                    status: status,
                    createdAt: now,
                    updatedAt: now
                )
                state.dailyRecords.append(record)
            }
            state.dailyRecords.sort { $0.date > $1.date }
        }
    }

    func clearDailyRecord(for date: Date, calendar: Calendar = .current) {
        let normalizedDate = calendar.startOfDay(for: date)
        let dayKey = DailyRecord.dayKey(for: date, calendar: calendar)
        update { state in
            state.dailyRecords.removeAll { Self.dailyRecord($0, matches: dayKey, normalizedDate: normalizedDate, calendar: calendar) }
            state.dailyRecords.sort { $0.date > $1.date }
        }
    }

    func dailyRecord(for date: Date, calendar: Calendar = .current) -> DailyRecord? {
        let normalizedDate = calendar.startOfDay(for: date)
        let dayKey = DailyRecord.dayKey(for: date, calendar: calendar)
        return state.dailyRecords.first { Self.dailyRecord($0, matches: dayKey, normalizedDate: normalizedDate, calendar: calendar) }
    }

    func markDailyPlantReviewShown(type: String) {
        update { state in
            state.lastReviewShownType = type
        }
    }

    func setDailyGardenDisplayDays(_ days: Int?) {
        update { state in
            state.dailyGardenDisplayDays = days
        }
    }

    @discardableResult
    func resetCurrentStreak(now: Date = Date(), calendar: Calendar = .current) -> RelapseRecord? {
        guard let currentHabit = state.habit else { return nil }
        let previousStreakDays = SGProgressCalculator.currentStreakDays(
            startDate: currentHabit.startDate,
            now: now,
            calendar: calendar
        )
        let record = RelapseRecord(
            id: UUID(),
            date: now,
            previousStartDate: currentHabit.startDate,
            previousStreakDays: previousStreakDays,
            note: nil
        )

        update { state in
            state.relapseRecords.append(record)
            state.relapseRecords.sort { $0.date > $1.date }
            state.habit?.startDate = now
            state.habit?.updatedAt = now
        }

        return record
    }

    func recordPromptShown(id: String, shownAt: Date = Date()) {
        update { state in
            state.recentPromptIDs.removeAll { shownAt.timeIntervalSince($0.shownAt) > Self.promptRepeatWindow }
            state.recentPromptIDs.removeAll { $0.id == id }
            state.recentPromptIDs.append(PromptDisplayRecord(id: id, shownAt: shownAt))
            state.recentPromptIDs.sort { $0.shownAt > $1.shownAt }
        }
    }

    func recentPromptIDs(within interval: TimeInterval, now: Date = Date()) -> [String] {
        state.recentPromptIDs
            .filter { now.timeIntervalSince($0.shownAt) <= interval }
            .map { $0.id }
    }

    func updateSettings(_ transform: (inout SoberGardenSettings) -> Void) {
        update { state in
            transform(&state.settings)
        }
    }

    func markTodayCheckInConfirmed(
        outcome: SoberGardenCheckInOutcome,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) {
        update { state in
            Self.applyCheckInConfirmation(
                to: &state.checkIn,
                outcome: outcome,
                confirmedDate: now,
                calendar: calendar
            )
        }
    }

    func recordYesterdayCheckInConfirmed(
        outcome: SoberGardenCheckInOutcome,
        yesterdayDate: Date,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) {
        update { state in
            Self.applyYesterdayCheckInConfirmation(
                to: &state.checkIn,
                outcome: outcome,
                yesterdayDate: yesterdayDate,
                recordedAt: now,
                calendar: calendar
            )
        }
    }

    func updateCheckInStreak(
        confirmedAt date: Date = Date(),
        calendar: Calendar = .current
    ) {
        update { state in
            state.checkIn.checkInStreakDays = Self.nextCheckInStreakDays(
                from: state.checkIn,
                confirmedAt: date,
                calendar: calendar
            )
        }
    }

    @discardableResult
    func resetCleanStreakAfterCheckInReset(
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> RelapseRecord? {
        let record = resetCurrentStreak(now: now, calendar: calendar)
        update { state in
            state.checkIn = SoberGardenCheckInState()
        }
        return record
    }

    func deleteAllData() {
        do {
            if fileManager.fileExists(atPath: stateURL.path) {
                try fileManager.removeItem(at: stateURL)
            }
        } catch {
            debugPrint("Failed to delete sober garden state: \(error)")
        }
        state = SoberGardenState()
        if sideEffectsEnabled {
            SGNotificationService.shared.cancelScheduledNotifications()
            SGWidgetSnapshotWriter.shared.clearSnapshot()
        }
    }

    private func ensureStorageDirectoryExists() throws {
        let directoryURL = stateURL.deletingLastPathComponent()
        guard !directoryURL.path.isEmpty else {
            throw StoreError.documentsDirectoryUnavailable
        }

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }

    private static let promptRepeatWindow: TimeInterval = 24 * 60 * 60

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func dailyRecord(
        _ record: DailyRecord,
        matches dayKey: String,
        normalizedDate: Date,
        calendar: Calendar
    ) -> Bool {
        record.dayKey == dayKey || calendar.isDate(record.date, inSameDayAs: normalizedDate)
    }

    private static func reconcileCheckInState(
        _ state: inout SoberGardenState,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        let normalized = normalizedCheckInState(from: state.checkIn, now: now, calendar: calendar)
        guard normalized != state.checkIn else { return false }
        state.checkIn = normalized
        return true
    }

    private static func normalizedCheckInState(
        from checkInState: SoberGardenCheckInState,
        now: Date,
        calendar: Calendar
    ) -> SoberGardenCheckInState {
        var state = checkInState
        if let lastDate = state.lastCheckInDate {
            state.confirmedToday = calendar.isDate(lastDate, inSameDayAs: now)
            state.needsYesterdayConfirmation = state.confirmedToday == false && calendar.isDateInYesterday(lastDate)
        } else {
            state.confirmedToday = false
            state.needsYesterdayConfirmation = false
        }
        return state
    }

    private static func applyCheckInConfirmation(
        to state: inout SoberGardenCheckInState,
        outcome: SoberGardenCheckInOutcome,
        confirmedDate: Date,
        calendar: Calendar
    ) {
        state.checkInStreakDays = nextCheckInStreakDays(from: state, confirmedAt: confirmedDate, calendar: calendar)
        state.lastCheckInDate = confirmedDate
        state.confirmedToday = true
        state.needsYesterdayConfirmation = false
        state.lastOutcome = outcome
        state.lastOutcomeDate = confirmedDate
    }

    private static func applyYesterdayCheckInConfirmation(
        to state: inout SoberGardenCheckInState,
        outcome: SoberGardenCheckInOutcome,
        yesterdayDate: Date,
        recordedAt: Date,
        calendar: Calendar
    ) {
        state.checkInStreakDays = nextCheckInStreakDays(from: state, confirmedAt: recordedAt, calendar: calendar)
        state.lastCheckInDate = recordedAt
        state.confirmedToday = true
        state.needsYesterdayConfirmation = false
        state.lastOutcome = outcome
        state.lastOutcomeDate = yesterdayDate
    }

    private static func nextCheckInStreakDays(
        from state: SoberGardenCheckInState,
        confirmedAt date: Date,
        calendar: Calendar
    ) -> Int {
        guard let lastDate = state.lastCheckInDate else {
            return 1
        }

        if calendar.isDate(lastDate, inSameDayAs: date) {
            return max(state.checkInStreakDays, 1)
        }

        if let expectedPrevious = calendar.date(byAdding: .day, value: 1, to: lastDate),
           calendar.isDate(expectedPrevious, inSameDayAs: date) {
            return max(state.checkInStreakDays, 0) + 1
        }

        return 1
    }
}

#if DEBUG
extension SoberGardenStore {
    static func debugAssertDailyRecordPersistenceBehavior() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let day = Date(timeIntervalSince1970: 1_800_000_000)
        let laterSameDay = day.addingTimeInterval(60 * 60)
        let previousDay = day.addingTimeInterval(-24 * 60 * 60)
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("sober_garden_state.json")

        let store = SoberGardenStore(fileManager: FileManager.default, stateURL: temporaryURL, sideEffectsEnabled: false)
        store.update { state in
            state.dailyRecords = [
                DailyRecord(
                    id: UUID(),
                    date: laterSameDay,
                    dayKey: DailyRecord.dayKey(for: laterSameDay, calendar: calendar),
                    status: .rainy,
                    createdAt: day,
                    updatedAt: day
                )
            ]
        }

        store.updateDailyRecord(for: day, status: .planted, now: day, calendar: calendar)
        let planted = store.dailyRecord(for: laterSameDay, calendar: calendar)
        assert(planted?.status == .planted)
        assert(planted?.date == calendar.startOfDay(for: day))
        assert(planted?.dayKey == DailyRecord.dayKey(for: day, calendar: calendar))

        store.recordTodayAsRainy(now: laterSameDay, calendar: calendar)
        let rainy = store.dailyRecord(for: day, calendar: calendar)
        assert(rainy?.status == .rainy)
        assert(rainy?.id == planted?.id)
        assert(rainy?.createdAt == planted?.createdAt)

        store.updateDailyRecord(for: previousDay, status: .planted, now: previousDay, calendar: calendar)
        assert(store.state.dailyRecords.map(\.date) == store.state.dailyRecords.map(\.date).sorted(by: >))

        store.clearDailyRecord(for: day, calendar: calendar)
        assert(store.dailyRecord(for: day, calendar: calendar) == nil)

        try? FileManager.default.removeItem(at: temporaryURL.deletingLastPathComponent())
    }
}
#endif
