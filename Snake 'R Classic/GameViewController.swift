import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    //MARK: - View Lifecycle

    override func loadView() {
        self.view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let view = self.view as? SKView {
            guard view.scene == nil else { return }

            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            view.presentScene(scene)
        }
    }

    //MARK: - Interface Orientation

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    //MARK: - UI Visibility

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
