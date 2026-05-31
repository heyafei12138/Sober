//
//  SGWatchBreathingView.swift
//  SoberGardenWatch
//

import SwiftUI
import Combine
import WatchKit

struct SGWatchBreathingView: View {

    private let duration: TimeInterval = 90

    @State private var startDate = Date()
    @State private var remainingSeconds = 90
    @State private var isBreathingIn = false
    @State private var isCompleted = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(SGWatchPalette.primary.opacity(0.18), lineWidth: 10)
                    .frame(width: 118, height: 118)

                Circle()
                    .fill(SGWatchPalette.primary.opacity(0.72))
                    .frame(width: isBreathingIn ? 96 : 54, height: isBreathingIn ? 96 : 54)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathingIn)

                Text(isCompleted ? SGLoc("common.done") : "\(remainingSeconds)s")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
            }

            Text(isCompleted ? SGLoc("watch.breathing.completed") : phaseText)
                .font(.headline.weight(.semibold))
                .multilineTextAlignment(.center)

            Button(SGLoc("watch.breathing.restart")) {
                restart()
            }
            .font(.footnote.weight(.semibold))
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 8)
        .navigationTitle(SGLoc("watch.breathing.title"))
        .onAppear {
            restart()
        }
        .onReceive(timer) { now in
            update(now: now)
        }
    }

    private var phaseText: String {
        isBreathingIn ? SGLoc("breathing.inhale") : SGLoc("breathing.exhale")
    }

    private func restart() {
        startDate = Date()
        remainingSeconds = Int(duration)
        isCompleted = false
        isBreathingIn = true
        WKInterfaceDevice.current().play(.start)
    }

    private func update(now: Date) {
        guard !isCompleted else { return }

        let elapsed = now.timeIntervalSince(startDate)
        remainingSeconds = max(Int(ceil(duration - elapsed)), 0)
        isBreathingIn = Int(elapsed / 4).isMultiple(of: 2)

        if remainingSeconds == 0 {
            isCompleted = true
            isBreathingIn = false
            WKInterfaceDevice.current().play(.success)
        }
    }
}

#Preview {
    NavigationStack {
        SGWatchBreathingView()
    }
}
