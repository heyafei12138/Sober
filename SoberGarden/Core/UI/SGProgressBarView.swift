//
//  SGProgressBarView.swift
//  SoberGarden
//

import UIKit

final class SGProgressBarView: UIView {

    private let trackView = UIView()
    private let fillView = UIView()
    private var fillWidthConstraint: Constraint?
    private var currentProgress: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFillWidth()
    }

    func setProgress(_ progress: CGFloat, animated: Bool) {
        currentProgress = min(max(progress, 0), 1)
        updateFillWidth()

        guard animated else { return }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.layoutIfNeeded()
        }
    }

    private func setupView() {
        backgroundColor = .clear
        trackView.backgroundColor = SGColor.primaryLight.withAlphaComponent(0.75)
        trackView.layer.cornerRadius = 5
        trackView.layer.masksToBounds = true

        fillView.backgroundColor = SGColor.primary
        fillView.layer.cornerRadius = 5
        fillView.layer.masksToBounds = true

        addSubview(trackView)
        trackView.addSubview(fillView)

        snp.makeConstraints { make in
            make.height.equalTo(10)
        }

        trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        fillView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            fillWidthConstraint = make.width.equalTo(0).constraint
        }
    }

    private func updateFillWidth() {
        let width = bounds.width * currentProgress
        fillWidthConstraint?.update(offset: width)
    }
}
