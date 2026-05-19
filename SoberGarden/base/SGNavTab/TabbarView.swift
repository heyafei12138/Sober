//
//  TabbarView.swift
//  ShotPilot
//
//  Created by hebert on 2026/4/9.
//

import Foundation
import UIKit
/// 【代码说明】自定义TabBar回调协议
protocol CustomTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: CustomTabBar, didSelectItemAt index: Int)
}

/// 【代码说明】自定义TabBar视图，提供悬浮式胶囊外观和交互
class CustomTabBar: UIView {
    // MARK: - 属性
    
    public static let barHeight: CGFloat = 60
    
    /// 【代码说明】代理对象
    weak var delegate: CustomTabBarDelegate?
    
    /// 【代码说明】当前选中的索引
    var selectedIndex: Int = 0 {
        didSet {
            updateSelectedItem()
        }
    }
    
    /// 【代码说明】TabBar项数组
    private var tabBarItems: [CustomTabBarItem] = []
    
    /// 【代码说明】主背景容器视图（深色胶囊形状）
    private let backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.10)
        view.layer.cornerRadius = barHeight*0.5
        view.clipsToBounds = false
        
        // 添加阴影效果
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.35
        
        return view
    }()
    
    /// 【代码说明】水平堆栈视图
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 0
        return stack
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI设置
    
    /// 【代码说明】设置UI布局
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(stackView)
        
        backgroundContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(CustomTabBar.barHeight)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12))
        }
    }
    
    // MARK: - 公共方法
    
    /// 【代码说明】配置TabBar项
    /// - Parameter items: TabBar项配置数组，包含标题、普通图片和选中图片
    func configureItems(_ items: [(title: String, normalImage: String, selectedImage: String)]) {
        // 清除旧的视图
        tabBarItems.forEach { $0.removeFromSuperview() }
        tabBarItems.removeAll()
        
        // 创建新的TabBar项
        for (index, item) in items.enumerated() {
            let normalImage = UIImage(named: item.normalImage)
            let selectedImage = UIImage(named: item.selectedImage)
            
            let tabBarItem = CustomTabBarItem(
                title: item.title,
                normalImage: normalImage,
                selectedImage: selectedImage
            )
            
            // 添加点击手势
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
            tabBarItem.addGestureRecognizer(tapGesture)
            tabBarItem.tag = index
            tabBarItem.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(tabBarItem)
            tabBarItems.append(tabBarItem)
        }
        
        // 设置默认选中第一项
        updateSelectedItem()
    }
    
    // MARK: - 私有方法
    
    /// 【代码说明】处理TabBar项点击事件
    @objc private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        
        if index != selectedIndex {
            selectedIndex = index
            delegate?.tabBar(self, didSelectItemAt: index)
            
            // 添加触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    /// 【代码说明】更新选中状态
    private func updateSelectedItem() {
        for (index, item) in tabBarItems.enumerated() {
            item.isSelectedItem = (index == selectedIndex)
        }
    }
}


class CustomTabBarItem: UIView {
    
    // MARK: - 属性
    
    /// 【代码说明】背景容器视图
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    
    /// 【代码说明】内容容器视图，用于包裹图标和标题实现整体居中
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 【代码说明】图标视图
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    /// 【代码说明】标题标签
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    /// 【代码说明】是否被选中
    var isSelectedItem: Bool = false {
        didSet {
            updateAppearance(animated: true)
        }
    }
    
    /// 【代码说明】普通状态图片
    private var normalImage: UIImage?
    
    /// 【代码说明】选中状态图片
    private var selectedImage: UIImage?
    
    /// 【代码说明】标题文字
    private var title: String?
    
    /// 【代码说明】父视图宽度约束
    private var selfWidthConstraint: Constraint?
    
    // MARK: - 初始化
    
    /// 【代码说明】初始化自定义TabBar项
    /// - Parameters:
    ///   - title: 标题文字
    ///   - normalImage: 普通状态图片
    ///   - selectedImage: 选中状态图片
    init(title: String, normalImage: UIImage?, selectedImage: UIImage?) {
        self.title = title
        self.normalImage = normalImage?.withRenderingMode(.alwaysOriginal)
        self.selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 【代码说明】设置UI布局
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.addSubview(contentView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        // 【代码说明】父视图需要有固定高度和宽度，以便StackView正确布局和响应点击
        // 初始宽度设置为44（未选中状态），后续通过updateAppearance更新
        self.snp.makeConstraints { make in
            make.height.equalTo(44)
            // 保存父视图宽度约束引用
            selfWidthConstraint = make.width.equalTo(44).constraint
        }
        
        // 【代码说明】背景视图铺满父视图，使用圆角
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 【代码说明】内容容器视图在背景视图中居中，左右有最小边距
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(0)
            make.right.lessThanOrEqualToSuperview().offset(0)
        }
        
        // 【代码说明】图标在内容容器中：左侧对齐，垂直居中，固定大小
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        // 【代码说明】标题在图标右侧：垂直居中
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // 设置文字不可压缩
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.text = title
        
        // 初始化时设置为隐藏和透明，宽度为0
        titleLabel.alpha = 0.0
        titleLabel.isHidden = true
        
        // 初始化时不执行动画
        updateAppearance(animated: false)
    }
    
    /// 【代码说明】更新视图外观
    /// - Parameter animated: 是否执行动画
    private func updateAppearance(animated: Bool) {
        // 立即更新图标
        iconImageView.image = isSelectedItem ? selectedImage : normalImage
        
        if isSelectedItem {
            // 【代码说明】选中状态：展开宽度，显示标题，contentView作为整体自动居中
            titleLabel.isHidden = false
            titleLabel.text = title
            
            // 计算需要的宽度：图标宽度28 + 间距4 + 标题宽度 + 左右边距各8
            let titleWidth = (title ?? "").size(withAttributes: [.font: titleLabel.font!]).width
            let targetWidth = ceil(28 + 4 + titleWidth + 16 + 4)
            
            // 更新父视图宽度约束
            selfWidthConstraint?.update(offset: targetWidth)
            
            if animated {
                // 执行动画
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                    self.backgroundView.backgroundColor = .red
                    self.titleLabel.alpha = 1.0
                    // 触发布局更新以实现宽度动画
                    self.superview?.layoutIfNeeded()
                }
            } else {
                // 不执行动画，立即更新
                self.backgroundView.backgroundColor = .red
                self.titleLabel.alpha = 1.0
            }
        } else {
            // 【代码说明】未选中状态：收缩宽度到44，隐藏标题，contentView中只有图标自动居中
            
            // 更新父视图宽度约束
            selfWidthConstraint?.update(offset: 44)
            titleLabel.text = ""
            
            if animated {
                // 执行动画
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]) {
                    self.backgroundView.backgroundColor = .clear
                    self.titleLabel.alpha = 0.0
                    // 触发布局更新以实现宽度动画
                    self.superview?.layoutIfNeeded()
                } completion: { finished in
                    // 动画完成后隐藏标题，节省渲染资源
                    if finished && !self.isSelectedItem {
                        self.titleLabel.isHidden = true
                    }
                }
            } else {
                // 不执行动画，立即更新
                self.backgroundView.backgroundColor = .clear
                self.titleLabel.alpha = 0.0
                self.titleLabel.isHidden = true
            }
        }
    }
}

