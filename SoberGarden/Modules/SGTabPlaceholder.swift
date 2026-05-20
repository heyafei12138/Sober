//
//  SGTabPlaceholder.swift
//  SoberGarden
//

import UIKit

extension BaseViewController {

    func makePlaceholderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = SGColor.textDark
        label.textAlignment = .center
        return label
    }
}
