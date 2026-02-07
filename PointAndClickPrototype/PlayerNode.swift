import SpriteKit
import UIKit

final class PlayerNode: SKNode {
    enum Facing {
        case up
        case down
        case left
        case right
    }

    private let sprite: SKSpriteNode
    private let moveSpeed: CGFloat = 260.0

    private var idleDownFrames: [SKTexture] = []
    private var walkDownFrames: [SKTexture] = []
    private var walkUpFrames: [SKTexture] = []
    private var walkLeftFrames: [SKTexture] = []
    private var walkRightFrames: [SKTexture] = []
    private var interactDownFrames: [SKTexture] = []

    private(set) var facing: Facing = .down
    private(set) var isMoving: Bool = false

    override init() {
        sprite = SKSpriteNode(color: .systemBlue, size: CGSize(width: 80, height: 130))
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        super.init()

        name = "player"
        addChild(sprite)

        loadAnimations()
        playIdle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadAnimations() {
        let atlas = SKTextureAtlas(named: "Hero")
        let names = Set(atlas.textureNames)

        idleDownFrames = loadFrames(prefix: "hero_idle_down", count: 6, atlas: atlas, names: names)
        walkDownFrames = loadFrames(prefix: "hero_walk_down", count: 8, atlas: atlas, names: names)
        walkUpFrames = loadFrames(prefix: "hero_walk_up", count: 8, atlas: atlas, names: names)
        walkLeftFrames = loadFrames(prefix: "hero_walk_left", count: 8, atlas: atlas, names: names)
        walkRightFrames = loadFrames(prefix: "hero_walk_right", count: 8, atlas: atlas, names: names)
        interactDownFrames = loadFrames(prefix: "hero_interact_reach_down", count: 4, atlas: atlas, names: names)

        if idleDownFrames.isEmpty {
            idleDownFrames = placeholderFrames(base: .systemBlue, count: 6)
        }
        if walkDownFrames.isEmpty {
            walkDownFrames = placeholderFrames(base: .systemBlue, count: 8)
        }
        if walkUpFrames.isEmpty {
            walkUpFrames = placeholderFrames(base: .systemTeal, count: 8)
        }
        if walkLeftFrames.isEmpty {
            walkLeftFrames = placeholderFrames(base: .systemIndigo, count: 8)
        }
        if walkRightFrames.isEmpty {
            walkRightFrames = placeholderFrames(base: .systemCyan, count: 8)
        }
        if interactDownFrames.isEmpty {
            interactDownFrames = placeholderFrames(base: .systemOrange, count: 4)
        }

        sprite.texture = idleDownFrames.first
        if let texture = sprite.texture {
            sprite.size = texture.size()
            if sprite.size.width <= 1 || sprite.size.height <= 1 {
                sprite.size = CGSize(width: 80, height: 130)
            }
        }
    }

    private func loadFrames(prefix: String, count: Int, atlas: SKTextureAtlas, names: Set<String>) -> [SKTexture] {
        var frames: [SKTexture] = []
        for index in 1...count {
            let name = String(format: "%@_%04d", prefix, index)
            let filename = "\(name).png"
            guard names.contains(filename) else { continue }
            frames.append(atlas.textureNamed(name))
        }
        return frames
    }

    private func placeholderFrames(base: UIColor, count: Int) -> [SKTexture] {
        (0..<count).map { i in
            let color = base.withAlphaComponent(0.78 + CGFloat(i % 3) * 0.07)
            return Self.makeTexture(color: color, size: CGSize(width: 80, height: 130))
        }
    }

    private static func makeTexture(color: UIColor, size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }

    func move(to target: CGPoint, completion: (() -> Void)? = nil) {
        removeAction(forKey: "interact")
        removeAction(forKey: "move")

        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = hypot(dx, dy)
        guard distance > 2 else {
            playIdle()
            completion?()
            return
        }

        isMoving = true
        updateFacing(dx: dx, dy: dy)
        playWalk(for: facing)

        let duration = TimeInterval(distance / moveSpeed)
        let moveAction = SKAction.move(to: target, duration: duration)
        moveAction.timingMode = .easeInEaseOut

        let done = SKAction.run { [weak self] in
            guard let self else { return }
            self.isMoving = false
            self.playIdle()
            completion?()
        }

        run(SKAction.sequence([moveAction, done]), withKey: "move")
    }

    func playInteract(completion: (() -> Void)? = nil) {
        removeAction(forKey: "interact")
        let interact = SKAction.animate(with: interactDownFrames, timePerFrame: 0.09, resize: false, restore: false)
        let end = SKAction.run { [weak self] in
            self?.playIdle()
            completion?()
        }
        run(SKAction.sequence([interact, end]), withKey: "interact")
    }

    func stopMovement() {
        removeAction(forKey: "move")
        isMoving = false
        playIdle()
    }

    private func updateFacing(dx: CGFloat, dy: CGFloat) {
        if abs(dx) > abs(dy) {
            facing = dx >= 0 ? .right : .left
        } else {
            facing = dy >= 0 ? .up : .down
        }
    }

    private func playWalk(for facing: Facing) {
        sprite.removeAction(forKey: "anim")
        let frames: [SKTexture]
        switch facing {
        case .up: frames = walkUpFrames
        case .down: frames = walkDownFrames
        case .left: frames = walkLeftFrames
        case .right: frames = walkRightFrames
        }
        let action = SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.09, resize: false, restore: false))
        sprite.run(action, withKey: "anim")
    }

    func playIdle() {
        sprite.removeAction(forKey: "anim")
        let action = SKAction.repeatForever(SKAction.animate(with: idleDownFrames, timePerFrame: 0.16, resize: false, restore: false))
        sprite.run(action, withKey: "anim")
    }
}
