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
            return "garden.stage.seed".localized()
        case .sprout:
            return "garden.stage.sprout".localized()
        case .youngPlant:
            return "garden.stage.youngPlant".localized()
        case .flower:
            return "garden.stage.flower".localized()
        case .gardenBed:
            return "garden.stage.gardenBed".localized()
        case .bloomingGarden:
            return "garden.stage.bloomingGarden".localized()
        case .peacefulGarden:
            return "garden.stage.peacefulGarden".localized()
        case .smallForest:
            return "garden.stage.smallForest".localized()
        case .sanctuary:
            return "garden.stage.sanctuary".localized()
        }
    }

    var badgeName: String {
        switch self {
        case .seed:
            return "garden.badge.firstSeed".localized()
        case .sprout:
            return "garden.badge.tinyLeaf".localized()
        case .youngPlant:
            return "garden.badge.firstWeek".localized()
        case .flower:
            return "garden.badge.steadyBloom".localized()
        case .gardenBed:
            return "garden.badge.thirtyDayBloom".localized()
        case .bloomingGarden:
            return "garden.badge.deepRoots".localized()
        case .peacefulGarden:
            return "garden.badge.ninetyDaySanctuary".localized()
        case .smallForest:
            return "garden.badge.strongRoots".localized()
        case .sanctuary:
            return "garden.badge.oneYearClean".localized()
        }
    }

    var rewardDescription: String {
        switch self {
        case .seed:
            return "garden.reward.seed".localized()
        case .sprout:
            return "garden.reward.sprout".localized()
        case .youngPlant:
            return "garden.reward.youngPlant".localized()
        case .flower:
            return "garden.reward.flower".localized()
        case .gardenBed:
            return "garden.reward.gardenBed".localized()
        case .bloomingGarden:
            return "garden.reward.bloomingGarden".localized()
        case .peacefulGarden:
            return "garden.reward.peacefulGarden".localized()
        case .smallForest:
            return "garden.reward.smallForest".localized()
        case .sanctuary:
            return "garden.reward.sanctuary".localized()
        }
    }
}
