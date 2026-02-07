import Foundation

struct InventoryItem: Equatable, Codable {
    let id: String
    let displayName: String
    let iconName: String

    static let brassKey = InventoryItem(
        id: "brass_key",
        displayName: "Brass Key",
        iconName: "inv_brass_key"
    )
}

final class InventoryModel {
    private(set) var items: [InventoryItem] = []
    private(set) var selectedItemID: String?

    var onChanged: (() -> Void)?

    func hasItem(id: String) -> Bool {
        items.contains { $0.id == id }
    }

    func item(for id: String) -> InventoryItem? {
        items.first { $0.id == id }
    }

    func addItem(_ item: InventoryItem) {
        guard !hasItem(id: item.id) else { return }
        items.append(item)
        onChanged?()
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
        if selectedItemID == id {
            selectedItemID = nil
        }
        onChanged?()
    }

    func toggleSelection(itemID: String) {
        selectedItemID = (selectedItemID == itemID) ? nil : itemID
        onChanged?()
    }

    func clearSelection() {
        selectedItemID = nil
        onChanged?()
    }
}
