//
//  SGShareProgressService.swift
//  SoberGarden
//

import UIKit

final class SGShareProgressService {

    static let shared = SGShareProgressService()

    private init() {}

    func makeActivityItems(for state: SoberGardenState = SoberGardenStore.shared.state) -> [Any]? {
        guard let habit = state.habit else { return nil }

        let now = Date()
        let cleanDays = SGProgressCalculator.currentStreakDays(startDate: habit.startDate, now: now)
        let elapsedCleanDays = SGProgressCalculator.elapsedCleanDaysForSavings(startDate: habit.startDate, now: now)
        let savedMoney = SGProgressCalculator.moneySaved(dailyCost: habit.dailyCost ?? 0, cleanDays: elapsedCleanDays)
        let gardenStage = SGProgressCalculator.currentGardenStage(for: cleanDays)
        let savedMoneyText = Self.moneyText(for: savedMoney)

        let cardContent = SGProgressShareCardView.Content(
            cleanDays: cleanDays,
            savedMoneyText: savedMoneyText,
            gardenStage: gardenStage,
            habitName: habit.displayName
        )

        let image = renderCardImage(content: cardContent)
        let text = [
            "I'm growing one clean day at a time.",
            "\(cleanDays) \(cleanDays == 1 ? "day" : "days") clean from \(habit.displayName).",
            "Garden stage: \(gardenStage.title).",
            "Saved: \(savedMoneyText)."
        ].joined(separator: "\n")

        return [image, text]
    }

    private func renderCardImage(content: SGProgressShareCardView.Content) -> UIImage {
        let cardSize = CGSize(width: 1080, height: 1350)
        let cardView = SGProgressShareCardView(frame: CGRect(origin: .zero, size: cardSize))
        cardView.configure(with: content)
        cardView.setNeedsLayout()
        cardView.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: cardSize)
        return renderer.image { context in
            cardView.layer.render(in: context.cgContext)
        }
    }

    private static func moneyText(for amount: Double) -> String {
        guard amount > 0 else { return "Progress" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.maximumFractionDigits = amount >= 100 ? 0 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
