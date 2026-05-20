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
}
