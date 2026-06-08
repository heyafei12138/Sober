# SoberGarden 当前功能介绍与 UI 风格总结

版本：基于当前项目代码整理  
日期：2026-06-08  
适用范围：SoberGarden iOS App、Widget Extension、Watch App、App Store / ASO 资料整理

## 1. 产品定位

SoberGarden 是一款以清醒追踪为核心、兼容多种习惯戒除场景的 iOS 应用。产品把用户的恢复过程表达为一座逐步成长的花园，通过每日种植、恢复天数、冲动急救、反思记录、里程碑和分享海报，帮助用户在低压力的体验中建立长期坚持感。

当前 ASO 方向更适合采用：

> Sobriety-first, multi-habit-compatible

也就是对外优先表达为戒酒、清醒天数、冲动支持和恢复花园；对内继续支持 Smoking、Vaping、Alcohol、Porn、Gambling、Sugar、Social Media、Weed、Custom 等习惯。

## 2. 核心用户场景

- 用户首次打开 App，创建自己的恢复旅程。
- 用户每天打开首页，确认今天是否坚持，并把当天“种进花园”。
- 用户查看 sober days / clean days、最长坚持、节省金额、节省时间和下一个里程碑。
- 用户在冲动、压力、焦虑、孤独、无聊等时刻进入 Rescue 急救流程。
- 用户记录当天心情、冲动程度、触发因素和备注。
- 用户查看花园阶段、成长路径和已解锁徽章。
- 用户生成恢复进展分享海报。
- 用户通过 Widget 或 Watch 快速查看进度，或进入急救入口。

## 3. App 信息与本地化

主 App 已支持多语言 App Name 本地化，`InfoPlist.strings` 位于主 target 根目录下的各语言 `.lproj`：

- English / Spanish / German / French / Italian：`SoberGarden`
- 简体中文：`戒酒花园`
- 繁体中文：`戒酒花園`
- Japanese：`禁酒ガーデン`
- Korean：`금주정원`

当前主 App、Widget、Watch 的文案资源均按多语言目录维护。主 App 的业务文案在 `SoberGarden/Helper/*.lproj/Localizable.strings`，Widget 和 Watch 分别在各自 target 的 `.lproj` 下。

## 4. 信息架构

主 App 使用 UIKit 实现。首次启动时，如果本地状态中没有 `habit`，进入 Onboarding；如果已有习惯，进入主界面。

主界面为自定义 TabBar，共 4 个 Tab：

| Tab | 控制器 | 功能定位 |
| --- | --- | --- |
| Home | `SGHomeViewController` | 恢复进度总览、今日种植、统计、分享、急救入口 |
| Rescue | `SGRescueViewController` | 冲动急救流程 |
| Garden | `SGGardenViewController` | 花园阶段、成长路径、徽章 |
| Journal | `SGJournalViewController` | 每日反思记录与历史 |

Settings 从 Home 右上角进入，不作为独立 Tab。

## 5. 当前功能介绍

### 5.1 Onboarding

Onboarding 用于创建恢复旅程，包含习惯选择、开始日期、每日花费、每日耗时、坚持原因、通知授权和完成页。Alcohol 被作为当前 ASO 方向的重点习惯，选择 Alcohol 后会进入 sobriety 文案体系，例如 sober days、quit drinking、craving、sobriety garden 等表达。

当前支持的习惯类型：

- Alcohol
- Smoking
- Vaping
- Porn
- Gambling
- Sugar
- Social Media
- Weed
- Custom

Custom 允许用户输入自定义习惯名称。开始日期不能选择未来日期。每日花费和每日耗时用于后续计算节省金额和节省时间。坚持原因会在 Rescue 流程中作为提醒内容展示。

### 5.2 Home 首页

Home 是 App 的核心聚合页，承担每日使用和转化首屏的主要职责。

当前首页能力：

- 展示当前恢复天数和习惯名称。
- 展示 Calm Coach 本地鼓励文案。
- 展示今日种植卡片，支持 Plant Today / Mark Today Sober 和 setback / rainy day 记录。
- 展示每日花园网格，支持自动范围和 3、7、14、30、60、90、180、365 天手动范围。
- 展示 Current Streak 和 Total Planted Days。
- 展示 7 天、30 天等阶段回顾提示。
- 展示 streak、最长坚持、开始日期、习惯名称等统计。
- 展示节省金额和节省时间，并支持进入习惯编辑。
- 展示下一个里程碑和花园阶段预览。
- 提供分享进展入口。
- 右下角提供呼吸动画样式的 Rescue 浮动入口。

首页的设计重点是让用户快速回答四个问题：

- 我已经坚持了多久？
- 今天是否已经完成？
- 冲动来了可以去哪里？
- 我的恢复是否正在变好？

### 5.3 每日种植系统

每日种植是 SoberGarden 与普通计时器的核心差异。

当前每日状态：

- `planted`：用户确认今天坚持。
- `rainy`：用户记录今天出现 setback。
- `empty`：过去或今天无记录。
- `future`：未来日期，仅作占位。

产品表达上避免使用 Failed、Broken、Reset 这类强惩罚文案，改用 Plant Today、Rainy Day、Your garden can still grow 等低压力表达。即使出现 setback，也保留累计种植天数和花园成长感。

### 5.4 Rescue 急救流程

Rescue 是面向冲动时刻的核心功能，当前为 7 步流程：

1. 记录急救前 urge / craving 强度。
2. 选择当前情绪。
3. 进行呼吸练习。
4. 回看坚持原因。
5. 做出延迟承诺。
6. 记录急救后 urge / craving 强度。
7. 完成急救流程。

该模块的产品定位是“即时陪伴”和“延迟冲动”，而不是医疗建议。视觉上使用温暖橙色作为 CTA，避免使用警报红，降低用户在脆弱时刻的压力感。

### 5.5 Garden 花园

Garden 页面展示恢复旅程的长期视觉成果，包括：

- 当前花园阶段插画。
- 当前恢复天数。
- 分享按钮。
- 到下一个里程碑的进度。
- 阶段奖励文案。
- 成长路径。
- 徽章网格。
- 鼓励文案卡片。

默认里程碑围绕 1、3、7、14、30、60、90、180、365 天设计。花园阶段和徽章是 App 的品牌差异化核心，用于把抽象的坚持天数转化为可感知的成长反馈。

注意：当前代码中 `SGGardenViewController` 仍保留 `SGGardenSubscriptionOverlayView` 的显示逻辑，非 Plus 时覆盖层会显示；如果后续确定“基础花园免费可见”为最终产品策略，需要继续同步该处实现。

### 5.6 Journal 反思记录

Journal 用于记录每天的恢复状态：

- 心情。
- 冲动强度。
- 触发因素。
- 文字备注。
- 今日记录编辑。
- 历史记录展示。
- Check-in streak / clean streak 统计。

当前代码中，历史记录对 Plus 用户完整展示最近记录；非 Plus 用户会看到历史记录解锁入口。今日记录本身是恢复闭环的重要部分，适合在 ASO 截图和产品介绍中作为“recovery journal / urge tracker”的辅助卖点。

### 5.7 分享海报

分享模块可以基于当前恢复进展生成海报预览。分享页支持不同海报风格切换，并提供保存图片和系统分享操作。

当前权限边界：

- Garden 样式在样式选择上对免费用户可见。
- 保存图片和系统分享操作需要 Plus 权限。
- 其他高级模板需要 Plus 权限。

该模块更适合作为长期留存和自然传播能力，不应在首屏压过 Home / Rescue / Garden 的核心体验。

### 5.8 订阅与 Plus

订阅页使用全屏 Paywall，包含 hero、权益说明、套餐卡片、Apple 订阅提示、继续按钮、隐私政策、服务条款、恢复购买和法律说明。

Plus 当前涉及的能力包括：

- Journal 历史记录解锁。
- Check-in 统计解锁。
- 高级通知能力。
- 分享保存和系统分享。
- 高级分享模板。
- 设置里的多习惯能力入口目前为 Plus + Coming Soon。

付费表达建议保持“增强恢复支持”，不要让用户感觉基础恢复旅程被截断。

### 5.9 Settings

Settings 提供 App 配置与账户外的本地管理能力：

- Plus 状态卡片。
- Check-in / clean streak 统计。
- 习惯编辑。
- 开始日期、每日花费、每日耗时、坚持原因查看。
- Sobriety / Generic 文案模式说明。
- 语言选择。
- 通知设置。
- 隐私与非医疗声明入口。
- 数据管理。
- Widget 使用指引。
- About、反馈、隐私政策、服务条款等入口。

Settings 的信息层级偏工具化，适合稳定、清晰、低装饰，避免营销化表达。

### 5.10 Widget

Widget 使用 SwiftUI 实现，读取 App Group 快照，提供多种小组件视图：

- Streak Widget：展示 clean days / sober days、下一个里程碑、今日状态和进度线。
- Garden Widget：展示花园成长状态和当前阶段插画。
- Rescue Widget：提供快速打开 Rescue 的入口。

Widget 视觉沿用 App 的绿色、米色和花园插画资产，并通过 deep link 打开 Home、Garden 或 Rescue。

### 5.11 Watch App

Watch App 使用 SwiftUI 实现，读取共享快照，核心功能为：

- 展示当前习惯名称。
- 展示 clean days / sober days。
- 展示下一个里程碑。
- 提供 “I'm Struggling” 快速入口。
- 进入 Watch breathing view 做呼吸练习。

Watch 的定位应保持轻量：进度查看 + 急救入口，不承载完整记录和设置。

### 5.12 数据与系统能力

当前 App 以本地数据为主：

- 主状态保存在 Documents 下的 `sober_garden_state.json`。
- Widget / Watch 通过 App Group 快照读取关键状态。
- 通知服务支持每日提醒、里程碑提醒、夜间提醒、Rescue 延迟提醒等能力，其中部分能力依赖 Plus。
- Deep link 支持从 Widget 跳转到 Home、Garden、Rescue 等入口。
- 当前不包含账号系统、云同步、社区、排行榜或远程 AI Coach。

## 6. UI 风格总结

### 6.1 整体风格

SoberGarden 的 UI 是“温和恢复 + 花园成长”的视觉系统。整体不是严肃医疗工具，也不是高压打卡工具，而是偏私密、安静、鼓励式的自我恢复 App。

关键词：

- Gentle
- Private
- Warm
- Nature-inspired
- Low-pressure
- Calm
- Supportive
- Recovery-focused

### 6.2 色彩系统

当前主题 token：

| Token | 色值 | 用途 |
| --- | --- | --- |
| `SGColor.primary` | `#8AA86B` | 主绿色、图标、强调 |
| `SGColor.primaryDark` | `#5F7D46` | 主按钮、深色强调 |
| `SGColor.primaryLight` | `#DDE8D2` | 次级背景、分隔、浅绿色容器 |
| `SGColor.background` | `#F7F5EA` | 页面背景 |
| `SGColor.textDark` | `#31412B` | 主文字 |
| `SGColor.rescue` | `#E89B5C` | Rescue CTA |
| `SGColor.flower` | `#F2C879` | 花朵、徽章、暖色点缀 |

视觉基调是暖米色背景 + 鼠尾草绿色 + 少量暖橙色。绿色负责恢复、成长和稳定；橙色只用于急救入口和关键 Rescue 行动；黄色/奶油色用于鼓励卡片和花园氛围。

### 6.3 布局语言

主 App 页面多采用纵向滚动布局，内容使用 `UIStackView` 组织。页面左右边距通常为 16-20pt，卡片之间间距约 18-22pt，底部为自定义 TabBar 留出空间。

主要布局特征：

- 单列内容流，适合移动端连续阅读。
- 关键模块使用白色或浅暖色卡片承载。
- 首页首屏聚合多个轻量模块，强调快速扫描。
- Rescue 使用步骤式单卡结构，减少用户在高压时刻的选择负担。
- Settings 使用 section + row 的工具型结构。

### 6.4 卡片与圆角

基础卡片 `SGCardView`：

- 白色 surface。
- 默认 16pt 圆角。
- 柔和阴影：深绿色低透明度阴影，半径 10，垂直偏移 4。
- 默认内边距 18pt。

卡片整体偏柔和、温暖，但不应堆叠过多装饰。卡片用于承载具体功能块，而不是把整页包装成大卡片。

### 6.5 按钮风格

基础按钮 `SGPrimaryButton`：

- 高度不低于 54pt。
- 18pt 圆角。
- 字体 17pt Semibold。
- Primary：深绿色背景 + 白字。
- Rescue：暖橙色背景 + 白字。
- Secondary：浅绿色背景 + 深色文字。

按钮状态有透明度反馈，disabled 状态通过背景和文字透明度降低表现。整体符合低压力、可触达、移动端友好的交互风格。

### 6.6 字体与信息层级

当前主要使用系统字体：

- 大标题：26-28pt Bold。
- 模块标题：18-20pt Semibold / Bold。
- 正文和说明：14-17pt Medium / Semibold。
- 辅助文字：13-15pt Medium。

文本颜色以深绿色为主，不使用纯黑作为主要阅读色。次级文字通过 alpha 形成层级，避免强对比带来的紧张感。

### 6.7 图标与插画

App 使用 SF Symbols 和花园资产混合：

- TabBar：house、lifepreserver、leaf、book。
- 分享：paperplane。
- Rescue：lifepreserver。
- Widget：leaf、camera.macro、lifepreserver。
- 花园阶段：seed、sprout、plant、flower、garden、forest 等图像资产。
- 首页 Calm Coach 使用 `home_calm_coach_icon` 或 flower fallback。

插画资产是品牌识别的重要部分，适合在首页、Garden、Widget 和分享海报中保持持续露出。

### 6.8 交互气质

SoberGarden 的交互应保持“轻确认、少惩罚、多鼓励”：

- 今日坚持用 Plant / Sober 表达。
- setback 用 Rainy Day 表达。
- Rescue 用呼吸、原因、延迟承诺降低冲动。
- Review prompt 和阶段回顾用于强化长期坚持感。
- 不用红色错误、强警告、羞耻化文案表达用户反复。

### 6.9 与 ASO 的视觉一致性建议

App Store 截图和产品页应保持与 App 内 UI 一致：

- 首张截图突出 sober days / quit drinking / recovery garden。
- 第二张展示今日种植和每日花园网格。
- 第三张展示 Rescue / craving support。
- 第四张展示 Garden 阶段和里程碑。
- 第五张展示 Journal / reflection。
- 第六张展示 Widget / Watch。

文案顺序建议先讲用户搜索意图，再讲品牌隐喻：

- 优先：Track sober days、Quit drinking、Calm cravings、Recovery journal。
- 辅助：Grow your recovery garden、Milestones、Badges。

## 7. 当前产品边界

当前已具备完整的本地恢复追踪闭环：

> Onboarding -> Home 今日种植 -> Rescue 急救 -> Journal 反思 -> Garden 成长 -> Widget / Watch 留存 -> Share 海报传播

当前不应优先扩展的方向：

- 账号系统。
- 云同步。
- 社区。
- 排行榜。
- 医疗化建议。
- 远程 AI Coach。
- 复杂趋势图表。
- 多习惯完整管理。

更适合优先打磨的方向：

- 清醒追踪文案一致性。
- Alcohol / Sobriety 模式首屏表达。
- Rescue 的 urge / craving 价值展示。
- Garden 基础体验的免费可见策略。
- App Store 截图和多语言 ASO 文案。
- 分享与 Journal 的付费边界清晰度。

