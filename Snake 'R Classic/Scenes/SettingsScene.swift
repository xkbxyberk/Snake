import SpriteKit
import GameplayKit

class SettingsScene: SKScene {
    
    // MARK: - Arayüz Öğeleri
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var settingCards: [SKNode] = []
    
    // MARK: - Ayar Değişkenleri
    private var soundEnabled: Bool = true
    private var hapticEnabled: Bool = true
    private var gameSpeed: Int = 2
    
    // MARK: - Renk Paleti
    private let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    private let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    private let cardColor = SKColor(red: 220/255, green: 240/255, blue: 220/255, alpha: 0.95)
    private let enabledColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 1.0)
    private let disabledColor = SKColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1.0)
    private let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    private let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    
    override func didMove(to view: SKView) {
        loadSettings()
        setupSettings()
        createAnimatedBackground()
        startAnimations()
    }
    
    // MARK: - Ayarları Yükleme ve Kaydetme
    private func loadSettings() {
        soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        gameSpeed = UserDefaults.standard.object(forKey: "gameSpeed") as? Int ?? 2
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled")
        UserDefaults.standard.set(gameSpeed, forKey: "gameSpeed")
    }
    
    // MARK: - Arayüz Kurulumu
    private func createAnimatedBackground() {
        self.backgroundColor = backgroundGreen
        
        let gradientOverlay = SKSpriteNode(color: SKColor(red: 150/255, green: 205/255, blue: 1/255, alpha: 0.3),
                                          size: frame.size)
        gradientOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        gradientOverlay.zPosition = -10
        addChild(gradientOverlay)
        
        let pulseUp = SKAction.fadeAlpha(to: 0.5, duration: 3.0)
        let pulseDown = SKAction.fadeAlpha(to: 0.2, duration: 3.0)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        gradientOverlay.run(repeatPulse)
    }
    
    private func setupSettings() {
        createEnhancedTitle()
        createSettingCards()
        createBackButton()
        createDecorations()
    }
    
    private func createEnhancedTitle() {
        titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "⚙️ SETTINGS ⚙️"
        titleLabel.fontSize = 36
        titleLabel.fontColor = primaryColor
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 280)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        let titleShadow = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleShadow.text = "SETTINGS"
        titleShadow.fontSize = 36
        titleShadow.fontColor = shadowColor
        titleShadow.position = CGPoint(x: frame.midX + 3, y: frame.midY + 277)
        titleShadow.zPosition = 9
        addChild(titleShadow)
        
        let float = SKAction.moveBy(x: 0, y: 8, duration: 1.2)
        let floatDown = SKAction.moveBy(x: 0, y: -8, duration: 1.2)
        let floatSequence = SKAction.sequence([float, floatDown])
        let floatRepeat = SKAction.repeatForever(floatSequence)
        titleLabel.run(floatRepeat)
        titleShadow.run(floatRepeat)
    }
    
    private func createSettingCards() {
        let cardWidth: CGFloat = 280
        let cardHeight: CGFloat = 80
        let cardSpacing: CGFloat = 100
        let startY = frame.midY + 150
        
        let soundCard = createSettingCard(
            title: "🔊 SOUND EFFECTS",
            description: "Turn game sounds on/off",
            position: CGPoint(x: frame.midX, y: startY),
            size: CGSize(width: cardWidth, height: cardHeight),
            name: "soundCard",
            isEnabled: soundEnabled
        )
        addChild(soundCard)
        settingCards.append(soundCard)
        
        let hapticCard = createSettingCard(
            title: "📳 VIBRATION",
            description: "Turn haptic feedback on/off",
            position: CGPoint(x: frame.midX, y: startY - cardSpacing),
            size: CGSize(width: cardWidth, height: cardHeight),
            name: "hapticCard",
            isEnabled: hapticEnabled
        )
        addChild(hapticCard)
        settingCards.append(hapticCard)
        
        let speedCard = createSpeedCard(
            position: CGPoint(x: frame.midX, y: startY - cardSpacing * 2),
            size: CGSize(width: cardWidth, height: cardHeight)
        )
        addChild(speedCard)
        settingCards.append(speedCard)
    }
    
    private func createSettingCard(title: String, description: String, position: CGPoint, size: CGSize, name: String, isEnabled: Bool) -> SKNode {
        let cardContainer = SKNode()
        cardContainer.position = position
        cardContainer.name = name
        cardContainer.zPosition = 5
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: size.width + 40, height: size.height + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = name + "HitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: -size.height/2 - 4, width: size.width, height: size.height))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 2
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = title
        titleLabel.fontSize = 18
        titleLabel.fontColor = primaryColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -size.width/2 + 20, y: 12)
        titleLabel.zPosition = 3
        cardContainer.addChild(titleLabel)
        
        let descLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        descLabel.text = description
        descLabel.fontSize = 12
        descLabel.fontColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        descLabel.horizontalAlignmentMode = .left
        descLabel.verticalAlignmentMode = .center
        descLabel.position = CGPoint(x: -size.width/2 + 20, y: -12)
        descLabel.zPosition = 3
        cardContainer.addChild(descLabel)
        
        let toggle = createToggleSwitch(isEnabled: isEnabled)
        toggle.position = CGPoint(x: size.width/2 - 40, y: 0)
        toggle.zPosition = 3
        toggle.name = "\(name)Toggle"
        cardContainer.addChild(toggle)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        
        let delay = SKAction.wait(forDuration: Double(settingCards.count) * 0.04)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([delay, entrance])
        cardContainer.run(sequence)
        
        return cardContainer
    }
    
    private func createSpeedCard(position: CGPoint, size: CGSize) -> SKNode {
        let cardContainer = SKNode()
        cardContainer.position = position
        cardContainer.name = "speedCard"
        cardContainer.zPosition = 5
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: size.width + 40, height: size.height + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "speedCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: -size.height/2 - 4, width: size.width, height: size.height))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 2
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "⚡ GAME SPEED"
        titleLabel.fontSize = 18
        titleLabel.fontColor = primaryColor
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -size.width/2 + 20, y: 20)
        titleLabel.zPosition = 3
        cardContainer.addChild(titleLabel)
        
        let speedIndicator = createSpeedIndicator()
        speedIndicator.position = CGPoint(x: 0, y: -15)
        speedIndicator.zPosition = 3
        speedIndicator.name = "speedIndicator"
        cardContainer.addChild(speedIndicator)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        
        let delay = SKAction.wait(forDuration: Double(settingCards.count) * 0.04)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([delay, entrance])
        cardContainer.run(sequence)
        
        return cardContainer
    }
    
    private func createToggleSwitch(isEnabled: Bool) -> SKNode {
        let toggleContainer = SKNode()
        
        let toggleBg = SKShapeNode(rect: CGRect(x: -25, y: -8, width: 50, height: 16))
        toggleBg.fillColor = isEnabled ? enabledColor : disabledColor
        toggleBg.strokeColor = .clear
        toggleBg.zPosition = 1
        toggleContainer.addChild(toggleBg)
        
        let toggleCircle = SKSpriteNode(color: .white, size: CGSize(width: 12, height: 12))
        toggleCircle.position = CGPoint(x: isEnabled ? 15 : -15, y: 0)
        toggleCircle.zPosition = 2
        toggleCircle.name = "toggleCircle"
        toggleContainer.addChild(toggleCircle)
        
        let statusLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        statusLabel.text = isEnabled ? "ON" : "OFF"
        statusLabel.fontSize = 10
        statusLabel.fontColor = primaryColor
        statusLabel.position = CGPoint(x: 0, y: -20)
        statusLabel.zPosition = 2
        statusLabel.name = "statusLabel"
        toggleContainer.addChild(statusLabel)
        
        return toggleContainer
    }
    
    private func createSpeedIndicator() -> SKNode {
        let indicatorContainer = SKNode()
        
        let speedTexts = ["SLOW", "NORMAL", "FAST", "VERY FAST"]
        let dotSpacing: CGFloat = 55
        let startX: CGFloat = -82.5
        
        for i in 0..<4 {
            let speed = i + 1
            let isActive = speed == gameSpeed
            
            let dotHitArea = SKSpriteNode(color: .clear, size: CGSize(width: 40, height: 40))
            dotHitArea.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: 0)
            dotHitArea.name = "speedDot\(speed)HitArea"
            dotHitArea.zPosition = 5
            indicatorContainer.addChild(dotHitArea)
            
            let dot = SKSpriteNode(color: isActive ? enabledColor : disabledColor,
                                 size: CGSize(width: 12, height: 12))
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: 8)
            dot.name = "speedDot\(speed)"
            indicatorContainer.addChild(dot)
            
            let label = SKLabelNode(fontNamed: "Jersey15-Regular")
            label.text = speedTexts[i]
            label.fontSize = 9
            label.fontColor = isActive ? primaryColor : disabledColor
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -8)
            label.name = "speedLabel\(speed)"
            indicatorContainer.addChild(label)
            
            if isActive {
                let glow = SKSpriteNode(color: glowColor, size: CGSize(width: 16, height: 16))
                glow.alpha = 0.6
                glow.position = dot.position
                glow.zPosition = -1
                indicatorContainer.addChild(glow)
                
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.8),
                    SKAction.scale(to: 1.0, duration: 0.8)
                ])
                glow.run(SKAction.repeatForever(pulse))
            }
        }
        
        return indicatorContainer
    }
    
    private func createBackButton() {
        let buttonWidth: CGFloat = 160
        let buttonHeight: CGFloat = 50
        
        backButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        backButton.fillColor = primaryColor
        backButton.strokeColor = glowColor
        backButton.lineWidth = 3
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 80)
        backButton.name = "backButton"
        backButton.zPosition = 5
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth + 40, height: buttonHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "backButtonHitArea"
        backButton.addChild(hitArea)
        
        let shadow = SKShapeNode(rect: CGRect(x: -buttonWidth/2 + 3, y: -buttonHeight/2 - 3, width: buttonWidth, height: buttonHeight))
        shadow.fillColor = shadowColor
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        backButton.addChild(shadow)
        
        let label = SKLabelNode(fontNamed: "Jersey15-Regular")
        label.text = "🏠 BACK"
        label.fontSize = 18
        label.fontColor = backgroundGreen
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        backButton.addChild(label)
        
        addChild(backButton)
        
        let scaleUp = SKAction.scale(to: 1.02, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatAction = SKAction.repeatForever(sequence)
        backButton.run(repeatAction)
    }
    
    private func createDecorations() {
        for i in 0..<6 {
            let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 4, height: 4))
            let randomX = CGFloat.random(in: 50...(frame.maxX - 50))
            let randomY = CGFloat.random(in: 100...(frame.maxY - 100))
            particle.position = CGPoint(x: randomX, y: randomY)
            particle.zPosition = 1
            particle.alpha = 0.0
            addChild(particle)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.1)
            let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
            let float = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20), duration: 4.0)
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 2.0)
            let sequence = SKAction.sequence([delay, fadeIn, SKAction.group([float, fadeOut])])
            let repeatAction = SKAction.repeatForever(sequence)
            
            particle.run(repeatAction)
        }
    }
    
    // MARK: - Animasyonlar
    private func startAnimations() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.run { self.createFloatingParticle() }
        ])))
    }
    
    private func createFloatingParticle() {
        let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 3, height: 3))
        particle.position = CGPoint(x: CGFloat.random(in: 0...frame.maxX), y: -10)
        particle.zPosition = 1
        addChild(particle)
        
        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: frame.height + 20, duration: 6.0)
        let fadeOut = SKAction.fadeOut(withDuration: 6.0)
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([group, remove])
        particle.run(sequence)
    }
    
    // MARK: - Arayüz Güncellemeleri
    private func updateToggle(_ toggle: SKNode, isEnabled: Bool) {
        if let bg = toggle.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            bg.fillColor = isEnabled ? enabledColor : disabledColor
        }
        
        if let circle = toggle.childNode(withName: "toggleCircle") {
            let moveAction = SKAction.moveTo(x: isEnabled ? 15 : -15, duration: 0.3)
            circle.run(moveAction)
        }
        
        if let statusLabel = toggle.childNode(withName: "statusLabel") as? SKLabelNode {
            statusLabel.text = isEnabled ? "ON" : "OFF"
        }
    }
    
    private func updateSpeedIndicator() {
        if let speedCard = childNode(withName: "speedCard"),
           let indicator = speedCard.childNode(withName: "speedIndicator") {
            
            for i in 1...4 {
                let isActive = i == gameSpeed
                
                if let dot = indicator.childNode(withName: "speedDot\(i)") as? SKSpriteNode {
                    dot.color = isActive ? enabledColor : disabledColor
                }
                
                if let label = indicator.childNode(withName: "speedLabel\(i)") as? SKLabelNode {
                    label.fontColor = isActive ? primaryColor : disabledColor
                }
            }
            
            indicator.children.filter { $0.zPosition == -1 }.forEach { $0.removeFromParent() }
            
            if let dot = indicator.childNode(withName: "speedDot\(gameSpeed)") {
                let glow = SKSpriteNode(color: glowColor, size: CGSize(width: 16, height: 16))
                glow.alpha = 0.6
                glow.position = dot.position
                glow.zPosition = -1
                indicator.addChild(glow)
                
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.8),
                    SKAction.scale(to: 1.0, duration: 0.8)
                ])
                glow.run(SKAction.repeatForever(pulse))
            }
        }
    }
    
    // MARK: - Etkileşim Animasyonları
    private func animateCardPress(_ card: SKNode) {
        let instantScale = SKAction.scale(to: 0.92, duration: 0.05)
        let bounceBack = SKAction.scale(to: 1.08, duration: 0.1)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([instantScale, bounceBack, settle])
        card.run(sequence)
        
        createInstantGlowEffect(at: card.position, size: CGSize(width: 320, height: 120))
        
        triggerInstantHaptic()
    }
    
    private func animateButtonPress(_ button: SKNode) {
        let instantScale = SKAction.scale(to: 0.88, duration: 0.03)
        let bounceBack = SKAction.scale(to: 1.12, duration: 0.08)
        let settle = SKAction.scale(to: 1.0, duration: 0.12)
        let sequence = SKAction.sequence([instantScale, bounceBack, settle])
        button.run(sequence)
        
        createInstantGlowEffect(at: button.position, size: CGSize(width: 200, height: 80))
        
        triggerInstantHaptic()
    }
    
    private func createInstantGlowEffect(at position: CGPoint, size: CGSize) {
        let glowNode = SKSpriteNode(color: glowColor, size: size)
        glowNode.alpha = 0.0
        glowNode.position = position
        glowNode.zPosition = 15
        addChild(glowNode)
        
        let instantGlow = SKAction.fadeAlpha(to: 0.7, duration: 0.02)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([instantGlow, fadeOut, remove])
        glowNode.run(glowSequence)
    }
    
    private func triggerInstantHaptic() {
        HapticManager.shared.playSimpleHaptic()
    }
    
    // MARK: - Dokunma Yönetimi
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name ?? touchedNode.parent?.parent?.name {
            
            switch nodeName {
            case "soundCard", "soundCardToggle", "soundCardHitArea":
                if let card = childNode(withName: "soundCard") {
                    animateCardPress(card)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.toggleSound()
                    }
                }
            case "hapticCard", "hapticCardToggle", "hapticCardHitArea":
                if let card = childNode(withName: "hapticCard") {
                    animateCardPress(card)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.toggleHaptic()
                    }
                }
            case "speedCard", "speedIndicator", "speedCardHitArea":
                if let card = childNode(withName: "speedCard") {
                    animateCardPress(card)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.cycleSpeed()
                    }
                }
            case "backButton", "backButtonHitArea":
                animateButtonPress(backButton)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.goBack()
                }
            default:
                if nodeName.contains("speedDot") || nodeName.contains("speedLabel") {
                    if let speedString = nodeName.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().first,
                       let speed = Int(String(speedString)) {
                        if let card = childNode(withName: "speedCard") {
                            animateCardPress(card)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.setSpeed(speed)
                        }
                    }
                }
                break
            }
        }
    }
    
    // MARK: - Ayar Kontrol Fonksiyonları
    private func toggleSound() {
        soundEnabled.toggle()
        if let soundCard = childNode(withName: "soundCard"),
           let toggle = soundCard.childNode(withName: "soundCardToggle") {
            updateToggle(toggle, isEnabled: soundEnabled)
        }
        saveSettings()
    }
    
    private func toggleHaptic() {
        hapticEnabled.toggle()
        if let hapticCard = childNode(withName: "hapticCard"),
           let toggle = hapticCard.childNode(withName: "hapticCardToggle") {
            updateToggle(toggle, isEnabled: hapticEnabled)
        }
        saveSettings()
    }
    
    private func cycleSpeed() {
        gameSpeed = gameSpeed == 4 ? 1 : gameSpeed + 1
        updateSpeedIndicator()
        saveSettings()
    }
    
    private func setSpeed(_ speed: Int) {
        if speed >= 1 && speed <= 4 {
            gameSpeed = speed
            updateSpeedIndicator()
            saveSettings()
        }
    }
    
    // MARK: - Sahne Geçişi
    private func goBack() {
        let menuScene = MenuScene()
        menuScene.size = frame.size
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.push(with: .right, duration: 0.2)
        view?.presentScene(menuScene, transition: transition)
    }
}
