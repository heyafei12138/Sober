# SoberGarden 功能说明文档

版本：基于当前项目代码整理  
日期：2026-06-04  
适用范围：SoberGarden iOS App、Widget Extension、Watch App

## 1. 产品概述

SoberGarden 是一款帮助用户戒除不良习惯、记录恢复过程并在冲动时获得即时支持的 iOS 应用。产品将“戒断天数”表达为“花园成长”，通过每日种植、阶段花园、温和鼓励、急救流程和反思记录，降低传统打卡失败感，帮助用户持续建立恢复节奏。

当前代码实现以本地存储为主，不包含账号系统、云同步或社区功能。应用数据保存在本机 Documents 目录下的 `sober_garden_state.json`，并通过 App Group 快照同步给 Widget 和 Watch。

## 2. 目标用户与核心场景

### 2.1 目标用户

- 正在戒烟、戒酒、戒糖、戒赌博、减少社交媒体、戒除色情内容或其他自定义习惯的用户。
- 希望每天获得低压力确认和正向反馈的人。
- 在冲动、压力、孤独、无聊、焦虑等状态下需要即时干预的人。
- 希望通过可视化成长、节省金额、节省时间、复盘记录来感知长期进展的人。

### 2.2 核心场景

- 首次启动时创建恢复旅程。
- 每天打开首页确认今天是否坚持。
- 查看当前坚持天数、最长坚持天数、节省金额和时间。
- 在冲动时进入 Rescue 急救流程。
- 记录当天心情、冲动程度、触发因素和备注。
- 查看花园阶段、成长路径和已解锁徽章。
- 分享恢复进展海报。
- 使用 Widget 或 Watch 快速查看进度或进入救援入口。

## 3. 应用结构

主 App 使用 UIKit 实现，根控制器根据是否已有 `habit` 决定进入 Onboarding 或主界面。

主界面使用自定义 TabBar，共 4 个 Tab：

| Tab | 控制器 | 功能定位 |
| --- | --- | --- |
| Home | `SGHomeViewController` | 首页总览、今日种植、统计、分享、救援入口 |
| Rescue | `SGRescueViewController` | 冲动急救流程 |
| Garden | `SGGardenViewController` | 花园阶段、成长路径、徽章 |
| Journal | `SGJournalViewController` | 每日反思记录、历史记录 |

Settings 从首页右上角进入，不作为独立 Tab。

## 4. Onboarding 首次设置

Onboarding 由 `SGOnboardingViewController` 实现，共 8 步。

### 4.1 欢迎页

- 展示产品欢迎文案和花园插画。
- 点击主按钮进入习惯选择。

### 4.2 选择习惯

支持的习惯类型：

- Smoking
- Vaping
- Alcohol
- Porn
- Gambling
- Sugar
- Social Media
- Weed
- Custom

当选择 Custom 时，必须输入自定义习惯名称后才能继续。

### 4.3 设置开始日期

用户可以选择：

- 今天
- 昨天
- 自定义过去日期

日期选择器最大日期为当天，不能选择未来日期。

### 4.4 设置每日花费

用于计算后续节省金额。当前支持跳过或输入金额，金额会转为 `dailyCost` 存入习惯模型。

### 4.5 设置每日耗时

用于计算后续节省时间。当前支持跳过或输入时间，最终转为每日分钟数 `dailyMinutes`。

### 4.6 设置坚持原因

- 可选择系统预设原因。
- 可输入自定义原因。
- 所有原因会写入 `Habit.reasons`，并在 Rescue 流程中作为提醒内容展示。

### 4.7 通知授权

- 用户可选择开启通知或稍后再说。
- 若授权成功，默认开启每日提醒和里程碑提醒设置。

### 4.8 完成并进入主界面

完成时生成 `Habit` 并保存到本地状态。之后根界面切换为 `MainTabBarController`。

## 5. Home 首页功能

首页是当前 App 的核心聚合页面，展示恢复旅程、每日种植、花园预览、统计和分享入口。

### 5.1 顶部恢复状态

展示：

- 当前坚持天数 `cleanDays`
- 当前习惯名称

`cleanDays` 根据 `habit.startDate` 到当天的日历天数计算，最小为 1。若用户重置当前 streak，`habit.startDate` 会更新为重置时间。

### 5.2 Calm Coach 鼓励卡片

首页展示本地 Calm Coach 文案，不接入外部 AI API。

文案来源：

- 优先读取 `calm_coach_prompts.json`
- 读取失败时使用代码中的 fallback prompts

文案上下文会根据当前状态变化：

- 今日已种植：`postCheckInEncouragement`
- 今日为 rainy：`relapse`
- 当前为第 7 天：`milestone7`
- 今日未确认：`notConfirmedToday`

同一 prompt 在 24 小时内尽量避免重复展示。

### 5.3 今日种植卡片

今日卡片有 3 种状态：

- 未记录：可点击 Plant Today 或 I had a setback
- 已种植：展示今日已完成状态，可编辑
- Rainy Day：展示今日低落/挫折状态，可编辑

用户操作：

- Plant Today：写入今日 `DailyRecord(status: .planted)`
- I had a setback：写入今日 `DailyRecord(status: .rainy)`
- 编辑今日记录：可改为 planted、rainy，或清除今日记录

当前实现限制：首次点击今日记录时，若当天已有记录，主按钮和次按钮不会重复覆盖，必须通过编辑入口修改。

### 5.4 每日花园网格

首页展示每日种植网格，状态由 `DailyRecord` 推导：

- planted：已种植
- rainy：雨天/挫折日
- empty：过去或今天无记录
- future：未来日期

展示范围支持自动或手动：

- 自动：根据下一个里程碑决定展示天数
- 手动：可选 3、7、14、30、60、90、180、365 天

自动展示逻辑：

- 若用户仍在早期阶段，展示到下一个里程碑所需天数
- 若已超过所有里程碑，默认展示最后一个里程碑天数

### 5.5 每日种植统计

首页展示：

- Current Streak：连续 planted 天数
- Total Planted Days：累计 planted 天数

连续 planted 计算规则：

- 今天 planted：从今天向前连续统计 planted
- 今天 empty 且昨天 planted：从昨天向前统计
- 今天 rainy 或昨天非 planted：为 0

### 5.6 阶段回顾提示

当累计 planted 天数达到特定节点时展示回顾卡片：

- 7 天累计种植
- 30 天累计种植

用户关闭后，类型会保存到 `lastReviewShownType`，避免重复展示同一回顾卡片。

### 5.7 Streak 卡片

展示：

- 当前 clean days
- 当前 hours
- 最长 streak
- 开始日期
- 习惯名称

最长 streak 取当前 cleanDays 与历史 relapse 记录中的 `previousStreakDays` 最大值。

### 5.8 节省金额与时间

若用户在 Onboarding 或设置中填写了每日花费、每日耗时，首页会基于完整经过天数计算：

- 节省金额 = dailyCost × elapsedCleanDays
- 节省时间 = dailyMinutes × elapsedCleanDays

点击节省统计可进入习惯编辑。

### 5.9 里程碑卡片与花园预览

首页展示下一个里程碑和当前花园阶段预览。

默认里程碑：

| 天数 | 阶段 | 徽章 |
| --- | --- | --- |
| 1 | Seed | First Seed |
| 3 | Sprout | Tiny Leaf |
| 7 | Young Plant | First Week |
| 14 | Flower | Steady Bloom |
| 30 | Garden Bed | 30-Day Bloom |
| 60 | Blooming Garden | Deep Roots |
| 90 | Peaceful Garden | 90-Day Sanctuary |
| 180 | Small Forest | Strong Roots |
| 365 | Sanctuary | One Year Clean |

### 5.10 分享入口

首页提供分享进展入口，生成分享预览页。保存图片和系统分享操作需要 Plus 权限。

### 5.11 浮动救援入口

首页右下角有呼吸动画样式的 Rescue 按钮，点击切换到 Rescue Tab。滚动时按钮会轻微隐藏，停止滚动后恢复。

### 5.12 非医疗声明

首次进入首页时，如果用户尚未确认非医疗声明，会弹出全屏声明页。确认后写入 `hasAcknowledgedNonMedicalDisclaimer`。

## 6. Rescue 急救流程

Rescue 由 `SGRescueViewController` 实现，用于用户产生冲动或情绪波动时的即时干预。

### 6.1 流程步骤

共 6 步：

| 步骤 | 功能 |
| --- | --- |
| Emotion | 选择当前情绪或跳过 |
| Coach | 展示 Calm Coach 提示 |
| Breathing | 呼吸练习 |
| Reasons | 展示用户设置的坚持原因 |
| Delay | 10 分钟延迟承诺 |
| Feedback | 记录干预后的冲动评分 |

### 6.2 情绪类型

支持：

- urge
- stress
- lonely
- bored
- angry
- tired
- anxious
- triggered

选择情绪后，Coach 文案会按情绪上下文加载。若跳过情绪，则默认使用 urge 上下文。

### 6.3 Coach 提示

Coach 提示模拟加载 1.2 秒后展示本地 prompt。该功能是本地随机加权选择，不调用远程 AI。

### 6.4 呼吸练习

进入 breathing 步骤后，呼吸组件自动开始。用户可以：

- 自然完成呼吸练习
- 提前结束

是否完成会保存到 `RescueSession.completedBreathing`。

### 6.5 坚持原因提醒

Rescue 会读取用户在 Onboarding / 习惯编辑中保存的 `habit.reasons`。如果没有原因，则展示 fallback 文案。

### 6.6 10 分钟延迟承诺

用户点击主按钮后：

- `completedDelay` 记为 true
- 若 Plus 且开启急救延迟提醒，则安排 10 分钟后的本地通知
- 进入反馈步骤

如果用户仍然很难受，可以点击 Still Struggling 返回呼吸步骤。

### 6.7 反馈记录

用户通过 slider 记录干预后的冲动评分，范围 0-10。

完成后保存 `RescueSession`：

- id
- date
- emotion
- urgeBefore
- urgeAfter
- completedBreathing
- completedDelay

保存后会重置为新一轮 Rescue 流程，并可能触发 App Store 评价提示。

## 7. Garden 花园页

Garden 由 `SGGardenViewController` 实现，展示阶段花园、下一奖励进度、成长路径和徽章。

### 7.1 Plus 权限

当前 Garden 页整体被 Plus 遮罩保护：

- Plus 用户：可完整查看花园页
- Free 用户：看到动态背景和解锁按钮，点击进入订阅页

### 7.2 当前阶段

根据 `cleanDays` 匹配最近一个不超过当前天数的里程碑，得到当前 `GardenStage`。

### 7.3 下一奖励进度

若存在下一个里程碑，展示：

- 下一阶段名称
- 还差多少天
- 解锁奖励描述
- 当前阶段进度条

若已达到最终 Sanctuary，进度条为 100% 并展示完全成长文案。

### 7.4 成长路径

展示所有默认里程碑，当前进度基于 cleanDays。

### 7.5 徽章保留

徽章解锁天数使用 `retainedBadgeDays`：

- 当前 cleanDays
- 历史 relapse 记录中的最高 previousStreakDays

因此用户重置当前 streak 后，历史已达到的徽章可保留。

### 7.6 分享

Garden 页右上角分享按钮复用进展分享服务，打开分享预览页。

## 8. Journal 每日反思

Journal 由 `SGJournalViewController` 实现，用于记录每天的情绪、冲动、触发因素和备注。

### 8.1 今日记录

今日 Check-in 包含：

- Mood：great、calm、okay、low、stressed
- Urge Level：none、mild、strong
- Triggers：stress、boredom、loneliness、socialMedia、lateNight、conflict、tiredness、custom
- Note：文本备注

保存逻辑：

- 若当天已有记录，则覆盖当天记录
- 若当天无记录，则新增
- 保存后按日期倒序排列

### 8.2 统计卡片

Journal 展示 clean streak 和 check-in streak 统计。该统计卡对 Free 用户显示锁定状态，Plus 用户可查看完整内容。

### 8.3 历史记录

- 无记录时展示空状态。
- Free 用户有记录时展示解锁卡片。
- Plus 用户展示最近 7 条 journal entries。

## 9. Settings 设置

Settings 由 `SGSettingsViewController` 实现，从首页右上角进入。

### 9.1 Plus 卡片

展示当前订阅状态：

- 未订阅：展示 Plus 介绍和查看方案入口
- 已订阅：展示 Plus Active 状态和管理入口文案

点击进入订阅页。

### 9.2 习惯设置

展示：

- 当前习惯类型
- 开始日期
- 每日花费
- 每日耗时
- 坚持原因数量

可进入 `SGEditHabitViewController` 编辑当前习惯。

额外习惯功能当前标记为 Plus，但实现为 Coming Soon。

### 9.3 偏好设置

支持语言选择。当前项目包含多语言资源，覆盖：

- English
- 简体中文
- 繁体中文
- 日语
- 韩语
- 法语
- 德语
- 西班牙语
- 意大利语

语言切换后通过 Localize-Swift 通知刷新设置页文案。

### 9.4 通知设置

通知项：

| 通知 | 默认 | 权限 |
| --- | --- | --- |
| 每日提醒 | 开启，默认 09:00 | Free 可用 |
| 里程碑提醒 | 开启 | Plus |
| 夜间提醒 | 开启，默认 22:00 | Plus |
| 急救延迟提醒 | 开启 | Plus |

开启通知时会请求系统通知权限。若被拒绝，会提示用户打开系统设置。

### 9.5 隐私设置

包含：

- App Lock
- Privacy Policy
- Terms
- Disclaimer

App Lock 使用 LocalAuthentication 的 `deviceOwnerAuthentication`，支持设备密码、Face ID 或 Touch ID，取决于系统能力。开启前需要认证；开启后 App 回到前台或处理深链前会认证。

隐私政策、条款通过 Safari View 打开外部链接；免责声明进入本地声明页。

### 9.6 数据管理

支持：

- Reset Current Streak：记录一次 relapse，保存 previousStartDate 和 previousStreakDays，并把当前 habit.startDate 重置为现在
- Delete All Data：删除本地状态文件、取消通知、清除 Widget 快照，并回到 Onboarding

### 9.7 Widget 指南

打开 `SGWidgetGuideViewController`，以 page sheet 形式展示小组件使用指南。

### 9.8 关于

包含：

- Feedback：通过邮件反馈服务发起反馈
- Version：展示 `CFBundleShortVersionString (CFBundleVersion)`

## 10. Subscription 订阅

订阅由 StoreKit 2 实现。

### 10.1 产品方案

当前代码定义 3 个产品：

| 方案 | Product ID |
| --- | --- |
| Weekly | `sober.weekly` |
| Yearly | `sober.yearly` |
| Lifetime | `SoberGarden.Lifetime` |

订阅页默认选择 Yearly。

### 10.2 权益状态

权益类型：

- unknown
- free
- active(plan, expirationDate)
- lifetime

`active` 和 `lifetime` 都视为 Plus。

权益会缓存到 UserDefaults，并监听 StoreKit transaction updates 自动刷新。

### 10.3 购买与恢复

支持：

- 加载 App Store 产品
- 购买选中方案
- 验证交易
- finish transaction
- 刷新 entitlement
- Restore purchases

购买结果包括：

- purchased
- cancelled
- pending
- failed

### 10.4 当前 Plus 保护能力

当前代码中被 Plus 限制的能力包括：

- Garden 页完整访问
- Journal 历史记录
- Journal / Settings 中的部分统计展示
- 保存分享海报到相册
- 系统分享海报
- 里程碑通知
- 夜间提醒
- Rescue 10 分钟延迟提醒
- 额外习惯入口目前为 Coming Soon

## 11. 分享海报

分享由 `SGShareProgressService` 和 `SGSharePreviewViewController` 实现。

### 11.1 海报内容

生成 1080 × 1350 图片，内容包括：

- cleanDays
- habitName
- gardenStage
- savedMoneyText
- savedTimeText
- generatedAt

### 11.2 海报风格

支持 3 种风格：

- garden
- fresh
- sunrise

用户可在预览页通过 segmented control 切换，切换后重新生成海报。

### 11.3 分享文本

系统分享包含图片和文本，文本包含：

- 产品分享引导语
- clean days + habit
- garden stage
- 节省金额与时间

### 11.4 保存与分享权限

保存到相册和调用系统分享前会检查 Plus。保存图片时会请求 Photos addOnly 权限。

## 12. Widget

Widget Extension 包含 3 个静态小组件，支持 systemSmall 和 systemMedium。

### 12.1 Streak Widget

展示：

- SoberGarden 标题
- clean days
- 下一个里程碑
- 今日状态：planted、rainy、not planted
- 中尺寸展示进度线

点击跳转：`sobergarden://home`

### 12.2 Garden Widget

展示：

- 当前花园成长状态
- clean days
- garden stage
- 花园阶段插画

点击跳转：`sobergarden://garden`

### 12.3 Rescue Widget

展示：

- Rescue 标题
- 入口问题文案
- Open 按钮样式

点击跳转：`sobergarden://rescue`

### 12.4 数据刷新

Widget 通过 `SGWidgetSnapshotReader` 读取 App Group 中的快照，Timeline 每小时刷新一次。主 App 每次保存状态时会写入快照并调用 `WidgetCenter.reloadAllTimelines()`。

## 13. Watch App

Watch App 使用 SwiftUI 实现。

### 13.1 首页

展示：

- habitDisplayName
- clean days
- next milestone

数据来自 App Group 快照。

### 13.2 呼吸救援入口

Watch 首页提供 “I'm Struggling” 入口，进入 `SGWatchBreathingView` 进行手表端呼吸练习。

## 14. 深链

App 支持 `sobergarden://` scheme。

### 14.1 支持路径

| 深链 | 目标 |
| --- | --- |
| `sobergarden://home` | Home Tab |
| `sobergarden://rescue` | Rescue Tab，并重置为新 Rescue session |
| `sobergarden://garden` | Garden Tab |
| `sobergarden://journal` | Journal Tab |
| `sobergarden://settings` | Home Tab 后 push Settings |

### 14.2 App Lock 处理

当 App Lock 开启时，深链会先缓存为 pending URL，认证成功后再路由。认证失败则丢弃 pending URL。

## 15. 通知

通知服务由 `SGNotificationService` 统一管理。

### 15.1 通知类型

| 类型 | Identifier | 触发方式 |
| --- | --- | --- |
| 每日提醒 | `sg.notification.dailyReminder` | 每天固定时间重复 |
| 里程碑提醒 | `sg.notification.milestone` | 下一个里程碑日期一次性提醒 |
| 夜间提醒 | `sg.notification.nightReminder` | 每天固定时间重复 |
| 急救延迟提醒 | `sg.notification.rescueDelay` | Rescue 延迟承诺后 10 分钟 |
| 测试通知 | `sg.notification.test` | Debug 参数触发 |

### 15.2 重排逻辑

每次保存状态时会重新调度通知：

- 先移除 daily、milestone、night 的 pending requests
- 若没有 habit，不安排通知
- 若通知授权允许且 dailyReminderEnabled，安排每日提醒
- 若 Plus 且对应设置开启，安排夜间提醒和里程碑提醒

急救延迟提醒单独调度，不在常规重排列表中。

## 16. 数据模型

### 16.1 全局状态

`SoberGardenState` 字段：

- `habit`
- `rescueSessions`
- `journalEntries`
- `relapseRecords`
- `dailyRecords`
- `dailyGardenDisplayDays`
- `lastReviewShownType`
- `lastMonthlyReviewShownMonth`
- `recentPromptIDs`
- `checkIn`
- `settings`

### 16.2 Habit

字段：

- id
- type
- customName
- startDate
- dailyCost
- dailyMinutes
- reasons
- createdAt
- updatedAt

### 16.3 DailyRecord

字段：

- id
- date
- dayKey
- status：planted 或 rainy
- createdAt
- updatedAt

说明：empty 和 future 不入库，由 UI 计算。

### 16.4 RescueSession

字段：

- id
- date
- emotion
- urgeBefore
- urgeAfter
- completedBreathing
- completedDelay

当前代码中 `urgeBefore` 字段存在，但 Rescue 当前流程主要保存 `urgeAfter`，未看到前置冲动评分输入步骤。

### 16.5 JournalEntry

字段：

- id
- date
- mood
- urgeLevel
- triggers
- note

### 16.6 RelapseRecord

字段：

- id
- date
- previousStartDate
- previousStreakDays
- note

### 16.7 SoberGardenCheckInState

字段：

- lastCheckInDate
- confirmedToday
- needsYesterdayConfirmation
- checkInStreakDays
- lastOutcome
- lastOutcomeDate

当前状态模型和 store 中存在 check-in streak 相关逻辑，但主线首页每日种植使用的是 `dailyRecords`。Journal / Settings 统计会展示 `checkIn.checkInStreakDays`。

### 16.8 Settings

字段：

- dailyReminderEnabled
- dailyReminderTime
- milestoneNotificationsEnabled
- nightReminderEnabled
- nightReminderTime
- rescueDelayReminderEnabled
- appLockEnabled
- hasAcknowledgedNonMedicalDisclaimer

默认：

- dailyReminderEnabled：true
- dailyReminderTime：09:00
- milestoneNotificationsEnabled：true
- nightReminderEnabled：true
- nightReminderTime：22:00
- rescueDelayReminderEnabled：true
- appLockEnabled：false
- hasAcknowledgedNonMedicalDisclaimer：false

## 17. 本地化

项目使用 Localize-Swift 和 `Localizable.strings` 管理文案。

当前主 App、Widget、Watch 均包含多语言资源。主 App storyboard 也包含各语言的 Main 和 LaunchScreen strings。

支持语言包括：

- en
- zh-Hans
- zh-HK
- ja
- ko
- fr
- de
- es
- it

## 18. 技术边界与当前限制

### 18.1 已实现

- 本地 JSON 状态存储
- 多语言
- 自定义 TabBar
- Onboarding
- 每日种植
- Streak / savings / milestone 统计
- Rescue 急救流程
- Journal 今日记录与历史
- Plus 订阅与权益缓存
- 本地通知
- App Lock
- 分享海报
- Widget
- Watch 快照与呼吸入口
- 深链

### 18.2 未实现或未在当前代码中看到完整实现

- 账号系统
- 云同步
- 社区功能
- 排行榜
- 远程 AI Coach
- 多设备数据同步
- Core Data / SQLite 数据库
- Rescue 的 urgeBefore 输入步骤
- 多习惯完整管理，当前额外习惯入口为 Coming Soon
- 月度回顾完整 UI，状态字段存在 `lastMonthlyReviewShownMonth`，但当前读取范围内未看到对应展示逻辑

## 19. 关键业务规则摘要

- 没有 habit 时进入 Onboarding；有 habit 时进入主界面。
- cleanDays 基于 habit.startDate 到今天的日历天数，最小为 1。
- Reset Current Streak 会生成 relapse record，并把 habit.startDate 改为当前时间。
- DailyRecord 只保存 planted/rainy；empty/future 由日期和记录推导。
- 今日记录首次创建后，需通过编辑入口修改或清除。
- Total Planted Days 统计所有唯一日期中状态为 planted 的记录。
- Daily Plant Streak 只统计连续 planted；rainy 会使该统计归 0。
- 徽章使用当前 cleanDays 与历史 previousStreakDays 的最大值决定解锁保留。
- Plus 影响 Garden、Journal 历史、部分通知、分享保存/分享、部分统计和未来多习惯能力。
- Widget / Watch 读取 App Group 快照，不直接读取主 App 的 JSON 状态文件。
- App Lock 开启后，前台恢复和深链路由都需要先通过系统认证。

