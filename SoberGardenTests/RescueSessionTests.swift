import XCTest
@testable import SoberGarden

final class RescueSessionTests: XCTestCase {

    func testUrgeReductionReturnsDifferenceWhenAfterIsLower() {
        let session = RescueSession(
            id: UUID(),
            date: Date(),
            emotion: .urge,
            urgeBefore: 8,
            urgeAfter: 3,
            completedBreathing: true,
            completedDelay: true
        )

        XCTAssertEqual(session.urgeReduction, 5)
    }

    func testUrgeReductionClampsAtZeroWhenUrgeGoesUp() {
        let session = RescueSession(
            id: UUID(),
            date: Date(),
            emotion: .stress,
            urgeBefore: 4,
            urgeAfter: 7,
            completedBreathing: false,
            completedDelay: true
        )

        XCTAssertEqual(session.urgeReduction, 0)
    }

    func testUrgeReductionIsNilWhenRatingsAreMissing() {
        let session = RescueSession(
            id: UUID(),
            date: Date(),
            emotion: .lonely,
            urgeBefore: 6,
            urgeAfter: nil,
            completedBreathing: false,
            completedDelay: false
        )

        XCTAssertNil(session.urgeReduction)
    }
}
