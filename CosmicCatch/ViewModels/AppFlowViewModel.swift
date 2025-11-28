import SwiftUI

@MainActor
final class AppFlowViewModel: ObservableObject {
    enum Screen: Equatable {
        case splash
        case title
        case playing
        case paused
    }

    @Published private(set) var screen: Screen = .splash

    private var hasScheduledLaunch = false
    private var splashWorkItem: DispatchWorkItem?

    func handleAppLaunch() {
        guard !hasScheduledLaunch else { return }
        hasScheduledLaunch = true

        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeInOut(duration: 0.6)) {
                self?.screen = .title
            }
        }
        splashWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: workItem)
    }

    func skipSplash() {
        splashWorkItem?.cancel()
        withAnimation(.easeInOut(duration: 0.4)) {
            screen = .title
        }
    }

    func startGame(using gameViewModel: GameViewModel) {
        gameViewModel.startGame()
        transitionToPlaying()
    }

    func pauseGame(using gameViewModel: GameViewModel) {
        guard screen == .playing else { return }
        gameViewModel.pauseGame()
        screen = .paused
    }

    func resumeGame(using gameViewModel: GameViewModel) {
        guard screen == .paused else { return }
        gameViewModel.resumeGame()
        transitionToPlaying()
    }

    func restartGame(using gameViewModel: GameViewModel) {
        gameViewModel.startGame()
        transitionToPlaying()
    }

    func exitToTitle(using gameViewModel: GameViewModel) {
        gameViewModel.resetGame()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            screen = .title
        }
    }

    private func transitionToPlaying() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            screen = .playing
        }
    }
}
