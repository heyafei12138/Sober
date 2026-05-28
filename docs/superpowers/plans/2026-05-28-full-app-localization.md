# Full App Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Localize all user-facing SoberGarden app text through Localize-Swift and complete the nine `Localizable.strings` files.

**Architecture:** Keep Localize-Swift as the runtime source of truth. Replace visible labels, buttons, alerts, notification bodies, share-card copy, accessibility copy, and user-facing enum display names with `.localized()` keys while leaving internal identifiers, asset names, SF Symbols, routes, colors, URLs, debug logs, and persistence keys untouched. Use format strings for dynamic text.

**Tech Stack:** UIKit, SnapKit, Localize-Swift, CocoaPods, Xcode build validation.

---

### Task 1: Localize Shared Display Models

**Files:**
- Modify: `SoberGarden/Core/Models/Habit.swift`
- Modify: `SoberGarden/Core/Models/Milestone.swift`
- Modify: `SoberGarden/Modules/Onboarding/SGOnboardingDraft.swift`
- Modify: `SoberGarden/Modules/Rescue/SGRescueDraft.swift`

- [ ] Convert enum `displayName`, `title`, and option labels to localized keys.
- [ ] Keep raw values and persistence-facing fields unchanged.
- [ ] Build to verify references still compile.

### Task 2: Localize Main Screens

**Files:**
- Modify: `SoberGarden/base/SGNavTab/MainTabBarController.swift`
- Modify: `SoberGarden/Modules/Home/**/*.swift`
- Modify: `SoberGarden/Modules/Onboarding/*.swift`
- Modify: `SoberGarden/Modules/Rescue/**/*.swift`
- Modify: `SoberGarden/Modules/Garden/**/*.swift`
- Modify: `SoberGarden/Modules/Journal/**/*.swift`

- [ ] Replace visible strings with `.localized()` or localized format strings.
- [ ] Preserve image names, SF Symbol names, animation keys, and debug strings.
- [ ] Build to verify compile-time coverage.

### Task 3: Localize Settings, Subscription, Share, Notifications

**Files:**
- Modify: `SoberGarden/Modules/Settings/**/*.swift`
- Modify: `SoberGarden/Modules/Subscription/SGSubscriptionPaywallViewController.swift`
- Modify: `SoberGarden/Modules/Share/*.swift`
- Modify: `SoberGarden/Core/Services/SGNotificationService.swift`
- Modify: `SoberGarden/Core/Services/SGAppLockService.swift`
- Modify: `SoberGarden/Core/Services/SGCalmCoachService.swift`

- [ ] Localize all settings rows, alerts, guide text, paywall copy, share copy, notification copy, app-lock prompt, and fallback coach prompts.
- [ ] Keep service identifiers and product identifiers unchanged.
- [ ] Build to verify compile-time coverage.

### Task 4: Complete Translation Resources

**Files:**
- Modify: `SoberGarden/Helper/en.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/zh-Hans.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/zh-HK.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/ja.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/ko.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/de.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/fr.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/it.lproj/Localizable.strings`
- Modify: `SoberGarden/Helper/es.lproj/Localizable.strings`

- [ ] Add every new localization key to every language file.
- [ ] Preserve `%@`, `%d`, and other format placeholders consistently across languages.
- [ ] Run Xcode build so `CopyStringsFile --validate` checks resource syntax.

### Task 5: Verification

- [ ] Run `xcodebuild -workspace SoberGarden.xcworkspace -scheme SoberGarden -destination 'generic/platform=iOS Simulator' build`.
- [ ] Scan remaining hardcoded Swift strings and manually classify nonlocalized survivors as internal/resource strings.
- [ ] Report remaining known limitations, if any.
