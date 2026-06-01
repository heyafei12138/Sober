//
//  WidgetSnapshot.swift
//  SoberGarden
//

import Foundation

struct WidgetSnapshot: Codable {
    var cleanDays: Int
    var nextMilestone: Int?
    var gardenStage: GardenStage
    var habitDisplayName: String
    var updatedAt: Date
    var todayStatus: DailyRecordStatus?
}
