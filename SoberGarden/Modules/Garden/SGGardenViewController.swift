//
//  SGGardenViewController.swift
//  SoberGarden
//

import UIKit

/// 成长花园：阶段插画、进度、已解锁徽章
final class SGGardenViewController: BaseViewController {

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func setupSubviews() {
        let label = makePlaceholderLabel(text: "Garden")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
