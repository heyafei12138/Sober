# Sober Garden v1.3 Daily Plant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade Sober Garden from a timer-first recovery tracker into a daily planting loop where users can mark each local day as `planted` or `rainy`, see the last 30 days, and review cumulative progress without shame language.

**Architecture:** Keep the existing UIKit + SnapKit app shell, `SoberGardenStore` Codable JSON storage, Home check-in card, Garden, Journal, Widget, and Watch structure. Add a first-class `DailyRecord` model to persisted state, use a focused daily-record service layer inside `SoberGardenStore`, and adapt the existing Home check-in UI into the v1.3 Daily Plant interaction instead of building a parallel flow.

**Tech Stack:** Swift, UIKit, SnapKit, Codable local JSON storage, existing `SGCardView`/`SGPrimaryButton` components, existing Widget App Group snapshot writer.

---

## Requirement Summary

The new `sober_garden_1.3daily_plant_prd.md` changes the daily loop from "check in / confirm clean" to "plant today / rainy day." The product goal is to increase daily return motivation, make every successful day visible, and preserve cumulative value even when the user has a setback.

Core v1.3 concepts:

- `Planted Day`: user actively confirms today's small recovery win.
- `Rainy Day`: user records a setback with non-punitive language.
- `Empty Day`: no record exists for the local date; it is not treated as failure.
- `Future Day`: display-only placeholder, not stored.
- `Current Streak`: consecutive planted days, with gentle handling when today is empty but yesterday was planted.
- `Total Planted Days`: lifetime count of planted records, never cleared by rainy or empty days.

## Current Project Fit

Existing project facts:

- Local storage already lives in `SoberGarden/Core/Services/SoberGardenState.swift` and `SoberGarden/Core/Services/SoberGardenStore.swift`.
- Home already has `SGTodayCheckInCardView` and `SGTodayCheckInFlowViewController`.
- Existing check-in state is metadata only: `lastCheckInDate`, `confirmedToday`, `needsYesterdayConfirmation`, `checkInStreakDays`, and last outcome.
- Existing main clean streak is still based on `Habit.startDate` via `SGProgressCalculator.currentStreakDays`.
- Garden, Widget, Share, Watch currently read clean days from habit start date, not daily records.
- `docs/superpowers/plans/2026-05-21-sober-garden-checkin.md` already planned a related check-in system; v1.3 should supersede its product semantics, not duplicate it.

Key gap:

The code can show "today confirmed," but it cannot yet answer "which of the last 30 local days were planted, rainy, empty, or future?" It also cannot calculate `Total Planted Days` or daily-record-based `Current Streak`.

## Scope Decision

### P0 for v1.3

- Add `DailyRecord` and `DailyRecordStatus`.
- Persist daily records in existing `SoberGardenState`.
- Replace Home card copy/actions with `Plant Today`, `I had a setback`, `Planted`, and Rainy Day copy.
- Record today as planted or rainy using `Calendar.current.startOfDay(for:)`.
- Add last 30 days growth grid to Home.
- Add `Current Streak` and `Total Planted Days` summary.
- Keep old `checkIn` decoding for compatibility, but make DailyRecord the source of truth for v1.3 daily status.

### P1 after P0 is stable

- Add `Edit today` with `Planted`, `Rainy Day`, and `Clear Record`.
- Add 7-day and 30-day review card.
- Add tap-to-view detail for each daily grid cell.
- Add subtle planted/rainy animations.

### P2 after app polish

- Extend Widget snapshot with today status.
- Add monthly review.
- Add share poster based on monthly/daily planted progress.
- Add Watch quick Plant Today.

## Files To Modify Or Create

### Core models and storage

- Modify: `SoberGarden/Core/Services/SoberGardenState.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: `SoberGarden/Core/Services/SGProgressCalculator.swift`
- Modify: `SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`
- Modify: `SoberGarden/Core/Models/WidgetSnapshot.swift`

### Home daily planting UI

- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInFlowViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGDailyGardenGridView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGDailyPlantStatsView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGDailyRecordDetailViewController.swift` for P1 tap details.

### Localization

- Modify all current `.strings` files under `SoberGarden/Helper/*.lproj/Localizable.strings`.
- Minimum English source keys must be added first; other locales can receive English fallback text if there is no translation pass yet.

### Xcode project

- Modify: `SoberGarden.xcodeproj/project.pbxproj` if new Swift files are added manually outside Xcode.

## Task 1: Add Daily Record Persistence

**Files:**

- Modify: `SoberGarden/Core/Services/SoberGardenState.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [ ] Add these Codable types to `SoberGardenState.swift`:

```swift
struct DailyRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    var status: DailyRecordStatus
    var createdAt: Date
    var updatedAt: Date
}

enum DailyRecordStatus: String, Codable, Equatable {
    case planted
    case rainy
}
```

- [ ] Add `var dailyRecords: [DailyRecord]` to `SoberGardenState`, defaulting to `[]` in `init(from:)`.
- [ ] In `SoberGardenStore`, add:

```swift
func recordTodayAsPlanted(now: Date = Date(), calendar: Calendar = .current)
func recordTodayAsRainy(now: Date = Date(), calendar: Calendar = .current)
func updateDailyRecord(for date: Date, status: DailyRecordStatus, now: Date = Date(), calendar: Calendar = .current)
func clearDailyRecord(for date: Date, calendar: Calendar = .current)
func dailyRecord(for date: Date, calendar: Calendar = .current) -> DailyRecord?
```

- [ ] Normalize all stored record dates with `calendar.startOfDay(for:)`.
- [ ] Sort `dailyRecords` descending after each mutation.
- [ ] Keep existing `checkIn` fields decoding untouched so current users do not lose app state.
- [ ] Build:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: build succeeds.

## Task 2: Add Daily Record Calculations

**Files:**

- Modify: `SoberGarden/Core/Services/SGProgressCalculator.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [ ] Add `DailyDayItem` for the 30-day grid:

```swift
struct DailyDayItem: Equatable {
    enum Status: Equatable {
        case planted
        case rainy
        case empty
        case future
    }

    let date: Date
    let status: Status
    let isToday: Bool
}
```

- [ ] Add calculation helpers:

```swift
static func recentDailyItems(records: [DailyRecord], count: Int, now: Date = Date(), calendar: Calendar = .current) -> [DailyDayItem]
static func dailyPlantStreak(records: [DailyRecord], now: Date = Date(), calendar: Calendar = .current) -> Int
static func totalPlantedDays(records: [DailyRecord]) -> Int
static func totalRainyDays(records: [DailyRecord]) -> Int
```

- [ ] Apply v1.3 streak rule:
  - If today is planted, count backward from today.
  - If today is empty and yesterday is planted, count backward from yesterday.
  - If today is rainy, planted streak is `0`.
  - If there is a gap before the anchor day, stop counting.
- [ ] Keep `currentStreakDays(startDate:)` unchanged for Journey Day display.
- [ ] Build with the same `xcodebuild` command.

Expected: build succeeds.

## Task 3: Convert Home Card To Daily Plant Semantics

**Files:**

- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInFlowViewController.swift`

- [ ] Rename view-facing states conceptually to:
  - `todayEmpty`
  - `todayPlanted`
  - `todayRainy`
- [ ] Render these exact English strings through localization keys:
  - Empty title: `How did today go?`
  - Empty subtitle: `Every small choice helps your garden grow.`
  - Empty primary: `Plant Today`
  - Empty secondary: `I had a setback`
  - Planted title: `Today has been planted.`
  - Planted subtitle: `Come back tomorrow and keep growing.`
  - Planted disabled button: `Planted`
  - Rainy title: `Today is a rainy day.`
  - Rainy subtitle: `A setback is not the end. Your garden can still grow.`
- [ ] In `SGHomeViewController`, derive today card state from `SoberGardenStore.shared.dailyRecord(for: Date())`.
- [ ] Primary action calls `recordTodayAsPlanted()`.
- [ ] Secondary action calls `recordTodayAsRainy()`.
- [ ] After saving, call `renderContent()` and run the existing subtle feedback animation.
- [ ] Do not reset `Habit.startDate` when recording rainy day.
- [ ] Build with the same `xcodebuild` command.

Expected: Home uses DailyRecord as source of truth, and journey day remains independent.

## Task 4: Add Last 30 Days Growth Grid

**Files:**

- Create: `SoberGarden/Modules/Home/Views/SGDailyGardenGridView.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden.xcodeproj/project.pbxproj`

- [ ] Implement a 5 x 6 grid view using UIKit and SnapKit.
- [ ] Accept `[DailyDayItem]` from Home.
- [ ] Use these colors:
  - planted: `#6B9E7A`
  - rainy: `#A9BBC8`
  - empty: `#E8DCC8`
  - future: `#E7E9E4`
  - today border: `#24352A`
- [ ] Add section title `Last 30 Days`.
- [ ] Add subtitle `A quiet record of your progress.`
- [ ] Place the grid below today card and above the existing streak/savings/milestone blocks.
- [ ] Build with the same `xcodebuild` command.

Expected: last 30 local days show stable state after app relaunch.

## Task 5: Add Daily Plant Stats Summary

**Files:**

- Create: `SoberGarden/Modules/Home/Views/SGDailyPlantStatsView.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden.xcodeproj/project.pbxproj`

- [ ] Display two compact stats:
  - `Current Streak`
  - `Total Planted Days`
- [ ] Calculate values from `dailyRecords`, not `Habit.startDate`.
- [ ] Keep Rainy Days out of the Home summary for P0.
- [ ] Add accessibility labels for both stat values.
- [ ] Build with the same `xcodebuild` command.

Expected: `Total Planted Days` increases only for planted records; rainy records do not increment it.

## Task 6: Add Today Editing

**Files:**

- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`

- [ ] Add a small `Edit today` action only when today has a record.
- [ ] Present an action sheet with:
  - `Planted`
  - `Rainy Day`
  - `Clear Record`
  - `Cancel`
- [ ] `Planted` calls `updateDailyRecord(for: Date(), status: .planted)`.
- [ ] `Rainy Day` calls `updateDailyRecord(for: Date(), status: .rainy)`.
- [ ] `Clear Record` calls `clearDailyRecord(for: Date())`.
- [ ] Build with the same `xcodebuild` command.

Expected: same-day mistakes are reversible without changing the journey start date.

## Task 7: Add 7-Day And 30-Day Review Cards

**Files:**

- Modify: `SoberGarden/Core/Services/SoberGardenState.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGPlantReviewCardView.swift`
- Modify: `SoberGarden.xcodeproj/project.pbxproj`

- [ ] Add persisted review fields:

```swift
var lastReviewShownType: String?
var lastMonthlyReviewShownMonth: String?
```

- [ ] Show 7-day review when `totalPlantedDays == 7` and `lastReviewShownType != "total_planted_7"`.
- [ ] Show 30-day review when `totalPlantedDays == 30` and `lastReviewShownType != "total_planted_30"`.
- [ ] Use Home inline card instead of blocking modal for P1.
- [ ] Copy:
  - `You planted 7 days. Small steps are becoming real progress.`
  - `You planted 30 days. Your garden is becoming stronger.`
- [ ] Add `Keep Growing` dismissal and persist the shown type.
- [ ] Build with the same `xcodebuild` command.

Expected: each review appears once and does not repeat after relaunch.

## Task 8: Extend Widget Snapshot Later

**Files:**

- Modify: `SoberGarden/Core/Models/WidgetSnapshot.swift`
- Modify: `SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`
- Modify: `SoberGardenWidgets/SGWidgetSnapshotReader.swift`
- Modify: `SoberGardenWidgets/SoberGardenWidgetViews.swift`

- [ ] Add optional widget field:

```swift
var todayStatus: DailyRecordStatus?
```

- [ ] Keep decoding backward compatible by making the property optional.
- [ ] Render:
  - No status: `Today not planted yet`
  - Planted: `Today planted`
  - Rainy: `Rainy day`
- [ ] Build app and widget target:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGardenWidgetsExtension -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: widget still renders for old snapshots and new snapshots.

## Verification Matrix

- [ ] Fresh install: Home shows `Plant Today`, today cell empty with border.
- [ ] Tap `Plant Today`: today record is saved as planted, card shows planted state, grid cell turns green, total planted days increments.
- [ ] Relaunch app: planted state persists.
- [ ] Tap `I had a setback`: today record is saved as rainy, grid cell turns blue-gray, total planted days does not increment.
- [ ] Edit today from planted to rainy: total planted days decrements by one.
- [ ] Edit today from rainy to planted: total planted days increments by one.
- [ ] Clear today: today returns to empty state.
- [ ] Device date advances one day: new today is empty and previous day remains in grid.
- [ ] Today empty and yesterday planted: current planted streak still displays yesterday's streak.
- [ ] Today rainy: current planted streak displays 0.
- [ ] User with old JSON state and no `dailyRecords`: app decodes, launches, and uses empty daily records.

## Product Notes

- Keep `Journey Day` based on habit start date. Do not describe it as a planted streak.
- Keep `Clean Streak`/legacy check-in stats secondary until product language is cleaned up.
- Do not use `Failed`, `Streak broken`, red X icons, or reset language for rainy days.
- Do not connect rainy day to relapse reset unless the user explicitly uses the existing reset flow.
- Avoid reusing "check-in" visible copy for the v1.3 daily loop; the user-facing metaphor should be "Plant Today."
