# Point-and-Click SpriteKit Prototype (iPad)

Minimal playable Swift + SpriteKit adventure prototype with:
- One scrollable room with 3 parallax layers (`bg/mid/fg`)
- Tap-to-walk movement on walkable ground
- 3 hotspots (`Ancient Statue`, `Rusty Door`, `Loose Brick`)
- Inventory bar (5 slots) with one usable item (`Brass Key`)
- Default verb `USE`, long-press for `LOOK`
- Codable single-slot save/load (`GameState`)

## Source Files
Located in:
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/GameViewController.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/RoomScene.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/PlayerNode.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/HotspotNode.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/InventoryModel.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/InventoryUI.swift`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/GameState.swift`

## Quick Run (Xcode)
1. Create a new iOS App project in Xcode (`Swift`, `Storyboard` or `UIKit App Delegate`, iPad target).
2. Add `SpriteKit.framework` if not already linked.
3. Replace your default `GameViewController.swift` with the one above.
4. Add the other six Swift files to the target.
5. Set `GameViewController` as initial root view controller (or initial VC class in storyboard).
6. Build and run on an iPad simulator/device in landscape.

## Asset Folder Structure
Add these to your app target `Copy Bundle Resources`:

- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Rooms/room01_bg.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Rooms/room01_mid.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Rooms/room01_fg.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_idle_down_0001.png` ... `hero_idle_down_0006.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_walk_down_0001.png` ... `hero_walk_down_0008.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_walk_up_0001.png` ... `hero_walk_up_0008.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_walk_left_0001.png` ... `hero_walk_left_0008.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_walk_right_0001.png` ... `hero_walk_right_0008.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Hero.atlas/hero_interact_reach_down_0001.png` ... `hero_interact_reach_down_0004.png`
- `/Users/roberto/Documents/GitHub/pointandclick_test/PointAndClickPrototype/Resources/Inventory.atlas/inv_brass_key.png`

Notes:
- Current code runs with placeholders if assets are missing.
- Keep exact filenames (case-sensitive).
- Atlas folder names should remain `Hero.atlas` and `Inventory.atlas`.

## Gameplay Notes
- Tap walkable ground to move.
- Tap hotspot to `USE`.
- Long-press hotspot to `LOOK`.
- `Loose Brick` reveals `Brass Key` once.
- Select `Brass Key` from inventory then tap `Rusty Door` to unlock.
- Save is auto-written to app documents (`save_slot_01.json`).
