import SpriteKit
import GameplayKit

// MARK: - GameScene: Dokunma Yönetimi
extension GameScene {
    
    // MARK: - Çift Dokunma Özellikleri
    private static var lastTapTime: TimeInterval = 0
    private static let doubleTapThreshold: TimeInterval = 0.4
    
    // MARK: - Dokunma Yaşam Döngüsü Olayları
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            handleSingleTouch(at: touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            handleSingleTouch(at: touchLocation, isMoveAction: true)
        }
    }
    
    // MARK: - Dokunma Sonlandırma ve İptal Olayları
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            if isInControlArea(touchLocation) && isGameRunning && !isGamePaused && !isCountdownActive {
                handleUltraSensitiveDirectionControls(at: touchLocation, isMoveAction: false)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            if isInControlArea(touchLocation) && isGameRunning && !isGamePaused && !isCountdownActive {
                handleUltraSensitiveDirectionControls(at: touchLocation, isMoveAction: false)
            }
        }
    }
    
    // MARK: - Ana Dokunma İşleyici
    private func handleSingleTouch(at touchLocation: CGPoint, isMoveAction: Bool = false) {
        if isCountdownActive {
            return
        }
        
        if isNameInputActive {
            handleNameInputTouches(touchedNode: atPoint(touchLocation))
            return
        }
        
        if !isGameRunning {
            handleGameOverTouches(touchedNode: atPoint(touchLocation))
            return
        }
        
        if handlePauseTouches(touchedNode: atPoint(touchLocation)) {
            return
        }
        
        if isPauseButtonTouch(at: touchLocation) {
            if isGamePaused {
                resumeGame()
            } else {
                pauseGame()
            }
            return
        }
        
        if !isMoveAction && isInGameArea(touchLocation) && !isGamePaused {
            let currentTime = CACurrentMediaTime()
            if currentTime - Self.lastTapTime <= Self.doubleTapThreshold {
                pauseGame()
                Self.lastTapTime = 0
                return
            } else {
                Self.lastTapTime = currentTime
            }
        }
        
        if isGamePaused {
            return
        }
        
        handleUltraSensitiveDirectionControls(at: touchLocation, isMoveAction: isMoveAction)
    }
    
    // MARK: - Duruma Özel Dokunma İşleyicileri
    private func handleNameInputTouches(touchedNode: SKNode) {
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name {
            switch nodeName {
            case "saveScoreButton":
                saveScoreWithName(playerName)
                triggerStrongHapticFeedback()
            case "anonScoreButton":
                saveScoreWithName("Anonymous")
                triggerStrongHapticFeedback()
            default:
                break
            }
        }
    }
    
    private func handleGameOverTouches(touchedNode: SKNode) {
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name {
            switch nodeName {
            case "restartButton":
                if let button = childNode(withName: "restartButton") {
                    animateGameOverButtonPress(button)
                }
                restartGame()
                triggerStrongHapticFeedback()
                return
            case "menuButton":
                if let button = childNode(withName: "menuButton") {
                    animateGameOverButtonPress(button)
                }
                goToMenu()
                triggerStrongHapticFeedback()
                return
            default:
                break
            }
        }
    }
    
    private func handlePauseTouches(touchedNode: SKNode) -> Bool {
        if touchedNode.name == "playButton" || touchedNode.parent?.name == "playButton" {
            if let playButton = touchedNode.name == "playButton" ? touchedNode : touchedNode.parent {
                animatePauseButtonPress(playButton)
            }
            resumeGame()
            triggerStrongHapticFeedback()
            return true
        }
        
        if touchedNode.name == "menuButtonPause" || touchedNode.parent?.name == "menuButtonPause" {
            if let menuButton = touchedNode.name == "menuButtonPause" ? touchedNode : touchedNode.parent {
                animatePauseButtonPress(menuButton)
            }
            goToMenu()
            triggerStrongHapticFeedback()
            return true
        }
        
        // Yeni ses toggle butonu kontrolü
        if touchedNode.name == "soundToggleButton" || touchedNode.parent?.name == "soundToggleButton" {
            if let soundButton = touchedNode.name == "soundToggleButton" ? touchedNode : touchedNode.parent {
                animatePauseButtonPress(soundButton)
            }
            toggleSoundSetting()
            triggerStrongHapticFeedback()
            return true
        }
        
        // Yeni titreşim toggle butonu kontrolü
        if touchedNode.name == "hapticToggleButton" || touchedNode.parent?.name == "hapticToggleButton" {
            if let hapticButton = touchedNode.name == "hapticToggleButton" ? touchedNode : touchedNode.parent {
                animatePauseButtonPress(hapticButton)
            }
            toggleHapticSetting()
            triggerStrongHapticFeedback()
            return true
        }
        
        return false
    }
    
    // MARK: - Yeni Ayar Toggle Fonksiyonları
    private func toggleSoundSetting() {
        let currentSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let newSoundEnabled = !currentSoundEnabled
        
        UserDefaults.standard.set(newSoundEnabled, forKey: "soundEnabled")
        soundEnabled = newSoundEnabled
        
        // Buton görselini güncelle
        updateSoundButtonVisual()
        
        // Test sesi çal (eğer ses açıldıysa)
        if newSoundEnabled {
            SoundManager.shared.playSound(named: "eat.wav")
        }
    }
    
    private func toggleHapticSetting() {
        let currentHapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        let newHapticEnabled = !currentHapticEnabled
        
        UserDefaults.standard.set(newHapticEnabled, forKey: "hapticEnabled")
        hapticEnabled = newHapticEnabled
        
        // Buton görselini güncelle
        updateHapticButtonVisual()
        
        // Test titreşimi (eğer titreşim açıldıysa)
        if newHapticEnabled {
            HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 0.8)
        }
    }
    
    // MARK: - Yön Kontrol Mantığı
    private func handleUltraSensitiveDirectionControls(at location: CGPoint, isMoveAction: Bool) {
        var detectedDirection: Direction?
        var buttonToAnimate: SKShapeNode?
        
        if let upBtn = upButton {
            let expandedUpArea = CGRect(
                x: upBtn.position.x - 80,
                y: upBtn.position.y - 50,
                width: 160,
                height: 120
            )
            
            if expandedUpArea.contains(location) && currentDirection != .down {
                detectedDirection = .up
                buttonToAnimate = upBtn
            }
        }
        
        if detectedDirection == nil, let downBtn = downButton {
            let expandedDownArea = CGRect(
                x: downBtn.position.x - 80,
                y: downBtn.position.y - 50,
                width: 160,
                height: 120
            )
            
            if expandedDownArea.contains(location) && currentDirection != .up {
                detectedDirection = .down
                buttonToAnimate = downBtn
            }
        }
        
        if detectedDirection == nil, let leftBtn = leftButton {
            let expandedLeftArea = CGRect(
                x: leftBtn.position.x - 70,
                y: leftBtn.position.y - 80,
                width: 140,
                height: 160
            )
            
            if expandedLeftArea.contains(location) && currentDirection != .right {
                detectedDirection = .left
                buttonToAnimate = leftBtn
            }
        }
        
        if detectedDirection == nil, let rightBtn = rightButton {
            let expandedRightArea = CGRect(
                x: rightBtn.position.x - 70,
                y: rightBtn.position.y - 80,
                width: 140,
                height: 160
            )
            
            if expandedRightArea.contains(location) && currentDirection != .right {
                detectedDirection = .right
                buttonToAnimate = rightBtn
            }
        }
        
        if detectedDirection == nil {
            detectedDirection = detectDirectionByScreenRegion(at: location)
            
            switch detectedDirection {
            case .up: buttonToAnimate = upButton
            case .down: buttonToAnimate = downButton
            case .left: buttonToAnimate = leftButton
            case .right: buttonToAnimate = rightButton
            case .none: break
            }
        }
        
        if let direction = detectedDirection {
            let isValidDirection: Bool
            switch direction {
            case .up: isValidDirection = currentDirection != .down
            case .down: isValidDirection = currentDirection != .up
            case .left: isValidDirection = currentDirection != .right
            case .right: isValidDirection = currentDirection != .left
            }
            
            if isValidDirection {
                nextDirection = direction
                
                if let button = buttonToAnimate {
                    animateButtonPress(button)
                }
                
                triggerStrongHapticFeedback()
            }
        }
    }
    
    private func detectDirectionByScreenRegion(at location: CGPoint) -> Direction? {
        let screenCenterX = frame.midX
        
        let controlAreaTop = gameAreaStartY
        let controlAreaBottom: CGFloat = 40
        let controlAreaLeft: CGFloat = 20
        let controlAreaRight = frame.maxX - 20
        
        guard location.y >= controlAreaBottom && location.y <= controlAreaTop &&
              location.x >= controlAreaLeft && location.x <= controlAreaRight else {
            return nil
        }
        
        let deltaX = location.x - screenCenterX
        let deltaY = location.y - (controlAreaBottom + (controlAreaTop - controlAreaBottom) / 2)
        
        let absX = abs(deltaX)
        let absY = abs(deltaY)
        
        let minimumDistance: CGFloat = 30
        
        if max(absX, absY) < minimumDistance {
            return nil
        }
        
        if absX > absY {
            return deltaX > 0 ? .right : .left
        } else {
            return deltaY > 0 ? .up : .down
        }
    }
    
    // MARK: - Geometri ve Alan Kontrolleri
    private func isInGameArea(_ location: CGPoint) -> Bool {
        let gameAreaRect = CGRect(
            x: gameAreaStartX,
            y: gameAreaStartY,
            width: gameAreaWidth,
            height: gameAreaHeight
        )
        return gameAreaRect.contains(location)
    }
    
    private func isPauseButtonTouch(at location: CGPoint) -> Bool {
        guard let pause = pauseButton else { return false }
        
        let expandedWidth: CGFloat = 50
        let expandedHeight: CGFloat = 50
        let expandedArea = CGRect(
            x: pause.position.x - expandedWidth/2,
            y: pause.position.y - expandedHeight/2,
            width: expandedWidth,
            height: expandedHeight
        )
        
        return expandedArea.contains(location)
    }

    private func isInControlArea(_ location: CGPoint) -> Bool {
        let controlAreaTop = gameAreaStartY
        let controlAreaBottom: CGFloat = 40
        
        return location.y >= controlAreaBottom && location.y <= controlAreaTop
    }
    
    // MARK: - Geri Bildirim (Animasyon ve Haptik)
    internal func animateButtonPress(_ button: SKShapeNode) {
        let scaleDown = SKAction.scale(to: 0.85, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.08)
        let scaleNormal = SKAction.scale(to: 1.0, duration: 0.05)
        let sequence = SKAction.sequence([scaleDown, scaleUp, scaleNormal])
        
        button.run(sequence)
    }
    
    private func createInstantVisualFeedback(at position: CGPoint) {
        let flashNode = SKSpriteNode(color: glowColor, size: CGSize(width: 100, height: 100))
        flashNode.alpha = 0.0
        flashNode.position = position
        flashNode.zPosition = 50
        addChild(flashNode)
        
        let flashIn = SKAction.fadeAlpha(to: 0.8, duration: 0.05)
        let flashOut = SKAction.fadeOut(withDuration: 0.15)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([flashIn, flashOut, remove])
        flashNode.run(sequence)
        
        let ring = SKSpriteNode(color: glowColor, size: CGSize(width: 60, height: 60))
        ring.alpha = 0.6
        ring.position = position
        ring.zPosition = 49
        addChild(ring)
        
        let ringScale = SKAction.scale(to: 2.0, duration: 0.2)
        let ringFade = SKAction.fadeOut(withDuration: 0.2)
        let ringRemove = SKAction.removeFromParent()
        let ringSequence = SKAction.sequence([SKAction.group([ringScale, ringFade]), ringRemove])
        ring.run(ringSequence)
    }

    internal func animatePauseButtonPress(_ button: SKNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let bounce = SKAction.scale(to: 1.05, duration: 0.05)
        let normalSize = SKAction.scale(to: 1.0, duration: 0.05)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp, bounce, normalSize])
        button.run(sequence)
        
        let glowNode = SKSpriteNode(color: glowColor, size: CGSize(width: 200, height: 75))
        glowNode.alpha = 0.0
        glowNode.position = button.position
        glowNode.zPosition = button.zPosition - 1
        addChild(glowNode)
        
        let glowIn = SKAction.fadeAlpha(to: 0.6, duration: 0.05)
        let glowOut = SKAction.fadeOut(withDuration: 0.25)
        let removeGlow = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([glowIn, glowOut, removeGlow])
        glowNode.run(glowSequence)
    }
    
    internal func animateGameOverButtonPress(_ button: SKNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let bounce = SKAction.scale(to: 1.05, duration: 0.05)
        let normalSize = SKAction.scale(to: 1.0, duration: 0.05)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp, bounce, normalSize])
        button.run(sequence)
        
        let glowNode = SKSpriteNode(color: glowColor, size: CGSize(width: 200, height: 70))
        glowNode.alpha = 0.0
        glowNode.position = button.position
        glowNode.zPosition = button.zPosition - 1
        addChild(glowNode)
        
        let glowIn = SKAction.fadeAlpha(to: 0.8, duration: 0.05)
        let glowOut = SKAction.fadeOut(withDuration: 0.25)
        let removeGlow = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([glowIn, glowOut, removeGlow])
        glowNode.run(glowSequence)
    }

    private func triggerStrongHapticFeedback() {
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 0.8)
    }

    // MARK: - Kurulum ve Hassasiyet Modları
    internal func setupUltraSensitiveControls() {
        self.view?.isMultipleTouchEnabled = true
    }
    
    internal func enableExtremeSensitivity() {
        [upButton, downButton, leftButton, rightButton].compactMap { $0 }.forEach { button in
            let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 200))
            hitArea.position = button.position
            hitArea.zPosition = -1
            hitArea.name = button.name
            addChild(hitArea)
        }
    }
}
