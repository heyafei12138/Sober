//
//  CustomNavigationBar.swift
//  ShotPilot
//
//  Created by hebert on 2026/4/11.
//


import UIKit


open class CustomNavigationBar: UIView {
    
    // MARK: - Callback
    
    public var onLeftAction: (() -> Void)?
    public var onRightAction: (() -> Void)?
    
    // MARK: - UI
    
    public private(set) lazy var backgroundColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public private(set) lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.isHidden = true
        return label
    }()
    
    public private(set) lazy var leftActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(handleLeftButtonTapped), for: .touchUpInside)
        return button
    }()
    
    public private(set) lazy var rightActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(handleRightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor =  .hexString("#DDDDDD")
        return view
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: CGFloat(kNavHeight)))
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeUI()
    }
}

// MARK: - Setup
private extension CustomNavigationBar {
    
    func initializeUI() {
        backgroundColor = .clear
        
        addSubview(backgroundColorView)
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(leftActionButton)
        addSubview(rightActionButton)
        addSubview(separatorLine)
        
        setupLayout()
        setupButtonInsets()
    }
    
    func setupLayout() {
        let barContentHeight: CGFloat = 44
        
        backgroundColorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(barContentHeight)
            make.left.greaterThanOrEqualToSuperview().offset(72)
            make.right.lessThanOrEqualToSuperview().offset(-72)
        }
        
        leftActionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(titleLabel)
            make.height.equalTo(barContentHeight)
            make.width.greaterThanOrEqualTo(40)
        }
        
        rightActionButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(titleLabel)
            make.height.equalTo(barContentHeight)
            make.width.greaterThanOrEqualTo(40)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setupButtonInsets() {
        leftActionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        rightActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        rightActionButton.titleLabel?.minimumScaleFactor = 0.5
    }
}

// MARK: - Public
extension CustomNavigationBar {
    
    public func setTitle(_ text: String?) {
        titleLabel.isHidden = false
        titleLabel.attributedText = nil
        titleLabel.text = text
    }
    
    public func setAttributedTitle(_ attributedText: NSAttributedString?) {
        titleLabel.isHidden = false
        titleLabel.text = nil
        titleLabel.attributedText = attributedText
    }
    
    public func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    public func setTitleFont(_ font: UIFont) {
        titleLabel.font = font
    }
    
    public func setBarBackgroundColor(_ color: UIColor?) {
        backgroundImageView.isHidden = true
        backgroundColorView.isHidden = false
        backgroundColorView.backgroundColor = color
    }
    
    public func setBarBackgroundImage(_ image: UIImage?) {
        backgroundColorView.isHidden = true
        backgroundImageView.isHidden = false
        backgroundImageView.image = image
    }
    
    public func setSeparatorHidden(_ hidden: Bool) {
        separatorLine.isHidden = hidden
    }
    
    public func setBackgroundAlpha(_ alpha: CGFloat) {
        backgroundColorView.alpha = alpha
        backgroundImageView.alpha = alpha
        separatorLine.alpha = alpha
    }
    
    public func setTintStyleColor(_ color: UIColor) {
        titleLabel.textColor = color
        leftActionButton.setTitleColor(color, for: .normal)
        rightActionButton.setTitleColor(color, for: .normal)
    }
    
    public func showLeftButton(image: UIImage, highlighted: UIImage? = nil) {
        leftActionButton.isHidden = false
        leftActionButton.setImage(image, for: .normal)
        leftActionButton.setImage(highlighted ?? image, for: .highlighted)
        leftActionButton.setTitle(nil, for: .normal)
        
        leftActionButton.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 40, height: 44))
        }
    }
    
    public func showLeftButton(title: String, color: UIColor = .black) {
        leftActionButton.isHidden = false
        leftActionButton.setImage(nil, for: .normal)
        leftActionButton.setTitle(title, for: .normal)
        leftActionButton.setTitleColor(color, for: .normal)
        
        leftActionButton.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(titleLabel)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    public func showRightButton(image: UIImage, highlighted: UIImage? = nil) {
        rightActionButton.isHidden = false
        rightActionButton.setImage(image, for: .normal)
        rightActionButton.setImage(highlighted ?? image, for: .highlighted)
        rightActionButton.setTitle(nil, for: .normal)
        
        rightActionButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 40, height: 44))
        }
    }
    
    public func showRightButton(title: String, color: UIColor = .black) {
        rightActionButton.isHidden = false
        rightActionButton.setImage(nil, for: .normal)
        rightActionButton.setTitle(title, for: .normal)
        rightActionButton.setTitleColor(color, for: .normal)
        
        rightActionButton.snp.remakeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(titleLabel)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(40)
        }
    }
    
    public func hideLeftButton() {
        leftActionButton.isHidden = true
    }
    
    public func hideRightButton() {
        rightActionButton.isHidden = true
    }
}

// MARK: - Event
private extension CustomNavigationBar {
    
    @objc func handleLeftButtonTapped() {
        if let action = onLeftAction {
            action()
        } else {
            UIApplication.topViewController()?.popCurrentController()
        }
    }
    
    @objc func handleRightButtonTapped() {
        onRightAction?()
    }
}
