//
//  SGRecoveryLanguage.swift
//  SoberGarden
//

import Foundation

enum SGRecoveryMode: Equatable {
    case sobriety
    case generic
}

struct SGRecoveryCoachContexts: Equatable {
    let morning: String
    let craving: String
    let postSetback: String
    let milestone: String
    let nightReflection: String
}

struct SGRecoveryLanguage: Equatable {
    let mode: SGRecoveryMode
    let dayUnitTitleKey: String
    let streakTitleKey: String
    let dayCountFormatKey: String
    let primaryCheckInActionKey: String
    let setbackActionKey: String
    let completedCheckInStatusKey: String
    let urgeTitleKey: String
    let journeyTitleKey: String
    let gardenTitleKey: String
    let homeStatusTitleFormatKey: String
    let homeStatusSubtitleKey: String
    let homeStatusCaptionKey: String
    let coachContextPrefix: String
    let coachContexts: SGRecoveryCoachContexts
}

extension SGRecoveryLanguage {
    static let sobriety = SGRecoveryLanguage(
        mode: .sobriety,
        dayUnitTitleKey: "recovery.dayUnit.sober",
        streakTitleKey: "recovery.streak.sober",
        dayCountFormatKey: "recovery.dayCount.soberFormat",
        primaryCheckInActionKey: "recovery.action.markTodaySober",
        setbackActionKey: "recovery.action.setback",
        completedCheckInStatusKey: "recovery.action.status.sober",
        urgeTitleKey: "recovery.urge.craving",
        journeyTitleKey: "recovery.journey.sober",
        gardenTitleKey: "recovery.garden.recoveryGarden",
        homeStatusTitleFormatKey: "recovery.dayCount.soberFormat",
        homeStatusSubtitleKey: "recovery.home.alcoholFreeAndGrowing",
        homeStatusCaptionKey: "recovery.home.takingRoot",
        coachContextPrefix: "sobriety",
        coachContexts: SGRecoveryCoachContexts(
            morning: "sobrietyMorning",
            craving: "cravingMoment",
            postSetback: "postSetback",
            milestone: "milestoneSober",
            nightReflection: "nightReflection"
        )
    )

    static let generic = SGRecoveryLanguage(
        mode: .generic,
        dayUnitTitleKey: "recovery.dayUnit.clean",
        streakTitleKey: "recovery.streak.clean",
        dayCountFormatKey: "recovery.dayCount.cleanFormat",
        primaryCheckInActionKey: "dailyPlant.card.empty.primary",
        setbackActionKey: "recovery.action.setback",
        completedCheckInStatusKey: "dailyPlant.card.planted.status",
        urgeTitleKey: "recovery.urge.generic",
        journeyTitleKey: "recovery.journey.generic",
        gardenTitleKey: "recovery.garden.generic",
        homeStatusTitleFormatKey: "recovery.dayCount.cleanFormat",
        homeStatusSubtitleKey: "recovery.home.genericGrowing",
        homeStatusCaptionKey: "home.header.caption",
        coachContextPrefix: "generic",
        coachContexts: SGRecoveryCoachContexts(
            morning: "home",
            craving: "urge",
            postSetback: "relapse",
            milestone: "milestone7",
            nightReflection: "lateNight"
        )
    )
}
