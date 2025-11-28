import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var appFlow: AppFlowViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch appFlow.screen {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .title:
                TitleScreenView(
                    onStart: handleStart,
                    onSettings: handlePlaceholderAction,
                    onCodex: handlePlaceholderAction
                )
                .transition(.opacity)
            case .playing, .paused:
                playingLayer
            }

            if appFlow.screen == .paused {
                PauseOverlayView(
                    onResume: handleResume,
                    onRestart: handleRestart,
                    onQuit: handleQuitToTitle
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            appFlow.handleAppLaunch()
        }
        .animation(.easeInOut(duration: 0.35), value: appFlow.screen)
    }

    private var playingLayer: some View {
        ZStack(alignment: .top) {
            GameView(viewModel: gameViewModel)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                statusBar
                pauseControls
            }
            .padding(20)
        }
    }

    private var statusBar: some View {
        HStack(spacing: 16) {
            statusPill(title: "Score", value: "\(gameViewModel.gameState.score)")
            statusPill(title: "Lives", value: "\(gameViewModel.gameState.lives)")
            statusPill(title: "Level", value: "\(gameViewModel.gameState.level)")
        }
        .frame(maxWidth: .infinity)
    }

    private func statusPill(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .foregroundStyle(.white)
    }

    private var pauseControls: some View {
        HStack(spacing: 12) {
            Button(action: handlePauseOrResume) {
                Label(appFlow.screen == .playing ? "Pause" : "Resume", systemImage: appFlow.screen == .playing ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)

            Button(action: handleRestart) {
                Label("Restart", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .tint(.white.opacity(0.8))

            Spacer()

            Button(action: handleQuitToTitle) {
                Label("Quit", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .tint(.white)
        }
    }

    private func handleStart() {
        appFlow.skipSplash()
        appFlow.startGame(using: gameViewModel)
    }

    private func handlePauseOrResume() {
        if appFlow.screen == .playing {
            appFlow.pauseGame(using: gameViewModel)
        } else {
            appFlow.resumeGame(using: gameViewModel)
        }
    }

    private func handleResume() {
        appFlow.resumeGame(using: gameViewModel)
    }

    private func handleRestart() {
        appFlow.restartGame(using: gameViewModel)
    }

    private func handleQuitToTitle() {
        appFlow.exitToTitle(using: gameViewModel)
    }

    private func handlePlaceholderAction() {
        // Placeholder actions will be implemented in future tasks (settings, codex, etc.).
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
        .environmentObject(AppFlowViewModel())
}
