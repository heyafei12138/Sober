//
//  SGBreathingExerciseView.swift
//  SoberGarden
//

import UIKit

final class SGBreathingExerciseView: UIView {

    var onComplete: (() -> Void)?

    private enum Phase {
        case inhale
        case hold
        case exhale

        var title: String {
            switch self {
            case .inhale:
                return "Inhale"
            case .hold:
                return "Hold"
            case .exhale:
                return "Exhale"
            }
        }

        var duration: Int {
            switch self {
            case .inhale:
                return 4
            case .hold:
                return 2
            case .exhale:
                return 6
            }
        }
    }

    private let totalDuration: Int
    private let stackView = UIStackView()
    private let circleContainerView = UIView()
    private let circleView = UIView()
    private let phaseLabel = UILabel()
    private let instructionLabel = UILabel()
    private let remainingLabel = UILabel()

    private var timer: Timer?
    private var elapsedSeconds = 0
    private var hasStarted = false

    init(totalDuration: Int = 90) {
        self.totalDuration = totalDuration
        super.init(frame: .zero)
        setupView()
        updateLabels()
    }

    required init?(coder: NSCoder) {
        self.totalDuration = 90
        super.init(coder: coder)
        setupView()
        updateLabels()
    }

    deinit {
        stop()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        elapsedSeconds = 0
        updateLabels()
        animateCurrentPhase()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.handleTick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        circleView.layer.removeAllAnimations()
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 14

        circleContainerView.backgroundColor = UIColor.hexString("#FDF0D9")
        circleContainerView.layer.cornerRadius = 82
        circleContainerView.layer.masksToBounds = false

        circleView.backgroundColor = SGColor.rescue.withAlphaComponent(0.72)
        circleView.layer.cornerRadius = 58
        circleView.layer.shadowColor = SGColor.rescue.cgColor
        circleView.layer.shadowOpacity = 0.24
        circleView.layer.shadowRadius = 18
        circleView.layer.shadowOffset = CGSize(width: 0, height: 8)

        phaseLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        phaseLabel.textColor = SGColor.textDark
        phaseLabel.textAlignment = .center

        instructionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        instructionLabel.textColor = SGColor.textSecondary
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0

        remainingLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
        remainingLabel.textColor = SGColor.primaryDark
        remainingLabel.textAlignment = .center

        addSubview(stackView)
        circleContainerView.addSubview(circleView)
        stackView.addArrangedSubview(circleContainerView)
        stackView.addArrangedSubview(phaseLabel)
        stackView.addArrangedSubview(instructionLabel)
        stackView.addArrangedSubview(remainingLabel)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        circleContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(164)
        }

        circleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(116)
        }
    }

    private func handleTick() {
        elapsedSeconds += 1

        if elapsedSeconds >= totalDuration {
            stop()
            elapsedSeconds = totalDuration
            updateLabels()
            onComplete?()
            return
        }

        let previousPhase = phase(for: elapsedSeconds - 1)
        updateLabels()
        if phase(for: elapsedSeconds) != previousPhase {
            animateCurrentPhase()
        }
    }

    private func updateLabels() {
        let phase = phase(for: elapsedSeconds)
        phaseLabel.text = phase.title
        instructionLabel.text = instruction(for: phase)
        remainingLabel.text = "\(max(totalDuration - elapsedSeconds, 0)) seconds remaining"
    }

    private func animateCurrentPhase() {
        let phase = phase(for: elapsedSeconds)
        let targetScale: CGFloat

        switch phase {
        case .inhale:
            targetScale = 1.18
        case .hold:
            targetScale = 1.18
        case .exhale:
            targetScale = 0.78
        }

        UIView.animate(
            withDuration: TimeInterval(phase.duration),
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.circleView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            }
        )
    }

    private func phase(for elapsedSeconds: Int) -> Phase {
        let cycleSecond = elapsedSeconds % 12
        if cycleSecond < Phase.inhale.duration {
            return .inhale
        }
        if cycleSecond < Phase.inhale.duration + Phase.hold.duration {
            return .hold
        }
        return .exhale
    }

    private func instruction(for phase: Phase) -> String {
        switch phase {
        case .inhale:
            return "Breathe in slowly for 4 seconds."
        case .hold:
            return "Keep the breath soft for 2 seconds."
        case .exhale:
            return "Release the breath for 6 seconds."
        }
    }
}
