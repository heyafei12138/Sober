//
//  SGNotificationService.swift
//  SoberGarden
//

import Foundation
import UserNotifications

final class SGNotificationService: NSObject {

    static let shared = SGNotificationService()

    enum Identifier {
        static let dailyReminder = "sg.notification.dailyReminder"
        static let milestone = "sg.notification.milestone"
        static let nightReminder = "sg.notification.nightReminder"
        static let rescueDelay = "sg.notification.rescueDelay"
        static let test = "sg.notification.test"

        static let scheduledIdentifiers: [String] = [
            dailyReminder,
            milestone,
            nightReminder
        ]
    }

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
    }

    func configure() {
        center.delegate = self
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                debugPrint("Notification authorization failed: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func fetchAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func rescheduleNotifications(for state: SoberGardenState = SoberGardenStore.shared.state) {
        center.removePendingNotificationRequests(withIdentifiers: Identifier.scheduledIdentifiers)

        guard state.habit != nil else { return }
        let isPlus = SGSubscriptionManager.shared.isPlus

        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            guard settings.authorizationStatus.allowsScheduling else { return }

            if state.settings.dailyReminderEnabled {
                self.scheduleDailyReminder(time: state.settings.dailyReminderTime)
            }

            guard isPlus else { return }

            if state.settings.nightReminderEnabled {
                self.scheduleNightReminder(time: state.settings.nightReminderTime)
            }

            if state.settings.milestoneNotificationsEnabled,
               let request = self.makeMilestoneRequest(for: state) {
                self.add(request)
            }
        }
    }

    func cancelScheduledNotifications() {
        center.removePendingNotificationRequests(
            withIdentifiers: Identifier.scheduledIdentifiers + [Identifier.rescueDelay, Identifier.test]
        )
    }

    func scheduleRescueDelayReminder(after timeInterval: TimeInterval = 10 * 60) {
        guard SoberGardenStore.shared.state.settings.rescueDelayReminderEnabled else { return }
        guard SGSubscriptionManager.shared.isPlus else { return }

        let content = UNMutableNotificationContent()
        content.title = "notification.rescueDelay.title".localized()
        content.body = "notification.rescueDelay.body".localized()
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: Identifier.rescueDelay,
            content: content,
            trigger: trigger
        )

        requestAuthorization { granted in
            guard granted else { return }
            self.center.removePendingNotificationRequests(withIdentifiers: [Identifier.rescueDelay])
            self.add(request)
        }
    }

    func scheduleTestNotification(after timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = "notification.generic.title".localized()
        content.body = "notification.generic.body".localized()
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false)
        let request = UNNotificationRequest(
            identifier: Identifier.test,
            content: content,
            trigger: trigger
        )

        requestAuthorization { granted in
            guard granted else { return }
            self.center.removePendingNotificationRequests(withIdentifiers: [Identifier.test])
            self.add(request)
        }
    }

    private func scheduleDailyReminder(time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "notification.generic.title".localized()
        content.body = "notification.generic.body".localized()
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: normalizedTimeComponents(time), repeats: true)
        let request = UNNotificationRequest(
            identifier: Identifier.dailyReminder,
            content: content,
            trigger: trigger
        )

        add(request)
    }

    private func scheduleNightReminder(time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "notification.generic.title".localized()
        content.body = "notification.night.body".localized()
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: normalizedTimeComponents(time), repeats: true)
        let request = UNNotificationRequest(
            identifier: Identifier.nightReminder,
            content: content,
            trigger: trigger
        )

        add(request)
    }

    private func makeMilestoneRequest(for state: SoberGardenState) -> UNNotificationRequest? {
        guard let habit = state.habit else { return nil }

        let calendar = Calendar.current
        let cleanDays = SGProgressCalculator.currentStreakDays(startDate: habit.startDate, calendar: calendar)
        guard let milestone = SGProgressCalculator.nextMilestone(for: cleanDays),
              var milestoneDate = calendar.date(byAdding: .day, value: milestone.day - 1, to: habit.startDate) else {
            return nil
        }

        let reminderTime = normalizedTimeComponents(state.settings.dailyReminderTime)
        milestoneDate = calendar.date(
            bySettingHour: reminderTime.hour ?? 9,
            minute: reminderTime.minute ?? 0,
            second: 0,
            of: milestoneDate
        ) ?? milestoneDate

        guard milestoneDate > Date() else { return nil }

        let content = UNMutableNotificationContent()
        content.title = "notification.milestone.title".localized()
        content.body = "notification.milestone.body".localizedFormat(milestone.day)
        content.sound = .default

        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: milestoneDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        return UNNotificationRequest(
            identifier: Identifier.milestone,
            content: content,
            trigger: trigger
        )
    }

    private func normalizedTimeComponents(_ components: DateComponents) -> DateComponents {
        DateComponents(hour: components.hour ?? 9, minute: components.minute ?? 0)
    }

    private func add(_ request: UNNotificationRequest) {
        center.add(request) { error in
            if let error {
                debugPrint("Failed to schedule notification \(request.identifier): \(error)")
            } else {
                #if DEBUG
                debugPrint("Scheduled notification \(request.identifier)")
                #endif
            }
        }
    }
}

extension SGNotificationService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

private extension UNAuthorizationStatus {
    var allowsScheduling: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}
