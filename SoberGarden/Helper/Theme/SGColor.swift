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

    /// 花朵/徽章点缀色
    static let flower = UIColor.hexString("#F2C879")
    static let flowerSoft = UIColor.hexString("#FBF0D6")

    /// 分区浅底（打破全白单调）
    static let coachTint = UIColor.hexString("#EFF5E6")
    static let savingsMoneyTint = UIColor.hexString("#FAF6EE")
    static let savingsTimeTint = UIColor.hexString("#F0F6EC")
    static let milestoneTint = UIColor.hexString("#F8FAF4")

    /// 柔和卡片阴影
    static let softShadow = UIColor.hexString("#31412B").withAlphaComponent(0.10)
}
