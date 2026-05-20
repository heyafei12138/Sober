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

    private(set) var state: SoberGardenState

    convenience init() {
        self.init(fileManager: .default)
    }

    init(fileManager: FileManager) {
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        self.stateURL = (documentsURL ?? fileManager.temporaryDirectory).appendingPathComponent("sober_garden_state.json")
        self.state = SoberGardenState()
        self.state = load()
    }

    @discardableResult
    func load() -> SoberGardenState {
        guard fileManager.fileExists(atPath: stateURL.path) else {
            state = SoberGardenState()
            return state
        }

        do {
            let data = try Data(contentsOf: stateURL)
            let decodedState = try decoder.decode(SoberGardenState.self, from: data)
            state = decodedState
            return decodedState
        } catch {
            debugPrint("Failed to load sober garden state: \(error)")
            state = SoberGardenState()
            return state
        }
    }

    func save(_ state: SoberGardenState) {
        do {
            try ensureStorageDirectoryExists()
            let data = try encoder.encode(state)
            try data.write(to: stateURL, options: [.atomic])
            self.state = state
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

    func deleteAllData() {
        do {
            if fileManager.fileExists(atPath: stateURL.path) {
                try fileManager.removeItem(at: stateURL)
            }
        } catch {
            debugPrint("Failed to delete sober garden state: \(error)")
        }
        state = SoberGardenState()
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
}
