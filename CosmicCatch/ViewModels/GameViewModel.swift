import SwiftUI
import SpriteKit
import Combine

final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published private(set) var viewportSize: CGSize = .zero
    @Published private(set) var isGameRunning: Bool = false

    let scene: GameScene
    private let coordinator: GameSessionCoordinator
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: GameSessionCoordinator) {
        self.coordinator = coordinator
        self.scene = GameScene()
        self.state = coordinator.state
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
        scene.spawnProvider = { [weak coordinator] in
            coordinator?.spawnEvent()
        }
        bind()
    }

    private func bind() {
        coordinator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
            .store(in: &cancellables)

        coordinator.$isGameRunning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] running in
                self?.isGameRunning = running
            }
            .store(in: &cancellables)

        coordinator.debugSettings.$spawnRateMultiplier
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.scene.spawnMultiplier = value
            }
            .store(in: &cancellables)

        coordinator.debugSettings.$enableSlowMotion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.scene.applyDebugSlowMotion(enabled)
            }
            .store(in: &cancellables)

        coordinator.debugSettings.$autoPlay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.scene.setAutoPlay(enabled)
            }
            .store(in: &cancellables)
    }

    func start(challenge: ChallengeMode, sector: SectorDefinition) {
        coordinator.start(challenge: challenge, sector: sector)
        scene.prepareForNewSession(using: sector)
        scene.setGameplayActive(true)
    }

    func pause() {
        coordinator.pause()
        scene.setGameplayActive(false)
    }

    func resume() {
        coordinator.resume()
        scene.setGameplayActive(true)
    }

    func reset() {
        coordinator.endRun(didComplete: false)
        scene.prepareForNewSession(using: state.sector)
        scene.setGameplayActive(false)
    }

    func updateViewport(size: CGSize) {
        guard size != .zero, viewportSize != size else { return }
        viewportSize = size
        scene.updateViewport(size: size)
    }
}

extension GameViewModel: GameSceneDelegate {
    func gameScene(_ scene: GameScene, didCatch definition: CollectibleDefinition) {
        coordinator.registerCatch(definition: definition)
    }

    func gameSceneDidRegisterMiss(_ scene: GameScene) {
        coordinator.registerMiss()
    }

    func gameScene(_ scene: GameScene, didTrigger hazard: HazardEffect) {
        coordinator.registerHazard(hazard)
    }

    func gameScene(_ scene: GameScene, didTrigger event: EventType) {
        coordinator.registerEvent(event)
    }
}
