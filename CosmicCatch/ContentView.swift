import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var gameViewModel: GameViewModel
    @EnvironmentObject private var appFlow: AppFlowViewModel
    @EnvironmentObject private var coordinator: GameSessionCoordinator
    @EnvironmentObject private var hudViewModel: HUDViewModel
    @EnvironmentObject private var menuViewModel: MenuViewModel
    @EnvironmentObject private var tutorialViewModel: TutorialViewModel
    @EnvironmentObject private var runSummaryViewModel: RunSummaryViewModel
    @EnvironmentObject private var debugSettings: DebugSettings

    @State private var safeArea = EdgeInsets()

    var body: some View {
        ZStack {
            CosmicStyle.background.ignoresSafeArea()
            switch appFlow.screen {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .title:
                titleStack
            case .playing, .paused:
                playingStack
            }
            overlayLayers
        }
        .onAppear {
            appFlow.handleAppLaunch()
        }
        .onSafeAreaChange { safeArea = $0 }
    }

    private var titleStack: some View {
        VStack(spacing: 24) {
            TitleScreenView(onStart: handleLaunch, onSettings: { menuViewModel.selectedTab = .settings }, onCodex: { menuViewModel.selectedTab = .codex })
                .padding(.top, safeArea.top + 40)
            MenuStackView()
        }
        .padding(.horizontal, 24)
    }

    private var playingStack: some View {
        ZStack(alignment: .top) {
            GameView(viewModel: gameViewModel)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                HUDView()
                controlBar
                    .padding(.horizontal, 16)
            }
            .padding(.top, safeArea.top + 12)
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Button(action: togglePause) {
                Label(coordinator.isPaused ? "Resume" : "Pause", systemImage: coordinator.isPaused ? "play.fill" : "pause.fill")
            }
            .buttonStyle(CosmicCapsuleButtonStyle())

            Button(action: resetRun) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(CosmicCapsuleButtonStyle(fill: .gray.opacity(0.4)))

            Spacer()

            Button(action: quitToTitle) {
                Label("Quit", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            .tint(.white)
        }
    }

    private var overlayLayers: some View {
        ZStack {
            if coordinator.isPaused {
                PauseOverlayView(onResume: { appFlow.resumeGame(using: gameViewModel) }, onRestart: { appFlow.restartGame(using: gameViewModel) }, onQuit: quitToTitle)
            }
            if !gameViewModel.isGameRunning && coordinator.state.lives == 0 {
                FailureOverlayView(onRetry: { appFlow.restartGame(using: gameViewModel) }, onQuit: quitToTitle)
            }
            if tutorialViewModel.isVisible {
                TutorialOverlayView()
            }
            if runSummaryViewModel.isPresenting {
                RunSummaryView()
            }
            if debugSettings.enableDeveloperHUD {
                VStack {
                    DebugOverlayView()
                    TimelineOverlayView()
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
            }
        }
        .allowsHitTesting(true)
    }

    private func handleLaunch() {
        appFlow.skipSplash()
        appFlow.startGame(using: gameViewModel, challenge: menuViewModel.selectedChallenge, sector: menuViewModel.selectedSector)
    }

    private func togglePause() {
        if coordinator.isPaused {
            appFlow.resumeGame(using: gameViewModel)
        } else {
            appFlow.pauseGame(using: gameViewModel)
        }
    }

    private func resetRun() {
        appFlow.restartGame(using: gameViewModel)
    }

    private func quitToTitle() {
        appFlow.exitToTitle(using: gameViewModel)
    }
}

#Preview {
    let coordinator = GameSessionCoordinator()
    let viewModel = GameViewModel(coordinator: coordinator)
    ContentView()
        .environmentObject(viewModel)
        .environmentObject(AppFlowViewModel())
        .environmentObject(coordinator)
        .environmentObject(coordinator.hudViewModel)
        .environmentObject(coordinator.menuViewModel)
        .environmentObject(coordinator.settingsViewModel)
        .environmentObject(coordinator.tutorialViewModel)
        .environmentObject(coordinator.runSummaryViewModel)
        .environmentObject(coordinator.debugSettings)
}
