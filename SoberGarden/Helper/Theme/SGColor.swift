//
//  SGColor.swift
//  SoberGarden
//

import UIKit

/// 应用主题色（设计 Token）
enum SGColor {

    /// 主色 #8AA86B
    static let primary = UIColor.hexString("#8AA86B")

    /// 主色深色 #5F7D46
    static let primaryDark = UIColor.hexString("#5F7D46")

    /// 主色浅色 #DDE8D2
    static let primaryLight = UIColor.hexString("#DDE8D2")

    /// 页面背景 #F7F5EA
    static let background = UIColor.hexString("#F7F5EA")

    /// 主文字 #31412B
    static let textDark = UIColor.hexString("#31412B")

    // MARK: - 语义色（由主 Token 衍生）

    static let textSecondary = textDark.withAlphaComponent(0.65)
    static let textTertiary = textDark.withAlphaComponent(0.4)
    static let surface = UIColor.white
    static let separator = primaryLight
    static let tabBarTint = UIColor.black.withAlphaComponent(0.08)

    /// 急救 CTA（PRD：温暖橙，非警告红）
    static let rescue = UIColor.hexString("#E89B5C")
}
