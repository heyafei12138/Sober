# Sober Garden v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the PRD v1.0 iOS app in Swift with UIKit and SnapKit, turning the current four placeholder tabs into a complete local-first recovery companion.

**Architecture:** Keep the existing `BaseViewController`, custom navigation, and custom tab bar. Add a lightweight local domain layer under `SoberGarden/Core`, then implement each feature module as small UIKit view controllers and reusable SnapKit views. Use Codable local storage first, then add App Group snapshot data for widgets when the core app is stable.

**Tech Stack:** Swift, UIKit, SnapKit, JKSwiftExtension, UserNotifications, WidgetKit, WatchKit/SwiftUI for the optional watch target.

---

## Current Project Facts

- Workspace: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden.xcworkspace`
- Main target: `SoberGarden`
- Deployment target currently set in project: iOS `26.1`
- Existing layout framework: SnapKit via Swift Package
- Existing shared imports: `SoberGarden/Helper/Define/SGDefine.swift`
- Existing base UI: `SoberGarden/base/SGNavTab/BaseViewContoller.swift`, `CustomNavigationBar.swift`, `MainTabBarController.swift`, `TabbarView.swift`
- Existing module placeholders: `Home`, `Rescue`, `Garden`, `Journal`
- Xcode project uses a file-system-synchronized root group for `SoberGarden`, so new Swift files under that folder should be picked up by the app target automatically.

## Build And Verification Commands

Use these commands after every task that changes Swift code:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If the simulator name is unavailable, list simulators and choose the latest iPhone simulator:

```bash
xcrun simctl list devices available
```

Run the app manually after UI tasks and verify the touched flow on simulator.

---

## File Structure To Add

Create these folders under `SoberGarden` as the plan progresses:

```text
SoberGarden/Core/Models
SoberGarden/Core/Services
SoberGarden/Core/ViewModels
SoberGarden/Core/UI
SoberGarden/Core/Resources
SoberGarden/Modules/Onboarding
SoberGarden/Modules/Home/Views
SoberGarden/Modules/Rescue/Views
SoberGarden/Modules/Garden/Views
SoberGarden/Modules/Journal/Views
SoberGarden/Modules/Settings
SoberGarden/Modules/Share
SoberGarden/WidgetShared
```

Keep files focused. Do not turn one module controller into a large all-in-one file.

---

## Phase 0: Foundation

### Task 1: Add Core Domain Models

**Files:**
- Create: `SoberGarden/Core/Models/Habit.swift`
- Create: `SoberGarden/Core/Models/RescueSession.swift`
- Create: `SoberGarden/Core/Models/JournalEntry.swift`
- Create: `SoberGarden/Core/Models/RelapseRecord.swift`
- Create: `SoberGarden/Core/Models/Milestone.swift`
- Create: `SoberGarden/Core/Models/WidgetSnapshot.swift`

- [x] Add `Habit`, `HabitType`, `RescueSession`, `EmotionType`, `JournalEntry`, `MoodType`, `UrgeLevel`, `TriggerType`, `RelapseRecord`, `Milestone`, `GardenStage`, and `WidgetSnapshot` exactly matching the PRD fields.
- [x] Make display helpers local to the models where useful, for example `HabitType.displayName`, `GardenStage.title`, `GardenStage.badgeName`, and `EmotionType.displayName`.
- [x] Add `Milestone.defaultMilestones` with days `[1, 3, 7, 14, 30, 60, 90, 180, 365]`.
- [x] Build the app.
- [x] Commit: `feat: add sober garden domain models`

### Task 2: Add Date, Streak, Milestone, And Garden Calculators

**Files:**
- Create: `SoberGarden/Core/Services/SGProgressCalculator.swift`

- [ ] Implement `currentStreakDays(startDate:now:calendar:) -> Int` using calendar day boundaries and PRD display behavior: same-day start should display as day `1`.
- [ ] Implement `elapsedCleanDaysForSavings(startDate:now:) -> Int` using `floor((now - startDate) / 86400)` for money/time calculations.
- [ ] Implement `nextMilestone(for:) -> Milestone?`.
- [ ] Implement `currentGardenStage(for:) -> GardenStage`.
- [ ] Implement `moneySaved(dailyCost:cleanDays:)` and `timeSavedMinutes(dailyMinutes:cleanDays:)`.
- [ ] Add small in-file debug assertions in a `#if DEBUG` static method, covering same-day, yesterday, milestone day 7, and next milestone day 14.
- [ ] Build the app.
- [ ] Commit: `feat: add progress calculations`

### Task 3: Add Local Codable Storage

**Files:**
- Create: `SoberGarden/Core/Services/SoberGardenStore.swift`
- Create: `SoberGarden/Core/Services/SoberGardenState.swift`

- [ ] Implement `SoberGardenState: Codable` containing optional `habit`, arrays for `rescueSessions`, `journalEntries`, `relapseRecords`, `recentPromptIDs`, and settings flags.
- [ ] Implement `SoberGardenStore` as a singleton with `load()`, `save(_:)`, and convenience mutation methods.
- [ ] Store JSON in app documents directory as `sober_garden_state.json`.
- [ ] Keep all storage local; do not add networking or accounts.
- [ ] Build the app.
- [ ] Commit: `feat: add local sober garden store`

### Task 4: Add Shared Design Components

**Files:**
- Create: `SoberGarden/Core/UI/SGCardView.swift`
- Create: `SoberGarden/Core/UI/SGPrimaryButton.swift`
- Create: `SoberGarden/Core/UI/SGOptionChip.swift`
- Create: `SoberGarden/Core/UI/SGProgressBarView.swift`
- Create: `SoberGarden/Core/UI/SGSectionHeaderView.swift`
- Modify: `SoberGarden/Helper/Theme/SGColor.swift`

- [ ] Add reusable UIKit components styled with `SGColor`, rounded cards, restrained shadows, and SnapKit constraints.
- [ ] Add semantic colors only if needed: flower accent, warning-free orange, soft shadow.
- [ ] Buttons must support normal and disabled states.
- [ ] Option chips must support selected/unselected state.
- [ ] Build the app.
- [ ] Commit: `feat: add shared UIKit components`

---

## Phase 1: First Launch And Onboarding

### Task 5: Add Onboarding Coordinator

**Files:**
- Create: `SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Create: `SoberGarden/Modules/Onboarding/SGOnboardingStepView.swift`
- Create: `SoberGarden/Modules/Onboarding/SGOnboardingDraft.swift`
- Modify: `SoberGarden/SceneDelegate.swift`

- [ ] On launch, load `SoberGardenStore.shared.state`.
- [ ] If `state.habit == nil`, show `SGOnboardingViewController`; otherwise show `MainTabBarController`.
- [ ] Keep onboarding in one controller with a step enum to avoid over-building navigation.
- [ ] Add progress indicator and Back/Next behavior.
- [ ] Build and verify first launch shows onboarding.
- [ ] Commit: `feat: route first launch to onboarding`

### Task 6: Implement Onboarding Steps 1-4

**Files:**
- Modify: `SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Modify: `SoberGarden/Modules/Onboarding/SGOnboardingDraft.swift`

- [ ] Step 1 welcome: title `Break the habit. Grow a calmer life.`, subtitle, button `Get Started`.
- [ ] Step 2 habit picker with PRD options and custom text field when `Custom` is selected.
- [ ] Step 3 start date: Today, Yesterday, Pick a date; reject future dates.
- [ ] Step 4 cost input: per day, per week, per month, Skip; normalize to `dailyCost`.
- [ ] Use SnapKit for all layout; avoid storyboard edits.
- [ ] Build and manually step through pages 1-4.
- [ ] Commit: `feat: implement onboarding habit setup`

### Task 7: Implement Onboarding Steps 5-8

**Files:**
- Modify: `SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Create: `SoberGarden/Core/Services/SGNotificationService.swift`
- Modify: `SoberGarden/SceneDelegate.swift`

- [ ] Step 5 time input: minutes per day, hours per week, Skip; normalize to `dailyMinutes`.
- [ ] Step 6 reasons: multi-select PRD templates, custom reason text, Skip allowed.
- [ ] Step 7 notification explainer: buttons `Enable Notifications` and `Maybe Later`; request system permission only after tapping enable.
- [ ] Step 8 completion: save `Habit`, set `createdAt/updatedAt`, transition to `MainTabBarController`.
- [ ] Build and verify a full onboarding completion persists after app restart.
- [ ] Commit: `feat: complete onboarding flow`

---

## Phase 2: Home, Calm Coach, And Garden Core

### Task 8: Add Calm Coach Local Prompt System

**Files:**
- Create: `SoberGarden/Core/Resources/calm_coach_prompts.json`
- Create: `SoberGarden/Core/Services/SGCalmCoachService.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [ ] Add local prompts for `home`, `urge`, `stress`, `lonely`, `bored`, `angry`, `tired`, `anxious`, `triggered`, `lateNight`, `milestone7`, and `relapse`.
- [ ] Implement weighted random prompt selection.
- [ ] Avoid repeating prompt IDs from the last 24 hours when candidates are available.
- [ ] Never use AI wording such as `AI`, `AI says`, or `Powered by AI`.
- [ ] Build the app.
- [ ] Commit: `feat: add local calm coach prompts`

### Task 9: Replace Home Placeholder With PRD Home

**Files:**
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGHomeHeaderView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGStreakCardView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGSavedStatsView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGMilestoneCardView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGGardenPreviewView.swift`

- [ ] Use a vertical `UIScrollView` and content stack with SnapKit.
- [ ] Show top habit status: `Day N` and `Clean from Habit`.
- [ ] Show Calm Coach card with local prompt text.
- [ ] Show streak main card: days clean, hours, longest streak, started date.
- [ ] Show money/time saved cards with empty states if no cost/time.
- [ ] Show next milestone with progress bar.
- [ ] Show garden preview and make tapping it switch to Garden tab.
- [ ] Add strong visible `I'm Struggling` CTA that switches to Rescue tab.
- [ ] Add Share Progress row; implementation can be wired in Task 20.
- [ ] Build and verify Home is not a placeholder.
- [ ] Commit: `feat: build home dashboard`

### Task 10: Replace Garden Placeholder With Growth Page

**Files:**
- Modify: `SoberGarden/Modules/Garden/SGGardenViewController.swift`
- Create: `SoberGarden/Modules/Garden/Views/SGGardenIllustrationView.swift`
- Create: `SoberGarden/Modules/Garden/Views/SGBadgeGridView.swift`

- [ ] Show current garden illustration using simple UIKit shapes first: seed, sprout, plant, flower, garden bed, blooming garden, peaceful garden, small forest, sanctuary.
- [ ] Show current stage name and clean days.
- [ ] Show next stage progress.
- [ ] Show unlocked badges from milestones already reached; keep badges visually retained.
- [ ] Show PRD growth copy; for reset state use `Your garden remembers your effort. A new seed has been planted.`
- [ ] Build and manually verify different stages by temporarily changing start date in storage or debug seed data.
- [ ] Commit: `feat: build garden growth page`

---

## Phase 3: Rescue Flow

### Task 11: Build Rescue Step State Machine

**Files:**
- Modify: `SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Create: `SoberGarden/Modules/Rescue/SGRescueDraft.swift`
- Create: `SoberGarden/Modules/Rescue/Views/SGRescueStepHeaderView.swift`

- [ ] Replace placeholder with a single controller driven by `enum Step`.
- [ ] Support steps: emotion, coach, breathing, reasons, delay, feedback.
- [ ] Keep draft fields: emotion, urgeBefore, urgeAfter, completedBreathing, completedDelay.
- [ ] Add `startNewSession()` and `renderCurrentStep()`.
- [ ] Build and verify Rescue tab shows Step 1.
- [ ] Commit: `feat: add rescue flow state`

### Task 12: Implement Rescue Emotion And Coach Steps

**Files:**
- Modify: `SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Create: `SoberGarden/Modules/Rescue/Views/SGEmotionPickerView.swift`
- Create: `SoberGarden/Modules/Rescue/Views/SGCoachMessageView.swift`

- [ ] Step 1 title `What are you feeling right now?`.
- [ ] Show all PRD emotions plus Skip.
- [ ] Record `emotionType` when selected.
- [ ] Step 2 first shows `Calm Coach is here...` for 0.8-1.2 seconds.
- [ ] Then show selected local prompt and `Start Breathing`.
- [ ] Build and verify transition timing.
- [ ] Commit: `feat: implement rescue emotion and coach steps`

### Task 13: Implement Breathing Exercise

**Files:**
- Modify: `SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Create: `SoberGarden/Modules/Rescue/Views/SGBreathingExerciseView.swift`

- [ ] Implement 4s inhale, 2s hold, 6s exhale cycle for default 90 seconds.
- [ ] Animate a circle scaling up/down.
- [ ] Show current phase and remaining seconds.
- [ ] `Finish Early` continues to next step with `completedBreathing = false`.
- [ ] Natural completion sets `completedBreathing = true`.
- [ ] Build and manually verify the timer can finish early without blocking.
- [ ] Commit: `feat: add rescue breathing exercise`

### Task 14: Implement Reasons, Delay Commitment, And Feedback

**Files:**
- Modify: `SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Modify: `SoberGarden/Core/Services/SGNotificationService.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [ ] Step 4 show user reasons, or default: `You chose this because your future matters more than this urge.`
- [ ] Step 5 show `Can you wait 10 minutes?` and schedule local notification after tapping `I'll wait 10 minutes`.
- [ ] `I'm still struggling` should show another coach prompt or restart breathing.
- [ ] Step 6 show urge strength slider 0-10 and buttons `I'm okay now`, `Start another rescue`.
- [ ] Save `RescueSession` with all PRD fields.
- [ ] Build and verify a completed rescue session is persisted.
- [ ] Commit: `feat: complete rescue session flow`

---

## Phase 4: Journal And Settings

### Task 15: Build Journal Check-In

**Files:**
- Modify: `SoberGarden/Modules/Journal/SGJournalViewController.swift`
- Create: `SoberGarden/Modules/Journal/Views/SGJournalCheckInView.swift`
- Create: `SoberGarden/Modules/Journal/Views/SGJournalHistoryCell.swift`

- [ ] Replace placeholder with Today Check-in UI.
- [ ] Mood single choice: Great, Calm, Okay, Low, Stressed.
- [ ] Urge single choice: No urge, Mild urge, Strong urge.
- [ ] Trigger multi-choice: Stress, Boredom, Loneliness, Social media, Late night, Conflict, Tiredness, Custom.
- [ ] Reflection text view placeholder: `What helped you today?`
- [ ] Save or update today's `JournalEntry`.
- [ ] Show recent entries list with date, mood, urge level, triggers, note.
- [ ] Build and verify journal survives app restart.
- [ ] Commit: `feat: build daily journal`

### Task 16: Add Settings Entry And Main Settings Page

**Files:**
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Create: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Create: `SoberGarden/Modules/Settings/SGSettingsRowView.swift`

- [ ] Wire Home settings button to push `SGSettingsViewController`.
- [ ] Sections: Habit, Notifications, Privacy & Safety, Data Management, About.
- [ ] Include rows from PRD: edit habit, start date, cost, time, reasons, notification toggles, Privacy Policy, Terms, Non-medical disclaimer, Reset current streak, Delete all data, App version.
- [ ] Use `SFSafariViewController` for external policy/terms URLs; use placeholder URLs only if final URLs are not available.
- [ ] Build and verify push/pop works with existing custom navigation.
- [ ] Commit: `feat: add settings page`

### Task 17: Implement Habit Editing And Reset Streak

**Files:**
- Modify: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Create: `SoberGarden/Modules/Settings/SGEditHabitViewController.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [ ] Let user edit habit type/custom name, start date, daily cost, daily minutes, and reasons.
- [ ] Reject future start dates.
- [ ] Reset flow: confirmation title `Start again?`, body from PRD, buttons Cancel and Start Again.
- [ ] On reset, save `RelapseRecord`, update `longestStreak`, reset `startDate`, keep unlocked badges behavior via milestone history.
- [ ] Show relapse Calm Coach copy after reset.
- [ ] Build and verify Home/Garden update after reset.
- [ ] Commit: `feat: support habit edits and streak reset`

---

## Phase 5: Notifications, Deep Links, And Sharing

### Task 18: Finish Local Notifications

**Files:**
- Modify: `SoberGarden/Core/Services/SGNotificationService.swift`
- Modify: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Modify: `SoberGarden/AppDelegate.swift`

- [ ] Implement daily reminder, milestone notification, night reminder, and rescue delay notification identifiers.
- [ ] Store notification settings locally.
- [ ] Reschedule notifications when settings or habit state changes.
- [ ] Add notification delegate handling for foreground display.
- [ ] Build and verify permission request and one test notification.
- [ ] Commit: `feat: add local notification scheduling`

### Task 19: Add URL Scheme And Deep Link Router

**Files:**
- Modify: `SoberGarden/Info.plist`
- Modify: `SoberGarden/SceneDelegate.swift`
- Create: `SoberGarden/Core/Services/SGDeepLinkRouter.swift`

- [ ] Add URL scheme `sobergarden`.
- [ ] Route `sobergarden://home`, `rescue`, `garden`, `journal`, `settings`.
- [ ] For settings, push settings on the selected Home navigation controller or top visible navigation controller.
- [ ] For rescue, switch to Rescue tab and reset to Step 1.
- [ ] Build and verify deep links with `xcrun simctl openurl booted sobergarden://rescue`.
- [ ] Commit: `feat: add sober garden deep links`

### Task 20: Add Share Progress Card

**Files:**
- Create: `SoberGarden/Modules/Share/SGProgressShareCardView.swift`
- Create: `SoberGarden/Modules/Share/SGShareProgressService.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`

- [ ] Render a shareable card containing clean days, saved money, garden stage, app name, and text `I'm growing one clean day at a time.`
- [ ] Present `UIActivityViewController` from Home.
- [ ] Ensure share card image uses the same warm visual style as Home/Garden.
- [ ] Build and verify share sheet opens.
- [ ] Commit: `feat: add progress sharing`

---

## Phase 6: Widget

### Task 21: Add Widget Shared Snapshot Writer

**Files:**
- Create: `SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: project capabilities manually in Xcode if App Group is required.

- [ ] Define App Group identifier, for example `group.com.Sober.SoberGarden`, after confirming Apple Developer configuration.
- [ ] Write `WidgetSnapshot` to App Group UserDefaults after onboarding completion, app open, start date edit, reset, and milestone changes.
- [ ] Keep a fallback standard UserDefaults writer for simulator development before App Group is configured.
- [ ] Build the app.
- [ ] Commit: `feat: write widget snapshot data`

### Task 22: Add Widget Extension

**Files:**
- Create via Xcode: Widget Extension target, suggested name `SoberGardenWidgets`
- Add widget files under generated extension folder.

- [ ] Create Streak Widget small/medium: `7 Days Clean`, `Next: 14 Days`, deep link `sobergarden://home`.
- [ ] Create Garden Widget small/medium: `Your garden is growing.`, `Day N`, current stage graphic, deep link `sobergarden://garden`.
- [ ] Create Rescue Widget small/medium: `Struggling?`, `Open Rescue`, deep link `sobergarden://rescue`.
- [ ] Read only `WidgetSnapshot`; do not duplicate app storage logic.
- [ ] Build app and widget extension.
- [ ] Commit: `feat: add home screen widgets`

---

## Phase 7: Watch Lite And App Lock

### Task 23: Add Apple Watch Lite Target

**Files:**
- Create via Xcode: Watch App target, suggested name `SoberGardenWatch`
- Add watch shared snapshot reader.

- [ ] Show streak glance: `N days clean`, `Next: X days`.
- [ ] Add `I'm Struggling` button.
- [ ] Implement 60 or 90 second breathing page with circle animation and optional haptic feedback.
- [ ] Keep watch app read-only except local breathing interaction.
- [ ] Build iOS app and watch target.
- [ ] Commit: `feat: add watch lite rescue`

### Task 24: Add Face ID / App Lock

**Files:**
- Create: `SoberGarden/Core/Services/SGAppLockService.swift`
- Modify: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Modify: `SoberGarden/SceneDelegate.swift`

- [ ] Add settings toggle for Face ID / App Lock.
- [ ] Use `LocalAuthentication`.
- [ ] Lock on app foreground only when setting is enabled.
- [ ] Provide passcode fallback through system authentication policy.
- [ ] Do not block notification or deep-link routing permanently; authenticate first, then route.
- [ ] Build and verify enabling/disabling app lock.
- [ ] Commit: `feat: add local app lock`

---

## Phase 8: Polish And Review Readiness

### Task 25: Add Non-Medical Disclaimer And Review-Safe Copy Pass

**Files:**
- Modify: `SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Modify: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Search all Swift/resource files.

- [ ] Add concise non-medical disclaimer in onboarding or settings.
- [ ] Search and remove prohibited terms from PRD: cure addiction, treat addiction, medical treatment, therapy, diagnosis, clinical recovery, scientifically proven to cure, quit forever, stop relapse permanently, AI therapist, AI doctor, powered by AI.
- [ ] Verify allowed copy uses recovery companion, urge support, calming exercise, self-reflection, gentle reminders, progress tracking.
- [ ] Build the app.
- [ ] Commit: `chore: align copy with review guidance`

### Task 26: Final MVP Acceptance Pass

**Files:**
- Modify only files required by discovered issues.

- [ ] Fresh install shows onboarding.
- [ ] User can create a single habit.
- [ ] Home shows clean days, Calm Coach, Garden preview, money/time saved, next milestone, and `I'm Struggling`.
- [ ] Rescue flow completes and saves `RescueSession`.
- [ ] Garden stage changes based on clean days.
- [ ] Journal saves and lists entries.
- [ ] Settings can edit habit and reset streak without deleting history.
- [ ] Notifications request permission only after custom explainer.
- [ ] Deep links open correct tabs.
- [ ] Widget displays streak and rescue entry after App Group is configured.
- [ ] App contains no subscription, account, AI API, community, or medical-claim UI.
- [ ] Run full build command.
- [ ] Commit: `chore: verify sober garden mvp`

---

## Recommended Execution Order

Do not start Widget or Watch until Tasks 1-20 are stable. The critical App Store 4.3 differentiation should be visible after Tasks 8-14: Home has Calm Coach/Garden/Rescue, and Rescue is a real guided flow.

Recommended Codex batch size:

1. Tasks 1-4: foundation and reusable UI.
2. Tasks 5-7: onboarding and first usable data.
3. Tasks 8-10: Home, Calm Coach, Garden.
4. Tasks 11-14: Rescue.
5. Tasks 15-17: Journal and Settings.
6. Tasks 18-20: notifications, deep links, share.
7. Tasks 21-24: Widget, Watch, app lock.
8. Tasks 25-26: review readiness.

## Notes For Codex Implementers

- Use Swift and UIKit only for the iOS app screens.
- Use SnapKit for every programmatic layout.
- Do not edit storyboards for feature UI.
- Do not add networking, accounts, subscriptions, or AI API calls.
- Prefer small view classes over massive view controller methods.
- Keep copy gentle and non-medical.
- After each task, build before committing.
