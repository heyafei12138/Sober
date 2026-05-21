# Sober Garden Today’s Check-in Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-class Today’s Check-in system to the Home screen with gentle daily confirmation, yesterday follow-up, and garden growth feedback, while keeping Clean Streak and Check-in Streak separate.

**Architecture:** Extend the existing local state model with check-in metadata, add a focused Home check-in card and bottom-sheet flow, and keep the clean streak logic independent from daily check-in behavior. The feature should remain local-only, use the current UIKit + SnapKit patterns, and reuse the app’s card/button styling instead of introducing a new design language.

**Tech Stack:** Swift, UIKit, SnapKit, Codable local storage, existing SoberGarden base view controllers and card/button components.

---

## Current Project Facts

- Workspace: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden.xcworkspace`
- Main target: `SoberGarden`
- Existing four-tab app shell is already in place
- Home, Rescue, Garden, Journal, and Settings modules already exist
- Local storage is handled by `SoberGardenStore` and `SoberGardenState`
- Shared UI components already exist in `SoberGarden/Core/UI`
- The current app uses SnapKit for layout and UIKit for screens

## Verification Command

Run this build after every task that changes Swift code:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

If the simulator name is unavailable, list available devices and choose the latest iPhone simulator:

```bash
xcrun simctl list devices available
```

---

## File Structure To Add Or Modify

### Core state and storage

- Modify: `SoberGarden/Core/Services/SoberGardenState.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

### Home check-in UI

- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInFlowViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInFeedbackView.swift`

### Shared helpers if needed

- Modify: `SoberGarden/Core/UI/SGPrimaryButton.swift`
- Modify: `SoberGarden/Core/UI/SGCardView.swift`
- Modify: `SoberGarden/Core/UI/SGSectionHeaderView.swift`

Keep each file narrowly focused. Do not place the entire flow in `SGHomeViewController`.

---

## Task 1: Add Check-in State To Local Storage

**Files:**
- Modify: `SoberGarden/Core/Services/SoberGardenState.swift`
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`

- [x] Add a check-in state model that tracks:
  - the date of the last Home check-in
  - whether today has been confirmed
  - whether yesterday needs a gentle confirmation prompt
  - the current check-in streak count
  - the last check-in outcome, including `easy`, `okay`, `hard`, and `urges`
- [x] Keep `Clean Streak` unchanged. It must continue to depend on the habit start date and relapse logic, not on daily check-ins.
- [x] Make the new state Codable with safe defaults so existing users decode without errors.
- [x] Add storage helpers in `SoberGardenStore` for:
  - marking today as confirmed
  - recording yesterday confirmation
  - resetting the clean streak after user choice
  - updating the check-in streak
- [x] Build the app.
- [ ] Commit: `feat: add check-in state storage`

### Suggested implementation details

Use a small nested struct in `SoberGardenState` instead of spreading the fields across unrelated models. Keep the API simple enough that Home can render from one state object without extra lookups.

---

## Task 2: Define The Today’s Check-in UI State Machine

**Files:**
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInFlowViewController.swift`
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInFeedbackView.swift`

- [x] Define a small state enum for the check-in flow:
  - `todayNotConfirmed`
  - `todayConfirmed`
  - `yesterdayPending`
  - `dailyFlow`
- [ ] Build a lightweight presentation flow that can render:
  - the initial state card
  - the step 1 mood selector
  - the step 2 trigger selector that appears only for hard days
  - the step 3 completion feedback
- [ ] Use UIKit views and SnapKit only; do not introduce a new framework.
- [ ] Keep the flow as a bottom-sheet style experience or a compact modal page, not a full navigation stack.
- [x] Build the app.
- [ ] Commit: `feat: add today check-in flow state machine`

### Suggested implementation details

The flow controller should be reusable from Home and should not own Home layout. Its only job is to collect the daily confirmation and return a result.

---

## Task 3: Add The Today’s Check-in Card To Home

**Files:**
- Create: `SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`

- [x] Add a dedicated `Today’s Check-in` card to the Home scroll stack.
- [x] Render the three required states with exact copy:
  - `How are you holding up today?`
  - `Today protected`
  - `Did you stay clean yesterday?`
- [x] Show the correct buttons for each state:
  - `I’m still clean today`
  - `I’m struggling`
  - `Yes, I stayed clean`
  - `No, I want to reset`
- [x] Place the card above garden, savings, and milestone content so it becomes the main daily interaction.
- [x] Keep the card visually aligned with the existing rounded-card style and padding rhythm.
- [x] Build the app.
- [ ] Commit: `feat: add today check-in home card`

### Suggested implementation details

The card should be driven entirely by a view model or render struct, not by hard-coded branching inside the view controller. Keep the button actions as closures.

---

## Task 4: Wire Today’s Check-in Submission And Feedback

**Files:**
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInFlowViewController.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGTodayCheckInFeedbackView.swift`

- [x] When the user taps `I’m still clean today`, present the flow controller and collect a compact response.
- [x] Show the follow-up trigger selector only when the user chooses `Hard` or `I had urges`.
- [x] After completion, show the confirmation copy:
  - `Nice. Your garden grew a little today.`
  - `You protected another day.`
  - `Your garden grew stronger.`
- [x] Update the Home card to the confirmed state immediately after save.
- [x] Trigger a small visual feedback moment on the garden preview or home card, using only lightweight UIKit animation.
- [x] Build the app.
- [ ] Commit: `feat: wire today check-in confirmation flow`

### Suggested implementation details

Keep the animation subtle. A small glow, alpha pulse, or a short scale pulse is enough. Do not build a full particle system for the first pass.

---

## Task 5: Add Yesterday Follow-Up Logic

**Files:**
- Modify: `SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`

- [x] Detect the case where today is not confirmed but the streak is still active and the previous day has not been acknowledged.
- [x] Render the warm follow-up copy:
  - `Did you stay clean yesterday?`
- [x] Support the two actions:
  - `Yes, I stayed clean`
  - `No, I want to reset`
- [x] On `Yes, I stayed clean`, record the confirmation without resetting the clean streak.
- [x] On `No, I want to reset`, create the appropriate reset record and refresh the Home state.
- [x] Make the copy avoid any language like “missed”, “late”, “make up”, or “补签”.
- [x] Build the app.
- [ ] Commit: `feat: add yesterday confirmation flow`

### Suggested implementation details

This task should keep the streak logic conservative. The user should never lose the clean streak because they skipped opening the app for a day.

---

## Task 6: Add Calm Coach Message Variants For Check-in States

**Files:**
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden/Core/Resources/calm_coach_prompts.json`
- Modify: `SoberGarden/Core/Services/SGCalmCoachService.swift`

- [x] Add prompt variants for:
  - not confirmed today
  - confirmed today
  - yesterday follow-up
  - post-check-in encouragement
- [x] Make sure the prompt system can return a short, state-aware message without sounding repetitive.
- [x] Keep the wording calm and non-medical.
- [x] Avoid introducing any AI terminology in the visible UI.
- [x] Build the app.
- [ ] Commit: `feat: add check-in calm coach prompts`

### Suggested implementation details

The prompts should be small enough to fit comfortably under the Home header and the Today’s Check-in card.

---

## Task 7: Add Check-in Streak Display Outside The Main Hero

**Files:**
- Modify: `SoberGarden/Modules/Journal/SGJournalViewController.swift`
- Modify: `SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Create if needed: `SoberGarden/Modules/Settings/Views/SGCheckInStatsView.swift`

- [x] Expose the check-in streak as secondary information, not the main streak.
- [x] Place it in Journal or Settings rather than on the Home hero.
- [x] Keep the copy simple:
  - `Check-in streak`
  - `Clean streak`
- [x] Make the Home screen continue to prioritize clean streak and daily confirmation.
- [x] Build the app.
- [ ] Commit: `feat: surface check-in streak as secondary stats`

### Suggested implementation details

This task is optional in visual prominence but useful for product completeness. Do not let it replace the main Home streak.

---

## Task 8: Polish Home Layout Spacing And Check-in Card Balance

**Files:**
- Modify: `SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `SoberGarden/Modules/Home/Views/SGHomeHeaderView.swift`
- Modify: `SoberGarden/Core/UI/SGCardView.swift` if padding reuse is needed

- [x] Rebalance the spacing so the Today’s Check-in card does not feel crowded against the header or adjacent cards.
- [x] Ensure the check-in card has readable internal padding on small screens.
- [x] Keep the action buttons visually distinct and easy to tap.
- [x] Make the layout remain stable across compact and regular iPhone sizes.
- [x] Build the app.
- [ ] Commit: `feat: polish home check-in spacing`

### Suggested implementation details

Treat this as a layout pass, not a redesign. Keep the existing style and correct only spacing, hierarchy, and readability issues.

---

## Task 9: Manual Verification On Simulator

**Files:**
- No code changes expected unless a bug is found

- [ ] Run the app in the simulator.
- [ ] Verify the first launch path shows the disclaimer if the user has not acknowledged it.
- [ ] Verify Home shows the correct Today’s Check-in state for:
  - no confirmation yet
  - already confirmed today
  - yesterday pending
- [ ] Verify tapping `I’m still clean today` opens the flow.
- [ ] Verify the flow shows trigger options only for harder days.
- [ ] Verify the post-confirmation state updates correctly.
- [ ] Verify build succeeds after any bug fix.
- [ ] Commit only if code changed.

### Build command

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

---

## Scope Check

This plan is intentionally limited to the Today’s Check-in system and its immediate supporting state. It does not attempt to redesign Rescue, Garden, Journal, or onboarding.

Any larger UI restyling or new data export feature should be split into a separate plan.
