import SwiftUI

struct TutorialOverlayView: View {
    @EnvironmentObject private var tutorialViewModel: TutorialViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tutorial")
                .cosmicTitle()
            Text(tutorialViewModel.steps.isEmpty ? "" : tutorialViewModel.steps[tutorialViewModel.currentIndex])
                .font(.body)
                .foregroundStyle(.white)
            Button("Next") {
                tutorialViewModel.advance()
            }
            .buttonStyle(CosmicCapsuleButtonStyle(fill: .white.opacity(0.2)))
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(CosmicStyle.overlayBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(radius: 30)
    }
}

struct RunSummaryView: View {
    @EnvironmentObject private var runSummaryViewModel: RunSummaryViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Run Summary").cosmicTitle()
            Text("Score: \(runSummaryViewModel.summary.score)")
            Text("Combo: \(runSummaryViewModel.summary.combo)")
            Text("Accuracy: \(Int(runSummaryViewModel.summary.accuracy * 100))%")
        }
        .foregroundStyle(.white)
        .padding(24)
        .background(CosmicStyle.overlayBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct FailureOverlayView: View {
    var onRetry: () -> Void
    var onQuit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Mission Failed")
                .cosmicTitle()
            Button("Retry", action: onRetry)
                .buttonStyle(CosmicCapsuleButtonStyle())
            Button("Quit", action: onQuit)
                .buttonStyle(CosmicCapsuleButtonStyle(fill: .gray))
        }
        .padding(24)
        .background(CosmicStyle.overlayBackground, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct DebugOverlayView: View {
    @EnvironmentObject private var debugSettings: DebugSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Show FPS", isOn: $debugSettings.showFPS)
            Toggle("Slow Motion", isOn: $debugSettings.enableSlowMotion)
            Toggle("Auto Play", isOn: $debugSettings.autoPlay)
            Slider(value: $debugSettings.spawnRateMultiplier, in: 0.2...3) {
                Text("Spawn Rate")
            }
            Toggle("Timeline", isOn: $debugSettings.showTimeline)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding()
    }
}

struct TimelineOverlayView: View {
    @EnvironmentObject private var coordinator: GameSessionCoordinator
    @EnvironmentObject private var debugSettings: DebugSettings

    var body: some View {
        if debugSettings.showTimeline {
            VStack(alignment: .leading) {
                Text("Timeline").font(.headline)
                ForEach(coordinator.timeline.recentEvents()) { event in
                    HStack {
                        Text(event.timestamp, style: .time)
                        Text(event.kind.rawValue)
                        Spacer()
                        Text(event.metadata ?? "")
                    }
                    .font(.caption)
                }
            }
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding()
        }
    }
}
