//
//  SGEmotionPickerView.swift
//  SoberGarden
//

import UIKit

final class SGEmotionPickerView: UIView {

    var onSelectEmotion: ((EmotionType?) -> Void)?

    private let gridStackView = UIStackView()
    private var chips: [SGOptionChip] = []
    private var selectedEmotion: EmotionType?
    private var didSelectSkip = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(selectedEmotion: EmotionType?, didSelectSkip: Bool) {
        self.selectedEmotion = selectedEmotion
        self.didSelectSkip = didSelectSkip
        updateSelection()
    }

    private func setupView() {
        gridStackView.axis = .vertical
        gridStackView.alignment = .fill
        gridStackView.distribution = .fill
        gridStackView.spacing = 10

        addSubview(gridStackView)
        gridStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let options: [EmotionType?] = EmotionType.allCases.map(Optional.some) + [nil]
        for rowOptions in options.chunked(into: 2) {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10

            for option in rowOptions {
                let chip = SGOptionChip(title: option?.displayName ?? "common.skip".localized())
                chip.accessibilityIdentifier = option.map { "rescue_emotion_\($0.rawValue)" } ?? "rescue_emotion_skip"
                chip.addTarget(self, action: #selector(handleChipTapped(_:)), for: .touchUpInside)
                chip.tag = chips.count
                chips.append(chip)
                rowStackView.addArrangedSubview(chip)
            }

            gridStackView.addArrangedSubview(rowStackView)
        }

        updateSelection()
    }

    @objc private func handleChipTapped(_ sender: SGOptionChip) {
        let options: [EmotionType?] = EmotionType.allCases.map(Optional.some) + [nil]
        guard sender.tag < options.count else { return }
        selectedEmotion = options[sender.tag]
        didSelectSkip = selectedEmotion == nil
        updateSelection()
        onSelectEmotion?(selectedEmotion)
    }

    private func updateSelection() {
        let options: [EmotionType?] = EmotionType.allCases.map(Optional.some) + [nil]
        for (index, chip) in chips.enumerated() {
            let option = options[index]
            chip.isSelected = option.map { $0 == selectedEmotion } ?? didSelectSkip
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
