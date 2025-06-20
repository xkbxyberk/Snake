import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }

        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.rootViewController = GameViewController()

        self.window = newWindow
        newWindow.makeKeyAndVisible()
    }

    // MARK: - Scene Lifecycle

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        HapticManager.shared.start()

        if #available(iOS 16.0, *) {
            if let windowScene = scene as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        HapticManager.shared.stop()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if #available(iOS 16.0, *) {
            if let windowScene = scene as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
