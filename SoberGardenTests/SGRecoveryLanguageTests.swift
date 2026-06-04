import XCTest
@testable import SoberGarden

final class SGRecoveryLanguageTests: XCTestCase {

    func testAlcoholHabitTypeUsesSobrietyFocusedLanguage() {
        XCTAssertTrue(HabitType.alcohol.isSobrietyFocused)

        let language = HabitType.alcohol.recoveryLanguage
        XCTAssertEqual(language.mode, .sobriety)
        XCTAssertEqual(language.primaryCheckInActionKey, "recovery.action.markTodaySober")
        XCTAssertEqual(language.dayCountFormatKey, "recovery.dayCount.soberFormat")
        XCTAssertEqual(language.urgeTitleKey, "recovery.urge.craving")
        XCTAssertEqual(language.gardenTitleKey, "recovery.garden.recoveryGarden")
    }

    func testGenericHabitTypeUsesGenericRecoveryLanguage() {
        XCTAssertFalse(HabitType.smoking.isSobrietyFocused)

        let language = HabitType.smoking.recoveryLanguage
        XCTAssertEqual(language.mode, .generic)
        XCTAssertEqual(language.primaryCheckInActionKey, "dailyPlant.card.empty.primary")
        XCTAssertEqual(language.dayCountFormatKey, "recovery.dayCount.cleanFormat")
        XCTAssertEqual(language.urgeTitleKey, "recovery.urge.generic")
        XCTAssertEqual(language.gardenTitleKey, "recovery.garden.generic")
    }

    func testHabitUsesTypeRecoveryLanguage() {
        let alcoholHabit = Habit(
            id: UUID(),
            type: .alcohol,
            customName: nil,
            startDate: Date(),
            dailyCost: nil,
            dailyMinutes: nil,
            reasons: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(alcoholHabit.recoveryLanguage.mode, .sobriety)
        XCTAssertEqual(alcoholHabit.recoveryLanguage.setbackActionKey, "recovery.action.setback")
    }
}
