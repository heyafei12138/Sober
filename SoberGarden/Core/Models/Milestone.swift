//
//  Milestone.swift
//  SoberGarden
//

import Foundation

struct Milestone: Codable, Identifiable {
    let id: UUID
    let day: Int
    let title: String
    let gardenStage: GardenStage
    let badgeName: String

    var rewardDescription: String {
        gardenStage.rewardDescription
    }

    static let defaultMilestones: [Milestone] = [
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, day: 1, title: "Seed", gardenStage: .seed, badgeName: "First Seed"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, day: 3, title: "Sprout", gardenStage: .sprout, badgeName: "Tiny Leaf"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!, day: 7, title: "Young Plant", gardenStage: .youngPlant, badgeName: "First Week"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!, day: 14, title: "Flower", gardenStage: .flower, badgeName: "Steady Bloom"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!, day: 30, title: "Garden Bed", gardenStage: .gardenBed, badgeName: "30-Day Bloom"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000060")!, day: 60, title: "Blooming Garden", gardenStage: .bloomingGarden, badgeName: "Deep Roots"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000090")!, day: 90, title: "Peaceful Garden", gardenStage: .peacefulGarden, badgeName: "90-Day Sanctuary"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000180")!, day: 180, title: "Small Forest", gardenStage: .smallForest, badgeName: "Strong Roots"),
        Milestone(id: UUID(uuidString: "00000000-0000-0000-0000-000000000365")!, day: 365, title: "Sanctuary", gardenStage: .sanctuary, badgeName: "One Year Clean")
    ]
}

enum GardenStage: String, Codable, CaseIterable {
    case seed
    case sprout
    case youngPlant
    case flower
    case gardenBed
    case bloomingGarden
    case peacefulGarden
    case smallForest
    case sanctuary

    var title: String {
        switch self {
        case .seed:
            return "Seed"
        case .sprout:
            return "Sprout"
        case .youngPlant:
            return "Young Plant"
        case .flower:
            return "Flower"
        case .gardenBed:
            return "Garden Bed"
        case .bloomingGarden:
            return "Blooming Garden"
        case .peacefulGarden:
            return "Peaceful Garden"
        case .smallForest:
            return "Small Forest"
        case .sanctuary:
            return "Sanctuary"
        }
    }

    var badgeName: String {
        switch self {
        case .seed:
            return "First Seed"
        case .sprout:
            return "Tiny Leaf"
        case .youngPlant:
            return "First Week"
        case .flower:
            return "Steady Bloom"
        case .gardenBed:
            return "30-Day Bloom"
        case .bloomingGarden:
            return "Deep Roots"
        case .peacefulGarden:
            return "90-Day Sanctuary"
        case .smallForest:
            return "Strong Roots"
        case .sanctuary:
            return "One Year Clean"
        }
    }

    var rewardDescription: String {
        switch self {
        case .seed:
            return "Your first seed is planted."
        case .sprout:
            return "A tiny sprout breaks through the soil."
        case .youngPlant:
            return "Fresh leaves make your progress visible."
        case .flower:
            return "Your first flower appears in the garden."
        case .gardenBed:
            return "A small bed of blooms starts to fill the space."
        case .bloomingGarden:
            return "More flowers arrive, with the first tree taking root."
        case .peacefulGarden:
            return "Trees and a quiet path make the garden feel settled."
        case .smallForest:
            return "A cluster of trees grows into a small forest."
        case .sanctuary:
            return "The full sanctuary opens with sunlight, trees, and a path."
        }
    }
}
