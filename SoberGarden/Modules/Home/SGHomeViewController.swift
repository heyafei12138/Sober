//
//  SGHomeViewController.swift
//  SoberGarden
//

import UIKit

/// 首页：Streak、Calm Coach、Garden 预览、I'm Struggling 入口
final class SGHomeViewController: BaseViewController {

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        showsRightNavigationActions = true
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rightActionContainerView.isHidden = false
    }

    override func setupSubviews() {
        let label = makePlaceholderLabel(text: "Home")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
