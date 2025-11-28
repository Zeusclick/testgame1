import Foundation
import SwiftUI
import Combine

final class DebugSettings: ObservableObject {
    @Published var showFPS = true
    @Published var spawnRateMultiplier: Double = 1.0
    @Published var enableSlowMotion = false
    @Published var autoPlay = false
    @Published var showTimeline = false
    @Published var enableDeveloperHUD = true
}

struct GameServices {
    let spawner: ObjectSpawnerService
    let scoring: ScoringService
    let settings: SettingsStore
    let sessionStore: SessionSummaryStore
    let audio: AudioEngine
    let haptics: HapticsEngine
    let telemetry: TelemetryLogger
    let simulation: SmokeTestHarness

    static func makeDefault() -> GameServices {
        let spawner = DefaultObjectSpawnerService()
        let scoring = DefaultScoringService()
        let settings = UserDefaultsSettingsStore()
        let sessionStore = FileSessionSummaryStore()
        let audio = AdaptiveAudioEngine()
        let haptics = CoreHapticsEngine()
        let telemetry = TelemetryLogger()
        let simulation = SmokeTestHarness(spawner: spawner, scoring: scoring)
        return GameServices(spawner: spawner, scoring: scoring, settings: settings, sessionStore: sessionStore, audio: audio, haptics: haptics, telemetry: telemetry, simulation: simulation)
    }
}

final class GameSessionCoordinator: ObservableObject {
    @Published private(set) var state = GameState()
    @Published private(set) var isGameRunning = false
    @Published var isPaused = false
    @Published var lastSummary: SessionSummary = .empty

    let services: GameServices
    let debugSettings: DebugSettings
    let timeline: TimelineRecorder
    let hudViewModel: HUDViewModel
    let menuViewModel: MenuViewModel
    let settingsViewModel: SettingsViewModel
    let tutorialViewModel: TutorialViewModel
    let runSummaryViewModel: RunSummaryViewModel

    private var difficultyDirector: DifficultyDirector
    private var cancellables = Set<AnyCancellable>()
    private var tickTimer: AnyCancellable?
    private var seed: UInt64 = 0

    init(services: GameServices = .makeDefault(), debugSettings: DebugSettings = DebugSettings()) {
        self.services = services
        self.debugSettings = debugSettings
        self.timeline = TimelineRecorder()
        self.difficultyDirector = DifficultyDirector(sector: .coreNebula)
        self.hudViewModel = HUDViewModel()
        self.menuViewModel = MenuViewModel()
        self.settingsViewModel = SettingsViewModel(store: services.settings)
        self.tutorialViewModel = TutorialViewModel()
        self.runSummaryViewModel = RunSummaryViewModel()
        bind()
    }

    private func bind() {
        $state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.hudViewModel.update(with: newState)
            }
            .store(in: &cancellables)
    }

    func start(challenge: ChallengeMode, sector: SectorDefinition) {
        state.reset(for: challenge, sector: sector)
        difficultyDirector = DifficultyDirector(sector: sector)
        isGameRunning = true
        isPaused = false
        scheduleTick()
        services.audio.playMusic(layer: .calm)
        tutorialViewModel.beginIfNeeded(mission: state.mission)
    }

    func pause() {
        guard isGameRunning else { return }
        isPaused = true
        tickTimer?.cancel()
    }

    func resume() {
        guard isGameRunning else { return }
        isPaused = false
        scheduleTick()
    }

    func endRun(didComplete: Bool) {
        isGameRunning = false
        isPaused = false
        tickTimer?.cancel()
        let duration = state.elapsedTime
        let accuracy = state.captures + state.misses == 0 ? 1 : Double(state.captures) / Double(max(1, state.captures + state.misses))
        let summary = SessionSummary(date: Date(), score: state.score, duration: duration, accuracy: accuracy, combo: state.combo, completedMissions: state.stats.completedMissions, challenge: state.challenge, sector: state.sector)
        services.sessionStore.save(summary)
        runSummaryViewModel.present(summary: summary)
        lastSummary = summary
    }

    func registerCatch(definition: CollectibleDefinition) {
        let total = state.applyCatch(points: definition.baseValue, definition: definition, scoring: services.scoring)
        services.audio.playEffect(named: definition.audioCue)
        services.haptics.play(pattern: definition.hapticPattern)
        difficultyDirector.advance(score: state.score, combo: state.combo)
        timeline.record(.catchSuccess, metadata: definition.id)
        if let power = definition.powerUp {
            let effect = state.applyPowerUp(power)
            tutorialViewModel.note(powerUp: effect)
        }
    }

    func registerMiss() {
        state.registerMiss()
        services.haptics.play(pattern: "miss")
        timeline.record(.miss)
        if state.lives == 0 {
            endRun(didComplete: false)
        }
    }

    func registerHazard(_ hazard: HazardEffect) {
        state.registerHazard(hazard)
        timeline.record(.hazard, metadata: hazard.rawValue)
    }

    func registerEvent(_ event: EventType) {
        switch event {
        case .wormhole:
            state.combo += 5
        case .cometRain:
            state.score += 50
        case .novaPulse:
            state.shields += 1
        }
        timeline.record(.modifierStart, metadata: event.rawValue)
    }

    func update(elapsed: TimeInterval) {
        guard isGameRunning, !isPaused else { return }
        state.elapsedTime += elapsed
        state.activeModifiers = state.activeModifiers.compactMap { modifier in
            var mutable = modifier
            return mutable.tick(delta: elapsed) ? nil : mutable
        }
        difficultyDirector.applyDynamicModifiers(to: &state)
    }

    func spawnEvent() -> SpawnEvent {
        seed &+= 1
        return services.spawner.nextEvent(for: state, difficulty: difficultyDirector, seed: seed)
    }

    func recentSummaries() -> [SessionSummary] {
        services.sessionStore.fetchRecent()
    }

    private func scheduleTick() {
        tickTimer?.cancel()
        tickTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update(elapsed: 0.2)
            }
    }
}

// MARK: - HUD

final class HUDViewModel: ObservableObject {
    @Published private(set) var scoreText: String = "0"
    @Published private(set) var comboText: String = "x0"
    @Published private(set) var livesText: String = "❤︎❤︎❤︎"
    @Published private(set) var missionTitle: String = ""
    @Published private(set) var missionProgress: Double = 0
    @Published private(set) var powerMeter: Double = 0

    func update(with state: GameState) {
        scoreText = NumberFormatter.localizedString(from: NSNumber(value: state.score), number: .decimal)
        comboText = "x\(state.combo)"
        livesText = String(repeating: "❤︎", count: state.lives + state.shields)
        missionTitle = state.mission.title
        missionProgress = state.missionProgress
        powerMeter = state.powerMeter
    }
}

// MARK: - Menu / Meta

final class MenuViewModel: ObservableObject {
    enum Tab: String, CaseIterable, Identifiable { case play, codex, challenges, settings, profile
        var id: String { rawValue }
    }

    @Published var selectedTab: Tab = .play
    @Published var selectedChallenge: ChallengeMode = .standard
    @Published var selectedSector: SectorDefinition = .coreNebula
    @Published var codexEntries: [CollectibleDefinition] = CollectibleDefinition.defaultCatalog
    @Published var runHistory: [SessionSummary] = []

    func assignHistory(_ summaries: [SessionSummary]) {
        runHistory = summaries
    }
}

final class SettingsViewModel: ObservableObject {
    @Published var musicVolume: Double
    @Published var sfxVolume: Double
    @Published var hapticsEnabled: Bool
    @Published var accessibility: AccessibilityOptions
    @Published var localization: LocalizationBundle

    private let store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
        musicVolume = store.musicVolume == 0 ? 0.6 : store.musicVolume
        sfxVolume = store.sfxVolume == 0 ? 0.8 : store.sfxVolume
        hapticsEnabled = store.hapticsEnabled
        accessibility = store.accessibility
        localization = store.localization
    }

    func persist() {
        store.musicVolume = musicVolume
        store.sfxVolume = sfxVolume
        store.hapticsEnabled = hapticsEnabled
        store.accessibility = accessibility
        store.localization = localization
    }

    func reset() {
        store.reset()
        musicVolume = store.musicVolume
        sfxVolume = store.sfxVolume
        hapticsEnabled = store.hapticsEnabled
        accessibility = store.accessibility
    }
}

// MARK: - Tutorial & Summary

final class TutorialViewModel: ObservableObject {
    @Published private(set) var steps: [String] = []
    @Published private(set) var currentIndex: Int = 0
    @Published var isVisible: Bool = false

    func beginIfNeeded(mission: MissionCard) {
        guard !mission.tutorialSteps.isEmpty else { return }
        steps = mission.tutorialSteps
        currentIndex = 0
        isVisible = true
    }

    func advance() {
        guard currentIndex + 1 < steps.count else {
            isVisible = false
            return
        }
        currentIndex += 1
    }

    func note(powerUp: PowerUpEffect) {
        guard !steps.isEmpty else { return }
        steps.append("Power-up \(powerUp.type.rawValue) active for \(Int(powerUp.duration))s")
    }
}

final class RunSummaryViewModel: ObservableObject {
    @Published var isPresenting: Bool = false
    @Published var summary: SessionSummary = .empty

    func present(summary: SessionSummary) {
        self.summary = summary
        isPresenting = true
    }
}
