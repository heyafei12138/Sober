# Sober Garden V2 ASO Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reposition SoberGarden as a sobriety-first product without breaking its existing multi-habit architecture, by introducing a habit-aware recovery language layer, strengthening Rescue as an urge-support flow, unlocking the core Garden promise for free users, and aligning Widget/Watch/share/paywall copy with the new sober-first story.

**Architecture:** Keep the current UIKit + SnapKit app shell, local Codable JSON storage, Widget snapshot pipeline, and Watch companion structure. Implement V2 as a focused copy-and-access refactor around the existing modules instead of building new product surfaces: add a single recovery-language mapping layer, route all habit-sensitive UI text through it, evolve Rescue to capture `urgeBefore` and `urgeAfter`, and narrow Plus gates to advanced features only.

**Tech Stack:** Swift, UIKit, SwiftUI (Watch), SnapKit, Codable local JSON storage, Widget App Group snapshot writer, existing `SGSubscriptionManager`, existing localization string tables.

---

## Requirement Summary

`/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden_v2.md` defines a product repositioning, not a net-new app:

- External positioning becomes sobriety-first: `quit drinking`, `sober days`, `urge support`, `recovery garden`.
- Internal architecture still supports multiple habits: `alcohol`, `smoking`, `vaping`, `porn`, `gambling`, `sugar`, `socialMedia`, `weed`, `custom`.
- The main gaps are expression gaps, not infrastructure gaps:
  - onboarding does not currently bias toward alcohol;
  - Home still uses generic “clean / plant / rainy” semantics;
  - Rescue stores `urgeAfter` flow semantics better than `urgeBefore` flow semantics;
  - Garden’s core promise is partially behind Plus;
  - Journal, Widget, Watch, Share, and Paywall still speak in generic recovery language;
  - localized metadata and in-app strings are not organized around sobriety-first intent.

## Current Project Fit

Current codebase facts from inspection:

- Onboarding flow lives in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift` and already has the exact 8-step structure V2 wants.
- Habit selection already supports all required types in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/Habit.swift`.
- Home is assembled in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/SGHomeViewController.swift` and already contains the right surfaces: header, today card, coach, streak, savings, milestone, garden preview, rescue CTA, share entry.
- Rescue persists `urgeBefore` and `urgeAfter` already in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/RescueSession.swift`, but the UI flow in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueViewController.swift` still starts at emotion and does not make pre/post urge scoring the center of the flow.
- State persistence stays local in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SoberGardenStore.swift` and `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SoberGardenState.swift`; this is the right place to preserve backward compatibility.
- Widget payload is controlled by `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/WidgetSnapshot.swift` and `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`, read by `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/SGWidgetSnapshotReader.swift`.
- Watch home is in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchHomeView.swift`.
- Garden gating is implemented directly in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Garden/SGGardenViewController.swift`.
- Journal history gating is implemented directly in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Journal/SGJournalViewController.swift`.
- Settings already has a habit section and is the natural location for “Sobriety Mode / Habit Mode” explanation in `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Settings/SGSettingsViewController.swift`.

## Scope Decision

### P0 in this plan

- Introduce a centralized recovery-language mapping layer.
- Reorder onboarding habit choices and sober-first copy.
- Apply alcohol-mode copy mapping to Home.
- Rebuild Rescue around `urgeBefore -> support -> urgeAfter`.
- Make the base Garden visible to free users.
- Update core in-app localization keys required for the above.

### P1 in this plan

- Journal free history becomes “latest 3 entries.”
- Widget text becomes habit-aware and rescue-aware.
- Watch home and breathing completion copy align to sober-first mode.
- Share preview and paywall messaging align to “recovery with Plus,” not “recovery only with Plus.”
- Settings gets lightweight mode-mapping explanation.

### P2 outside this plan

- App Store metadata submission itself.
- Screenshot production assets.
- Complex analytics dashboards.
- New backend or cloud sync work.
- New account or community capabilities.

## File Map

### Core language and state

- Create: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/SGRecoveryLanguage.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/Habit.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/RescueSession.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SGCalmCoachService.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/WidgetSnapshot.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/SGWidgetSnapshotReader.swift`

### Onboarding

- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingDraft.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingStepView.swift`

### Home and rescue

- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGHomeHeaderView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGSavedStatsView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGMilestoneCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGGardenPreviewView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueDraft.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/Views/SGEmotionPickerView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/Views/SGCoachMessageView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/Views/SGBreathingExerciseView.swift`

### Garden, Journal, Settings, Subscription, Share

- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Garden/SGGardenViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Journal/SGJournalViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Settings/SGSettingsViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Subscription/SGSubscriptionPaywallViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Share/SGProgressShareCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Share/SGSharePreviewViewController.swift`

### Widget / Watch / localization

- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/SoberGardenWidgetViews.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchHomeView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchBreathingView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/en.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/zh-Hans.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/zh-HK.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/es.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/ja.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/en.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/zh-Hans.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/zh-HK.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/es.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/ja.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/en.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/zh-Hans.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/zh-HK.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/es.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/ja.lproj/Localizable.strings`

---

### Task 1: Add A Recovery Language Mapping Layer

**Files:**
- Create: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/SGRecoveryLanguage.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/Habit.swift`

- [ ] Define a single mapping model that converts `HabitType` into habit-aware copy tokens instead of scattering `if habit.type == .alcohol` checks across view controllers.
- [ ] Include at minimum these mapped concepts:
  - `dayUnitTitle`
  - `streakTitle`
  - `primaryCheckInAction`
  - `setbackAction`
  - `urgeTitle`
  - `journeyTitle`
  - `gardenTitle`
  - `homeStatusTitle`
  - `homeStatusSubtitle`
  - `coachContextPrefix`
- [ ] Add helper APIs on `HabitType` and `Habit`:
  - `var isSobrietyFocused: Bool`
  - `var recoveryLanguage: SGRecoveryLanguage`
- [ ] Make the alcohol mapping use sober-first text:
  - `Sober Days`
  - `Mark Today Sober`
  - `I had a setback`
  - `craving`
  - `sober journey`
  - `recovery garden`
- [ ] Keep non-alcohol mapping generic:
  - `Clean Days`
  - `Plant Today`
  - `I had a setback`
  - `urge`
  - `recovery journey`
  - `garden`
- [ ] Verify no persisted data shape changes are introduced in this task.

**Verification**

- [ ] Run:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: build succeeds and no file outside the language-mapping surface requires changes yet.

### Task 2: Rework Onboarding Into A Sobriety-First Entry Path

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Onboarding/SGOnboardingDraft.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/en.lproj/Localizable.strings`

- [ ] Reorder the habit grid so `alcohol` appears first, followed by `smoking`, `vaping`, `porn`, `gambling`, `sugar`, `socialMedia`, `weed`, `custom`.
- [ ] Update onboarding copy to match the V2 structure without changing the step count:
  - Welcome: gentle sobriety tracker framing
  - Habit: alcohol-first and “other habits supported” framing
  - Start date: `When did your sober journey begin?` for alcohol mode
  - Cost / time / reasons / notifications / complete copy aligned to the V2 document
- [ ] Keep the existing draft and persistence flow intact; this is a copy-and-ordering change, not a form architecture change.
- [ ] Preserve custom habit support and avoid introducing alcohol-specific persistence fields.
- [ ] Confirm that the app still routes to onboarding when `state.habit == nil`.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Simulator smoke test:
  - fresh install opens onboarding;
  - alcohol is first in the habit picker;
  - complete flow persists selected habit and lands in main tabs.

### Task 3: Convert Home Into Habit-Aware Sober-First Messaging

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGHomeHeaderView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGTodayCheckInCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGSavedStatsView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGMilestoneCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/Views/SGGardenPreviewView.swift`

- [ ] Thread `recoveryLanguage` into Home render paths instead of hardcoded “clean / plant” strings.
- [ ] In alcohol mode, Home top status should communicate:
  - `Day N Sober`
  - `Alcohol-free and still growing`
  - `Your recovery garden is taking root`
- [ ] In non-alcohol mode, keep generic variants:
  - `Day N Clean`
  - `Still growing, one day at a time`
- [ ] Update the today card primary CTA:
  - alcohol mode -> `Mark Today Sober`
  - generic mode -> `Plant Today`
- [ ] Keep setback semantics gentle and non-shaming; do not use “failed” or “relapsed” as primary CTA language.
- [ ] Update garden preview framing so sober progress leads and garden reward follows.
- [ ] Keep current streak calculations and daily record mechanics unchanged in this task; only the expression layer should move.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Simulator smoke test:
  - select alcohol habit -> Home shows sober-first text;
  - switch to non-alcohol habit -> Home falls back to generic recovery text;
  - today card action labels change with habit type.

### Task 4: Rebuild Rescue Around Pre/Post Urge Scoring

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueDraft.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/RescueSession.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SoberGardenStore.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/Views/SGEmotionPickerView.swift`

- [ ] Change Rescue flow order from:
  - emotion -> coach -> breathing -> reasons -> delay -> feedback
  into:
  - urgeBefore -> emotion -> breathing -> reasons -> delay -> urgeAfter -> completion
- [ ] Make `urgeBefore` a first-class required input for the happy path, but keep stored model fields optional so legacy data still decodes.
- [ ] Add `var urgeReduction: Int?` on `RescueSession`.
- [ ] Ensure `SoberGardenStore.saveRescueSession(...)` persists both `urgeBefore` and `urgeAfter`.
- [ ] Update completion messaging:
  - if `urgeAfter < urgeBefore`, show the drop count;
  - else show “you paused before acting” style copy.
- [ ] Keep Rescue core free. Do not add new paywall blocks in this flow.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Simulator smoke test:
  - open Rescue from Home;
  - enter `urgeBefore`;
  - complete breathing and delay;
  - enter `urgeAfter`;
  - verify the saved session contains both values after app relaunch.

### Task 5: Expand Calm Coach Context For Sobriety Moments

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Services/SGCalmCoachService.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Resources/calm_coach_prompts.json`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Home/SGHomeViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Rescue/SGRescueViewController.swift`

- [ ] Add sober-specific context keys:
  - `sobrietyMorning`
  - `cravingMoment`
  - `postSetback`
  - `milestoneSober`
  - `nightReflection`
- [ ] Route alcohol-mode Home and Rescue surfaces to these contexts when appropriate.
- [ ] Keep coach generation local-only; no network or remote AI dependencies should be introduced.
- [ ] Keep all prompts supportive, non-medical, and non-diagnostic.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Manually trigger Home and Rescue coaching states and confirm sober-specific prompts appear for alcohol habit.

### Task 6: Make Base Garden Free And Move Plus To Enhancements

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Garden/SGGardenViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Subscription/SGSubscriptionPaywallViewController.swift`

- [ ] Remove the full-screen Garden lock for free users.
- [ ] Keep advanced Plus value around:
  - deeper insights
  - customization
  - full journal history
  - milestone reminders
  - advanced sharing
- [ ] Update Garden text to `Recovery Garden` framing in alcohol mode.
- [ ] Preserve existing garden stage and milestone calculations; this task changes access boundaries and copy, not progression math.
- [ ] Ensure free users can see stage illustration, progress, and core garden copy.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Free-user smoke test:
  - Garden tab opens without paywall overlay blocking the main content;
  - Plus upsell remains accessible from enhancement entry points.

### Task 7: Relax Journal History Gate To Latest 3 Entries

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Journal/SGJournalViewController.swift`

- [ ] Keep today entry creation free as-is.
- [ ] For non-Plus users, render the latest 3 history entries instead of a full gate wall.
- [ ] Move the Plus gate below those entries to upsell unlimited history and advanced stats.
- [ ] Keep Plus users at the existing larger history window unless a separate pagination task is planned later.
- [ ] Update history header and empty-state copy to support “reflect without shame” messaging.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Create 4+ entries in simulator state and confirm a free user sees 3 items plus an upsell.

### Task 8: Make Widget Snapshot And Widget Views Habit-Aware

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Core/Models/WidgetSnapshot.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/WidgetShared/SGWidgetSnapshotWriter.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/SGWidgetSnapshotReader.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWidgets/SoberGardenWidgetViews.swift`

- [ ] Extend widget snapshot data with enough language information to render sober-first labels without duplicating app logic in the extension.
- [ ] In alcohol mode, widget strings should support:
  - `N Days Sober`
  - `Today: Mark sober`
  - `Your recovery garden`
  - `Urge hitting?`
  - `Open Rescue`
  - `Breathe for 60 seconds`
- [ ] Keep widget deep links unchanged:
  - `sobergarden://home`
  - `sobergarden://garden`
  - `sobergarden://rescue`
- [ ] Maintain backward compatibility when old snapshots are decoded.

**Verification**

- [ ] Build app and widget target:

```bash
xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: main app and widget compile cleanly.

### Task 9: Update Watch Copy For Sober-First Mode

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchHomeView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchBreathingView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGardenWatch/SGWatchSnapshotReader.swift`

- [ ] In alcohol mode, watch home should render:
  - `N Days Sober`
  - `Next: <milestone>`
  - `I'm Struggling`
- [ ] Keep the quick breathing entry prominent; this is the actual watch differentiator.
- [ ] Update breathing completion copy to “You paused. That counts.”
- [ ] Reuse widget/watch snapshot payload where possible instead of inventing a new watch-only data model.

**Verification**

- [ ] Build watch target via the main scheme build.
- [ ] Confirm watch strings update from shared snapshot data and do not regress generic habit mode.

### Task 10: Align Share, Paywall, And Settings To The New Story

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Share/SGProgressShareCardView.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Share/SGSharePreviewViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Subscription/SGSubscriptionPaywallViewController.swift`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Modules/Settings/SGSettingsViewController.swift`

- [ ] Update share preview copy so a free user can create and preview a basic sobriety/recovery share card.
- [ ] Keep premium share differentiation in templates and customization, not in the existence of sharing itself.
- [ ] Update paywall hero and benefits to frame Plus as “deeper support and personalization,” not as the prerequisite for recovery.
- [ ] Add a small Settings explanation row describing how Alcohol uses sobriety-first wording while other habits keep generic recovery wording.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Smoke test:
  - share preview opens for free user;
  - paywall messaging still fits existing UI;
  - settings renders the new explanation row without layout breakage.

### Task 11: Complete Minimum Localization Coverage For V2

**Files:**
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/en.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/zh-Hans.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/zh-HK.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/es.lproj/Localizable.strings`
- Modify: `/Users/mac/Desktop/project/2026/SoberGarden/SoberGarden/Helper/ja.lproj/Localizable.strings`
- Modify corresponding Widget and Watch `Localizable.strings` files.

- [ ] Add all new keys required by Tasks 1-10 in English first.
- [ ] Add minimum translations or fallback strings for simplified Chinese, traditional Chinese, Spanish, and Japanese.
- [ ] Keep key names grouped by module:
  - `onboarding.*`
  - `home.*`
  - `rescue.*`
  - `garden.*`
  - `journal.*`
  - `subscription.*`
  - `widget.*`
  - `watch.*`
  - `settings.*`
- [ ] Avoid editing App Store Connect metadata in code; this task is for in-app and extension string coverage only.

**Verification**

- [ ] Build with the same `xcodebuild` command.
- [ ] Manual language smoke:
  - switch app language in Settings;
  - confirm new sober-first strings resolve instead of falling back to raw localization keys.

---

## Cross-Cutting Risks

1. **Copy logic fragmentation**
   - If copy mapping is embedded directly in each screen, V2 will become expensive to maintain.
   - Mitigation: finish Task 1 before changing UI modules.

2. **Widget / Watch backward compatibility**
   - Snapshot schema changes can break extensions if decoding is strict.
   - Mitigation: add new fields as optional or with defaults and preserve old keys.

3. **Free / Plus boundary regressions**
   - Existing gating is hardcoded in Garden and Journal screens.
   - Mitigation: verify free-user flows explicitly after each entitlement-related task.

4. **Localization drift**
   - V2 introduces many copy changes across App, Widget, and Watch.
   - Mitigation: batch new keys once, then update all consumers against those keys.

## Recommended Execution Order

1. Task 1 `Recovery language layer`
2. Task 2 `Onboarding`
3. Task 3 `Home`
4. Task 4 `Rescue flow`
5. Task 5 `Calm Coach`
6. Task 6 `Garden free access`
7. Task 7 `Journal free 3`
8. Task 8 `Widget`
9. Task 9 `Watch`
10. Task 10 `Share + Paywall + Settings`
11. Task 11 `Localization sweep`

This order keeps the highest-impact ASO/product-expression changes first and delays wider extension surfaces until the app-side language model is stable.

## Acceptance Checklist

- [ ] Selecting `Alcohol` leads to sober-first wording on onboarding completion and Home.
- [ ] Home primary CTA becomes `Mark Today Sober` in alcohol mode.
- [ ] Rescue captures and persists both `urgeBefore` and `urgeAfter`.
- [ ] Garden core content is visible for free users.
- [ ] Free users can view at least 3 Journal history items.
- [ ] Widget copy follows habit type and keeps deep links working.
- [ ] Watch copy follows habit type and keeps breathing shortcut prominent.
- [ ] Paywall sells deeper support, not access to the basic recovery promise.
- [ ] Existing stored state continues to load without migration failure.
- [ ] New copy remains supportive, non-medical, and non-shaming.

## Non-Code Work To Track Separately

- App Store Connect:
  - App Name
  - Subtitle
  - Keywords
  - Promotional Text
- Screenshot redesign and export
- Localized App Store metadata QA

These belong to the release checklist, not the in-repo implementation tasks above.
