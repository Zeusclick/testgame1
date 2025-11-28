import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRegisterCatch(points: Int)
    func gameSceneDidRegisterMiss()
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?

    private var lastSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 1.4
    private var isGameplayActive = false
    private let collectibleName = "collectible"

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    convenience init() {
        self.init(size: CGSize(width: 430, height: 932))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        scaleMode = .resizeFill
        backgroundColor = .black
        isUserInteractionEnabled = true
        createStarfield()
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.ignoresSiblingOrder = true
    }

    func updateViewport(size: CGSize) {
        guard size != .zero else { return }
        self.size = size
        removeStarfield()
        createStarfield()
    }

    func prepareForNewSession() {
        removeAllChildren()
        removeAllActions()
        lastSpawnTime = 0
        spawnInterval = 1.4
        createStarfield()
    }

    func setGameplayActive(_ isActive: Bool) {
        isGameplayActive = isActive
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameplayActive else { return }
        if lastSpawnTime == 0 {
            lastSpawnTime = currentTime
        }

        if currentTime - lastSpawnTime >= spawnInterval {
            spawnCollectible()
            lastSpawnTime = currentTime
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameplayActive, let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleTouch(at: location)
    }

    private func handleTouch(at location: CGPoint) {
        guard let node = nodes(at: location).first(where: { $0.name == collectibleName }) else { return }
        let catchPosition = node.position
        node.removeAllActions()
        node.removeFromParent()
        showCatchEffect(at: catchPosition)
        gameDelegate?.gameSceneDidRegisterCatch(points: 10)
    }

    private func spawnCollectible() {
        guard size.width > 0 else { return }
        let radius: CGFloat = CGFloat.random(in: 14...22)
        let node = SKShapeNode(circleOfRadius: radius)
        node.name = collectibleName
        node.fillColor = SKColor(red: 0.6, green: 0.3, blue: 1.0, alpha: 1.0)
        node.strokeColor = SKColor(white: 1.0, alpha: 0.9)
        node.lineWidth = 2
        node.glowWidth = 4

        let positionX = CGFloat.random(in: radius...(size.width - radius))
        node.position = CGPoint(x: positionX, y: size.height + radius * 2)
        addChild(node)

        let fallDuration = TimeInterval.random(in: 2.2...3.6)
        let fallAction = SKAction.move(to: CGPoint(x: positionX, y: -radius * 2), duration: fallDuration)
        let missAction = SKAction.run { [weak self, weak node] in
            guard let self = self, let node = node else { return }
            self.gameDelegate?.gameSceneDidRegisterMiss()
            self.showMissEffect(at: node.position)
            node.removeFromParent()
        }

        node.run(SKAction.sequence([fallAction, missAction]))
    }

    private func createStarfield(count: Int = 60) {
        for index in 0..<count {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            star.fillColor = SKColor(white: 1, alpha: CGFloat.random(in: 0.3...0.9))
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.name = "starfield_\(index)"
            addChild(star)

            let duration = TimeInterval.random(in: 6...12)
            let fadeSequence = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: duration / 2),
                SKAction.fadeAlpha(to: 0.9, duration: duration / 2)
            ])
            star.run(SKAction.repeatForever(fadeSequence))
        }
    }

    private func removeStarfield() {
        enumerateChildNodes(withName: "starfield_*") { node, _ in
            node.removeAllActions()
            node.removeFromParent()
        }
    }

    private func showCatchEffect(at position: CGPoint) {
        let pulse = SKShapeNode(circleOfRadius: 30)
        pulse.position = position
        pulse.fillColor = SKColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 0.4)
        pulse.strokeColor = .clear
        addChild(pulse)

        let expand = SKAction.group([
            SKAction.scale(to: 2.0, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3)
        ])
        pulse.run(SKAction.sequence([expand, .removeFromParent()]))
    }

    private func showMissEffect(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.particleBirthRate = 150
        emitter.particleLifetime = 0.4
        emitter.particleSize = CGSize(width: 3, height: 3)
        emitter.particleColor = .systemPink
        emitter.particleSpeed = 140
        emitter.particleSpeedRange = 80
        emitter.emissionAngleRange = .pi * 2
        emitter.numParticlesToEmit = 40
        emitter.position = CGPoint(x: position.x, y: max(position.y, 0))
        addChild(emitter)

        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            .removeFromParent()
        ]))
    }
}
