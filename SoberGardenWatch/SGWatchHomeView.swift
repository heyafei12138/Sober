//
//  SGWatchHomeView.swift
//  SoberGardenWatch
//

import SwiftUI

struct SGWatchHomeView: View {

    @State private var snapshot = SGWatchSnapshotReader.shared.readSnapshot()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    streakCard

                    NavigationLink {
                        SGWatchBreathingView()
                    } label: {
                        Label("I'm Struggling", systemImage: "lifepreserver.fill")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SGWatchPalette.rescue)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .navigationTitle("SoberGarden")
            .onAppear {
                snapshot = SGWatchSnapshotReader.shared.readSnapshot()
            }
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(SGWatchPalette.primary)
                Text(snapshot.habitDisplayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text("\(snapshot.cleanDays) days clean")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.72)
                .lineLimit(1)

            Text(nextMilestoneText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SGWatchPalette.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(SGWatchPalette.card)
        )
    }

    private var nextMilestoneText: String {
        guard let nextMilestone = snapshot.nextMilestone else {
            return "All milestones reached"
        }
        return "Next: \(nextMilestone) days"
    }
}

enum SGWatchPalette {
    static let primary = Color(red: 0.53, green: 0.69, blue: 0.39)
    static let rescue = Color(red: 0.92, green: 0.48, blue: 0.32)
    static let card = Color(red: 0.13, green: 0.16, blue: 0.11)
}

#Preview {
    SGWatchHomeView()
}
