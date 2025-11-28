#if canImport(UIKit)
import UIKit
#endif
import Foundation
import SwiftUI
import Combine

// MARK: - Core Game State & Progression Models

struct GameState: Codable {
    var score: Int = 0
    var lives: Int = 3
    var level: Int = 1
    var combo: Int = 0
    var captures: Int = 0
    var misses: Int = 0
    var shields: Int = 0
    var powerMeter: Double = 0
    var sector: SectorDefinition = SectorDefinition.coreNebula
    var mission: MissionCard = MissionCard.coreTutorial
    var challenge: ChallengeMode = .standard
    var activeModifiers: [Modifier] = []
    var missionProgress: Double = 0
    var elapsedTime: TimeInterval = 0
    var stats: SessionStats = SessionStats()
    var metaProgress: MetaProgressionState = MetaProgressionState()
    var accessibility: AccessibilityOptions = AccessibilityOptions()
    var cosmetics: CosmeticTheme = CosmeticTheme()

    mutating func reset(for challenge: ChallengeMode, sector: SectorDefinition) {
        score = 0
        lives = challenge.startingLives
        level = 1
        combo = 0
        captures = 0
        misses = 0
        shields = challenge.startingShields
        powerMeter = 0
        mission = sector.primaryMission
        self.sector = sector
        self.challenge = challenge
        missionProgress = 0
        elapsedTime = 0
        stats = SessionStats()
        activeModifiers.removeAll()
        accessibility = accessibility.updatedForChallenge(challenge)
    }

    mutating func applyCatch(points: Int, definition: CollectibleDefinition, scoring: ScoringService) -> Int {
        captures += 1
        combo += 1
        let comboBonus = scoring.comboMultiplier(for: combo)
        let total = scoring.score(for: definition, comboMultiplier: comboBonus)
        score += total
        powerMeter = min(1.0, powerMeter + definition.powerContribution)
        missionProgress = min(1.0, missionProgress + mission.goal.progressIncrement(for: definition))
        stats.recordCatch(value: total)
        if missionProgress >= 1.0 {
            metaProgress.softCurrency += mission.rewardCurrency
            stats.completedMissions += 1
            missionProgress = 0
        }
        return total
    }

    mutating func registerMiss() {
        combo = 0
        misses += 1
        if shields > 0 {
            shields -= 1
        } else {
            lives = max(lives - 1, 0)
        }
        stats.recordMiss()
    }

    mutating func registerHazard(_ hazard: HazardEffect) {
        switch hazard {
        case .drainCombo:
            combo = 0
        case .removeLife:
            registerMiss()
        case .scrambleControls:
            activeModifiers.append(Modifier(kind: .scrambleInput, duration: 5))
        case .blackoutHUD:
            activeModifiers.append(Modifier(kind: .hudBlackout, duration: 4))
        }
    }

    mutating func applyPowerUp(_ descriptor: PowerUpDescriptor) -> PowerUpEffect {
        switch descriptor.type {
        case .slowMotion:
            activeModifiers.append(Modifier(kind: .slowMotion(descriptor.magnitude), duration: descriptor.duration))
        case .scoreBoost:
            activeModifiers.append(Modifier(kind: .scoreBoost(descriptor.magnitude), duration: descriptor.duration))
        case .shield:
            shields += Int(descriptor.magnitude)
        case .magnet:
            activeModifiers.append(Modifier(kind: .autoCatch, duration: descriptor.duration))
        case .timeFreeze:
            activeModifiers.append(Modifier(kind: .timeFreeze, duration: descriptor.duration))
        }
        stats.powerUpsCollected += 1
        return PowerUpEffect(type: descriptor.type, duration: descriptor.duration)
    }
}

struct SessionStats: Codable {
    var highestCombo: Int = 0
    var averageCatchValue: Double = 0
    var completedMissions: Int = 0
    var powerUpsCollected: Int = 0
    var hazardsTriggered: Int = 0
    var timeline: [TimelineEvent] = []

    mutating func recordCatch(value: Int) {
        highestCombo = max(highestCombo, value)
        averageCatchValue = averageCatchValue == 0 ? Double(value) : (averageCatchValue * 0.9 + Double(value) * 0.1)
    }

    mutating func recordMiss() {
        timeline.append(TimelineEvent(kind: .miss, timestamp: Date()))
    }
}

struct SessionSummary: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var score: Int
    var duration: TimeInterval
    var accuracy: Double
    var combo: Int
    var completedMissions: Int
    var challenge: ChallengeMode
    var sector: SectorDefinition

    static let empty = SessionSummary(date: .now, score: 0, duration: 0, accuracy: 1, combo: 0, completedMissions: 0, challenge: .standard, sector: .coreNebula)
}

// MARK: - Missions, Sectors, Modifiers

enum MissionGoalType: String, Codable { case score, combo, accuracy, object, duration }

struct MissionGoal: Codable {
    var type: MissionGoalType
    var target: Double
    var trackedObject: String?

    func progressIncrement(for definition: CollectibleDefinition) -> Double {
        switch type {
        case .score:
            return definition.rewardMultiplier * 0.02
        case .combo:
            return 0.05
        case .accuracy:
            return 0.01
        case .object:
            return definition.id == trackedObject ? 0.2 : 0
        case .duration:
            return 0.01
        }
    }
}

struct MissionCard: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var goal: MissionGoal
    var rewardCurrency: Int
    var tutorialSteps: [String]

    static let coreTutorial = MissionCard(
        id: "mission.tutorial",
        title: "Starfall Primer",
        description: "Catch stellar shards without missing more than twice.",
        goal: MissionGoal(type: .score, target: 200, trackedObject: nil),
        rewardCurrency: 100,
        tutorialSteps: [
            "Tap glowing shards to catch them.",
            "Avoid void mines.",
            "Build combo streaks for extra points."
        ]
    )
}

enum SectorTheme: String, Codable, CaseIterable { case coreNebula, auroraStrand, eclipseRidge, chronoCradle }

struct SectorDefinition: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var description: String
    var theme: SectorTheme
    var backgroundGradient: [Color]
    var difficulty: Int
    var primaryMission: MissionCard
    var availableObjects: [String]

    static let coreNebula = SectorDefinition(
        id: "sector.core",
        name: "Core Nebula",
        description: "Balanced intro sector with gentle spawn cadence.",
        theme: .coreNebula,
        backgroundGradient: [Color.black, Color.purple.opacity(0.7)],
        difficulty: 1,
        primaryMission: MissionCard.coreTutorial,
        availableObjects: CollectibleDefinition.defaultCatalog.map { $0.id }
    )
}

struct Modifier: Identifiable, Codable {
    enum Kind: Codable {
        case slowMotion(Double)
        case scoreBoost(Double)
        case autoCatch
        case timeFreeze
        case scrambleInput
        case hudBlackout
    }

    let id = UUID()
    var kind: Kind
    var duration: TimeInterval

    mutating func tick(delta: TimeInterval) -> Bool {
        duration -= delta
        return duration <= 0
    }
}

enum ChallengeMode: String, Codable, CaseIterable, Identifiable {
    case standard, endless, blitz, precision

    var id: String { rawValue }

    var startingLives: Int {
        switch self {
        case .standard: return 3
        case .endless: return 4
        case .blitz: return 2
        case .precision: return 1
        }
    }

    var startingShields: Int {
        switch self {
        case .standard: return 0
        case .endless: return 1
        case .blitz: return 0
        case .precision: return 0
        }
    }
}

struct MetaProgressionState: Codable {
    var softCurrency: Int = 0
    var unlockTokens: Int = 0
    var bestScore: Int = 0
    var unlockedObjects: Set<String> = []
    var achievements: [Achievement] = []
}

struct Achievement: Identifiable, Codable {
    enum Kind: String, Codable { case scoreHunter, comboMaster, flawlessRun, powerSurge }
    let id = UUID()
    var kind: Kind
    var achievedOn: Date
    var description: String
}

struct AccessibilityOptions: Codable {
    var colorBlindMode: Bool = false
    var highContrastHUD: Bool = false
    var reduceMotion: Bool = false
    var voiceOverHints: Bool = true

    func updatedForChallenge(_ challenge: ChallengeMode) -> AccessibilityOptions {
        var updated = self
        if challenge == .precision {
            updated.reduceMotion = true
        }
        return updated
    }
}

struct CosmeticTheme: Codable {
    var trailColor: Color = .white
    var hudAccent: Color = Color.purple
    var shipName: String = "Nova"
}

// MARK: - Collectible Definitions & Spawn Events

enum CollectibleCategory: String, Codable { case good, hazard, powerUp, event }

struct CollectibleDefinition: Identifiable, Codable {
    let id: String
    var displayName: String
    var description: String
    var category: CollectibleCategory
    var baseValue: Int
    var fallSpeed: CGFloat
    var radius: CGFloat
    var rarity: Double
    var rewardMultiplier: Double
    var penalty: Int
    var animation: CollectibleAnimation
    var powerUp: PowerUpDescriptor?
    var hazard: HazardDescriptor?
    var event: EventDescriptor?
    var audioCue: String
    var hapticPattern: String
    var powerContribution: Double

    static let defaultCatalog: [CollectibleDefinition] = [
        CollectibleDefinition(
            id: "stellar_shard",
            displayName: "Stellar Shard",
            description: "Reliable score fragment.",
            category: .good,
            baseValue: 10,
            fallSpeed: 220,
            radius: 18,
            rarity: 1.0,
            rewardMultiplier: 1.0,
            penalty: 0,
            animation: CollectibleAnimation.spawnPulse,
            powerUp: nil,
            hazard: nil,
            event: nil,
            audioCue: "catch_shard",
            hapticPattern: "light",
            powerContribution: 0.05
        ),
        CollectibleDefinition(
            id: "plasma_orb",
            displayName: "Plasma Orb",
            description: "High value but faster.",
            category: .good,
            baseValue: 20,
            fallSpeed: 260,
            radius: 16,
            rarity: 0.6,
            rewardMultiplier: 1.6,
            penalty: 0,
            animation: CollectibleAnimation.plasmaBloom,
            powerUp: nil,
            hazard: nil,
            event: nil,
            audioCue: "catch_plasma",
            hapticPattern: "medium",
            powerContribution: 0.08
        ),
        CollectibleDefinition(
            id: "void_mine",
            displayName: "Void Mine",
            description: "Hazardous trap.",
            category: .hazard,
            baseValue: -20,
            fallSpeed: 210,
            radius: 22,
            rarity: 0.4,
            rewardMultiplier: 0,
            penalty: 1,
            animation: CollectibleAnimation.voidMine,
            powerUp: nil,
            hazard: HazardDescriptor(effect: .removeLife),
            event: nil,
            audioCue: "hazard_void",
            hapticPattern: "heavy",
            powerContribution: 0
        ),
        CollectibleDefinition(
            id: "chrono_bloom",
            displayName: "Chrono Bloom",
            description: "Triggers slow motion.",
            category: .powerUp,
            baseValue: 0,
            fallSpeed: 200,
            radius: 20,
            rarity: 0.25,
            rewardMultiplier: 0,
            penalty: 0,
            animation: CollectibleAnimation.chronoBloom,
            powerUp: PowerUpDescriptor(type: .slowMotion, duration: 4, magnitude: 0.4),
            hazard: nil,
            event: nil,
            audioCue: "powerup_time",
            hapticPattern: "light",
            powerContribution: 0.2
        ),
        CollectibleDefinition(
            id: "wormhole_core",
            displayName: "Wormhole Core",
            description: "Rare event object that clears screen.",
            category: .event,
            baseValue: 0,
            fallSpeed: 180,
            radius: 30,
            rarity: 0.1,
            rewardMultiplier: 0,
            penalty: 0,
            animation: CollectibleAnimation.wormhole,
            powerUp: nil,
            hazard: nil,
            event: EventDescriptor(event: .wormhole),
            audioCue: "event_wormhole",
            hapticPattern: "heavy",
            powerContribution: 0.5
        )
    ]
}

struct CollectibleAnimation: Codable {
    var spawnColor: Color
    var idleColor: Color
    var impactColor: Color
    var missColor: Color
    var glow: Double

    static let spawnPulse = CollectibleAnimation(spawnColor: .purple, idleColor: .white, impactColor: .cyan, missColor: .red, glow: 10)
    static let plasmaBloom = CollectibleAnimation(spawnColor: .pink, idleColor: .orange, impactColor: .yellow, missColor: .red, glow: 12)
    static let voidMine = CollectibleAnimation(spawnColor: .gray, idleColor: .black, impactColor: .red, missColor: .purple, glow: 6)
    static let chronoBloom = CollectibleAnimation(spawnColor: .mint, idleColor: .blue, impactColor: .teal, missColor: .gray, glow: 14)
    static let wormhole = CollectibleAnimation(spawnColor: .indigo, idleColor: .purple, impactColor: .white, missColor: .orange, glow: 20)
}

struct PowerUpDescriptor: Codable {
    var type: PowerUpType
    var duration: TimeInterval
    var magnitude: Double
}

enum PowerUpType: String, Codable, CaseIterable { case slowMotion, scoreBoost, shield, magnet, timeFreeze }

struct HazardDescriptor: Codable { var effect: HazardEffect }

enum HazardEffect: String, Codable { case drainCombo, removeLife, scrambleControls, blackoutHUD }

struct EventDescriptor: Codable { var event: EventType }

enum EventType: String, Codable { case cometRain, wormhole, novaPulse }

struct SpawnEvent: Identifiable, Codable {
    let id = UUID()
    var definition: CollectibleDefinition
    var spawnTime: TimeInterval
    var lane: CGFloat
}

struct SpawnSchedule: Codable {
    var seed: UInt64
    var events: [SpawnEvent]
}

// MARK: - Difficulty + Timeline Systems

final class DifficultyDirector {
    private var intensity: Double = 1
    private(set) var sector: SectorDefinition

    init(sector: SectorDefinition) {
        self.sector = sector
    }

    func advance(score: Int, combo: Int) {
        let scoreFactor = min(Double(score) / 1000.0, 2.0)
        let comboFactor = min(Double(combo) / 50.0, 1.5)
        intensity = 1 + scoreFactor * 0.4 + comboFactor * 0.3
    }

    func spawnInterval(for definition: CollectibleDefinition) -> TimeInterval {
        max(0.4, (2.0 - Double(definition.rarity)) / intensity)
    }

    func applyDynamicModifiers(to state: inout GameState) {
        if state.powerMeter >= 1.0 {
            state.activeModifiers.append(Modifier(kind: .scoreBoost(2.0), duration: 6))
            state.powerMeter = 0
        }
    }
}

struct TimelineEvent: Codable, Identifiable {
    enum Kind: String, Codable { case catchSuccess, miss, powerUp, hazard, modifierStart, modifierEnd }
    let id = UUID()
    var kind: Kind
    var timestamp: Date
    var metadata: String?
}

final class TimelineRecorder: ObservableObject {
    @Published private(set) var events: [TimelineEvent] = []

    func record(_ kind: TimelineEvent.Kind, metadata: String? = nil) {
        events.append(TimelineEvent(kind: kind, timestamp: Date(), metadata: metadata))
        if events.count > 120 {
            events.removeFirst()
        }
    }

    func recentEvents() -> [TimelineEvent] {
        events.suffix(40)
    }
}

// MARK: - Services & Stores

protocol ObjectSpawnerService {
    func loadCatalog() -> [CollectibleDefinition]
    func nextEvent(for state: GameState, difficulty: DifficultyDirector, seed: UInt64) -> SpawnEvent
}

final class DefaultObjectSpawnerService: ObjectSpawnerService {
    private let catalog: [CollectibleDefinition]

    init(bundle: Bundle = .main) {
        if let url = bundle.url(forResource: "ObjectDefinitions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([CollectibleDefinition].self, from: data) {
            catalog = decoded
        } else {
            catalog = CollectibleDefinition.defaultCatalog
        }
    }

    func loadCatalog() -> [CollectibleDefinition] { catalog }

    func nextEvent(for state: GameState, difficulty: DifficultyDirector, seed: UInt64) -> SpawnEvent {
        let rng = SeededRandomNumberGenerator(seed: seed)
        let available = catalog.filter { state.sector.availableObjects.contains($0.id) }
        let definition = available.randomElement(using: &rng) ?? catalog[0]
        let time = difficulty.spawnInterval(for: definition)
        let lane = Double.random(in: 0.1...0.9, using: &rng)
        return SpawnEvent(definition: definition, spawnTime: time, lane: lane)
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

protocol ScoringService {
    func comboMultiplier(for combo: Int) -> Double
    func score(for definition: CollectibleDefinition, comboMultiplier: Double) -> Int
}

final class DefaultScoringService: ScoringService {
    func comboMultiplier(for combo: Int) -> Double {
        1 + Double(combo) * 0.05
    }

    func score(for definition: CollectibleDefinition, comboMultiplier: Double) -> Int {
        Int(Double(definition.baseValue) * definition.rewardMultiplier * comboMultiplier)
    }
}

protocol SettingsStore {
    var musicVolume: Double { get set }
    var sfxVolume: Double { get set }
    var hapticsEnabled: Bool { get set }
    var accessibility: AccessibilityOptions { get set }
    var localization: LocalizationBundle { get set }
    func reset()
}

final class UserDefaultsSettingsStore: SettingsStore {
    private let defaults = UserDefaults.standard

    var musicVolume: Double {
        get { defaults.double(forKey: "musicVolume") }
        set { defaults.set(newValue, forKey: "musicVolume") }
    }

    var sfxVolume: Double {
        get { defaults.double(forKey: "sfxVolume") }
        set { defaults.set(newValue, forKey: "sfxVolume") }
    }

    var hapticsEnabled: Bool {
        get { defaults.object(forKey: "hapticsEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "hapticsEnabled") }
    }

    var accessibility: AccessibilityOptions {
        get {
            if let data = defaults.data(forKey: "accessibility"), let decoded = try? JSONDecoder().decode(AccessibilityOptions.self, from: data) {
                return decoded
            }
            return AccessibilityOptions()
        }
        set { defaults.set(try? JSONEncoder().encode(newValue), forKey: "accessibility") }
    }

    var localization: LocalizationBundle {
        get {
            if let data = defaults.data(forKey: "localization"), let decoded = try? JSONDecoder().decode(LocalizationBundle.self, from: data) {
                return decoded
            }
            return LocalizationBundle.defaultBundle
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: "localization")
        }
    }

    func reset() {
        defaults.removeObject(forKey: "musicVolume")
        defaults.removeObject(forKey: "sfxVolume")
        defaults.removeObject(forKey: "hapticsEnabled")
        defaults.removeObject(forKey: "accessibility")
    }
}

protocol SessionSummaryStore {
    func save(_ summary: SessionSummary)
    func fetchRecent() -> [SessionSummary]
    func resetSummaries()
}

final class FileSessionSummaryStore: SessionSummaryStore {
    private let url: URL

    init(filename: String = "session_summaries.json") {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        url = directory.appendingPathComponent(filename)
    }

    func save(_ summary: SessionSummary) {
        var current = fetchRecent()
        current.insert(summary, at: 0)
        let data = try? JSONEncoder().encode(current)
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data?.write(to: url)
    }

    func fetchRecent() -> [SessionSummary] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([SessionSummary].self, from: data)) ?? []
    }

    func resetSummaries() {
        try? FileManager.default.removeItem(at: url)
    }
}

protocol AudioEngine {
    func playMusic(layer: AudioLayer)
    func playEffect(named: String)
    func setMusicIntensity(_ value: Double)
}

enum AudioLayer: String { case calm, buildUp, intense }

final class AdaptiveAudioEngine: AudioEngine {
    private(set) var currentLayer: AudioLayer = .calm
    func playMusic(layer: AudioLayer) { currentLayer = layer }
    func playEffect(named: String) { debugPrint("Playing effect", named) }
    func setMusicIntensity(_ value: Double) {
        currentLayer = value > 0.7 ? .intense : (value > 0.3 ? .buildUp : .calm)
    }
}

protocol HapticsEngine {
    func play(pattern: String)
}

final class CoreHapticsEngine: HapticsEngine {
    func play(pattern: String) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        debugPrint("Haptic pattern", pattern)
    }
}

final class TelemetryLogger {
    private let logURL: URL

    init(filename: String = "telemetry.log") {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        logURL = directory.appendingPathComponent(filename)
    }

    func log(_ message: String) {
        let line = "[\(Date())] \(message)\n"
        if FileManager.default.fileExists(atPath: logURL.path) {
            if let handle = try? FileHandle(forWritingTo: logURL) {
                handle.seekToEndOfFile()
                handle.write(Data(line.utf8))
                try? handle.close()
            }
        } else {
            try? line.write(to: logURL, atomically: true, encoding: .utf8)
        }
    }
}

final class SmokeTestHarness {
    private let spawner: ObjectSpawnerService
    private let scoring: ScoringService

    init(spawner: ObjectSpawnerService, scoring: ScoringService) {
        self.spawner = spawner
        self.scoring = scoring
    }

    func runSimulation(iterations: Int = 200) -> SessionSummary {
        var state = GameState()
        let director = DifficultyDirector(sector: .coreNebula)
        let catalog = spawner.loadCatalog()
        let start = Date()
        for index in 0..<iterations {
            let seed = UInt64(index)
            let event = spawner.nextEvent(for: state, difficulty: director, seed: seed)
            if event.definition.category == .hazard {
                state.registerHazard(event.definition.hazard?.effect ?? .removeLife)
            } else {
                let score = scoring.score(for: event.definition, comboMultiplier: 1.0)
                state.score += score
            }
            director.advance(score: state.score, combo: state.combo)
        }
        state.elapsedTime = Date().timeIntervalSince(start)
        return SessionSummary(date: Date(), score: state.score, duration: state.elapsedTime, accuracy: 0.8, combo: state.combo, completedMissions: state.stats.completedMissions, challenge: state.challenge, sector: state.sector)
    }
}

// MARK: - Localization & Docs

struct LocalizationBundle: Codable {
    var locale: String
    var strings: [String: String]

    static let defaultBundle = LocalizationBundle(locale: "en", strings: [
        "play_button": "Launch Mission",
        "settings": "Settings",
        "codex": "Codex",
        "profile": "Pilot Profile"
    ])
}

struct AppStoreMetadata: Codable {
    var appName: String
    var subtitle: String
    var description: String
    var keywords: [String]
    var supportURL: URL
    var privacyURL: URL
}

struct MarketingAsset: Codable, Identifiable {
    enum Kind: String, Codable { case screenshot, banner, icon }
    let id = UUID()
    var kind: Kind
    var description: String
    var filePath: String
}

struct FAQEntry: Codable, Identifiable {
    let id = UUID()
    var question: String
    var answer: String
}

struct PostLaunchRoadmapItem: Codable, Identifiable {
    let id = UUID()
    var title: String
    var targetRelease: String
    var notes: String
}

struct QARequirement: Codable, Identifiable {
    let id = UUID()
    var title: String
    var status: String
}

struct InstrumentationSample: Codable {
    var timestamp: Date
    var frameTime: Double
    var memoryUsage: Double
    var nodeCount: Int
}

struct BalancingReport: Codable {
    var generatedOn: Date
    var spawnWeights: [String: Double]
    var notes: String
}

struct PowerUpEffect {
    var type: PowerUpType
    var duration: TimeInterval
}
