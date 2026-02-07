import SpriteKit
import UIKit

final class InventoryUI: SKNode {
    private struct SlotView {
        let bg: SKShapeNode
        let icon: SKSpriteNode
        let index: Int
    }

    private let slotCount: Int
    private let slotSize = CGSize(width: 78, height: 78)
    private var slots: [SlotView] = []

    private let barBackground = SKShapeNode(rectOf: CGSize(width: 520, height: 108), cornerRadius: 12)
    private let selectedOutline = SKShapeNode(rectOf: CGSize(width: 86, height: 86), cornerRadius: 10)

    private var model: InventoryModel?

    var onItemTapped: ((String) -> Void)?

    init(slotCount: Int = 5) {
        self.slotCount = slotCount
        super.init()
        name = "inventory_ui"
        isUserInteractionEnabled = false

        barBackground.fillColor = UIColor.black.withAlphaComponent(0.45)
        barBackground.strokeColor = UIColor.white.withAlphaComponent(0.25)
        barBackground.lineWidth = 1
        barBackground.zPosition = 1000
        addChild(barBackground)

        selectedOutline.strokeColor = UIColor.systemYellow
        selectedOutline.lineWidth = 3
        selectedOutline.fillColor = .clear
        selectedOutline.isHidden = true
        selectedOutline.zPosition = 1003
        addChild(selectedOutline)

        createSlots()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSlots() {
        let spacing: CGFloat = 12
        let totalWidth = CGFloat(slotCount) * slotSize.width + CGFloat(slotCount - 1) * spacing
        let leftEdge = -totalWidth / 2 + slotSize.width / 2

        for i in 0..<slotCount {
            let x = leftEdge + CGFloat(i) * (slotSize.width + spacing)
            let position = CGPoint(x: x, y: 0)

            let bg = SKShapeNode(rectOf: slotSize, cornerRadius: 8)
            bg.fillColor = UIColor.white.withAlphaComponent(0.08)
            bg.strokeColor = UIColor.white.withAlphaComponent(0.25)
            bg.lineWidth = 1
            bg.position = position
            bg.zPosition = 1001
            bg.name = "inventory_slot_\(i)"
            addChild(bg)

            let icon = SKSpriteNode(color: .clear, size: CGSize(width: 56, height: 56))
            icon.position = position
            icon.zPosition = 1002
            icon.name = "inventory_item_\(i)"
            icon.isHidden = true
            addChild(icon)

            slots.append(SlotView(bg: bg, icon: icon, index: i))
        }
    }

    func bind(model: InventoryModel) {
        self.model = model
        render()
    }

    func render() {
        guard let model else { return }
        for slot in slots {
            if slot.index < model.items.count {
                let item = model.items[slot.index]
                slot.icon.isHidden = false
                slot.icon.texture = loadIconTexture(named: item.iconName)
                slot.icon.color = .white
                slot.icon.colorBlendFactor = 0
                slot.icon.size = CGSize(width: 56, height: 56)
                slot.icon.name = "inventory_item_\(item.id)"
            } else {
                slot.icon.isHidden = true
                slot.icon.texture = nil
                slot.icon.name = "inventory_item_empty_\(slot.index)"
            }
        }

        if let selectedID = model.selectedItemID,
           let selectedIndex = model.items.firstIndex(where: { $0.id == selectedID }) {
            selectedOutline.isHidden = false
            selectedOutline.position = slots[selectedIndex].bg.position
        } else {
            selectedOutline.isHidden = true
        }
    }

    private func loadIconTexture(named name: String) -> SKTexture {
        let atlas = SKTextureAtlas(named: "Inventory")
        let filename = "\(name).png"
        if atlas.textureNames.contains(filename) {
            return atlas.textureNamed(name)
        }

        let size = CGSize(width: 56, height: 56)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.systemYellow.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            UIColor.black.setStroke()
            context.stroke(CGRect(x: 6, y: 6, width: 44, height: 44), width: 3)
        }
        return SKTexture(image: image)
    }

    func inventoryItemID(at nodeName: String) -> String? {
        guard nodeName.hasPrefix("inventory_item_") else { return nil }
        let id = String(nodeName.dropFirst("inventory_item_".count))
        if id.hasPrefix("empty_") || id.isEmpty {
            return nil
        }
        return id
    }
}
