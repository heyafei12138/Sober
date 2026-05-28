//
//  SGAppLanguage.swift
//  SoberGarden
//

import Foundation

struct SGAppLanguage: Equatable {
    let code: String
    let nativeName: String
    let detailName: String

    static let supported: [SGAppLanguage] = [
        SGAppLanguage(code: "en", nativeName: "English", detailName: "English"),
        SGAppLanguage(code: "zh-Hans", nativeName: "简体中文", detailName: "Chinese, Simplified"),
        SGAppLanguage(code: "zh-HK", nativeName: "繁體中文（香港）", detailName: "Chinese, Hong Kong"),
        SGAppLanguage(code: "ja", nativeName: "日本語", detailName: "Japanese"),
        SGAppLanguage(code: "ko", nativeName: "한국어", detailName: "Korean"),
        SGAppLanguage(code: "de", nativeName: "Deutsch", detailName: "German"),
        SGAppLanguage(code: "fr", nativeName: "Français", detailName: "French"),
        SGAppLanguage(code: "it", nativeName: "Italiano", detailName: "Italian"),
        SGAppLanguage(code: "es", nativeName: "Español", detailName: "Spanish")
    ]

    static var available: [SGAppLanguage] {
        let availableCodes = Set(Localize.availableLanguages(true))
        let filtered = supported.filter { availableCodes.contains($0.code) }
        return filtered.isEmpty ? supported : filtered
    }

    static var current: SGAppLanguage {
        language(for: Localize.currentLanguage()) ?? language(for: Localize.defaultLanguage()) ?? supported[0]
    }

    static func language(for code: String) -> SGAppLanguage? {
        supported.first { $0.code == code }
    }
}
