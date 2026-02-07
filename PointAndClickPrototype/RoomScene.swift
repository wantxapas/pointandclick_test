import SpriteKit
import UIKit

final class RoomScene: SKScene {
    private let gameState = GameState.shared
    private let inventoryModel = InventoryModel()

    private let roomSize = CGSize(width: 2600, height: 1200)
    private let walkableRect = CGRect(x: 140, y: 110, width: 2320, height: 270)

    private let worldNode = SKNode()
    private let parallaxBG = SKSpriteNode()
    private let parallaxMid = SKSpriteNode()
    private let parallaxFG = SKSpriteNode()

    private let player = PlayerNode()
    private let cameraNode2D = SKCameraNode()
    private let inventoryUI = InventoryUI(slotCount: 5)

    private let captionBackground = SKShapeNode(rectOf: CGSize(width: 700, height: 64), cornerRadius: 10)
    private let captionLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    private var hotspots: [String: HotspotNode] = [:]
    private var touchStartTimes: [ObjectIdentifier: TimeInterval] = [:]
    private var isInteractionLocked = false

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupWorld()
        setupCamera()
        setupUI()
        setupHotspots()
        setupInventory()

        player.position = CGPoint(x: 320, y: walkableRect.minY + 15)
        worldNode.addChild(player)

        showCaption("Tap to walk. Long-press to look.")
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutUI()
    }

    override func update(_ currentTime: TimeInterval) {
        updateCamera()
        updateParallax()
    }

    private func setupWorld() {
        addChild(worldNode)

        configureLayer(parallaxBG, imageName: "room01_bg", fallback: UIColor(red: 0.18, green: 0.22, blue: 0.30, alpha: 1))
        configureLayer(parallaxMid, imageName: "room01_mid", fallback: UIColor(red: 0.28, green: 0.30, blue: 0.26, alpha: 0.92))
        configureLayer(parallaxFG, imageName: "room01_fg", fallback: UIColor(red: 0.18, green: 0.20, blue: 0.16, alpha: 0.90))

        parallaxBG.zPosition = -30
        parallaxMid.zPosition = -20
        parallaxFG.zPosition = 20

        worldNode.addChild(parallaxBG)
        worldNode.addChild(parallaxMid)
        worldNode.addChild(parallaxFG)

        #if DEBUG
        let walkableOverlay = SKShapeNode(rect: walkableRect)
        walkableOverlay.strokeColor = .green
        walkableOverlay.lineWidth = 2
        walkableOverlay.fillColor = .clear
        walkableOverlay.zPosition = 30
        worldNode.addChild(walkableOverlay)
        #endif
    }

    private func configureLayer(_ node: SKSpriteNode, imageName: String, fallback: UIColor) {
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.position = .zero

        if Bundle.main.path(forResource: imageName, ofType: "png") != nil {
            node.texture = SKTexture(imageNamed: imageName)
            node.color = .white
            node.colorBlendFactor = 0
        } else {
            node.texture = nil
            node.color = fallback
            node.colorBlendFactor = 1
        }

        node.size = roomSize
    }

    private func setupCamera() {
        addChild(cameraNode2D)
        camera = cameraNode2D
        cameraNode2D.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    private func setupUI() {
        captionBackground.fillColor = UIColor.black.withAlphaComponent(0.45)
        captionBackground.strokeColor = UIColor.white.withAlphaComponent(0.3)
        captionBackground.lineWidth = 1
        captionBackground.zPosition = 1000

        captionLabel.fontSize = 24
        captionLabel.fontColor = .white
        captionLabel.verticalAlignmentMode = .center
        captionLabel.horizontalAlignmentMode = .center
        captionLabel.zPosition = 1001

        cameraNode2D.addChild(captionBackground)
        cameraNode2D.addChild(captionLabel)
        cameraNode2D.addChild(inventoryUI)

        layoutUI()
    }

    private func layoutUI() {
        inventoryUI.position = CGPoint(x: 0, y: -size.height / 2 + 86)
        captionBackground.position = CGPoint(x: 0, y: -size.height / 2 + 166)
        captionLabel.position = captionBackground.position
    }

    private func setupHotspots() {
        let statue = HotspotNode(
            hotspotID: "statue",
            displayName: "Ancient Statue",
            size: CGSize(width: 170, height: 250),
            position: CGPoint(x: 880, y: walkableRect.minY + 10),
            interactionPoint: CGPoint(x: 860, y: walkableRect.minY + 12)
        )

        let door = HotspotNode(
            hotspotID: "door",
            displayName: "Rusty Door",
            size: CGSize(width: 160, height: 310),
            position: CGPoint(x: 1870, y: walkableRect.minY + 10),
            interactionPoint: CGPoint(x: 1810, y: walkableRect.minY + 12)
        )

        let brick = HotspotNode(
            hotspotID: "brick",
            displayName: "Loose Brick",
            size: CGSize(width: 160, height: 140),
            position: CGPoint(x: 1280, y: walkableRect.minY + 10),
            interactionPoint: CGPoint(x: 1260, y: walkableRect.minY + 12)
        )

        [statue, door, brick].forEach {
            hotspots[$0.hotspotID] = $0
            worldNode.addChild($0)
        }
    }

    private func setupInventory() {
        inventoryUI.bind(model: inventoryModel)

        inventoryModel.onChanged = { [weak self] in
            guard let self else { return }
            self.inventoryUI.render()
            self.gameState.inventoryItemIDs = Set(self.inventoryModel.items.map(\.id))
            self.gameState.save()
        }

        if gameState.keyFound || gameState.inventoryItemIDs.contains(InventoryItem.brassKey.id) {
            inventoryModel.addItem(.brassKey)
        }

        inventoryUI.render()
    }

    private func updateCamera() {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        let minX = halfWidth
        let maxX = roomSize.width - halfWidth
        let minY = halfHeight
        let maxY = roomSize.height - halfHeight

        let targetX = player.position.x.clamped(to: minX...maxX)
        let fixedY = min(maxY, max(minY, size.height * 0.5))

        cameraNode2D.position = CGPoint(x: targetX, y: fixedY)
    }

    private func updateParallax() {
        let centerX = roomSize.width / 2
        let offset = cameraNode2D.position.x - centerX

        parallaxBG.position.x = -offset * 0.16
        parallaxMid.position.x = -offset * 0.34
        parallaxFG.position.x = -offset * 0.60
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchStartTimes[ObjectIdentifier(touch)] = touch.timestamp
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let key = ObjectIdentifier(touch)
            let start = touchStartTimes[key] ?? touch.timestamp
            let isLongPress = (touch.timestamp - start) >= 0.42
            touchStartTimes.removeValue(forKey: key)

            handleTouchEnd(touch: touch, isLook: isLongPress)
        }
    }

    private func handleTouchEnd(touch: UITouch, isLook: Bool) {
        let scenePoint = touch.location(in: self)

        if let inventoryItemID = tappedInventoryItemID(at: scenePoint) {
            inventoryModel.toggleSelection(itemID: inventoryItemID)
            if let selected = inventoryModel.selectedItemID,
               let selectedItem = inventoryModel.item(for: selected) {
                showCaption("Selected: \(selectedItem.displayName)")
            } else {
                showCaption("Item selection cleared")
            }
            return
        }

        if isInteractionLocked { return }

        if let hotspot = hotspot(at: scenePoint) {
            triggerHotspot(hotspot, isLook: isLook)
            return
        }

        if walkableRect.contains(scenePoint) {
            let clamped = clampToWalkableRect(scenePoint)
            player.move(to: clamped)
        }
    }

    private func tappedInventoryItemID(at scenePoint: CGPoint) -> String? {
        let tapped = nodes(at: scenePoint)
        for node in tapped {
            guard let name = node.name else { continue }
            if let itemID = inventoryUI.inventoryItemID(at: name), inventoryModel.hasItem(id: itemID) {
                return itemID
            }
        }
        return nil
    }

    private func hotspot(at point: CGPoint) -> HotspotNode? {
        let tappedNodes = nodes(at: point)
        for node in tappedNodes {
            if let hotspot = node as? HotspotNode { return hotspot }
            if let parent = node.parent as? HotspotNode { return parent }
        }
        return nil
    }

    private func triggerHotspot(_ hotspot: HotspotNode, isLook: Bool) {
        isInteractionLocked = true
        let interactionPoint = clampToWalkableRect(hotspot.interactionPoint)

        player.move(to: interactionPoint) { [weak self] in
            guard let self else { return }

            if isLook {
                self.handleLook(on: hotspot)
                self.isInteractionLocked = false
                return
            }

            self.player.playInteract {
                self.handleUse(on: hotspot)
                self.isInteractionLocked = false
            }
        }
    }

    private func handleLook(on hotspot: HotspotNode) {
        switch hotspot.hotspotID {
        case "statue":
            showCaption("An ancient statue worn smooth by time.")
        case "door":
            showCaption(gameState.doorUnlocked ? "The rusty door is now unlocked." : "A heavy rusty door. It's locked tight.")
        case "brick":
            showCaption(gameState.keyFound ? "The gap behind the brick is empty." : "One brick looks loose.")
        default:
            showCaption("Nothing unusual.")
        }
    }

    private func handleUse(on hotspot: HotspotNode) {
        let selectedItemID = inventoryModel.selectedItemID

        switch hotspot.hotspotID {
        case "statue":
            showCaption(selectedItemID == InventoryItem.brassKey.id ? "The key doesn't fit anything on the statue." : "You brush dust from the ancient statue.")

        case "door":
            if gameState.doorUnlocked {
                showCaption("The door creaks open.")
                return
            }

            if selectedItemID == InventoryItem.brassKey.id, inventoryModel.hasItem(id: InventoryItem.brassKey.id) {
                gameState.doorUnlocked = true
                gameState.save()
                showCaption("You unlock the rusty door.")
                inventoryModel.clearSelection()
            } else {
                showCaption("It's locked.")
            }

        case "brick":
            if gameState.keyFound {
                showCaption("Only dust behind the loose brick now.")
                return
            }

            gameState.keyFound = true
            gameState.inventoryItemIDs.insert(InventoryItem.brassKey.id)
            inventoryModel.addItem(.brassKey)
            gameState.save()
            showCaption("You found a Brass Key.")

        default:
            showCaption("Nothing happens.")
        }
    }

    private func clampToWalkableRect(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x.clamped(to: walkableRect.minX...walkableRect.maxX),
            y: point.y.clamped(to: walkableRect.minY...walkableRect.maxY)
        )
    }

    private func showCaption(_ text: String) {
        captionLabel.text = text
        captionLabel.removeAction(forKey: "captionPulse")

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeAlpha(to: 0.95, duration: 0.25)
        ])
        captionLabel.run(pulse, withKey: "captionPulse")
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
