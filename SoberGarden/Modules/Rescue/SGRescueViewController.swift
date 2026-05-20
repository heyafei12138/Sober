//
//  SGRescueViewController.swift
//  SoberGarden
//

import UIKit

/// 急救流程：冲动状态选择、呼吸练习、延迟承诺
final class SGRescueViewController: BaseViewController {

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func setupSubviews() {
        let label = makePlaceholderLabel(text: "Rescue")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
