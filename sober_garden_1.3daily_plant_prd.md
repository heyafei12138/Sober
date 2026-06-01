# Sober Garden 每日坚持反馈系统需求文档

## 1. 背景与问题

当前 Sober Garden 的核心逻辑偏向“戒断计时器”：用户设置一个开始时间后，App 默认认为用户一直在坚持，并持续展示已坚持的天数。

这种设计足够轻量，但存在一个明显问题：用户每天的坚持没有被及时确认，也缺少阶段性回顾时的满足感。

对于戒坏习惯、恢复、自我控制类 App 来说，用户需要的不只是看到“已经过去了多少天”，还需要看到“我今天又完成了一次小胜利”。

因此，本次需求目标是将 Sober Garden 从单纯的“时间累计”升级为更有情绪反馈的“每日种植”机制。

核心体验应类似 Habit Pixel 的可视化反馈，但使用 Sober Garden 自己的表达方式：

> 用户每天回来确认一次，把当天种进自己的恢复花园里。

---

## 2. 需求目标

### 2.1 产品目标

1. 增加用户每日回访动机。
2. 让用户每天的坚持被及时记录和反馈。
3. 让用户在 7 天、30 天等阶段回看时有明显的成就感。
4. 避免传统打卡带来的压力和失败羞耻感。
5. 强化 Sober Garden 的“恢复花园”品牌概念。

### 2.2 用户目标

用户打开 App 后，可以清晰感受到：

- 今天是否已经坚持。
- 最近一段时间自己坚持了多少天。
- 自己的恢复过程正在被一点点“种出来”。
- 即使某天失败，也不会觉得之前的努力全部清零。

---

## 3. 核心设计原则

### 3.1 低压力

不要把它设计成严肃的任务打卡系统。用户不是来完成 KPI 的，而是来获得陪伴和鼓励的。

避免使用过于强硬的文案，例如：

- Check in now
- Complete today
- Failed
- Streak broken

推荐使用更温和、更符合花园概念的文案：

- Plant Today
- Today has been planted
- Rainy Day
- Your garden can still grow

### 3.2 正向反馈优先

每一次用户确认今日坚持，都应该得到即时反馈。

反馈可以包括：

- 今日卡片状态变化
- 小叶子/小花被点亮
- 柔和动效
- 鼓励文案
- 成长格子更新

### 3.3 不惩罚失败

用户如果出现 setback，不应被强烈惩罚。不要使用红叉、失败、归零等视觉和文案。

推荐将 setback 表达为：

> Rainy Day

雨天不是失败，而是恢复过程的一部分。

### 3.4 累计价值不清零

即使用户某一天没有坚持，也不应该让用户感觉此前全部努力归零。

因此数据展示上要区分：

- Current Streak：当前连续坚持天数
- Total Planted Days：累计种植天数
- Rainy Days：低调展示，不突出惩罚

---

## 4. 功能范围

本需求属于 Sober Garden v1.3 可上线范围内的增强功能。

### 4.1 本期包含

1. 首页今日确认卡片
2. Plant Today 每日种植按钮
3. 今日状态记录
4. 最近 30 天成长格子
5. Current Streak / Total Planted Days 统计
6. Setback / Rainy Day 记录
7. 7 天 / 30 天阶段回顾提示
8. 本地存储

### 4.2 本期不包含

1. 云同步
2. 账号系统
3. 社区功能
4. 复杂成就系统
5. 排行榜
6. AI API 接入
7. 订阅功能
8. 多设备同步
9. 复杂数据分析报表

---

## 5. 核心概念定义

### 5.1 Plant Today

用户当天坚持住后，点击首页按钮，将当天记录为已种植。

含义：

> 我今天完成了一次恢复过程中的小胜利。

### 5.2 Planted Day

当天被用户主动确认为坚持成功。

视觉表现：绿色小叶子、小花、发光小格子等。

### 5.3 Rainy Day

用户当天出现 setback，或者用户主动记录“今天没有做到”。

注意：Rainy Day 不等于失败日，而是恢复过程中的低落日。

推荐文案：

> Some days are rainy. Your garden can still grow.

### 5.4 Empty Day

当天没有任何记录。

可能原因：

- 用户忘记打开 App
- 用户没有确认
- 用户不想记录

Empty Day 不主动提示为失败。

### 5.5 Future Day

未来日期，不可操作，仅作为占位显示。

---

## 6. 首页需求

首页需要从原来的“时间展示为主”调整为“时间展示 + 今日互动 + 成长反馈”。

推荐结构如下：

1. 顶部坚持状态区
2. 今日确认卡片
3. 最近 30 天成长格子
4. 统计摘要
5. 鼓励文案 / 本地 AI 提示

---

## 7. 顶部坚持状态区

### 7.1 展示内容

顶部保留用户当前坚持状态，例如：

```text
Day 18
Your garden is growing quietly.
```

或：

```text
18 Days
One more quiet victory.
```

### 7.2 数据逻辑

Day 数可以继续基于用户创建 habit / recovery journey 的开始日期计算。

但需要注意：这个数字表示“恢复旅程开始后的第几天”，不是严格意义上的连续成功天数。

为了避免误导，可以在 UI 中使用：

- Journey Day
- Day 18
- Since you started

不建议直接把它等同于 streak。

---

## 8. 今日确认卡片

### 8.1 未确认状态

当用户当天还没有记录时，首页展示今日确认卡片。

推荐文案：

```text
How did today go?
Every small choice helps your garden grow.
```

主按钮：

```text
Plant Today
```

次按钮：

```text
I had a setback
```

### 8.2 已种植状态

用户点击 Plant Today 后，卡片变为已完成状态。

推荐文案：

```text
Today has been planted.
Come back tomorrow and keep growing.
```

按钮状态：

- 主按钮变为 disabled
- 文案显示：Planted
- 可展示一个小叶子、小花或发光效果

### 8.3 Rainy Day 状态

用户点击 I had a setback 后，卡片进入 Rainy Day 状态。

推荐文案：

```text
Today is a rainy day.
A setback is not the end. Your garden can still grow.
```

按钮：

```text
Restart gently tomorrow
```

按钮可以不执行复杂逻辑，仅作为情绪安抚文案展示。

### 8.4 当天状态修改

v1 建议允许当天修改一次状态，避免误点。

例如用户点击 Plant Today 后，可以在当天再次点击小的编辑入口：

```text
Edit today
```

可选择：

- Planted
- Rainy Day
- Clear Record

如果不想增加复杂度，v1 也可以不做编辑入口，只在本地调试或后续版本加入。

推荐 v1 做简单编辑，因为误点在打卡类产品中比较常见。

---

## 9. 最近 30 天成长格子

### 9.1 模块名称

推荐标题：

```text
Last 30 Days
```

副标题可选：

```text
A quiet record of your progress.
```

### 9.2 展示形式

展示最近 30 天，每一天对应一个小格子。

可以使用：

- 小方块
- 圆角小格子
- 小叶子
- 小土地块
- 小花朵

建议 v1 使用圆角小方块，开发成本低，后续可升级为更具花园感的图形。

### 9.3 日期排列

推荐 5 行 × 6 列，展示最近 30 天。

也可以横向滚动，但 v1 不建议增加横向滚动复杂度。

### 9.4 状态颜色

建议状态：

| 状态 | 视觉表现 |
|---|---|
| Planted Day | 绿色 / 小叶子 |
| Rainy Day | 蓝灰色 / 雨滴感 |
| Empty Day | 浅土色 / 浅灰 |
| Future Day | 更淡的灰色，不可点击 |
| Today | 外圈描边或轻微高亮 |

### 9.5 点击格子

v1 可以支持点击某一天查看简单状态。

点击后弹出轻量 sheet：

```text
May 31
Planted Day
You showed up for yourself.
```

Rainy Day 文案：

```text
May 31
Rainy Day
A difficult day does not erase your progress.
```

Empty Day 文案：

```text
May 31
No record
You can keep going from today.
```

如果开发时间有限，v1 可以不支持点击，只展示状态。

---

## 10. 统计摘要

在成长格子下方展示轻量统计。

### 10.1 推荐指标

```text
Current Streak: 7 days
Total Planted Days: 21 days
```

可选：

```text
Rainy Days: 2
```

但 Rainy Days 不建议在首页突出展示，可以放到详情页或月度回顾中。

### 10.2 Current Streak 计算

Current Streak 表示从今天或最近一个 Planted Day 往前连续 Planted Day 的数量。

规则建议：

- 如果今天已 Planted，则从今天开始往前计算连续 Planted Day。
- 如果今天未记录，但昨天 Planted，则仍显示昨天之前的连续天数，不立即归零。
- 如果连续中断超过 1 天，则 streak 归零或从最近 Planted Day 重新计算。

为了降低压力，建议文案不要过度强调断签。

### 10.3 Total Planted Days 计算

Total Planted Days 表示用户全部历史记录中的 Planted Day 数量。

这个指标永远不会因为 setback 或 empty day 清零。

这是保护用户积极性的关键指标。

---

## 11. 阶段回顾机制

### 11.1 触发时机

v1 建议支持以下节点：

- 连续种植 7 天
- 累计种植 7 天
- 累计种植 30 天
- 每个月最后一天或用户进入新月份后的第一次打开 App

### 11.2 7 天回顾

触发条件：用户累计 Planted Day 达到 7 天。

文案：

```text
You planted 7 days.
Small steps are becoming real progress.
```

按钮：

```text
Keep Growing
```

### 11.3 30 天回顾

触发条件：用户累计 Planted Day 达到 30 天。

文案：

```text
You planted 30 days.
Your garden is becoming stronger.
```

按钮：

```text
View My Garden
```

### 11.4 月度回顾

每月展示一次简短总结。

示例：

```text
This month, you planted 20 days.
That is 20 choices you made for yourself.
```

如果用户有 Rainy Day：

```text
You also had 3 rainy days.
They did not stop your garden from growing.
```

### 11.5 展示形式

v1 可以用全屏弹窗、底部 sheet 或首页卡片。

推荐使用首页卡片，不打断用户。

---

## 12. 数据模型设计

### 12.1 DailyRecord

```swift
struct DailyRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var status: DailyRecordStatus
    var createdAt: Date
    var updatedAt: Date
}
```

### 12.2 DailyRecordStatus

```swift
enum DailyRecordStatus: String, Codable {
    case planted
    case rainy
}
```

说明：

- 没有记录时，不存 DailyRecord。
- Empty Day 通过查询不到记录来判断。
- Future Day 通过日期判断，不进入数据模型。

### 12.3 Journey / HabitProfile 扩展字段

如果当前已有 habit 或 profile 数据模型，可增加：

```swift
var startDate: Date
var records: [DailyRecord]
var lastReviewShownType: String?
var lastMonthlyReviewShownMonth: String?
```

如使用 SwiftData / CoreData，可将 DailyRecord 作为独立实体，关联到当前 habit。

---

## 13. 本地存储要求

v1 仅使用本地存储。

可选方案：

1. SwiftData
2. CoreData
3. UserDefaults + Codable JSON

如果当前项目结构较轻，v1 可以使用 UserDefaults + Codable JSON 快速实现。

建议封装一个 RecordStore：

```swift
final class DailyRecordStore: ObservableObject {
    @Published private(set) var records: [DailyRecord] = []

    func recordTodayAsPlanted()
    func recordTodayAsRainy()
    func updateRecord(for date: Date, status: DailyRecordStatus)
    func clearRecord(for date: Date)
    func record(for date: Date) -> DailyRecord?
    func recentDays(count: Int) -> [DailyDayItem]
    func currentStreak() -> Int
    func totalPlantedDays() -> Int
}
```

---

## 14. 日期处理要求

日期判断必须基于用户本地时区。

同一天判断不要直接比较 Date，需要转换为 Calendar 的 startOfDay。

示例：

```swift
let calendar = Calendar.current
let todayStart = calendar.startOfDay(for: Date())
```

每日状态以本地自然日为单位。

---

## 15. UI 文案

### 15.1 今日未确认

```text
How did today go?
Every small choice helps your garden grow.
Plant Today
I had a setback
```

### 15.2 今日已种植

```text
Today has been planted.
Come back tomorrow and keep growing.
Planted
```

### 15.3 Rainy Day

```text
Today is a rainy day.
A setback is not the end. Your garden can still grow.
```

### 15.4 成长格子

```text
Last 30 Days
A quiet record of your progress.
```

### 15.5 统计

```text
Current Streak
Total Planted Days
```

### 15.6 阶段回顾

```text
You planted 7 days.
Small steps are becoming real progress.
```

```text
You planted 30 days.
Your garden is becoming stronger.
```

```text
This month, you planted 20 days.
That is 20 choices you made for yourself.
```

---

## 16. 视觉设计建议

### 16.1 整体风格

延续 Sober Garden 的温和、自然、恢复感。

关键词：

- Calm
- Gentle
- Organic
- Warm
- Non-judgmental

### 16.2 颜色建议

可使用当前主题色体系，例如：

- 主绿色：#6B9E7A
- 浅绿色背景：#EAF4EC
- 土壤浅色：#E8DCC8
- 雨天蓝灰：#A9BBC8
- 文本深色：#24352A
- 次级文本：#6E7C72

### 16.3 状态图形

v1 推荐圆角方块：

- planted：绿色填充
- rainy：蓝灰填充，可加小雨滴 icon
- empty：浅土色
- today：外圈描边

后续版本可升级为小叶子、小花、土地块。

---

## 17. 动效建议

v1 可以做轻量动效。

### 17.1 Plant Today 动效

点击后：

1. 按钮轻微缩放
2. 今日格子从空状态变为绿色
3. 出现小叶子或柔和发光
4. 卡片文案切换为 Today has been planted

### 17.2 Rainy Day 动效

点击后：

1. 卡片颜色变为淡蓝灰
2. 今日格子变为雨天状态
3. 展示安慰文案

动效要轻，不要游戏化过重。

---

## 18. 用户流程

### 18.1 用户第一次打开 App

1. 用户完成初始设置。
2. 首页显示 Day 1。
3. 今日卡片显示 Plant Today。
4. 最近 30 天成长格子中，今天为空状态并高亮。

### 18.2 用户当天坚持成功

1. 用户打开首页。
2. 点击 Plant Today。
3. 今日状态保存为 planted。
4. 今日格子变绿。
5. 首页卡片显示 Today has been planted。
6. Total Planted Days +1。
7. Current Streak 更新。

### 18.3 用户当天出现 setback

1. 用户点击 I had a setback。
2. 今日状态保存为 rainy。
3. 今日格子变成雨天状态。
4. 首页卡片显示安慰文案。
5. Total Planted Days 不增加。
6. Current Streak 根据规则处理。

### 18.4 用户第二天回来

1. 系统根据本地日期判断进入新的一天。
2. 今日卡片重新显示未确认状态。
3. 昨天记录保留在成长格子中。

---

## 19. 边界情况

### 19.1 用户跨时区

v1 使用当前设备本地时区即可。

如果用户跨时区，记录按当前设备 Calendar.current 处理。

### 19.2 用户修改系统日期

v1 不做复杂防作弊。

该产品不是竞技或排行榜产品，不需要强制防作弊。

### 19.3 用户忘记记录

v1 可不做补签。

但建议后续版本加入“补记昨日”。

### 19.4 用户误点

建议 v1 支持当天状态编辑。

### 19.5 用户连续多天未打开

不要弹出责备文案。

推荐首页文案：

```text
Welcome back.
You can plant today.
```

---

## 20. 后续版本可扩展方向

以下功能不进入 v1，但可以作为后续方向：

1. 补记昨日
2. 每周回顾
3. 更丰富的花园成长动画
4. 月度花园海报分享
5. Widget 显示今日是否已种植
6. Lock Screen Widget
7. Apple Watch 快速 Plant Today
8. 自定义颜色主题
9. 多个 habit 独立成长格子
10. 本地 AI 鼓励语根据状态变化

---

## 21. Widget 扩展建议

虽然本需求 v1 可以只做 App 内页面，但非常建议后续把每日反馈延伸到 Widget。

Widget 可展示：

```text
Today not planted yet
```

或：

```text
Today planted 🌱
```

小组件价值：

1. 增强每日提醒。
2. 提高用户回访率。
3. 强化“每天填满”的心理反馈。
4. App Store 预览图更容易突出差异化。

v1 如果已有 Widget，可以优先显示：

- 今日状态
- Current Streak
- 一个小叶子图标

---

## 22. App Store 审核注意事项

本功能属于用户主动记录和本地成长反馈，不涉及医疗诊断、治疗建议或强制戒断承诺。

文案应避免：

- Cure addiction
- Guaranteed recovery
- Medical treatment
- Clinical therapy
- Diagnose

推荐使用：

- Support
- Companion
- Habit recovery
- Self-control
- Personal growth
- Reflection

Sober Garden 应继续定位为：

> A gentle recovery companion for building self-control and tracking personal growth.

---

## 23. 验收标准

### 23.1 今日记录

- 用户当天未记录时，首页显示 Plant Today。
- 用户点击 Plant Today 后，当天状态变为 planted。
- 用户点击 I had a setback 后，当天状态变为 rainy。
- 同一天重复打开 App，状态保持正确。
- 第二天打开 App，今日卡片重新进入未确认状态。

### 23.2 成长格子

- 最近 30 天正确显示。
- planted day 显示为绿色状态。
- rainy day 显示为雨天状态。
- empty day 显示为空状态。
- today 有明显高亮。

### 23.3 统计

- Total Planted Days 正确统计全部 planted 天数。
- Current Streak 根据连续 planted 天数正确计算。
- Rainy Day 不增加 Total Planted Days。

### 23.4 阶段回顾

- 累计 planted 7 天时，展示 7 天回顾。
- 累计 planted 30 天时，展示 30 天回顾。
- 同一个回顾不应反复弹出。

### 23.5 本地存储

- 关闭 App 后重新打开，记录不丢失。
- App 重启后成长格子和统计正确恢复。

---

## 24. 推荐开发优先级

### P0

1. DailyRecord 数据模型
2. Plant Today 按钮
3. Rainy Day 记录
4. 最近 30 天成长格子
5. Total Planted Days
6. Current Streak
7. 本地存储

### P1

1. 当天状态编辑
2. 7 天 / 30 天阶段回顾
3. 轻量动效
4. 点击成长格子查看详情

### P2

1. Widget 展示今日状态
2. 月度回顾
3. 分享海报
4. 更丰富的花园成长视觉

---

## 25. 最终产品表达

本次改造后，Sober Garden 的核心体验应从：

> 我从某天开始戒，到现在已经过去多久。

升级为：

> 我每天都在为自己的恢复花园种下一点东西。

首页的核心行动应变成：

```text
Plant Today
```

这是一个轻量、正向、低压力、可持续的每日反馈系统。它可以提升用户回访，也能让用户在阶段性回看时获得更强的满足感。

