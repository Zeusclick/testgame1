import SwiftUI
import SpriteKit

final class GameViewModel: ObservableObject {
    @Published private(set) var gameState = GameState()
    @Published var isGameRunning = false
    @Published private(set) var viewportSize: CGSize = .zero

    let scene: GameScene

    init() {
        scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
    }

    func startGame() {
        gameState.reset()
        isGameRunning = true
        scene.prepareForNewSession()
        scene.setGameplayActive(true)
    }

    func pauseGame() {
        isGameRunning = false
        scene.setGameplayActive(false)
    }

    func resumeGame() {
        guard !isGameRunning else { return }
        isGameRunning = true
        scene.setGameplayActive(true)
    }

    func resetGame() {
        gameState.reset()
        isGameRunning = false
        scene.prepareForNewSession()
        scene.setGameplayActive(false)
    }

    func updateViewport(size: CGSize) {
        guard size != .zero else { return }
        if viewportSize != size {
            viewportSize = size
            scene.updateViewport(size: size)
        }
    }
}

extension GameViewModel: GameSceneDelegate {
    func gameSceneDidRegisterCatch(points: Int) {
        guard isGameRunning else { return }
        gameState.applyCatch(points: points)
    }

    func gameSceneDidRegisterMiss() {
        guard isGameRunning else { return }
        gameState.registerMiss()
        if gameState.lives == 0 {
            pauseGame()
        }
    }
}
