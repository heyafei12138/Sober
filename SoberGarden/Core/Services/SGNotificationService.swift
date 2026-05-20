//
//  SGNotificationService.swift
//  SoberGarden
//

import Foundation
import UserNotifications

final class SGNotificationService {

    static let shared = SGNotificationService()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                debugPrint("Notification authorization failed: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func fetchAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func scheduleRescueDelayReminder(after timeInterval: TimeInterval = 10 * 60) {
        let content = UNMutableNotificationContent()
        content.title = "Check in with yourself"
        content.body = "Ten minutes passed. Notice whether the urge softened before you choose."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "rescue_delay_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        requestAuthorization { granted in
            guard granted else { return }
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    debugPrint("Failed to schedule rescue delay reminder: \(error)")
                }
            }
        }
    }
}
