//
//  SGAppLockService.swift
//  SoberGarden
//

import LocalAuthentication
import UIKit

final class SGAppLockService {

    static let shared = SGAppLockService()

    private var isAuthenticating = false
    private var lastSuccessfulAuthenticationDate: Date?
    private var pendingCompletions: [(Bool) -> Void] = []

    private init() {}

    var isEnabled: Bool {
        SoberGardenStore.shared.state.settings.appLockEnabled
    }

    func authenticateForEnable(completion: @escaping (Bool) -> Void) {
        authenticate(reason: "Unlock SoberGarden to enable App Lock.", completion: completion)
    }

    func authenticateIfNeeded(reason: String = "Unlock SoberGarden.", completion: @escaping (Bool) -> Void) {
        guard isEnabled, SoberGardenStore.shared.state.habit != nil else {
            completion(true)
            return
        }

        if let lastSuccessfulAuthenticationDate,
           Date().timeIntervalSince(lastSuccessfulAuthenticationDate) < 2 {
            completion(true)
            return
        }

        authenticate(reason: reason, completion: completion)
    }

    private func authenticate(reason: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticating {
            pendingCompletions.append(completion)
            return
        }

        isAuthenticating = true
        pendingCompletions = [completion]

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            finishAuthentication(success: false)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.finishAuthentication(success: success)
            }
        }
    }

    private func finishAuthentication(success: Bool) {
        isAuthenticating = false
        if success {
            lastSuccessfulAuthenticationDate = Date()
        }

        let completions = pendingCompletions
        pendingCompletions.removeAll()
        completions.forEach { $0(success) }
    }
}
