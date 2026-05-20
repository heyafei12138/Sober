//
//  SGRescueStepHeaderView.swift
//  SoberGarden
//

import UIKit

final class SGRescueStepHeaderView: UIView {

    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBarView = SGProgressBarView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, subtitle: String, stepIndex: Int, totalSteps: Int) {
        eyebrowLabel.text = "Step \(stepIndex) of \(totalSteps)"
        titleLabel.text = title
        subtitleLabel.text = subtitle
        progressBarView.setProgress(CGFloat(stepIndex) / CGFloat(max(totalSteps, 1)), animated: false)
    }

    private func setupView() {
        eyebrowLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        eyebrowLabel.textColor = SGColor.primaryDark
        eyebrowLabel.numberOfLines = 1

        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = SGColor.textDark
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = SGColor.textSecondary
        subtitleLabel.numberOfLines = 0

        addSubview(eyebrowLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(progressBarView)

        eyebrowLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(eyebrowLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }

        progressBarView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
}
