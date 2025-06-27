import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - Sabit Oyun Alanı Ayarları
    internal var cellSize: CGFloat = 12
    internal let gameWidth = 25
    internal let gameHeight = 35
    
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
    
    // MARK: - Çok Aşamalı Hız ve Grace Period Profilleri
    internal struct EnhancedSpeedProfile {
        let baseSpeed: TimeInterval
        let phases: [(threshold: Int, speedRate: Double, gracePeriodRate: Double)]
        let minSpeed: TimeInterval
        let baseGracePeriod: TimeInterval
        let minGracePeriod: TimeInterval
    }
    
    internal let speedProfiles: [EnhancedSpeedProfile] = [
        // SLOW Profili
        EnhancedSpeedProfile(
            baseSpeed: 0.18,
            phases: [
                (threshold: 8, speedRate: 0.006, gracePeriodRate: 0.010),
                (threshold: 18, speedRate: 0.007, gracePeriodRate: 0.011),
                (threshold: 30, speedRate: 0.008, gracePeriodRate: 0.012),
                (threshold: 44, speedRate: 0.009, gracePeriodRate: 0.013),
                (threshold: 60, speedRate: 0.010, gracePeriodRate: 0.014),
                (threshold: 78, speedRate: 0.011, gracePeriodRate: 0.015),
                (threshold: 98, speedRate: 0.012, gracePeriodRate: 0.016),
                (threshold: 120, speedRate: 0.013, gracePeriodRate: 0.017),
                (threshold: 144, speedRate: 0.014, gracePeriodRate: 0.018),
                (threshold: 170, speedRate: 0.015, gracePeriodRate: 0.019),
                (threshold: 198, speedRate: 0.016, gracePeriodRate: 0.020),
                (threshold: 228, speedRate: 0.017, gracePeriodRate: 0.021),
                (threshold: 260, speedRate: 0.018, gracePeriodRate: 0.022),
                (threshold: 294, speedRate: 0.019, gracePeriodRate: 0.023),
                (threshold: 330, speedRate: 0.020, gracePeriodRate: 0.024),
                (threshold: 999, speedRate: 0.021, gracePeriodRate: 0.025)
            ],
            minSpeed: 0.08,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.19
        ),
        
        // NORMAL Profili
        EnhancedSpeedProfile(
            baseSpeed: 0.15,
            phases: [
                (threshold: 10, speedRate: 0.007, gracePeriodRate: 0.012),
                (threshold: 22, speedRate: 0.008, gracePeriodRate: 0.013),
                (threshold: 36, speedRate: 0.009, gracePeriodRate: 0.014),
                (threshold: 52, speedRate: 0.010, gracePeriodRate: 0.015),
                (threshold: 70, speedRate: 0.011, gracePeriodRate: 0.016),
                (threshold: 90, speedRate: 0.012, gracePeriodRate: 0.017),
                (threshold: 112, speedRate: 0.013, gracePeriodRate: 0.018),
                (threshold: 136, speedRate: 0.014, gracePeriodRate: 0.019),
                (threshold: 162, speedRate: 0.015, gracePeriodRate: 0.020),
                (threshold: 190, speedRate: 0.016, gracePeriodRate: 0.021),
                (threshold: 220, speedRate: 0.017, gracePeriodRate: 0.022),
                (threshold: 252, speedRate: 0.018, gracePeriodRate: 0.023),
                (threshold: 286, speedRate: 0.019, gracePeriodRate: 0.024),
                (threshold: 999, speedRate: 0.020, gracePeriodRate: 0.025)
            ],
            minSpeed: 0.06,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.18
        ),
        
        // FAST Profili
        EnhancedSpeedProfile(
            baseSpeed: 0.12,
            phases: [
                (threshold: 8, speedRate: 0.008, gracePeriodRate: 0.015),
                (threshold: 18, speedRate: 0.009, gracePeriodRate: 0.016),
                (threshold: 30, speedRate: 0.010, gracePeriodRate: 0.017),
                (threshold: 44, speedRate: 0.011, gracePeriodRate: 0.018),
                (threshold: 60, speedRate: 0.012, gracePeriodRate: 0.019),
                (threshold: 78, speedRate: 0.013, gracePeriodRate: 0.020),
                (threshold: 98, speedRate: 0.014, gracePeriodRate: 0.021),
                (threshold: 120, speedRate: 0.015, gracePeriodRate: 0.022),
                (threshold: 144, speedRate: 0.016, gracePeriodRate: 0.023),
                (threshold: 170, speedRate: 0.017, gracePeriodRate: 0.024),
                (threshold: 198, speedRate: 0.018, gracePeriodRate: 0.025),
                (threshold: 999, speedRate: 0.019, gracePeriodRate: 0.026)
            ],
            minSpeed: 0.045,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.17
        ),
        
        // VERY FAST Profili
        EnhancedSpeedProfile(
            baseSpeed: 0.09,
            phases: [
                (threshold: 6, speedRate: 0.009, gracePeriodRate: 0.019),
                (threshold: 14, speedRate: 0.010, gracePeriodRate: 0.020),
                (threshold: 24, speedRate: 0.011, gracePeriodRate: 0.021),
                (threshold: 36, speedRate: 0.012, gracePeriodRate: 0.022),
                (threshold: 50, speedRate: 0.013, gracePeriodRate: 0.023),
                (threshold: 66, speedRate: 0.014, gracePeriodRate: 0.024),
                (threshold: 84, speedRate: 0.015, gracePeriodRate: 0.025),
                (threshold: 104, speedRate: 0.016, gracePeriodRate: 0.026),
                (threshold: 126, speedRate: 0.017, gracePeriodRate: 0.027),
                (threshold: 999, speedRate: 0.018, gracePeriodRate: 0.028)
            ],
            minSpeed: 0.03,
            baseGracePeriod: 0.35,
            minGracePeriod: 0.16
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
    
    // MARK: - Layout Change Observer (SKScene Method)
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        // Layout değişikliği olduğunda oyun alanını yeniden hesapla
        if isGameRunning || isGamePaused {
            // Oyun sırasında layout değişirse oyunu duraklat
            if !isGamePaused {
                pauseGame()
            }
        }
        
        // UI'ı yeniden düzenle (yeni responsive sistem otomatik ayarlayacak)
        recalculateLayout()
    }
    
    // MARK: - Layout Yeniden Hesaplama
    private func recalculateLayout() {
        // Sadece gerekli durumlarda yeniden hesapla
        guard view != nil else { return }
        
        // Mevcut oyun durumunu koru
        let wasRunning = isGameRunning
        let wasPaused = isGamePaused
        
        // Tüm UI elementlerini temizle
        removeExistingUIElements()
        
        // Layout'u yeniden hesapla (yeni modüler sistem)
        calculateGameArea()
        
        // Snake ve food'u yeniden çiz
        if wasRunning {
            drawGame()
        }
        
        // Oyun durumunu geri yükle
        if wasRunning {
            isGameRunning = true
        }
        if wasPaused {
            isGamePaused = true
        }
    }
    
    // MARK: - Mevcut UI Elementlerini Temizleme
    private func removeExistingUIElements() {
        // Mevcut UI elementlerini temizle
        pauseButton?.removeFromParent()
        scoreLabel?.removeFromParent()
        highScoreLabel?.removeFromParent()
        headerBar?.removeFromParent()
        upButton?.removeFromParent()
        downButton?.removeFromParent()
        leftButton?.removeFromParent()
        rightButton?.removeFromParent()
        
        // Container'ları temizle
        childNode(withName: "headerLineContainer")?.removeFromParent()
        childNode(withName: "gameBorderContainer")?.removeFromParent()
        
        // Referansları sıfırla
        pauseButton = nil
        scoreLabel = nil
        highScoreLabel = nil
        headerBar = nil
        upButton = nil
        downButton = nil
        leftButton = nil
        rightButton = nil
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
    
    // MARK: - Hız ve Grace Period Profilini Uygulama
    internal func applySpeedProfile() {
        let profileIndex = max(0, min(speedSetting - 1, speedProfiles.count - 1))
        let profile = speedProfiles[profileIndex]
        
        baseGameSpeed = profile.baseSpeed
        currentGameSpeed = baseGameSpeed
        
        baseGracePeriodDuration = profile.baseGracePeriod
        gracePeriodDuration = baseGracePeriodDuration
        
        currentPhaseIndex = 0
    }
    
    // MARK: - Oyun Kurulumu ve Başlatma (GÜNCELLENDİ)
    private func setupGame() {
        backgroundColor = backgroundGreen
        
        // YENİ MODÜLERSİSTEM - tek bir çağrı ile tüm layout
        calculateGameArea()
        
        // Ultra-sensitive kontroller
        setupUltraSensitiveControls()
        
        // Oyun nesneleri
        snake = Snake()
        spawnFood()
    }
    
    // MARK: - UI Element Pozisyonlarını Güncelleme (Artık gereksiz - ama legacy için korundu)
    private func updateUIElementPositions() {
        // Bu metod artık gereksiz çünkü calculateGameArea() tüm positioning'i hallediyor
        // Ama geriye dönük uyumluluk için boş bırakıldı
    }
    
    // MARK: - Kontrol Buton Pozisyonlarını Güncelle (Artık gereksiz - ama legacy için korundu)
    private func updateControlButtonPositions() {
        // Bu metod artık gereksiz çünkü setupControlButtons() positioning'i hallediyor
        // Ama geriye dönük uyumluluk için boş bırakıldı
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
