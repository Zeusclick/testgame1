#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, didCatch definition: CollectibleDefinition)
    func gameSceneDidRegisterMiss(_ scene: GameScene)
    func gameScene(_ scene: GameScene, didTrigger hazard: HazardEffect)
    func gameScene(_ scene: GameScene, didTrigger event: EventType)
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?
    var spawnProvider: (() -> SpawnEvent)?

    private var lastUpdate: TimeInterval = 0
    private var spawnCountdown: TimeInterval = 1.2
    private var slowMotionFactor: CGFloat = 1
    var spawnMultiplier: Double = 1 {
        didSet { spawnMultiplier = min(max(spawnMultiplier, 0.2), 3) }
    }
    private var debugAutoPlay = false
    private var parallaxLayers: [SKNode] = []
    private let nodePool = CollectibleNodePool()

    override init(size: CGSize) {
        super.init(size: size)
        configureScene()
    }

    convenience init() {
        self.init(size: CGSize(width: 430, height: 932))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureScene()
    }

    private func configureScene() {
        scaleMode = .resizeFill
        backgroundColor = .black
        physicsWorld.gravity = .zero
        createParallaxBackground()
    }

    func prepareForNewSession(using sector: SectorDefinition) {
        removeAllChildren()
        removeAllActions()
        nodePool.reset()
        createParallaxBackground(theme: sector.theme)
        lastUpdate = 0
        spawnCountdown = 1.0
    }

    func setGameplayActive(_ flag: Bool) {
        isPaused = !flag
    }

    func updateViewport(size: CGSize) {
        guard size != .zero else { return }
        self.size = size
        parallaxLayers.forEach { $0.removeFromParent() }
        createParallaxBackground()
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isPaused else { return }
        if lastUpdate == 0 { lastUpdate = currentTime }
        let delta = currentTime - lastUpdate
        spawnCountdown -= delta
        if spawnCountdown <= 0 {
            spawnNextObject()
        }
        lastUpdate = currentTime
        if debugAutoPlay, let target = children.compactMap({ $0 as? CollectibleNode }).first {
            handleTouch(at: target.position)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }

    private func spawnNextObject() {
        guard let event = spawnProvider?() else { return }
        let node = nodePool.dequeueNode(for: event.definition)
        node.position = CGPoint(x: size.width * event.lane, y: size.height + node.frame.height)
        node.alpha = 0
        addChild(node)
        animateSpawn(node, definition: event.definition)
        let duration = TimeInterval((size.height + 200) / event.definition.fallSpeed) * TimeInterval(slowMotionFactor)
        let move = SKAction.moveTo(y: -node.frame.height, duration: duration)
        node.run(SKAction.sequence([
            move,
            .run { [weak self, weak node] in
                guard let self, let node else { return }
                self.registerMiss(for: node)
            }
        ]))
        spawnCountdown = event.spawnTime / (Double(slowMotionFactor) * spawnMultiplier)
    }

    private func handleTouch(at point: CGPoint) {
        let tappedNodes = nodes(at: point).compactMap { $0 as? CollectibleNode }
        guard let node = tappedNodes.first else { return }
        let definition = node.definition
        node.removeAllActions()
        animateCatch(node)
        gameDelegate?.gameScene(self, didCatch: definition)
        if let hazard = definition.hazard {
            gameDelegate?.gameScene(self, didTrigger: hazard.effect)
        }
        if let power = definition.powerUp {
            runPowerUpEffect(power)
        }
        if let event = definition.event {
            triggerEvent(event.event)
        }
        nodePool.enqueue(node)
    }

    private func registerMiss(for node: CollectibleNode) {
        animateMiss(node)
        gameDelegate?.gameSceneDidRegisterMiss(self)
        nodePool.enqueue(node)
    }

    private func runPowerUpEffect(_ descriptor: PowerUpDescriptor) {
        switch descriptor.type {
        case .slowMotion:
            slowMotionFactor = CGFloat(max(0.2, descriptor.magnitude))
            run(SKAction.sequence([
                SKAction.wait(forDuration: descriptor.duration),
                SKAction.run { [weak self] in self?.slowMotionFactor = 1 }
            ]))
        case .shield, .scoreBoost, .magnet, .timeFreeze:
            break
        }
    }

    private func triggerEvent(_ event: EventType) {
        switch event {
        case .cometRain:
            for _ in 0..<6 { spawnNextObject() }
        case .wormhole:
            enumerateChildNodes(withName: CollectibleNode.nodeName) { node, _ in
                node.removeAllActions()
                node.removeFromParent()
            }
        case .novaPulse:
            run(SKAction.sequence([
                SKAction.run { self.backgroundColor = .white },
                SKAction.wait(forDuration: 0.2),
                SKAction.run { self.backgroundColor = .black }
            ]))
        }
        gameDelegate?.gameScene(self, didTrigger: event)
    }

    private func animateSpawn(_ node: CollectibleNode, definition: CollectibleDefinition) {
        node.alpha = 0
        let fade = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let scale = SKAction.scale(to: 1.1, duration: 0.2)
        node.run(SKAction.group([fade, scale]))
        if let emitter = node.spawnEmitter {
            addChild(emitter)
            emitter.position = node.position
            emitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), .removeFromParent()]))
        }
    }

    private func animateCatch(_ node: CollectibleNode) {
        if let emitter = node.impactEmitter {
            emitter.position = node.position
            addChild(emitter)
            emitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), .removeFromParent()]))
        }
        node.run(SKAction.sequence([SKAction.scale(to: 0.1, duration: 0.15), .removeFromParent()]))
    }

    private func animateMiss(_ node: CollectibleNode) {
        if let emitter = node.missEmitter {
            emitter.position = CGPoint(x: node.position.x, y: 0)
            addChild(emitter)
            emitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), .removeFromParent()]))
        }
        node.removeFromParent()
    }

    private func createParallaxBackground(theme: SectorTheme = .coreNebula) {
        parallaxLayers.forEach { $0.removeFromParent() }
        parallaxLayers = []
        for depth in 0..<3 {
            let layer = SKNode()
            let starCount = 30 + depth * 15
            for _ in 0..<starCount {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
                star.fillColor = SKColor(white: 1, alpha: CGFloat.random(in: 0.1...0.6))
                star.strokeColor = .clear
                star.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
                layer.addChild(star)
            }
            let speed = Double(depth + 1) * 10
            let move = SKAction.customAction(withDuration: 100) { node, time in
                node.position.y -= speed * time
                if node.position.y < -self.size.height {
                    node.position.y = self.size.height
                }
            }
            layer.run(SKAction.repeatForever(move))
            addChild(layer)
            parallaxLayers.append(layer)
        }
        backgroundColor = SKColor(themeColor: theme)
    }

    func applyDebugSlowMotion(_ enabled: Bool) {
        slowMotionFactor = enabled ? 0.4 : 1
    }

    func setAutoPlay(_ enabled: Bool) {
        debugAutoPlay = enabled
    }
}

private final class CollectibleNode: SKShapeNode {
    static let nodeName = "collectible"
    var definition: CollectibleDefinition {
        didSet { refreshAppearance() }
    }
    var spawnEmitter: SKEmitterNode?
    var impactEmitter: SKEmitterNode?
    var missEmitter: SKEmitterNode?

    init(definition: CollectibleDefinition) {
        self.definition = definition
        super.init()
        name = CollectibleNode.nodeName
        refreshAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureEmitters() {
        spawnEmitter = CollectibleNode.makeEmitter(color: definition.animation.spawnColor)
        impactEmitter = CollectibleNode.makeEmitter(color: definition.animation.impactColor)
        missEmitter = CollectibleNode.makeEmitter(color: definition.animation.missColor)
    }

    private func refreshAppearance() {
        path = CGPath(ellipseIn: CGRect(x: -definition.radius, y: -definition.radius, width: definition.radius * 2, height: definition.radius * 2), transform: nil)
        fillColor = SKColor(definition.animation.idleColor)
        strokeColor = SKColor(definition.animation.spawnColor)
        glowWidth = definition.animation.glow
    }

    private static func makeEmitter(color: Color) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleColor = SKColor(color)
        emitter.particleBirthRate = 120
        emitter.particleLifetime = 0.4
        emitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        emitter.particleSpeed = 80
        emitter.numParticlesToEmit = 40
        return emitter
    }
}

private final class CollectibleNodePool {
    private var storage: [String: [CollectibleNode]] = [:]

    func dequeueNode(for definition: CollectibleDefinition) -> CollectibleNode {
        if var list = storage[definition.id], let node = list.popLast() {
            storage[definition.id] = list
            node.definition = definition
            return node
        }
        let node = CollectibleNode(definition: definition)
        node.configureEmitters()
        return node
    }

    func enqueue(_ node: CollectibleNode) {
        node.removeAllActions()
        node.removeFromParent()
        var list = storage[node.definition.id] ?? []
        list.append(node)
        storage[node.definition.id] = list
    }

    func reset() {
        storage.removeAll()
    }
}

private extension SKColor {
    convenience init(_ color: Color) {
        let components = color.components
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    convenience init(themeColor: SectorTheme) {
        switch themeColor {
        case .coreNebula: self.init(red: 0.05, green: 0.04, blue: 0.08, alpha: 1)
        case .auroraStrand: self.init(red: 0.02, green: 0.1, blue: 0.15, alpha: 1)
        case .eclipseRidge: self.init(red: 0.1, green: 0.02, blue: 0.08, alpha: 1)
        case .chronoCradle: self.init(red: 0.03, green: 0.05, blue: 0.12, alpha: 1)
        }
    }
}

private extension Color {
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        #if os(iOS)
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
        #else
        return (1, 1, 1, 1)
        #endif
    }
}
