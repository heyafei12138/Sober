//
//  SGShareProgressService.swift
//  SoberGarden
//

import UIKit

enum SGSharePosterStyle: String, CaseIterable {
    case garden
    case fresh
    case sunrise

    var title: String {
        switch self {
        case .garden:
            return "Garden"
        case .fresh:
            return "Fresh"
        case .sunrise:
            return "Sunrise"
        }
    }
}

final class SGShareProgressService {

    static let shared = SGShareProgressService()

    private init() {}

    struct ProgressSharePackage {
        let image: UIImage
        let text: String
        let style: SGSharePosterStyle

        var activityItems: [Any] {
            [image, text]
        }
    }

    func makeActivityItems(for state: SoberGardenState = SoberGardenStore.shared.state, style: SGSharePosterStyle = .garden) -> [Any]? {
        makeProgressSharePackage(for: state, style: style)?.activityItems
    }

    func makeProgressSharePackage(
        for state: SoberGardenState = SoberGardenStore.shared.state,
        style: SGSharePosterStyle = .garden
    ) -> ProgressSharePackage? {
        guard let habit = state.habit else { return nil }

        let now = Date()
        let cleanDays = SGProgressCalculator.currentStreakDays(startDate: habit.startDate, now: now)
        let elapsedCleanDays = SGProgressCalculator.elapsedCleanDaysForSavings(startDate: habit.startDate, now: now)
        let savedMoney = SGProgressCalculator.moneySaved(dailyCost: habit.dailyCost ?? 0, cleanDays: elapsedCleanDays)
        let savedMinutes = SGProgressCalculator.timeSavedMinutes(dailyMinutes: habit.dailyMinutes ?? 0, cleanDays: elapsedCleanDays)
        let gardenStage = SGProgressCalculator.currentGardenStage(for: cleanDays)
        let savedMoneyText = Self.moneyText(for: savedMoney)
        let savedTimeText = Self.timeText(for: savedMinutes)

        let cardContent = SGProgressShareCardView.Content(
            cleanDays: cleanDays,
            savedMoneyText: savedMoneyText,
            savedTimeText: savedTimeText,
            gardenStage: gardenStage,
            habitName: habit.displayName,
            generatedAt: now,
            style: style
        )

        let image = renderCardImage(content: cardContent)
        let text = [
            "I'm growing one clean day at a time.",
            "\(cleanDays) \(cleanDays == 1 ? "day" : "days") clean from \(habit.displayName).",
            "Garden stage: \(gardenStage.title).",
            "Saved: \(savedMoneyText) and \(savedTimeText)."
        ].joined(separator: "\n")

        return ProgressSharePackage(image: image, text: text, style: style)
    }

    private func renderCardImage(content: SGProgressShareCardView.Content) -> UIImage {
        let cardSize = CGSize(width: 1080, height: 1350)
        let cardView = SGProgressShareCardView(frame: CGRect(origin: .zero, size: cardSize))
        cardView.configure(with: content)
        cardView.setNeedsLayout()
        cardView.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: cardSize, format: format)
        return renderer.image { context in
            cardView.layer.render(in: context.cgContext)
        }
    }

    private static func moneyText(for amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        formatter.maximumFractionDigits = amount >= 100 ? 0 : 2
        return formatter.string(from: NSNumber(value: max(amount, 0))) ?? "\(max(amount, 0))"
    }

    private static func timeText(for minutes: Int) -> String {
        guard minutes > 0 else { return "0 min" }
        guard minutes >= 60 else { return "\(minutes) min" }

        let hours = minutes / 60
        let leftover = minutes % 60
        if leftover == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(leftover)m"
    }
}
