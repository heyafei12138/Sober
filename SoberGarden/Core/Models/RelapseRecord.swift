//
//  RelapseRecord.swift
//  SoberGarden
//

import Foundation

struct RelapseRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let previousStartDate: Date
    let previousStreakDays: Int
    var note: String?
}
