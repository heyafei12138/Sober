//
//  CustomViewCOntroller.swift
//  ShotPilot
//
//  Created by hebert on 2026/4/9.
//
import UIKit
import Foundation
/// 【代码说明】主TabBar控制器，管理应用的四个主要页面
class MainTabBarController: UITabBarController {
    
    // MARK: - 属性
    
    /// 【代码说明】自定义TabBar视图
    private let customTabBar = CustomTabBar()
    private var hasCheckedInfoDeclaration = false
    
    // MARK: - 静态方法
    
    /// 【代码说明】获取当前活跃的导航控制器
    /// - Returns: 当前活跃的导航控制器，如果不存在则返回nil
    static func getCurrentNavigationController() -> UINavigationController? {
        // 获取当前窗口场景
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            
            return nil
        }
        
        // 获取根视图控制器
        guard let rootViewController = keyWindow.rootViewController else {
            
            return nil
        }
        
        // 如果根视图控制器是TabBarController
        if let tabBarController = rootViewController as? MainTabBarController {
            // 获取当前选中的视图控制器
            if let selectedViewController = tabBarController.selectedViewController as? UINavigationController {
                return selectedViewController
            }
        }
        // 如果根视图控制器是NavigationController
        else if let navigationController = rootViewController as? UINavigationController {
            return navigationController
        }
        // 如果根视图控制器有导航控制器
        else if let navigationController = rootViewController.navigationController {
            return navigationController
        }
        
        return nil
    }
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupCustomTabBar()
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentInfoDeclarationIfNeeded()
    }
    
    /// 【代码说明】设置TabBar的外观
    private func setupAppearance() {
        // 隐藏系统TabBar
        tabBar.isUserInteractionEnabled = false
        tabBar.isHidden = true
        view.bringSubviewToFront(customTabBar)
    }
    
    /// 【代码说明】设置四个主要视图控制器
    private func setupViewControllers() {
        let homeNav = createNavigationController(for: SGHomeViewController())
        let rescueNav = createNavigationController(for: SGRescueViewController())
        let gardenNav = createNavigationController(for: SGGardenViewController())
        let journalNav = createNavigationController(for: SGJournalViewController())

        viewControllers = [homeNav, rescueNav, gardenNav, journalNav]
    }
    
    /// 【代码说明】创建导航控制器并配置TabBar项
    private func createNavigationController(for rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.delegate = self
        rootViewController.title = ""
        return navController
    }
    
    /// 【代码说明】设置自定义TabBar
    private func setupCustomTabBar() {
        // 添加自定义TabBar到视图
        view.addSubview(customTabBar)
        customTabBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(CustomTabBar.barHeight)
        }
        
        // 配置TabBar项
        let items: [(title: String, systemImage: String, selectedSystemImage: String)] = [
            ("tab.home".localized(), "house", "house.fill"),
            ("tab.rescue".localized(), "lifepreserver", "lifepreserver.fill"),
            ("tab.garden".localized(), "leaf", "leaf.fill"),
            ("tab.journal".localized(), "book", "book.fill"),
        ]
        
        customTabBar.configureItems(items)
        customTabBar.delegate = self
        
        // 设置默认选中第一项
        customTabBar.selectedIndex = 0
    }
    
    /// 【代码说明】统一切换Tab，确保系统selectedIndex与自定义Tab同步
    func setSelectedIndex(_ index: Int) {
        let safeIndex = max(0, min(index, (viewControllers?.count ?? 1) - 1))
        selectedIndex = safeIndex
        customTabBar.selectedIndex = safeIndex
    }

    private func presentInfoDeclarationIfNeeded() {
        guard hasCheckedInfoDeclaration == false else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.presentedViewController == nil else { return }
            self.hasCheckedInfoDeclaration = true
        }
    }
}

// MARK: - TFTCustomTabBarDelegate

extension MainTabBarController:CustomTabBarDelegate {
    /// 【代码说明】处理TabBar项选择事件
    func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int) {
        selectedIndex = index
    }
}

// MARK: - UINavigationControllerDelegate

extension MainTabBarController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        /// 控制自定义tabbar的展示隐藏
        let hideTab: Bool = navigationController.viewControllers.count > 1
        self.customTabBar.isHidden = hideTab
    }
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        /// 控制自定义tabbar的展示隐藏
//        let hideTab: Bool = navigationController.viewControllers.count > 1
//        self.customTabBar.isHidden = hideTab
    }
}
