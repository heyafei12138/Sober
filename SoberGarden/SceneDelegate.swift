//
//  SceneDelegate.swift
//  SoberGarden
//
//  Created by hebert on 2026/5/19.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var pendingDeepLinkURL: URL?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let state = SoberGardenStore.shared.load()

        window.rootViewController = state.habit == nil
            ? SGOnboardingViewController()
            : MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window

        if let urlContext = connectionOptions.urlContexts.first {
            routeAfterUnlock(urlContext.url)
        }
    }

    func showMainInterface(animated: Bool = true) {
        guard let window else { return }
        let mainController = MainTabBarController()
        guard animated else {
            window.rootViewController = mainController
            return
        }
        UIView.transition(with: window, duration: 0.28, options: .transitionCrossDissolve) {
            window.rootViewController = mainController
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        routeAfterUnlock(urlContext.url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        SGReviewPromptCoordinator.shared.recordColdStartAndPromptIfNeeded(from: window?.rootViewController)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        SGAppLockService.shared.authenticateIfNeeded { [weak self] success in
            guard success else { return }
            self?.routePendingDeepLinkIfNeeded()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func routeAfterUnlock(_ url: URL) {
        pendingDeepLinkURL = url
        SGAppLockService.shared.authenticateIfNeeded(reason: "appLock.unlockReason".localized()) { [weak self] success in
            guard success else {
                self?.pendingDeepLinkURL = nil
                return
            }
            self?.routePendingDeepLinkIfNeeded()
        }
    }

    private func routePendingDeepLinkIfNeeded() {
        guard let pendingDeepLinkURL else { return }
        self.pendingDeepLinkURL = nil
        SGDeepLinkRouter.shared.route(pendingDeepLinkURL, from: window)
    }
}
