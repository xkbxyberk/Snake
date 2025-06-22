import UIKit
import SpriteKit

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
        // Scene bağlantısı kesildiğinde
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Uygulama aktif hale geldiğinde
        HapticManager.shared.start()

        if #available(iOS 16.0, *) {
            if let windowScene = scene as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Uygulama pasif hale geldiğinde (App Switcher açıldığında)
        HapticManager.shared.stop()
        
        // Oyun sahnesini kontrol et ve gerekirse duraklat
        checkAndPauseGameIfNeeded()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Uygulama ön plana geldiğinde
        if #available(iOS 16.0, *) {
            if let windowScene = scene as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Uygulama arka plana geçtiğinde
        // Oyun sahnesini kontrol et ve gerekirse duraklat
        checkAndPauseGameIfNeeded()
    }

    // MARK: - Game Scene Control Methods
    
    /// Mevcut sahnenin GameScene olup olmadığını kontrol eder ve oyun aktifse duraklatır
    private func checkAndPauseGameIfNeeded() {
        guard let window = window,
              let gameViewController = window.rootViewController as? GameViewController,
              let skView = gameViewController.view as? SKView,
              let gameScene = skView.scene as? GameScene else {
            return
        }
        
        // Oyun aktif ve duraklatılmamışsa duraklat
        if gameScene.isGameRunning && !gameScene.isGamePaused && !gameScene.isCountdownActive {
            DispatchQueue.main.async {
                gameScene.pauseGame()
            }
        }
    }
}
