import Foundation

@main
struct Task1RecoveryLanguageSpec {
    static func main() {
        expect(HabitType.alcohol.isSobrietyFocused == true, "Alcohol should be sobriety-focused.")

        let alcoholLanguage = HabitType.alcohol.recoveryLanguage
        expect(alcoholLanguage.mode == .sobriety, "Alcohol should use sobriety mode.")
        expect(alcoholLanguage.dayUnitTitleKey == "recovery.dayUnit.sober", "Alcohol day unit key mismatch.")
        expect(alcoholLanguage.streakTitleKey == "recovery.streak.sober", "Alcohol streak key mismatch.")
        expect(alcoholLanguage.primaryCheckInActionKey == "recovery.action.markTodaySober", "Alcohol action key mismatch.")
        expect(alcoholLanguage.dayCountFormatKey == "recovery.dayCount.soberFormat", "Alcohol day format key mismatch.")
        expect(alcoholLanguage.urgeTitleKey == "recovery.urge.craving", "Alcohol urge key mismatch.")
        expect(alcoholLanguage.homeStatusTitleFormatKey == "recovery.dayCount.soberFormat", "Alcohol home title key mismatch.")
        expect(alcoholLanguage.coachContextPrefix == "sobriety", "Alcohol coach prefix mismatch.")

        let genericLanguage = HabitType.smoking.recoveryLanguage
        expect(genericLanguage.mode == .generic, "Smoking should use generic mode.")
        expect(genericLanguage.dayUnitTitleKey == "recovery.dayUnit.clean", "Generic day unit key mismatch.")
        expect(genericLanguage.streakTitleKey == "recovery.streak.clean", "Generic streak key mismatch.")
        expect(genericLanguage.primaryCheckInActionKey == "dailyPlant.card.empty.primary", "Generic action key mismatch.")
        expect(genericLanguage.dayCountFormatKey == "recovery.dayCount.cleanFormat", "Generic day format key mismatch.")
        expect(genericLanguage.homeStatusTitleFormatKey == "recovery.dayCount.cleanFormat", "Generic home title key mismatch.")
        expect(genericLanguage.coachContextPrefix == "generic", "Generic coach prefix mismatch.")

        let session = RescueSession(
            id: UUID(),
            date: Date(),
            emotion: .urge,
            urgeBefore: 7,
            urgeAfter: 3,
            completedBreathing: true,
            completedDelay: true
        )
        expect(session.urgeReduction == 4, "Urge reduction should subtract after from before.")
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            fputs("FAIL: \\(message)\\n", stderr)
            exit(1)
        }
    }
}
