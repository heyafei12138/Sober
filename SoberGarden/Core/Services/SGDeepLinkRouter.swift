//
//  SGDeepLinkRouter.swift
//  SoberGarden
//

import UIKit

enum SGDeepLinkDestination: Equatable {
    case home
    case rescue
    case garden
    case journal
    case settings
}

final class SGDeepLinkRouter {

    static let shared = SGDeepLinkRouter()

    private init() {}

    func destination(for url: URL) -> SGDeepLinkDestination? {
        guard url.scheme?.lowercased() == "sobergarden" else { return nil }

        let target = [
            url.host,
            url.pathComponents.filter { $0 != "/" }.first
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        .first { !$0.isEmpty }

        switch target {
        case "home":
            return .home
        case "rescue":
            return .rescue
        case "garden":
            return .garden
        case "journal":
            return .journal
        case "settings":
            return .settings
        default:
            return nil
        }
    }

    func route(_ url: URL, from window: UIWindow?) {
        guard let destination = destination(for: url) else { return }
        route(destination, from: window)
    }

    func route(_ destination: SGDeepLinkDestination, from window: UIWindow?) {
        guard let window else { return }

        let tabBarController: MainTabBarController
        if let existing = window.rootViewController as? MainTabBarController {
            tabBarController = existing
        } else {
            let mainController = MainTabBarController()
            window.rootViewController = mainController
            tabBarController = mainController
        }

        switch destination {
        case .home:
            selectTab(0, in: tabBarController)
        case .rescue:
            routeToRescue(in: tabBarController)
        case .garden:
            selectTab(2, in: tabBarController)
        case .journal:
            selectTab(3, in: tabBarController)
        case .settings:
            routeToSettings(in: tabBarController)
        }
    }

    private func selectTab(_ index: Int, in tabBarController: MainTabBarController) {
        tabBarController.dismiss(animated: false)
        tabBarController.setSelectedIndex(index)
        selectedNavigationController(in: tabBarController)?.popToRootViewController(animated: false)
    }

    private func routeToRescue(in tabBarController: MainTabBarController) {
        tabBarController.dismiss(animated: false)
        tabBarController.setSelectedIndex(1)

        guard let navigationController = navigationController(at: 1, in: tabBarController) else { return }
        navigationController.popToRootViewController(animated: false)
        (navigationController.viewControllers.first as? SGRescueViewController)?.startNewSession()
    }

    private func routeToSettings(in tabBarController: MainTabBarController) {
        tabBarController.dismiss(animated: false)
        tabBarController.setSelectedIndex(0)

        guard let navigationController = navigationController(at: 0, in: tabBarController) ?? selectedNavigationController(in: tabBarController) else { return }
        if navigationController.topViewController is SGSettingsViewController { return }

        navigationController.popToRootViewController(animated: false)
        navigationController.pushViewController(SGSettingsViewController(), animated: true)
    }

    private func selectedNavigationController(in tabBarController: MainTabBarController) -> UINavigationController? {
        tabBarController.selectedViewController as? UINavigationController
    }

    private func navigationController(at index: Int, in tabBarController: MainTabBarController) -> UINavigationController? {
        guard let viewControllers = tabBarController.viewControllers,
              viewControllers.indices.contains(index) else {
            return nil
        }
        return viewControllers[index] as? UINavigationController
    }
}
