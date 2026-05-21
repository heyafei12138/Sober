//
//  SGCalmCoachService.swift
//  SoberGarden
//

import Foundation

enum SGCalmCoachContext: String, CaseIterable {
    case home
    case notConfirmedToday
    case confirmedToday
    case yesterdayFollowUp
    case postCheckInEncouragement
    case urge
    case stress
    case lonely
    case bored
    case angry
    case tired
    case anxious
    case triggered
    case lateNight
    case milestone7
    case relapse
}

struct SGCalmCoachPrompt: Codable, Identifiable {
    let id: String
    let context: String
    let weight: Double
    let text: String
}

final class SGCalmCoachService {

    static let shared = SGCalmCoachService()

    private let promptsByContext: [String: [SGCalmCoachPrompt]]
    private let store: SoberGardenStore
    private let repeatWindow: TimeInterval = 24 * 60 * 60

    init(store: SoberGardenStore = .shared, bundle: Bundle = .main) {
        self.store = store
        self.promptsByContext = Self.loadPrompts(from: bundle)
    }

    func prompt(for context: SGCalmCoachContext, now: Date = Date()) -> SGCalmCoachPrompt {
        let candidates = promptsByContext[context.rawValue] ?? Self.fallbackPrompts[context.rawValue] ?? []
        guard !candidates.isEmpty else {
            return SGCalmCoachPrompt(
                id: "fallback_\(context.rawValue)",
                context: context.rawValue,
                weight: 1,
                text: "Take one calm step. You do not need to solve everything right now."
            )
        }

        let recentPromptIDs = Set(store.recentPromptIDs(within: repeatWindow, now: now))
        let available = candidates.filter { !recentPromptIDs.contains($0.id) }
        let pool = available.isEmpty ? candidates : available
        let selected = weightedRandom(from: pool) ?? pool.randomElement() ?? candidates[0]
        store.recordPromptShown(id: selected.id, shownAt: now)
        return selected
    }

    func promptText(for context: SGCalmCoachContext, now: Date = Date()) -> String {
        prompt(for: context, now: now).text
    }

    private func weightedRandom(from prompts: [SGCalmCoachPrompt]) -> SGCalmCoachPrompt? {
        let positivePrompts = prompts.filter { $0.weight > 0 }
        let pool = positivePrompts.isEmpty ? prompts : positivePrompts
        guard !pool.isEmpty else { return nil }

        let totalWeight = pool.reduce(0) { $0 + max($1.weight, 0) }
        guard totalWeight > 0 else { return pool.randomElement() }

        let threshold = Double.random(in: 0..<totalWeight)
        var runningTotal: Double = 0

        for prompt in pool {
            runningTotal += max(prompt.weight, 0)
            if threshold < runningTotal {
                return prompt
            }
        }

        return pool.last
    }

    private static func loadPrompts(from bundle: Bundle) -> [String: [SGCalmCoachPrompt]] {
        guard let url = bundle.url(forResource: "calm_coach_prompts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let prompts = try? JSONDecoder().decode([SGCalmCoachPrompt].self, from: data) else {
            return fallbackPrompts
        }

        return Dictionary(grouping: prompts, by: { $0.context })
    }

    private static let fallbackPrompts: [String: [SGCalmCoachPrompt]] = [
        "home": [
            SGCalmCoachPrompt(id: "home_1", context: "home", weight: 3, text: "Take one steady breath and choose the next right thing."),
            SGCalmCoachPrompt(id: "home_2", context: "home", weight: 2, text: "You are building proof that change is possible, one day at a time.")
        ],
        "notConfirmedToday": [
            SGCalmCoachPrompt(id: "notConfirmedToday_1", context: "notConfirmedToday", weight: 3, text: "A quiet check-in can turn the day around."),
            SGCalmCoachPrompt(id: "notConfirmedToday_2", context: "notConfirmedToday", weight: 2, text: "You can start with one small, honest moment now.")
        ],
        "confirmedToday": [
            SGCalmCoachPrompt(id: "confirmedToday_1", context: "confirmedToday", weight: 3, text: "You have already protected today. Keep the rhythm gentle."),
            SGCalmCoachPrompt(id: "confirmedToday_2", context: "confirmedToday", weight: 2, text: "Small daily proof adds up. Let that sink in.")
        ],
        "yesterdayFollowUp": [
            SGCalmCoachPrompt(id: "yesterdayFollowUp_1", context: "yesterdayFollowUp", weight: 3, text: "If yesterday stayed clean, you can protect that progress now."),
            SGCalmCoachPrompt(id: "yesterdayFollowUp_2", context: "yesterdayFollowUp", weight: 2, text: "Yesterday still matters. A calm confirmation is enough.")
        ],
        "postCheckInEncouragement": [
            SGCalmCoachPrompt(id: "postCheckInEncouragement_1", context: "postCheckInEncouragement", weight: 3, text: "Nice work. You kept the garden moving today."),
            SGCalmCoachPrompt(id: "postCheckInEncouragement_2", context: "postCheckInEncouragement", weight: 2, text: "That was a steady choice. Let the win land.")
        ],
        "urge": [
            SGCalmCoachPrompt(id: "urge_1", context: "urge", weight: 3, text: "Ride this urge for one minute before you decide anything."),
            SGCalmCoachPrompt(id: "urge_2", context: "urge", weight: 2, text: "Urges peak, then pass. Stay with the wave until it softens.")
        ],
        "stress": [
            SGCalmCoachPrompt(id: "stress_1", context: "stress", weight: 3, text: "Lower the pressure. One calm action is enough for now."),
            SGCalmCoachPrompt(id: "stress_2", context: "stress", weight: 2, text: "You do not need to carry every problem at full weight tonight.")
        ],
        "lonely": [
            SGCalmCoachPrompt(id: "lonely_1", context: "lonely", weight: 3, text: "Reach for connection, even if it is just one message."),
            SGCalmCoachPrompt(id: "lonely_2", context: "lonely", weight: 2, text: "Loneliness is a feeling, not a verdict. Stay close to people who help.")
        ],
        "bored": [
            SGCalmCoachPrompt(id: "bored_1", context: "bored", weight: 3, text: "Boredom is a good time to change the scene, not your goals."),
            SGCalmCoachPrompt(id: "bored_2", context: "bored", weight: 2, text: "Pick a small task with a clear finish and let momentum do the rest.")
        ],
        "angry": [
            SGCalmCoachPrompt(id: "angry_1", context: "angry", weight: 3, text: "Do not act from the edge of the feeling. Let it drop first."),
            SGCalmCoachPrompt(id: "angry_2", context: "angry", weight: 2, text: "Anger wants motion. Give it a walk, water, or a slower breath.")
        ],
        "tired": [
            SGCalmCoachPrompt(id: "tired_1", context: "tired", weight: 3, text: "Fatigue makes old habits louder. Keep the next step small."),
            SGCalmCoachPrompt(id: "tired_2", context: "tired", weight: 2, text: "Rest is part of staying on track. Reduce decisions for tonight.")
        ],
        "anxious": [
            SGCalmCoachPrompt(id: "anxious_1", context: "anxious", weight: 3, text: "Name three things you can see, then return to the breath."),
            SGCalmCoachPrompt(id: "anxious_2", context: "anxious", weight: 2, text: "You only need enough calm for the next few minutes.")
        ],
        "triggered": [
            SGCalmCoachPrompt(id: "triggered_1", context: "triggered", weight: 3, text: "Leave the trigger if you can and give your body some space."),
            SGCalmCoachPrompt(id: "triggered_2", context: "triggered", weight: 2, text: "This is a cue, not a command. Pause before you respond.")
        ],
        "lateNight": [
            SGCalmCoachPrompt(id: "lateNight_1", context: "lateNight", weight: 3, text: "Night hours distort judgment. Put distance between you and the urge."),
            SGCalmCoachPrompt(id: "lateNight_2", context: "lateNight", weight: 2, text: "Late-night decisions are often the hardest to trust tomorrow.")
        ],
        "milestone7": [
            SGCalmCoachPrompt(id: "milestone7_1", context: "milestone7", weight: 3, text: "Seven days is a real shift. Let the progress land."),
            SGCalmCoachPrompt(id: "milestone7_2", context: "milestone7", weight: 2, text: "You have already changed your pattern. Keep tending it.")
        ],
        "relapse": [
            SGCalmCoachPrompt(id: "relapse_1", context: "relapse", weight: 3, text: "A slip is information, not a full stop. Return to the next step."),
            SGCalmCoachPrompt(id: "relapse_2", context: "relapse", weight: 2, text: "Start again from now. The garden still grows after the rain.")
        ]
    ]
}
