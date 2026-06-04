import Foundation

@main
struct Task2OnboardingSpec {
    static func main() {
        expect(HabitType.onboardingSelectionOrder.first == .alcohol, "Alcohol should be first in onboarding.")
        expect(HabitType.onboardingSelectionOrder.last == .custom, "Custom should stay last in onboarding.")
        expect(HabitType.onboardingSelectionOrder.count == 9, "Onboarding should include all supported habit choices.")
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            fputs("FAIL: \\(message)\\n", stderr)
            exit(1)
        }
    }
}
