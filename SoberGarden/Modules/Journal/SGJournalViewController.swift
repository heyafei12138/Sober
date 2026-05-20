//
//  SGJournalViewController.swift
//  SoberGarden
//

import UIKit

/// 每日记录：心情、冲动、触发、反思
final class SGJournalViewController: BaseViewController {

    override func viewDidLoad() {
        isCustomNavigationHidden = true
        super.viewDidLoad()
    }

    override func setupSubviews() {
        let label = makePlaceholderLabel(text: "Journal")
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
