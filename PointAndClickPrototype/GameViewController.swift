import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    private var skView: SKView {
        guard let view = view as? SKView else {
            fatalError("Expected root view to be SKView")
        }
        return view
    }

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        let scene = RoomScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }
}
