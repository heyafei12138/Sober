# SoberGarden ASO 导向功能改版需求文档 v2

版本：v2.0  
日期：2026-06-04  
适用范围：SoberGarden iOS App、Widget Extension、Watch App、App Store 元数据与截图素材  
目标读者：产品、设计、iOS 开发、AI 编程助手、ASO/运营  

---

## 1. 改版结论

SoberGarden 接下来不建议继续向“戒一切坏习惯”的方向发散，而应调整为：

> **Sobriety-first, multi-habit-compatible**

也就是：

- 对外：主打 `quit drinking / sober days / sobriety tracker / urge support / recovery garden`。
- 对内：继续兼容 Smoking、Vaping、Alcohol、Porn、Gambling、Sugar、Social Media、Weed、Custom 等习惯。
- 品牌：继续保留 **Garden**，但不要让 Garden 单独承担搜索与转化任务。
- 产品表达：从“一个温柔的花园成长 App”升级为“一个温和、私密、可视化的清醒追踪工具”。

一句话定位：

> **A gentle sobriety tracker that helps users track sober days, calm cravings, and grow their recovery garden.**

中文理解：

> 一个温和的清醒追踪 App，帮助用户记录戒酒天数、熬过冲动，并把恢复过程养成一座花园。

---

## 2. 为什么要改版

### 2.1 当前核心问题

当前 App 已经具备较完整的功能骨架：Onboarding、Home、Rescue、Garden、Journal、Subscription、Share Poster、Widget、Watch、Deep Link、Local Notification 等模块均已存在。

但问题在于：

> **ASO 搜索心智与 App 内体验表达没有完全对齐。**

当前 App 名称中包含 `Sober`，用户在 App Store 搜索中更可能把它理解为：

- quit drinking app
- sober tracker
- sobriety tracker
- sober days counter
- alcohol-free tracker
- craving support
- recovery journal

但当前功能文案和入口仍偏向泛习惯：

- quit bad habits
- clean days
- plant today
- rainy day
- habit tracker
- generic recovery

这会导致两个问题：

1. **搜索相关性不够聚焦**：标题、副标题、关键词、截图、首屏文案之间没有形成强一致性。
2. **转化链路不够明确**：用户看到 Sober 进来后，不一定能立刻确认“这就是我要找的戒酒/清醒追踪工具”。

### 2.2 Garden 是否保留

结论：**保留 Garden，但降低它作为搜索词的优先级。**

Garden 的价值是：

- 品牌差异化；
- 长期坚持的视觉奖励；
- 降低传统打卡失败感；
- 支撑首页、里程碑、徽章、Widget 和分享海报；
- 让产品区别于普通的 sober counter。

但 Garden 不是用户最先搜索的词。用户首先搜索的是：

- sober
- quit drinking
- sobriety
- alcohol free
- craving
- recovery

因此表达顺序应该是：

> 先讲 sober / quit drinking / cravings，再讲 garden growth。

推荐表达：

> **Turn every sober day into a growing garden.**

不推荐表达：

> **Grow your garden.**

后者太平淡，无法直接回答用户“这个 App 能帮我解决什么问题”。

---

## 3. 改版目标

### 3.1 产品目标

本次改版的目标不是大规模增加功能，而是让现有功能围绕“清醒追踪”形成更强的产品闭环：

1. 用户首次打开时，能快速进入戒酒/清醒路径。
2. 首页第一屏能明确展示 sober days、alcohol-free progress、urge support。
3. Rescue 流程能真正支撑 `craving / urge tracker` 的 ASO 卖点。
4. Garden 作为核心承诺，基础体验免费可见。
5. Journal 和 Widget 作为留存能力，不喧宾夺主。
6. App Store 截图不再是功能相册，而是形成完整说服链路。


## 6. 功能改版范围总览

### 6.1 P0 必做

| 模块 | 改版项 | 目标 |
| --- | --- | --- |
| Metadata | 改 App Name / Subtitle / Keywords | 对齐搜索意图 |
| Onboarding | Alcohol 前置，清醒路径优先 | 对齐用户第一预期 |
| Home | Alcohol 模式下改为 sober 文案体系 | 首屏强化转化 |
| Rescue | 增加 urge before 输入 | 支撑 urge/craving tracker 卖点 |
| Garden | 基础花园免费可见 | 避免核心承诺被付费墙截断 |
| Screenshots | 6 张说服链路重做 | 提升点击与下载转化 |
| Localization | 补全各语言 subtitle 和核心截图文案 | 避免搜索列表显示分类兜底 |

### 6.2 P1 建议

| 模块 | 改版项 | 目标 |
| --- | --- | --- |
| Journal | 免费展示最近 3 条记录 | 降低 journal 承诺落差 |
| Widget | 文案改为 sober days / rescue support | 强化留存和差异化 |
| Watch | 强调 I’m Struggling 快速呼吸入口 | 增强陪伴感 |
| Share | 免费允许基础分享，Plus 解锁高级模板 | 利于自然传播 |
| Settings | 增加 Sobriety Mode / Habit Mode 文案映射说明 | 避免泛习惯与戒酒冲突 |

### 6.3 P2 暂缓

暂时不建议做：

- 账号系统；
- 云同步；
- 社区；
- 排行榜；
- 远程 AI Coach；
- 多设备完整同步；
- 完整多习惯管理；
- 复杂趋势图表；
- 医疗化戒酒建议。

这些功能不能直接解决当前核心问题：搜索不够聚焦、搜索结果点击弱、产品页转化链路不够清晰。

---

## 7. Onboarding 改版需求

### 7.1 改版目标

让用户在首次进入时立即确认：

> 这个 App 可以帮我戒酒、记录清醒天数、熬过冲动，同时也支持其他习惯。

### 7.2 习惯选择排序

当前支持的习惯保持不变，但排序调整为：

1. Alcohol
2. Smoking
3. Vaping
4. Porn
5. Gambling
6. Sugar
7. Social Media
8. Weed
9. Something else

### 7.3 Alcohol 选择后的文案映射

当用户选择 Alcohol 时，全局进入 Sobriety 文案体系。

| 通用文案 | Alcohol 模式文案 |
| --- | --- |
| clean days | sober days |
| quit habit | quit drinking |
| habit | drinking |
| urge | drinking urge / craving |
| Plant Today | Mark Today Sober |
| I had a setback | I drank / I had a setback |
| Rainy Day | Setback Day |
| recovery garden | sobriety garden |

注意：不要把所有用户都默认描述成“addicted”。优先使用更温和表达：

- stay sober
- quit drinking
- alcohol-free
- recovery journey
- cravings
- hard moments

### 7.4 Onboarding 步骤调整

保持 8 步结构，但优化文案：

1. Welcome：强调 gentle sobriety tracker；
2. Choose Habit：Alcohol 前置；
3. Start Date：When did your sober journey begin?；
4. Daily Cost：How much could you save each day?；
5. Daily Time：How much time could you get back?；
6. Reasons：Why do you want to stay sober?；
7. Notifications：Gentle reminders, not pressure；
8. Finish：Start your recovery garden。

---

## 8. Home 首页改版需求

### 8.1 改版目标

首页第一屏必须回答：

1. 我已经坚持了多久？
2. 今天要做什么？
3. 冲动来了怎么办？
4. 我的恢复正在变好吗？

### 8.2 顶部状态改版

Alcohol 模式下：

- `Day 28 Sober`
- `Alcohol-free and still growing`
- `Your recovery garden is taking root`

非 Alcohol 模式下：

- `Day 28 Clean`
- `Still growing, one day at a time`

### 8.3 今日卡片改版

当前按钮：

- Plant Today
- I had a setback

建议 Alcohol 模式改为：

- Mark Today Sober
- I had a setback

卡片说明：

```text
Every sober day helps your garden grow.
```

Setback 后说明：

```text
A setback is not the end. You can restart gently.
```

### 8.4 Calm Coach 改版

本地 Calm Coach 保持，不接入远程 AI。

Alcohol 模式新增 prompt context：

- `sobrietyMorning`
- `cravingMoment`
- `postSetback`
- `milestoneSober`
- `nightReflection`

示例文案：

```text
You do not need to solve your whole life tonight. Just protect this next ten minutes.
```

```text
The urge can rise and fall without becoming an action.
```

```text
One setback does not erase the garden you have already grown.
```

### 8.5 首页花园预览

保留 Garden 作为品牌和视觉奖励，但首页表达要先讲 sober progress，再讲 garden。

示例：

```text
Your sober days are becoming a garden.
```

---

## 9. Rescue 急救流程改版需求

### 9.1 改版目标

Rescue 是本次改版最关键的功能模块之一，因为它直接支撑：

- urge tracker
- craving support
- sober support
- relapse prevention

当前流程已有 Emotion、Coach、Breathing、Reasons、Delay、Feedback，但需要补强“前后评分”的机制感。

### 9.2 新流程

建议改为 7 步：

| 步骤 | 页面标题 | 说明 |
| --- | --- | --- |
| 1 | How strong is the urge? | 输入 urgeBefore，0-10 |
| 2 | What are you feeling? | 选择 emotion/trigger，可跳过 |
| 3 | Take one calm breath | 呼吸练习 |
| 4 | Remember why you started | 展示 reasons |
| 5 | Wait 10 minutes | 延迟承诺 |
| 6 | How do you feel now? | 输入 urgeAfter，0-10 |
| 7 | You got through this moment | 完成页，展示变化 |

### 9.3 数据模型

现有 `RescueSession` 已包含：

- urgeBefore
- urgeAfter
- completedBreathing
- completedDelay

本次改版应真正写入 `urgeBefore`。

如当前字段为 optional，可继续保持 optional 兼容旧数据。

建议新增计算属性：

```swift
var urgeReduction: Int? {
    guard let before = urgeBefore, let after = urgeAfter else { return nil }
    return max(0, before - after)
}
```

### 9.4 完成页文案

当 urgeAfter < urgeBefore：

```text
The urge dropped by 3 points.
You gave yourself time, and that matters.
```

当 urgeAfter >= urgeBefore：

```text
The urge may still be here, but you paused before acting.
That is already progress.
```

### 9.5 Plus 权限调整

Rescue 核心流程必须免费。

Plus 可以解锁：

- 10 分钟后本地提醒；
- Rescue 历史统计；
- 高级趋势分析；
- 自定义 Rescue 文案；
- 夜间高风险提醒。

不要把“救急能力”作为强付费墙，否则会伤害产品信任。

---


### 10.4 Garden 页文案

标题：

```text
Recovery Garden
```

副标题：

```text
Every sober day helps something grow.
```

下一个里程碑：

```text
3 days until Steady Bloom
```

Setback 后：

```text
Your garden keeps what you have already grown.
Start again gently.
```

---

## 11. Journal 改版需求

### 11.1 改版目标

Journal 是增强留存和信任的模块，但不建议放在 ASO 前 3 张主截图中。

它的主要任务：

- 记录情绪；
- 记录 urge level；
- 记录 triggers；
- 记录 note；
- 让用户看到恢复不是线性过程。

### 11.2 免费策略

建议免费用户可见：

- 今日记录；
- 最近 3 条历史；
- 基础 check-in streak；
- 基础 trigger 标签。

Plus 解锁：

- 无限历史；
- 高级统计；
- 月度回顾；
- 导出；
- 长期趋势。

### 11.3 文案建议

标题：

```text
Reflect Without Shame
```

副标题：

```text
Track moods, triggers, and small wins.
```

Setback 记录页：

```text
This is not a failure report. It is a map for next time.
```

---

## 12. Widget 改版需求

### 12.1 改版目标

Widget 是 SoberGarden 的差异化资产，适合在后续截图中展示，但不要抢前 3 张主线。

### 12.2 Streak Widget

当前：

- clean days
- next milestone
- 今日状态

Alcohol 模式建议文案：

- `28 Days Sober`
- `Next: Steady Bloom`
- `Today: Mark sober`

### 12.3 Garden Widget

建议文案：

- `Your recovery garden`
- `Day 28`
- `Growing steadily`

### 12.4 Rescue Widget

建议文案：

- `Urge hitting?`
- `Open Rescue`
- `Breathe for 60 seconds`

Widget 点击路径保持：

- `sobergarden://home`
- `sobergarden://garden`
- `sobergarden://rescue`

---

## 13. Watch App 改版需求

### 13.1 改版目标

Watch App 不作为 ASO 主卖点，但可以作为信任和差异化补充。

### 13.2 文案建议

首页：

```text
28 Days Sober
Next: Steady Bloom
```

入口按钮：

```text
I'm Struggling
```

呼吸页完成：

```text
You paused. That counts.
```

---

## 14. Subscription 与付费墙调整



### 14.4 付费页主张

标题：

```text
Grow Your Recovery with Plus
```

卖点：

- Unlock deeper insights
- Keep a full recovery journal
- Customize your garden
- Get gentle milestone reminders
- Create beautiful progress posters

避免把 Plus 说成“才能恢复”，而是“让恢复过程更完整、更个性化”。

---

## 15. 本地化改版需求

### 15.1 必须补全的本地化元数据

为避免搜索列表页显示分类兜底，至少补全以下语言的 App Name、Subtitle、Promotional Text、截图文案：

- English

- Spanish
- Japanese

### 15.2 英文核心文案

App Name：

```text
Sober Garden: Quit Drinking
```

Subtitle：

```text
Sober Days & Urge Tracker
```

### 15.3 简体中文建议

App 名称：

```text
Sober Garden：戒酒追踪
```

副标题：

```text
清醒日数与冲动记录
```

### 15.4 繁体中文建议

App 名称：

```text
Sober Garden：戒酒追蹤
```

副标题：

```text
清醒日數與衝動記錄
```

### 15.5 西班牙语建议

App Name：

```text
Sober Garden: Deja el Alcohol
```

Subtitle：

```text
Días sobrios y apoyo diario
```

### 15.6 日语建议

App Name：

```text
Sober Garden: 禁酒記録
```

Subtitle：

```text
断酒日数と衝動ケア
```

---

## 16. 数据与兼容性要求

### 16.1 旧数据兼容

本次改版不应破坏已有数据：

- `Habit.type` 保持兼容；
- `DailyRecord.status` 保持 planted/rainy；
- `RescueSession.urgeBefore` 如果旧数据为空，UI 应兼容；
- `GardenStage` 里程碑保持；
- `RelapseRecord` 保持；
- Widget snapshot 结构尽量保持向后兼容。

### 16.2 文案映射层

建议增加文案映射层，而不是在各页面写大量 if/else。

示例：

```swift
struct SGRecoveryLanguage {
    let dayLabel: String
    let primaryAction: String
    let setbackAction: String
    let urgeName: String
    let journeyName: String
    let gardenName: String
}
```

根据 `Habit.type` 返回不同文案。

Alcohol：

```swift
Sober days / Mark Today Sober / I had a setback / craving / sober journey / recovery garden
```

Generic：

```swift
Clean days / Plant Today / I had a setback / urge / recovery journey / garden
```

---

## 17. 开发实施顺序

### Phase 1：ASO 对齐与文案层

目标：最短时间解决搜索结果与首屏表达问题。

任务：

1. 修改 App Name / Subtitle / Keywords；
2. 补全英文、简中、繁中本地化 subtitle；
3. Onboarding Alcohol 前置；
4. 增加 Alcohol 模式文案映射；
5. 首页文案改为 sober-first；

预估优先级：最高。

### Phase 2：Rescue 机制补强

目标：让 `Urge Tracker / Craving Support` 真实成立。

任务：

1. 增加 urgeBefore 页面；
2. 保存 urgeBefore；
3. 完成页展示 urge reduction；
4. Rescue Widget 文案更新；
5. 本地 Calm Coach 增加 craving context。

预估优先级：最高。



### Phase 4：Journal / Widget / Watch 优化

目标：增强留存和差异化。

任务：

1. Journal 免费展示最近 3 条；
2. Widget 文案根据 habit type 映射；
3. Watch 首页文案更新；
4. 分享海报文案更新。

预估优先级：中。

---

## 18. 验收标准


### 18.2 产品验收

- 选择 Alcohol 后，首页显示 sober days；
- 今日主按钮显示 Mark Today Sober；
- Rescue 可以记录 urgeBefore 和 urgeAfter；
- Garden 免费用户可看到基础成长内容；
- Journal 免费用户至少可查看最近 3 条；
- Widget 文案与用户选择的 habit type 一致；
- 旧数据不会丢失；
- 没有 habit 时仍正常进入 Onboarding。

### 18.3 合规验收

- 不宣称治疗、诊断、治愈酒精依赖；
- 不替代专业医疗建议；
- 隐私文案真实，不夸大；
- 不编造用户量、评分、媒体背书；
- 涉及 alcohol/recovery 的文案保持支持性和非羞辱性。

---

## 19. 改版后的产品主线

用户路径应变成：

7. 下载后 Onboarding 第一屏看到 Alcohol；
8. 创建 journey；
9. 首页看到 Day X Sober；
10. 冲动时进入 Rescue；
11. 每日确认，花园成长；
12. Widget / Watch 提醒用户继续回来。

---

## 20. 最终建议

SoberGarden 不要放弃 Garden。

但要从：

> 一个支持多种坏习惯的花园打卡 App

调整为：

> 一个以戒酒/清醒为主线的恢复陪伴 App，用花园成长来表达每一天的坚持。

最终产品表达：

```text
Track sober days.
Calm cravings.
Grow your recovery garden.
```

这三个短句应成为下一阶段所有功能、截图、文案和 ASO 的统一方向。
