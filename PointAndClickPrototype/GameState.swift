import Foundation

final class GameState: Codable {
    static let shared = GameState.loadOrDefault()

    var keyFound: Bool
    var doorUnlocked: Bool
    var inventoryItemIDs: Set<String>

    init(keyFound: Bool = false, doorUnlocked: Bool = false, inventoryItemIDs: Set<String> = []) {
        self.keyFound = keyFound
        self.doorUnlocked = doorUnlocked
        self.inventoryItemIDs = inventoryItemIDs
    }

    private static var saveURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("save_slot_01.json")
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(self)
            try data.write(to: Self.saveURL, options: .atomic)
        } catch {
            print("Save failed: \(error)")
        }
    }

    static func loadOrDefault() -> GameState {
        do {
            let data = try Data(contentsOf: saveURL)
            return try JSONDecoder().decode(GameState.self, from: data)
        } catch {
            return GameState()
        }
    }

    func resetProgress() {
        keyFound = false
        doorUnlocked = false
        inventoryItemIDs = []
        save()
    }
}
