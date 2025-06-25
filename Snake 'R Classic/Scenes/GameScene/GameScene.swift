import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Sabit Oyun Alanı Ayarları (iPhone 14 Pro Max Standardı)
    internal let UNIVERSAL_GAME_WIDTH = 27
    internal let UNIVERSAL_GAME_HEIGHT = 42
    
    // MARK: - Dinamik Görsel Ayarları
    internal var cellSize: CGFloat = 12
    internal var gameWidth = 27  // Artık sabit
    internal var gameHeight = 42 // Artık sabit
    
    // MARK: - Oyun Alanı Koordinatları
    internal var gameAreaStartX: CGFloat = 0
    internal var gameAreaStartY: CGFloat = 0
    internal var gameAreaWidth: CGFloat = 0
    internal var gameAreaHeight: CGFloat = 0
    
    // MARK: - Üst Bilgi Çubuğu (Header) Koordinatları
    internal var headerBarHeight: CGFloat = 8
    internal var headerBarStartY: CGFloat = 0
    
    // MARK: - Temel Oyun Değişkenleri
    internal var snake: Snake!
    internal var food: CGPoint!
    internal var gameTimer: Timer?
    internal var currentDirection: Direction = .right
    internal var nextDirection: Direction = .right
    internal var score = 0
    internal var highScore = 0
    
    // MARK: - Dinamik Grace Period (Hata Toleransı) Sistemi
    internal var isInGracePeriod = false
    internal var gracePeriodStartTime: TimeInterval = 0
    internal var gracePeriodDuration: TimeInterval = 0.35
    internal var baseGracePeriodDuration: TimeInterval = 0.35
    
    // MARK: - Gelişmiş Skor Sistemi
    internal var currentGameScore = 0
    internal var sessionHighScore = 0
    internal var allTimeHighScore = 0
    internal var isNewRecord = false
    
    // MARK: - Oyuncu Adı Giriş Sistemi
    internal var playerName: String = ""
    internal var isNameInputActive = false
    internal var nameInputContainer: SKNode?
    internal var nameTextField: UITextField?
    
    // MARK: - Gelişmiş Hız Sistemi
    internal var baseGameSpeed: TimeInterval = 0.5
    internal var currentGameSpeed: TimeInterval = 0.5
    internal var speedSetting: Int = 2
    
    // MARK: - Çok Aşamalı Hız ve Grace Period Profilleri (27x42 Grid İçin Optimize)
    internal struct EnhancedSpeedProfile {
        let baseSpeed: TimeInterval
        let phases: [(threshold: Int, speedRate: Double, gracePeriodRate: Double)]
        let minSpeed: TimeInterval
        let baseGracePeriod: TimeInterval
        let minGracePeriod: TimeInterval
    }
    
    internal let speedProfiles: [EnhancedSpeedProfile] = [
        // SLOW Profili - 27x42 Grid İçin Optimize
        EnhancedSpeedProfile(
            baseSpeed: 0.16,
            phases: [
                (threshold: 10, speedRate: 0.005, gracePeriodRate: 0.008),
                (threshold: 22, speedRate: 0.006, gracePeriodRate: 0.009),
                (threshold: 36, speedRate: 0.007, gracePeriodRate: 0.010),
                (threshold: 52, speedRate: 0.008, gracePeriodRate: 0.011),
                (threshold: 70, speedRate: 0.009, gracePeriodRate: 0.012),
                (threshold: 90, speedRate: 0.010, gracePeriodRate: 0.013),
                (threshold: 112, speedRate: 0.011, gracePeriodRate: 0.014),
                (threshold: 136, speedRate: 0.012, gracePeriodRate: 0.015),
                (threshold: 162, speedRate: 0.013, gracePeriodRate: 0.016),
                (threshold: 190, speedRate: 0.014, gracePeriodRate: 0.017),
                (threshold: 220, speedRate: 0.015, gracePeriodRate: 0.018),
                (threshold: 252, speedRate: 0.016, gracePeriodRate: 0.019),
                (threshold: 286, speedRate: 0.017, gracePeriodRate: 0.020),
                (threshold: 322, speedRate: 0.018, gracePeriodRate: 0.021),
                (threshold: 360, speedRate: 0.019, gracePeriodRate: 0.022),
                (threshold: 999, speedRate: 0.020, gracePeriodRate: 0.023)
            ],
            minSpeed: 0.07,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.18
        ),
        
        // NORMAL Profili - 27x42 Grid İçin Optimize
        EnhancedSpeedProfile(
            baseSpeed: 0.13,
            phases: [
                (threshold: 12, speedRate: 0.006, gracePeriodRate: 0.010),
                (threshold: 26, speedRate: 0.007, gracePeriodRate: 0.011),
                (threshold: 42, speedRate: 0.008, gracePeriodRate: 0.012),
                (threshold: 60, speedRate: 0.009, gracePeriodRate: 0.013),
                (threshold: 80, speedRate: 0.010, gracePeriodRate: 0.014),
                (threshold: 102, speedRate: 0.011, gracePeriodRate: 0.015),
                (threshold: 126, speedRate: 0.012, gracePeriodRate: 0.016),
                (threshold: 152, speedRate: 0.013, gracePeriodRate: 0.017),
                (threshold: 180, speedRate: 0.014, gracePeriodRate: 0.018),
                (threshold: 210, speedRate: 0.015, gracePeriodRate: 0.019),
                (threshold: 242, speedRate: 0.016, gracePeriodRate: 0.020),
                (threshold: 276, speedRate: 0.017, gracePeriodRate: 0.021),
                (threshold: 312, speedRate: 0.018, gracePeriodRate: 0.022),
                (threshold: 999, speedRate: 0.019, gracePeriodRate: 0.023)
            ],
            minSpeed: 0.05,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.17
        ),
        
        // FAST Profili - 27x42 Grid İçin Optimize
        EnhancedSpeedProfile(
            baseSpeed: 0.10,
            phases: [
                (threshold: 10, speedRate: 0.007, gracePeriodRate: 0.013),
                (threshold: 22, speedRate: 0.008, gracePeriodRate: 0.014),
                (threshold: 36, speedRate: 0.009, gracePeriodRate: 0.015),
                (threshold: 52, speedRate: 0.010, gracePeriodRate: 0.016),
                (threshold: 70, speedRate: 0.011, gracePeriodRate: 0.017),
                (threshold: 90, speedRate: 0.012, gracePeriodRate: 0.018),
                (threshold: 112, speedRate: 0.013, gracePeriodRate: 0.019),
                (threshold: 136, speedRate: 0.014, gracePeriodRate: 0.020),
                (threshold: 162, speedRate: 0.015, gracePeriodRate: 0.021),
                (threshold: 190, speedRate: 0.016, gracePeriodRate: 0.022),
                (threshold: 220, speedRate: 0.017, gracePeriodRate: 0.023),
                (threshold: 999, speedRate: 0.018, gracePeriodRate: 0.024)
            ],
            minSpeed: 0.04,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.16
        ),
        
        // VERY FAST Profili - 27x42 Grid İçin Optimize
        EnhancedSpeedProfile(
            baseSpeed: 0.08,
            phases: [
                (threshold: 8, speedRate: 0.008, gracePeriodRate: 0.017),
                (threshold: 18, speedRate: 0.009, gracePeriodRate: 0.018),
                (threshold: 30, speedRate: 0.010, gracePeriodRate: 0.019),
                (threshold: 44, speedRate: 0.011, gracePeriodRate: 0.020),
                (threshold: 60, speedRate: 0.012, gracePeriodRate: 0.021),
                (threshold: 78, speedRate: 0.013, gracePeriodRate: 0.022),
                (threshold: 98, speedRate: 0.014, gracePeriodRate: 0.023),
                (threshold: 120, speedRate: 0.015, gracePeriodRate: 0.024),
                (threshold: 144, speedRate: 0.016, gracePeriodRate: 0.025),
                (threshold: 999, speedRate: 0.017, gracePeriodRate: 0.026)
            ],
            minSpeed: 0.025,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.15
        )
    ]
    
    // MARK: - Aşama (Phase) Takibi
    internal var currentPhaseIndex: Int = 0
    
    // MARK: - Kullanıcı Ayarları
    internal var soundEnabled: Bool = true
    internal var hapticEnabled: Bool = true
    
    // MARK: - Arayüz (UI) Elementleri
    internal var scoreLabel: SKLabelNode!
    internal var highScoreLabel: SKLabelNode!
    internal var gameOverLabel: SKLabelNode!
    internal var restartLabel: SKLabelNode!
    internal var menuLabel: SKLabelNode!
    internal var pauseButton: SKShapeNode!
    internal var headerBar: SKSpriteNode!
    
    // MARK: - Kontrol Butonları
    internal var upButton: SKShapeNode!
    internal var downButton: SKShapeNode!
    internal var leftButton: SKShapeNode!
    internal var rightButton: SKShapeNode!
    
    // MARK: - Oyun Durum Yönetimi
    internal var isGameRunning = false
    internal var isGamePaused = false
    internal var isCountdownActive = false
    
    // MARK: - Geri Sayım Sistemi
    internal var countdownNumber = 3
    internal var countdownLabel: SKLabelNode!
    internal var countdownShadow: SKLabelNode!
    internal var countdownContainer: SKNode!
    internal var countdownTimer: Timer?
    
    // MARK: - Renk Paleti
    internal let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    internal let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    internal let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    internal let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    internal let countdownColors = [
        SKColor.red,
        SKColor.orange,
        SKColor.yellow,
        SKColor.green
    ]
    
    override func didMove(to view: SKView) {
        loadSettings()
        initializeScoreSystem()
        setupGame()
        startCountdown()
    }
    
    // MARK: - Skor Sistemini Başlatma
    private func initializeScoreSystem() {
        allTimeHighScore = ScoreManager.shared.getAllTimeHighScore()
        sessionHighScore = 0
        currentGameScore = 0
        highScore = allTimeHighScore
        currentPhaseIndex = 0
    }
    
    // MARK: - Ayarları Yükleme
    private func loadSettings() {
        soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        speedSetting = UserDefaults.standard.object(forKey: "gameSpeed") as? Int ?? 2
        
        applySpeedProfile()
    }
    
    // MARK: - Hız ve Grace Period Profilini Uygulama (Güncellenmiş)
    internal func applySpeedProfile() {
        let profileIndex = max(0, min(speedSetting - 1, speedProfiles.count - 1))
        let profile = speedProfiles[profileIndex]
        
        baseGameSpeed = profile.baseSpeed
        currentGameSpeed = baseGameSpeed
        
        baseGracePeriodDuration = profile.baseGracePeriod
        gracePeriodDuration = baseGracePeriodDuration
        
        currentPhaseIndex = 0
    }
    
    // MARK: - Oyun Kurulumu ve Başlatma
    private func setupGame() {
        backgroundColor = backgroundGreen
        
        // Sabit grid boyutları ata
        gameWidth = UNIVERSAL_GAME_WIDTH
        gameHeight = UNIVERSAL_GAME_HEIGHT
        
        calculateGameArea()
        createHeaderBar()
        createGameAreaBorder()
        createControlButtons()
        setupUltraSensitiveControls()
        
        snake = Snake()
        
        createUI()
        spawnFood()
    }
    
    // MARK: - Temizleme (Cleanup)
    deinit {
        gameTimer?.invalidate()
        countdownTimer?.invalidate()
        nameTextField?.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate Metotları
extension GameScene: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count <= 15 {
            playerName = updatedText
            updateNameDisplay()
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveScoreWithName(playerName)
        return true
    }
}
