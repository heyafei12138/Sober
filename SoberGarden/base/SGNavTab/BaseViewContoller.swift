//
//  BaseViewContoller.swift
//  ShotPilot
//
//  Created by hebert on 2026/4/11.
//

import UIKit
import SafariServices

open class BaseViewController: UIViewController {
    
    // MARK: - Navigation
    
    /// 是否隐藏自定义导航栏
    open var isCustomNavigationHidden: Bool = false
    
    /// 是否允许系统侧滑返回
    open var enablesInteractivePopGesture: Bool = false
    
    /// 是否显示右上角操作区
    open var showsRightNavigationActions: Bool = false
    
    /// 是否允许显示 Pro 标识（即使是 VIP 也可以由子类决定不显示）
    open var allowsShowProBadge: Bool = true
    
    /// 是否显示设置按钮
    open var showsSettingsButton: Bool = false

    /// 点击空白区域是否默认收起键盘
    open var enablesTapToDismissKeyboard: Bool = true
    
    /// 自定义导航栏
    open lazy var navigationHeaderView: CustomNavigationBar = {
        let view = CustomNavigationBar()
        return view
    }()
    
    /// 右上角容器
    open lazy var rightActionContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    

    
    /// 设置按钮
    open lazy var settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "setting_icon") ?? UIImage(systemName: "gearshape.fill"), for: .normal)
//        button.tintColor = UIColor.black
//        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.layer.masksToBounds = true
        return button
    }()
    
    open override var title: String? {
        didSet {
            guard isCustomNavigationHidden == false else { return }
            navigationHeaderView.setTitle(title)
        }
    }
    
    // MARK: - Status Bar
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupPageAppearance()
        if enablesTapToDismissKeyboard {
            enableTapToDismissKeyboard()
        }
        setupCustomNavigationIfNeeded()
        setupSubviews()
        bindViewModel()
        bringNavigationChromeToFrontIfNeeded()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshRightNavigationActionsIfNeeded()
        bringNavigationChromeToFrontIfNeeded()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureState()
        fixContainerHeightIfNeeded()
    }
    
    deinit {
        debugPrint("deinit controller >>> \(self)")
    }
   
}

// MARK: - Setup
extension BaseViewController {
    
    private func setupPageAppearance() {
        view.backgroundColor = .white.withAlphaComponent(0.2)
    }
    
    private func setupCustomNavigationIfNeeded() {
        setupRightNavigationActionsIfNeeded()

        guard isCustomNavigationHidden == false else { return }
        
        view.addSubview(navigationHeaderView)
        navigationHeaderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kNavHeight)
        }
        
        navigationHeaderView.onLeftAction = { [weak self] in
            self?.onNavigationBackPressed()
        }
        
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationHeaderView.showLeftButton(
                image: UIImage(named: "back_black") ?? UIImage()
            )
        }

    }
    private func setupRightNavigationActionsIfNeeded() {
        
        
        view.addSubview(rightActionContainerView)
       
        rightActionContainerView.addSubview(settingsButton)
        
        rightActionContainerView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(kStatusBarHeight + 5)
            make.height.equalTo(36)
        }
        
       
        
        settingsButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.right.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        settingsButton.addTarget(self, action: #selector(onSettingsButtonPressed), for: .touchUpInside)
        
       
    }
    open func refreshRightNavigationActionsIfNeeded() {
        
        guard showsRightNavigationActions else {
            rightActionContainerView.isHidden = true
            return
        }
        
       
    }
    @objc open func onSettingsButtonPressed() {
        
       
    }

    @objc open func onProBadgePressed() {
        print("点击了 Pro Badge")
    }
    private func updateInteractivePopGestureState() {
        guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
        if gesture.isEnabled != enablesInteractivePopGesture {
            gesture.isEnabled = enablesInteractivePopGesture
        }
    }
    
    /// 某些场景下导航容器高度异常时做兼容修复
    private func fixContainerHeightIfNeeded() {
        let containerHeight = navigationController?.view.frame.size.height ?? kScreenHeight
        
        guard containerHeight - kScreenHeight == kStatusBarHeight else { return }
        
        navigationController?.viewControllers.forEach { vc in
            vc.view.frame.size.height = kScreenHeight
        }
        navigationController?.view.frame.size.height = kScreenHeight
        
        let rootNav = UIApplication.topViewController() as? UINavigationController
        let rootTab = rootNav?.viewControllers.first as? UITabBarController
        rootTab?.view.frame.size.height = kScreenHeight
    }
    
    /// 子类重写：构建 UI
    @objc open func setupSubviews() { }
    
    /// 子类重写：绑定数据
    @objc open func bindViewModel() { }

    /// 子类在 `setupSubviews` 里铺满 `scrollView` 时会把自定义导航栏盖住，需将导航与右上角操作区提到最前，否则返回按钮无法响应。
    private func bringNavigationChromeToFrontIfNeeded() {
        guard isCustomNavigationHidden == false else { return }
        view.bringSubviewToFront(navigationHeaderView)
        if showsRightNavigationActions, !rightActionContainerView.isHidden {
            view.bringSubviewToFront(rightActionContainerView)
        }
    }
    
    /// 刷新左侧返回按钮
    open func reloadLeftNavigationButtonIfNeeded() {
        guard navigationHeaderView.leftActionButton.isHidden,
              (navigationController?.viewControllers.count ?? 0) > 1 else {
            return
        }
        
        navigationHeaderView.showLeftButton(
            image: UIImage(named: "back_black") ?? UIImage()
        )
    }

}

// MARK: - Action
extension BaseViewController {
    
    /// 默认返回事件，子类可重写
    @objc open func onNavigationBackPressed() {
        popCurrentController()
        
        
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    open func showLoginPageIfNeeded() { }
    
    open func openWebPageInSafari(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
