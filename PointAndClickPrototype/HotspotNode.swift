import SpriteKit

final class HotspotNode: SKSpriteNode {
    let hotspotID: String
    let displayName: String
    let interactionPoint: CGPoint

    init(
        hotspotID: String,
        displayName: String,
        size: CGSize,
        position: CGPoint,
        interactionPoint: CGPoint
    ) {
        self.hotspotID = hotspotID
        self.displayName = displayName
        self.interactionPoint = interactionPoint

        super.init(texture: nil, color: .clear, size: size)

        self.position = position
        self.name = "hotspot_\(hotspotID)"
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.isUserInteractionEnabled = false

        #if DEBUG
        let debugFrame = SKShapeNode(rectOf: size)
        debugFrame.strokeColor = .yellow
        debugFrame.lineWidth = 1
        debugFrame.alpha = 0.25
        debugFrame.position = CGPoint(x: 0, y: size.height / 2)
        addChild(debugFrame)
        #endif
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
