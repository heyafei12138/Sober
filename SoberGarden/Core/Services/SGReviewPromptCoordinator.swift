//
//  SGReviewPromptCoordinator.swift
//  SoberGarden
//

import StoreKit
import UIKit

enum SGReviewPromptTrigger {
    case secondColdStartToday
    case rescueCompleted
    case posterShared
}

private extension UIViewController {
    func sgTopMostViewController() -> UIViewController {
        if let presentedViewController {
            return presentedViewController.sgTopMostViewController()
        }

        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.sgTopMostViewController() ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.sgTopMostViewController() ?? tabBarController
        }

        return self
    }
}

final class SGReviewPromptCoordinator {

    static let shared = SGReviewPromptCoordinator()

    private enum DefaultsKey {
        static let hasChosenAppStoreReview = "sg.reviewPrompt.hasChosenAppStoreReview"
        static let coldStartDay = "sg.reviewPrompt.coldStartDay"
        static let coldStartCount = "sg.reviewPrompt.coldStartCount"
        static let lastPresentedAt = "sg.reviewPrompt.lastPresentedAt"
    }

    private let defaults: UserDefaults
    private var isPresenting = false
    private var didRecordColdStartForSession = false
    private var cachedReviewURL: URL?

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func recordColdStartAndPromptIfNeeded(from presenter: UIViewController?) {
        guard !didRecordColdStartForSession else { return }
        didRecordColdStartForSession = true

        let dayKey = Self.dayKey(for: Date())
        if defaults.string(forKey: DefaultsKey.coldStartDay) == dayKey {
            defaults.set(defaults.integer(forKey: DefaultsKey.coldStartCount) + 1, forKey: DefaultsKey.coldStartCount)
        } else {
            defaults.set(dayKey, forKey: DefaultsKey.coldStartDay)
            defaults.set(1, forKey: DefaultsKey.coldStartCount)
        }

        guard defaults.integer(forKey: DefaultsKey.coldStartCount) == 2 else { return }
        promptIfNeeded(trigger: .secondColdStartToday, from: presenter)
    }

    func promptIfNeeded(trigger: SGReviewPromptTrigger, from presenter: UIViewController?) {
        guard shouldPrompt else { return }
        guard let presenter = presenter?.sgTopMostViewController() else { return }
        guard presenter.presentedViewController == nil else { return }
        isPresenting = true
        defaults.set(Date().timeIntervalSince1970, forKey: DefaultsKey.lastPresentedAt)

        let promptViewController = SGReviewPromptViewController(
            onRate: { [weak self, weak presenter] in
                self?.openReview(from: presenter)
            },
            onFeedback: { [weak self, weak presenter] in
                self?.isPresenting = false
                guard let presenter else { return }
                DispatchQueue.main.async {
                    SGFeedbackMailPresenter.shared.presentFeedback(from: presenter.sgTopMostViewController())
                }
            },
            onDismiss: { [weak self] in
                self?.isPresenting = false
            }
        )

        presenter.present(promptViewController, animated: false)
    }

    private var shouldPrompt: Bool {
        guard !isPresenting else { return false }
        guard !defaults.bool(forKey: DefaultsKey.hasChosenAppStoreReview) else { return false }

        let lastPresentedAt = defaults.double(forKey: DefaultsKey.lastPresentedAt)
        guard lastPresentedAt == 0 || Date().timeIntervalSince1970 - lastPresentedAt > 60 else {
            return false
        }

        return true
    }

    private func openReview(from presenter: UIViewController?) {
        defaults.set(true, forKey: DefaultsKey.hasChosenAppStoreReview)
        isPresenting = false
        JKGlobalTools.evaluationInAppStore(appid: "6771756706")
        
    }


    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
