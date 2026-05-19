# Sober Garden v1.0 产品需求文档（PRD）

> 面向 Codex / 开发实现使用  
> 版本：v1.0 非订阅版  
> 平台：iOS + Widget + Apple Watch Lite  
> 核心目标：先上线、避免 4.3、验证留存和核心体验  
> 当前策略：不接 AI API、不做订阅、不做社区、不做账号，所有数据本地存储

---

## 1. 产品概述

### 1.1 产品名称

暂定：

**Sober Garden: Quit Tracker**

### 1.2 产品定位

Sober Garden 是一款帮助用户戒掉不想要的习惯、抵抗冲动、记录成长进度的恢复陪伴 App。

它不是单纯的 sober counter，也不是普通 habit tracker，而是围绕「冲动急救 + 温和鼓励 + 可视化成长」设计的 recovery companion。

### 1.3 一句话描述

Quit unwanted habits, survive urges, track your progress, and grow a peaceful garden with every clean day.

### 1.4 第一版核心目标

第一版不追求商业化，目标是：

1. 保证 App Store 上线。
2. 避免被认为是重复模板类 App，降低 4.3 风险。
3. 验证用户是否会持续打开 App。
4. 验证用户是否会在冲动时使用 Rescue 功能。
5. 为后续订阅、AI、云同步、多 habit 打基础。

---

## 2. 审核策略与 4.3 风险规避

### 2.1 4.3 风险来源

戒断、打卡、习惯追踪类 App 已经非常多，如果第一版只提供以下功能，容易被认为缺乏独特性：

- 戒断天数计时
- 简单打卡
- 省钱统计
- 普通 milestone
- 简单日记

### 2.2 第一版差异化点

第一版必须突出以下差异化体验：

1. **Urge Rescue 急救流程**
   - 用户冲动时可以立即进入 3 分钟左右的引导流程。
   - 包含状态选择、本地 Calm Coach 安慰、呼吸练习、戒断理由回看、10 分钟延迟承诺。

2. **Calm Coach 本地陪伴系统**
   - 不接 AI API。
   - 使用本地文案库，根据时间、streak、情绪、行为状态展示不同鼓励。
   - 不宣传 AI-powered，避免虚假 AI 和审核风险。

3. **Garden Growth 成长花园**
   - 用花园成长承载用户坚持进度。
   - relapse 后花园不死亡，保留历史努力，当前 streak 重新种下新种子。

4. **Home Screen Widgets**
   - Streak Widget
   - Garden Widget
   - Rescue Widget 深链入口

5. **Apple Watch Lite**
   - 查看 streak。
   - 快速进入 rescue breathing。
   - watch 端不做复杂功能，只做差异化与触达。

6. **Privacy-first 本地存储**
   - 不登录。
   - 不上传。
   - 所有数据保存在用户设备上。

### 2.3 App Review Notes 建议

提交审核时，在 App Review Notes 中写：

```text
This app is not a simple habit counter. It provides a recovery companion experience with:
1. A guided Urge Rescue flow for moments of temptation
2. A local Calm Coach prompt system for contextual encouragement
3. A visual recovery garden that grows with clean days
4. Home Screen widgets for streak, garden, and rescue access
5. Apple Watch support for quick streak view and breathing-based rescue

All user data is stored locally on device. The app does not provide medical diagnosis or treatment.
```

### 2.4 禁止使用的表述

App 内、App Store 元数据、截图、提示文案中避免使用：

- cure addiction
- treat addiction
- medical treatment
- therapy
- diagnosis
- clinical recovery
- scientifically proven to cure
- quit forever
- stop relapse permanently
- AI therapist
- AI doctor
- powered by AI

### 2.5 推荐使用的表述

可以使用：

- recovery companion
- urge support
- calming exercise
- self-reflection
- gentle reminders
- progress tracking
- habit recovery
- unwanted habits
- impulse support
- Calm Coach
- contextual encouragement

---

## 3. 第一版范围

### 3.1 必须做 P0

- Onboarding
- Home 首页
- Rescue 急救流程
- Garden 成长花园
- Journal 每日记录
- Settings 设置
- 本地数据存储
- 本地通知
- Widget
- App Store 隐私政策 / Terms 页面入口
- 非医疗免责声明

### 3.2 强烈建议 P0+

- Apple Watch Lite
- Share Progress Card
- Face ID / App Lock

### 3.3 第一版不做

- 订阅
- 真 AI API
- 社区
- 用户账号
- 云同步
- 多 habit 同时追踪
- 复杂统计图表
- 课程内容
- 真人 partner / sponsor
- UGC
- 内容举报 / 屏蔽机制
- 医疗建议
- 诊断问卷

---

## 4. 信息架构

第一版建议使用 4 个 Tab：

```text
Home
Rescue
Garden
Journal
```

Settings 放在 Home 右上角，不作为底部 Tab。

---

## 5. Onboarding 需求

### 5.1 Onboarding 总体目标

Onboarding 不只是设置数据，还要让用户理解本产品不是普通计时器，而是一个温和的 recovery companion。

### 5.2 Step 1 欢迎页

标题：

```text
Break the habit. Grow a calmer life.
```

副标题：

```text
Track clean days, survive urges, and grow your recovery garden.
```

主按钮：

```text
Get Started
```

### 5.3 Step 2 选择习惯

标题：

```text
What do you want to quit?
```

选项：

- Smoking
- Vaping
- Alcohol
- Porn
- Gambling
- Sugar
- Social Media
- Weed
- Custom

实现要求：

- 第一版只支持单个 habit。
- 用户选择 Custom 时，允许输入自定义名称。
- 不针对不同 habit 做复杂专业模型。
- 只做轻度文案与 icon 个性化。

### 5.4 Step 3 设置开始日期

标题：

```text
When did your clean streak begin?
```

选项：

- Today
- Yesterday
- Pick a date

实现要求：

- 选择日期不能晚于今天。
- 存储为 startDate。

### 5.5 Step 4 设置消耗金额

标题：

```text
How much did this habit cost you?
```

输入模式：

- Cost per day
- Cost per week
- Cost per month
- Skip

实现要求：

- 最终统一换算为 dailyCost。
- 用户可跳过。
- 金额单位使用系统 locale currency，第一版可默认 USD，后续再完善多币种。

### 5.6 Step 5 设置时间消耗

标题：

```text
How much time did this habit take?
```

输入模式：

- Minutes per day
- Hours per week
- Skip

实现要求：

- 最终统一换算为 dailyMinutes。
- 用户可跳过。

### 5.7 Step 6 写下戒断理由

标题：

```text
Why do you want to quit?
```

模板选项：

- I want to feel in control again.
- I want to protect my health.
- I want to stop feeling regret.
- I want to become someone I respect.
- I want more time and energy.
- I want to build a better future.

实现要求：

- 用户可以选择多个模板。
- 用户可以输入自定义理由。
- 至少允许跳过。
- 如果跳过，Rescue 流程中使用默认理由文案。

### 5.8 Step 7 通知权限解释页

标题：

```text
Let us support you at the right moments.
```

说明：

```text
We’ll send gentle reminders, milestone celebrations, and urge support prompts.
```

按钮：

- Enable Notifications
- Maybe Later

实现要求：

- 不要进入 onboarding 就直接弹系统权限。
- 先展示自定义解释页，用户点击 Enable 后再请求系统通知权限。

### 5.9 Step 8 完成页

标题：

```text
Your recovery garden is ready.
```

按钮：

```text
Start Growing
```

完成后进入 Home。

---

## 6. Home 首页需求

### 6.1 页面目标

用户打开 App 后，必须立刻获得：

- 成就感
- 被鼓励的感觉
- 明确知道自己坚持了多久
- 看到花园成长
- 在撑不住时有明显入口

### 6.2 页面模块顺序

从上到下：

1. 顶部 Habit 状态
2. Calm Coach 卡片
3. Streak 主卡片
4. Money / Time Saved 卡片
5. Next Milestone 卡片
6. Garden Preview
7. I’m Struggling 主按钮
8. Share Progress 入口

### 6.3 顶部 Habit 状态

展示：

```text
Day 7
Clean from Smoking
```

右上角：

- Settings icon
- Edit Habit 可放入 Settings

### 6.4 Calm Coach 卡片

卡片标题：

```text
Calm Coach
```

内容来自本地文案库。

示例：

```text
Small choices become a stronger identity.
Protect today.
```

实现要求：

- 根据时间、streak、今日是否首次打开、是否刚完成 milestone 选择文案。
- 不要显示 “AI says”。
- 不要显示 “Powered by AI”。

### 6.5 Streak 主卡片

核心展示：

```text
7 days clean
```

辅助展示：

- 168 hours
- Longest streak: 7 days
- Started: May 19

计算逻辑：

- currentStreakDays = floor((now - startDate) / 86400)
- 如果 startDate 是今天，显示 Day 0 或 Day 1 需要产品统一。
- 建议使用 “Day 1” 表达更积极，但内部计算可以是 elapsedDays。
- 展示 clean days 时，若不足 24 小时可显示 “Today is Day 1”。

### 6.6 Saved 卡片

两个并列卡片：

```text
$42 Saved
12h Saved
```

计算逻辑：

- moneySaved = dailyCost * cleanDays
- timeSavedMinutes = dailyMinutes * cleanDays

空状态：

```text
Add cost to see your savings.
```

```text
Add time to see your time saved.
```

### 6.7 Next Milestone

展示：

```text
Next milestone: 14 days
7 days to go
```

使用进度条。

默认 milestones：

- 1
- 3
- 7
- 14
- 30
- 60
- 90
- 180
- 365

### 6.8 Garden Preview

展示：

- 当前 garden 插画 / 状态
- 当前阶段名
- 下一个阶段

示例：

```text
Young Plant
Next bloom in 7 days
```

点击进入 Garden Tab。

### 6.9 I’m Struggling 按钮

文案：

```text
I’m Struggling
```

副文案：

```text
Get through the next few minutes.
```

实现要求：

- 首页底部必须强可见。
- 点击进入 Rescue 流程第一步。
- 这是第一版核心差异化，不能弱化。

### 6.10 Share Progress

第一版可做简单分享卡：

包含：

- clean days
- saved money
- garden stage
- app name

分享文案：

```text
I’m growing one clean day at a time.
```

---

## 7. Rescue 急救流程需求

### 7.1 页面目标

帮助用户在冲动来临时撑过关键几分钟。

目标不是治疗，也不是医疗建议，而是：

- 降低冲动强度
- 让用户延迟行为
- 让用户回想戒断理由
- 让用户感到被陪伴

### 7.2 Rescue 入口

入口包括：

- Home 的 I’m Struggling 按钮
- Rescue Tab
- Widget 深链
- Watch 端按钮
- 通知点击

### 7.3 Step 1 选择状态

标题：

```text
What are you feeling right now?
```

选项：

- Urge
- Stress
- Lonely
- Bored
- Angry
- Tired
- Anxious
- Triggered

实现要求：

- 选择后进入 Step 2。
- 记录 emotionType。
- 可以有 Skip。

### 7.4 Step 2 Calm Coach 回应

先展示短暂 loading：

```text
Calm Coach is here...
```

延迟：

- 0.8 到 1.2 秒

然后展示本地文案。

示例：

```text
This urge is uncomfortable, but it is not permanent.
Stay with it for one minute.
```

实现要求：

- 文案根据 emotionType、当前时间、streak 阶段选择。
- 同一用户短时间内不要频繁重复同一句。
- 可记录 lastShownPromptIDs。

按钮：

```text
Start Breathing
```

### 7.5 Step 3 呼吸练习

标题：

```text
Breathe with me
```

呼吸节奏：

- Inhale 4 秒
- Hold 2 秒
- Exhale 6 秒
- 总时长默认 90 秒

UI：

- 圆形缩放动画
- 中间显示 Inhale / Hold / Exhale
- 底部显示剩余时间

按钮：

- Finish Early
- Keep Going

实现要求：

- 完成后记录 completedBreathing = true。
- 提前结束也允许继续下一步，但 completedBreathing = false。
- 不要阻塞用户。

### 7.6 Step 4 展示戒断理由

标题：

```text
Remember why you started
```

内容：

- 优先显示用户 onboarding 写下的 reasons。
- 如果为空，显示默认文案：

```text
You chose this because your future matters more than this urge.
```

按钮：

```text
I remember
```

### 7.7 Step 5 10 分钟延迟承诺

标题：

```text
Can you wait 10 minutes?
```

说明：

```text
You don’t have to decide forever.
Just wait 10 minutes.
```

按钮：

- I’ll wait 10 minutes
- I’m still struggling

点击 I’ll wait 10 minutes：

- 设置一个 10 分钟后的本地通知。
- 记录 completedDelay = true。
- 进入结束反馈。

通知文案：

```text
You made it 10 minutes. How do you feel now?
```

点击 I’m still struggling：

- 允许重新开始 breathing。
- 或展示另一个 Calm Coach 文案。

### 7.8 Step 6 结束反馈

标题：

```text
How strong is the urge now?
```

控件：

- 0 到 10 slider
- 0 = Calm
- 10 = Very strong

按钮：

- I’m okay now
- Start another rescue

实现要求：

- 保存 RescueSession。
- 如果再次开始 rescue，不清除前一次记录。
- 如果用户没有输入 urgeBefore，至少保存 urgeAfter。

### 7.9 Rescue 数据记录

每次 rescue 至少记录：

- id
- date
- emotion
- urgeBefore 可选
- urgeAfter 可选
- completedBreathing
- completedDelay

---

## 8. Garden 成长花园需求

### 8.1 页面目标

把抽象的坚持天数可视化为花园成长，提升情绪价值与留存。

### 8.2 成长阶段

| Clean Days | Garden 状态 | Badge |
|---:|---|---|
| 1 | Seed | First Seed |
| 3 | Sprout | Tiny Leaf |
| 7 | Young Plant | First Week |
| 14 | Flower | Steady Bloom |
| 30 | Garden Bed | 30-Day Bloom |
| 60 | Blooming Garden | Deep Roots |
| 90 | Peaceful Garden | 90-Day Sanctuary |
| 180 | Small Forest | Strong Roots |
| 365 | Sanctuary | One Year Clean |

### 8.3 Garden 页面结构

从上到下：

1. 当前 Garden 插画
2. 当前阶段名称
3. 当前 clean days
4. 下一个阶段进度
5. 已解锁 badges
6. 成长说明文案

### 8.4 Relapse 后 Garden 处理

原则：

- 不羞辱用户。
- 不让花园死亡。
- 保留历史努力。
- 当前 streak 重新开始。

文案：

```text
Your garden remembers your effort.
A new seed has been planted.
```

实现建议：

- 保存 lifetimeCleanDays 或 historicalBest。
- currentStreak 用于当前阶段。
- longestStreak 用于成就感。
- relapse 后 startDate 重置，但 badges 可以按产品策略选择是否保留。

第一版建议：

- milestones badges 已经解锁后保留。
- 当前 Garden Preview 根据 currentStreak 显示。
- Garden History 可暂不做。

---

## 9. Journal 每日记录需求

### 9.1 页面目标

让用户轻量记录状态，帮助后续分析触发原因。

### 9.2 今日 Check-in

标题：

```text
How are you today?
```

问题 1：心情

选项：

- Great
- Calm
- Okay
- Low
- Stressed

问题 2：今天有没有冲动？

选项：

- No urge
- Mild urge
- Strong urge

问题 3：触发原因

多选：

- Stress
- Boredom
- Loneliness
- Social media
- Late night
- Conflict
- Tiredness
- Custom

问题 4：一句反思

占位：

```text
What helped you today?
```

### 9.3 历史记录

展示最近 journal entries：

- 日期
- mood
- urge level
- triggers
- note

第一版可用简单列表。

### 9.4 轻统计

可显示：

- This week check-ins
- Most common trigger
- Rescue sessions completed

不要做复杂图表，避免开发过重。

---

## 10. Calm Coach 本地文案系统

### 10.1 定位

Calm Coach 是本地文案陪伴系统，不是真 AI，不接 API。

目标：

- 制造陪伴感
- 降低用户压力
- 在合适场景给短句支持

### 10.2 命名

使用：

```text
Calm Coach
```

避免：

- AI Coach
- AI Therapist
- AI Doctor
- Powered by AI

### 10.3 触发维度

文案选择可根据以下条件：

1. 时间段
   - morning
   - afternoon
   - evening
   - lateNight

2. streak 阶段
   - day0
   - day1
   - day3
   - day7
   - day14
   - day30
   - milestone
   - relapse

3. 情绪状态
   - urge
   - stressed
   - lonely
   - bored
   - anxious
   - tired
   - angry
   - triggered

4. 行为状态
   - firstOpenToday
   - multipleOpensToday
   - afterRescue
   - missedCheckin
   - beforeBed

### 10.4 文案长度

每条文案建议：

- 1 到 2 句
- 不超过 120 字符为佳
- 温和、稳定、不说教

### 10.5 本地 JSON 示例

```json
{
  "urge": [
    {
      "id": "urge_001",
      "text": "This urge will rise, peak, and pass. You only need to wait it out.",
      "weight": 10
    },
    {
      "id": "urge_002",
      "text": "You do not need to obey this feeling. Breathe first.",
      "weight": 8
    }
  ],
  "lateNight": [
    {
      "id": "night_001",
      "text": "Late nights can make old habits louder. Choose rest over regret.",
      "weight": 10
    }
  ],
  "relapse": [
    {
      "id": "relapse_001",
      "text": "A setback is not the end of your recovery. Begin again without shame.",
      "weight": 10
    }
  ],
  "milestone7": [
    {
      "id": "m7_001",
      "text": "A full week clean. You are proving that change is possible.",
      "weight": 10
    }
  ]
}
```

### 10.6 不重复策略

实现要求：

- 记录最近展示的 prompt id。
- 最近 24 小时内尽量不重复。
- 如果候选不足，可以允许重复。
- 每个 category 内使用权重随机。

---

## 11. Widget 需求

### 11.1 Widget 总体目标

提升触达，并让产品区别于普通 tracker。

### 11.2 Widget 类型

第一版建议做 3 个 Widget：

1. Streak Widget
2. Garden Widget
3. Rescue Widget

### 11.3 Streak Widget

尺寸：

- Small
- Medium

展示：

```text
7 Days Clean
Next: 14 Days
```

可点击深链：

- 打开 Home

### 11.4 Garden Widget

尺寸：

- Small
- Medium

展示：

```text
Your garden is growing.
Day 7
```

展示当前 Garden 阶段图形。

可点击深链：

- 打开 Garden Tab

### 11.5 Rescue Widget

尺寸：

- Small
- Medium

展示：

```text
Struggling?
Open Rescue
```

可点击深链：

- 打开 Rescue 流程

注意：

- iOS Widget 不能直接完成复杂交互，点击后进入 App。
- Rescue Widget 是关键差异化点，建议必须做。

---

## 12. Apple Watch Lite 需求

### 12.1 Watch 目标

Watch 端用于形成差异化和快速触达，不做完整 App。

### 12.2 Watch 功能

#### 12.2.1 Streak Glance

展示：

```text
7 days clean
```

辅助：

```text
Next: 14 days
```

#### 12.2.2 Rescue Button

按钮：

```text
I’m Struggling
```

点击后进入 Watch breathing 页面。

#### 12.2.3 Breathing

- 60 秒或 90 秒
- 圆形动画
- 可选 haptic feedback
- 文案：

```text
Stay with this breath.
The urge will pass.
```

### 12.3 Watch 不做

- 不做 journal
- 不做设置
- 不做复杂 Garden
- 不做账号
- 不做聊天
- 不做输入复杂文本

---

## 13. 通知需求

### 13.1 通知类型

#### 每日提醒

```text
Protect today. Your garden is still growing.
```

#### Milestone 通知

```text
You reached 7 clean days. A new bloom is waiting.
```

#### Rescue 延迟通知

```text
You made it 10 minutes. How do you feel now?
```

#### 夜间保护提醒

```text
Late night reminder: choose rest over regret.
```

### 13.2 通知设置

用户可以设置：

- Daily reminder on/off
- Reminder time
- Milestone notification on/off
- Night reminder on/off
- Night reminder time

### 13.3 权限策略

- Onboarding 先解释，再请求权限。
- 用户拒绝后，在 Settings 中提供重新开启提示。

---

## 14. Settings 需求

Settings 页面包含：

### 14.1 Habit 设置

- Edit habit type
- Edit custom habit name
- Edit start date
- Edit cost
- Edit time cost
- Edit reasons to quit

### 14.2 通知设置

- Daily reminder
- Milestone notifications
- Night reminder
- Rescue delay reminder

### 14.3 隐私与安全

- Face ID / App Lock（P0+）
- Privacy Policy
- Terms of Use
- Non-medical disclaimer

### 14.4 数据管理

- Export data
- Reset current streak
- Delete all data

### 14.5 关于

- App version
- Contact support
- Rate App

---

## 15. Relapse / Reset 需求

### 15.1 入口

Settings 或 Home 中提供：

```text
Reset Streak
```

不要放得过于显眼，避免误触。

### 15.2 Reset 流程

点击后弹窗确认：

标题：

```text
Start again?
```

说明：

```text
Your progress is not erased. Your garden remembers your effort, and a new seed will be planted.
```

按钮：

- Cancel
- Start Again

### 15.3 Reset 后逻辑

- 保存一条 RelapseRecord。
- 更新 longestStreak。
- startDate 重置为当前时间或用户选择时间。
- 当前 garden 根据新 streak 重新显示。
- 已解锁 badges 保留。
- 展示温和文案：

```text
A new seed has been planted. Begin again without shame.
```

---

## 16. 数据模型建议

以下为 Swift 结构建议，可根据实际存储方案调整。

### 16.1 Habit

```swift
struct Habit: Codable, Identifiable {
    let id: UUID
    var type: HabitType
    var customName: String?
    var startDate: Date
    var dailyCost: Double?
    var dailyMinutes: Int?
    var reasons: [String]
    var createdAt: Date
    var updatedAt: Date
}
```

### 16.2 HabitType

```swift
enum HabitType: String, Codable, CaseIterable {
    case smoking
    case vaping
    case alcohol
    case porn
    case gambling
    case sugar
    case socialMedia
    case weed
    case custom
}
```

### 16.3 RescueSession

```swift
struct RescueSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    var emotion: EmotionType
    var urgeBefore: Int?
    var urgeAfter: Int?
    var completedBreathing: Bool
    var completedDelay: Bool
}
```

### 16.4 EmotionType

```swift
enum EmotionType: String, Codable, CaseIterable {
    case urge
    case stress
    case lonely
    case bored
    case angry
    case tired
    case anxious
    case triggered
}
```

### 16.5 JournalEntry

```swift
struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    var mood: MoodType
    var urgeLevel: UrgeLevel
    var triggers: [TriggerType]
    var note: String?
}
```

### 16.6 MoodType

```swift
enum MoodType: String, Codable, CaseIterable {
    case great
    case calm
    case okay
    case low
    case stressed
}
```

### 16.7 UrgeLevel

```swift
enum UrgeLevel: String, Codable, CaseIterable {
    case none
    case mild
    case strong
}
```

### 16.8 TriggerType

```swift
enum TriggerType: String, Codable, CaseIterable {
    case stress
    case boredom
    case loneliness
    case socialMedia
    case lateNight
    case conflict
    case tiredness
    case custom
}
```

### 16.9 RelapseRecord

```swift
struct RelapseRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let previousStartDate: Date
    let previousStreakDays: Int
    var note: String?
}
```

### 16.10 Milestone

```swift
struct Milestone: Codable, Identifiable {
    let id: UUID
    let day: Int
    let title: String
    let gardenStage: GardenStage
    let badgeName: String
}
```

### 16.11 GardenStage

```swift
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
}
```

---

## 17. 本地存储建议

### 17.1 第一版存储方案

建议使用：

- SwiftData 或 CoreData
- 小型配置可用 UserDefaults / AppStorage
- Widget 共享数据使用 App Group UserDefaults

### 17.2 数据本地化原则

- 不做账号。
- 不上传数据。
- 不接后端。
- 不使用云同步。
- 隐私政策中明确说明数据保存在设备上。

### 17.3 Widget 数据共享

需要通过 App Group 保存 Widget 所需摘要数据：

```swift
struct WidgetSnapshot: Codable {
    var cleanDays: Int
    var nextMilestone: Int?
    var gardenStage: GardenStage
    var habitDisplayName: String
    var updatedAt: Date
}
```

每次以下行为后更新 WidgetSnapshot：

- onboarding 完成
- app 打开
- startDate 修改
- reset streak
- milestone 达成
- daily timeline 刷新

---

## 18. 深链需求

用于 Widget / Watch / Notification 跳转。

建议定义 URL Scheme：

```text
sobergarden://home
sobergarden://rescue
sobergarden://garden
sobergarden://journal
sobergarden://settings
```

### 18.1 跳转行为

- `sobergarden://home` 打开 Home Tab
- `sobergarden://rescue` 打开 Rescue Step 1
- `sobergarden://garden` 打开 Garden Tab
- `sobergarden://journal` 打开 Journal Tab
- `sobergarden://settings` 打开 Settings

---

## 19. 视觉与 UI 风格

### 19.1 关键词

- calm
- healing
- warm
- soft
- hopeful
- non-judgmental
- premium but simple

### 19.2 避免风格

- 医疗化
- 冷冰冰工具感
- 红色警告过多
- 羞辱用户
- 过度游戏化
- 成人化
- 低质量模板 UI

### 19.3 色彩建议

可选方向：

- 主色：柔和绿色 / 青绿色
- 背景：暖白 / 浅米色
- 强调：柔和黄 / 花朵色
- 危机按钮可用温暖橙色，但不要过度警告红

### 19.4 组件风格

- 大圆角卡片
- 柔和阴影
- 大数字展示
- 轻量插画
- 呼吸动画
- Tab 简洁
- 字体层级清晰

---

## 20. App Store 元数据建议

### 20.1 App Name

```text
Sober Garden: Quit Tracker
```

### 20.2 Subtitle

```text
Break habits, grow progress
```

### 20.3 Keywords

```text
sober,quit,tracker,habit,streak,recovery,nofap,smoking,vaping,alcohol,urge,self control,discipline
```

### 20.4 Description 开头

```text
Sober Garden helps you break unwanted habits, survive urges, and grow a peaceful recovery garden with every clean day.

Track your streak, see your money and time saved, use guided urge rescue when temptation hits, and stay connected to your progress through widgets and Apple Watch.
```

### 20.5 功能点

- Track clean days and longest streak
- See money and time saved
- Grow a visual recovery garden
- Use Urge Rescue when cravings hit
- Receive gentle Calm Coach encouragement
- Reflect with simple daily check-ins
- View progress from Home Screen widgets
- Use Apple Watch for quick rescue breathing
- Keep your data private on your device

### 20.6 截图规划

#### Screenshot 1：首页

标题：

```text
Track every clean day
```

展示：

- streak
- saved money
- garden preview

#### Screenshot 2：Rescue

标题：

```text
Get through urges
```

展示：

- I’m Struggling
- breathing
- Calm Coach

#### Screenshot 3：Garden

标题：

```text
Grow your recovery garden
```

展示：

- 花园成长阶段

#### Screenshot 4：Journal

标题：

```text
Understand your triggers
```

展示：

- mood
- urge
- trigger check-in

#### Screenshot 5：Widget / Watch

标题：

```text
Support when you need it
```

展示：

- widget
- watch breathing

---

## 21. 隐私政策要点

隐私政策需要说明：

- 不需要账号。
- 用户数据保存在设备本地。
- 不上传 habit、journal、rescue 数据。
- 如果使用 Apple 通知权限，仅用于提醒。
- 如果使用 Face ID，仅用于本地解锁。
- 如果未来引入云同步或 AI，会更新隐私政策。

---

## 22. 非医疗免责声明

App 内设置页和首次 onboarding 可放简短说明：

```text
Sober Garden is a self-support and habit tracking tool. It does not provide medical advice, diagnosis, or treatment. If you are dealing with a serious addiction, withdrawal symptoms, or mental health crisis, please seek help from a qualified professional or local emergency services.
```

注意：

- 不要吓人。
- 不要过度医疗化。
- 但需要清晰声明非医疗用途。

---

## 23. 开发阶段建议

### Phase 1：核心 App

完成：

1. Onboarding
2. Home
3. Habit 数据模型
4. Streak 计算
5. Money saved
6. Time saved
7. Milestone
8. Garden
9. Rescue
10. Journal
11. Settings

### Phase 2：触达

完成：

1. Local notifications
2. Widget
3. Deep links
4. Share progress card

### Phase 3：差异化增强

完成：

1. Apple Watch Lite
2. Face ID / App Lock
3. 更丰富 Calm Coach 文案
4. 更精致 Garden 动画

---

## 24. MVP 验收标准

### 24.1 功能验收

- 用户可以完成 onboarding。
- 用户可以创建一个 habit。
- Home 正确显示 clean days。
- Home 正确显示 money saved 和 time saved。
- Milestone 正确计算下一个目标。
- Garden 根据 clean days 显示正确阶段。
- Rescue 流程可以完整走通。
- RescueSession 可以保存。
- JournalEntry 可以保存。
- 用户可以 reset streak。
- reset 后不删除历史记录。
- Widget 可以显示 streak。
- Widget 点击可以进入对应页面。
- 通知权限流程正常。
- 本地通知正常触发。

### 24.2 审核验收

- App 首次打开不是空白模板。
- 首页能看到 Garden、Calm Coach、I’m Struggling。
- Rescue 不是简单倒计时，而是完整引导流程。
- App 内没有医疗承诺。
- App 内没有虚假 AI 宣传。
- App 内没有订阅入口。
- App 内没有成人化营销。
- Privacy Policy 和 Terms 可访问。
- Review Notes 清晰解释差异化。

---

## 25. 后续版本方向

### v1.1

- 更丰富 Garden 插画
- 更多 Calm Coach 文案
- 更详细 trigger insights
- 更多 widgets
- Watch complication

### v1.2

- 多 habit 支持
- 数据导出优化
- iCloud 同步可选
- 自定义主题

### v2.0

- 订阅
- 真 AI Recovery Coach
- AI Weekly Reflection
- AI Trigger Analysis
- 高级 Garden 主题
- 更完整 Watch 体验

---

## 26. 最终产品原则

第一版不要做成：

```text
又一个戒断计时器
```

而要做成：

```text
用户想 relapse 前会打开的 Recovery Companion
```

第一版的核心体验优先级：

1. Urge Rescue
2. Calm Coach
3. Garden Growth
4. Streak / Milestone
5. Widget
6. Journal
7. Watch Lite

只要审核员和用户第一眼能看到：

```text
这是一个有急救流程、有成长花园、有桌面触达、有 Watch 呼吸支持的恢复陪伴 App
```

就能明显降低 4.3 风险，并为后续商业化打下基础。
