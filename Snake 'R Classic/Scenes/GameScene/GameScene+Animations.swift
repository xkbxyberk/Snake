import SpriteKit
import GameplayKit

// MARK: - GameScene Animations Extension
extension GameScene {
    
    // MARK: - Yeni Rekor Efekti
    internal func createNewRecordEffect() {
        let flashOverlay = SKSpriteNode(color: .white, size: frame.size)
        flashOverlay.alpha = 0.0
        flashOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        flashOverlay.zPosition = 50
        addChild(flashOverlay)
        
        let flashIn = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
        let flashOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([flashIn, flashOut, remove])
        flashOverlay.run(sequence)
        
        let recordLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        recordLabel.text = "🏆 NEW RECORD! 🏆"
        recordLabel.fontSize = 24
        recordLabel.fontColor = .yellow
        recordLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        recordLabel.alpha = 0.0
        recordLabel.zPosition = 51
        addChild(recordLabel)
        
        let labelFadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let labelWait = SKAction.wait(forDuration: 1.5)
        let labelFadeOut = SKAction.fadeOut(withDuration: 0.5)
        let labelRemove = SKAction.removeFromParent()
        let labelSequence = SKAction.sequence([labelFadeIn, labelWait, labelFadeOut, labelRemove])
        recordLabel.run(labelSequence)
        
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 1.0)
    }
    
    // MARK: - Oyun Başlangıç Efekti
    internal func createGameStartEffect() {
        let elements = [scoreLabel, highScoreLabel, pauseButton, headerBar]
        
        for element in elements {
            if let element = element {
                let originalAlpha = element.alpha
                let glowUp = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
                let glowDown = SKAction.fadeAlpha(to: originalAlpha, duration: 0.3)
                let glowSequence = SKAction.sequence([glowUp, glowDown])
                element.run(glowSequence)
            }
        }
        
        let buttons = [upButton, downButton, leftButton, rightButton]
        for button in buttons {
            if let button = button {
                let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
                let sequence = SKAction.sequence([scaleUp, scaleDown])
                button.run(sequence)
            }
        }
        
        for i in 0..<15 {
            let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 4, height: 4))
            particle.position = CGPoint(x: CGFloat.random(in: 0...frame.maxX), y: frame.maxY + 10)
            particle.zPosition = 10
            addChild(particle)
            
            let fall = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: -(frame.height + 20), duration: 2.0)
            let fadeOut = SKAction.fadeOut(withDuration: 2.0)
            let remove = SKAction.removeFromParent()
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.1)
            let group = SKAction.group([fall, fadeOut])
            let sequence = SKAction.sequence([delay, group, remove])
            particle.run(sequence)
        }
        
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 0.8)
    }
    
    // MARK: - Gelişmiş Duraklatma Menüsü
    internal func createEnhancedPauseMenu() {
        createPauseBackground()
        createPauseTitle()
        createPauseButtons()
        createPauseDecorations()
    }
    
    // MARK: - Duraklatma Menüsü Arkaplanı
    internal func createPauseBackground() {
        let pauseOverlay = SKSpriteNode(color: .black, size: frame.size)
        pauseOverlay.alpha = 0.0
        pauseOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        pauseOverlay.name = "pauseOverlay"
        pauseOverlay.zPosition = 100
        addChild(pauseOverlay)
        
        let gradientOverlay = SKSpriteNode(color: SKColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0), size: frame.size)
        gradientOverlay.alpha = 0.0
        gradientOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        gradientOverlay.name = "pauseGradient"
        gradientOverlay.zPosition = 101
        addChild(gradientOverlay)
        
        let fadeIn1 = SKAction.fadeAlpha(to: 0.7, duration: 0.15)
        let fadeIn2 = SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        
        pauseOverlay.run(fadeIn1)
        gradientOverlay.run(SKAction.sequence([SKAction.wait(forDuration: 0.05), fadeIn2]))
        
        let pulseUp = SKAction.fadeAlpha(to: 0.4, duration: 2.0)
        let pulseDown = SKAction.fadeAlpha(to: 0.2, duration: 2.0)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        
        gradientOverlay.run(SKAction.sequence([SKAction.wait(forDuration: 0.2), pulseRepeat]))
    }
    
    // MARK: - Duraklatma Menüsü Başlığı
    internal func createPauseTitle() {
        let pauseLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        pauseLabel.text = "⏸️ PAUSED ⏸️"
        pauseLabel.fontSize = 36
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 140)
        pauseLabel.name = "pauseLabel"
        pauseLabel.zPosition = 105
        pauseLabel.alpha = 0.0
        addChild(pauseLabel)
        
        let shadowLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        shadowLabel.text = "PAUSED"
        shadowLabel.fontSize = 36
        shadowLabel.fontColor = shadowColor
        shadowLabel.position = CGPoint(x: frame.midX + 3, y: frame.midY + 137)
        shadowLabel.name = "pauseShadow"
        shadowLabel.zPosition = 104
        shadowLabel.alpha = 0.0
        addChild(shadowLabel)
        
        let scaleSequence = SKAction.sequence([
            SKAction.scale(to: 0.8, duration: 0.0),
            SKAction.scale(to: 1.1, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let titleAnimation = SKAction.group([scaleSequence, fadeIn])
        
        pauseLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), titleAnimation]))
        shadowLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), titleAnimation]))
        
        let glowUp = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let glowDown = SKAction.fadeAlpha(to: 0.7, duration: 1.5)
        let glowSequence = SKAction.sequence([glowUp, glowDown])
        let glowRepeat = SKAction.repeatForever(glowSequence)
        
        pauseLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), glowRepeat]))
    }
    
    // MARK: - Duraklatma Menüsü Butonları (2x2 Grid)
    internal func createPauseButtons() {
        let mainButtonWidth: CGFloat = 160
        let mainButtonHeight: CGFloat = 50
        let miniButtonSize: CGFloat = 40
        let buttonSpacingX: CGFloat = 90
        let buttonSpacingY: CGFloat = 30  // Daha yakın mesafe
        
        // Sol üst: RESUME butonu
        let playButton = createEnhancedPauseButton(
            text: "▶️ RESUME",
            position: CGPoint(x: frame.midX - buttonSpacingX, y: frame.midY + buttonSpacingY/2),
            size: CGSize(width: mainButtonWidth, height: mainButtonHeight),
            name: "playButton",
            isPrimary: true
        )
        addChild(playButton)
        
        // Sağ üst: MAIN MENU butonu
        let menuButton = createEnhancedPauseButton(
            text: "🏠 MAIN MENU",
            position: CGPoint(x: frame.midX + buttonSpacingX, y: frame.midY + buttonSpacingY/2),
            size: CGSize(width: mainButtonWidth, height: mainButtonHeight),
            name: "menuButtonPause",
            isPrimary: false
        )
        addChild(menuButton)
        
        // Sol alt: SOUND butonu (Minimal)
        let currentSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let soundButton = createMinimalToggleButton(
            icon: currentSoundEnabled ? "🔊" : "🔇",
            position: CGPoint(x: frame.midX - buttonSpacingX, y: frame.midY - buttonSpacingY/2),
            size: miniButtonSize,
            name: "soundToggleButton",
            isEnabled: currentSoundEnabled
        )
        addChild(soundButton)
        
        // Sağ alt: VIBRATION butonu (Minimal)
        let currentHapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        let hapticButton = createMinimalToggleButton(
            icon: currentHapticEnabled ? "📳" : "📴",
            position: CGPoint(x: frame.midX + buttonSpacingX, y: frame.midY - buttonSpacingY/2),
            size: miniButtonSize,
            name: "hapticToggleButton",
            isEnabled: currentHapticEnabled
        )
        addChild(hapticButton)
        
        // Animasyonlar
        let slideFromLeft = SKAction.moveBy(x: 200, y: 0, duration: 0.2)
        let slideFromRight = SKAction.moveBy(x: -200, y: 0, duration: 0.2)
        let slideFromBottom = SKAction.moveBy(x: 0, y: -60, duration: 0.2)  // Daha kısa mesafe
        
        // Başlangıç pozisyonları
        playButton.position.x -= 200
        menuButton.position.x += 200
        soundButton.position.y -= 60  // Daha kısa mesafe
        hapticButton.position.y -= 60  // Daha kısa mesafe
        
        // Giriş animasyonları
        let delay1 = SKAction.wait(forDuration: 0.2)
        let delay2 = SKAction.wait(forDuration: 0.3)
        let delay3 = SKAction.wait(forDuration: 0.4)
        let delay4 = SKAction.wait(forDuration: 0.5)
        
        playButton.run(SKAction.sequence([delay1, slideFromLeft]))
        menuButton.run(SKAction.sequence([delay2, slideFromRight]))
        soundButton.run(SKAction.sequence([delay3, slideFromBottom]))
        hapticButton.run(SKAction.sequence([delay4, slideFromBottom]))
    }
    
    // MARK: - Minimal Toggle Butonu Oluşturma
    internal func createMinimalToggleButton(icon: String, position: CGPoint, size: CGFloat, name: String, isEnabled: Bool) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.position = position
        buttonContainer.name = name
        buttonContainer.zPosition = 103
        
        // Gölge
        let shadow = SKSpriteNode(color: shadowColor, size: CGSize(width: size + 2, height: size + 2))
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = 0
        buttonContainer.addChild(shadow)
        
        // Ana buton arkaplanı
        let button = SKSpriteNode(color: isEnabled ? glowColor : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), size: CGSize(width: size, height: size))
        button.zPosition = 1
        buttonContainer.addChild(button)
        
        // Çerçeve
        let border = SKShapeNode(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        border.fillColor = .clear
        border.strokeColor = .white
        border.lineWidth = 2
        border.zPosition = 2
        buttonContainer.addChild(border)
        
        // İkon
        let iconLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        iconLabel.text = icon
        iconLabel.fontSize = 18
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        iconLabel.zPosition = 3
        buttonContainer.addChild(iconLabel)
        
        // Aktif durumda highlight efekti (pulse olmadan)
        if isEnabled {
            let highlight = SKSpriteNode(color: .white, size: CGSize(width: size - 4, height: 4))
            highlight.position = CGPoint(x: 0, y: size/2 - 4)
            highlight.alpha = 0.6
            highlight.zPosition = 2
            buttonContainer.addChild(highlight)
        }
        
        return buttonContainer
    }
    
    // MARK: - Gelişmiş Duraklatma Butonu Oluşturma
    internal func createEnhancedPauseButton(text: String, position: CGPoint, size: CGSize, name: String, isPrimary: Bool) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.position = position
        buttonContainer.name = name
        buttonContainer.zPosition = 103
        
        let shadow = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: -size.height/2 - 4, width: size.width, height: size.height))
        shadow.fillColor = shadowColor
        shadow.strokeColor = .clear
        buttonContainer.addChild(shadow)
        
        let button = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        button.fillColor = isPrimary ? primaryColor : SKColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 1.0)
        button.strokeColor = isPrimary ? glowColor : .white
        button.lineWidth = 3
        buttonContainer.addChild(button)
        
        if isPrimary {
            let highlight = SKShapeNode(rect: CGRect(x: -size.width/2 + 5, y: size.height/2 - 8, width: size.width - 10, height: 4))
            highlight.fillColor = glowColor
            highlight.strokeColor = .clear
            buttonContainer.addChild(highlight)
        }
        
        let label = SKLabelNode(fontNamed: "Jersey15-Regular")
        label.text = text
        label.fontSize = 14
        label.fontColor = isPrimary ? backgroundGreen : .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        buttonContainer.addChild(label)
        
        if isPrimary {
            let scaleUp = SKAction.scale(to: 1.02, duration: 1.0)
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            let repeatAction = SKAction.repeatForever(sequence)
            buttonContainer.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), repeatAction]))
        }
        
        return buttonContainer
    }
    
    // MARK: - Duraklatma Menüsü Dekorasyonları
    internal func createPauseDecorations() {
        for i in 0..<6 {
            let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 4, height: 4))
            let randomX = CGFloat.random(in: 50...(frame.maxX - 50))
            let randomY = CGFloat.random(in: 200...(frame.maxY - 200))
            particle.position = CGPoint(x: randomX, y: randomY)
            particle.zPosition = 102
            particle.alpha = 0.0
            particle.name = "pauseParticle"
            addChild(particle)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.1 + 0.3)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.25)
            let float = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -30...30), duration: 3.0)
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 1.5)
            let sequence = SKAction.sequence([delay, fadeIn, SKAction.group([float, fadeOut])])
            let repeatAction = SKAction.repeatForever(sequence)
            
            particle.run(repeatAction)
        }
        
        for i in 0..<4 {
            let glowCircle = SKSpriteNode(color: SKColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 0.2),
                                          size: CGSize(width: 60, height: 60))
            let angle = CGFloat(i) * CGFloat.pi / 2
            let radius: CGFloat = 120
            let x = frame.midX + cos(angle) * radius
            let y = frame.midY + sin(angle) * radius
            glowCircle.position = CGPoint(x: x, y: y)
            glowCircle.zPosition = 102
            glowCircle.alpha = 0.0
            glowCircle.name = "pauseGlow"
            addChild(glowCircle)
            
            let delay = SKAction.wait(forDuration: 0.25 + Double(i) * 0.1)
            let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 0.25)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0)
            let rotateRepeat = SKAction.repeatForever(rotate)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 2.0),
                SKAction.scale(to: 1.0, duration: 2.0)
            ])
            let pulseRepeat = SKAction.repeatForever(pulse)
            
            glowCircle.run(SKAction.sequence([delay, fadeIn]))
            glowCircle.run(SKAction.sequence([delay, rotateRepeat]))
            glowCircle.run(SKAction.sequence([delay, pulseRepeat]))
        }
    }
    
    // MARK: - Resume için Hazırlık Efekti
    internal func createGetReadyEffect() {
        // Arka plan efekti
        let getReadyOverlay = SKSpriteNode(color: .black, size: frame.size)
        getReadyOverlay.alpha = 0.0
        getReadyOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        getReadyOverlay.name = "getReadyOverlay"
        getReadyOverlay.zPosition = 120
        addChild(getReadyOverlay)
        
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        getReadyOverlay.run(fadeIn)
        
        // Ana metin container
        let textContainer = SKNode()
        textContainer.position = CGPoint(x: frame.midX, y: frame.midY)
        textContainer.zPosition = 125
        textContainer.name = "getReadyContainer"
        addChild(textContainer)
        
        // GET READY metni
        let getReadyLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        getReadyLabel.text = "⚡ GET READY! ⚡"
        getReadyLabel.fontSize = 28
        getReadyLabel.fontColor = glowColor
        getReadyLabel.horizontalAlignmentMode = .center
        getReadyLabel.verticalAlignmentMode = .center
        getReadyLabel.position = CGPoint.zero
        getReadyLabel.zPosition = 3
        textContainer.addChild(getReadyLabel)
        
        // Gölge efekti
        let shadowLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        shadowLabel.text = "GET READY!"
        shadowLabel.fontSize = 28
        shadowLabel.fontColor = shadowColor
        shadowLabel.horizontalAlignmentMode = .center
        shadowLabel.verticalAlignmentMode = .center
        shadowLabel.position = CGPoint(x: 3, y: -3)
        shadowLabel.zPosition = 2
        textContainer.addChild(shadowLabel)
        
        // Işıma efekti
        let glowBg = SKSpriteNode(color: glowColor, size: CGSize(width: 250, height: 60))
        glowBg.alpha = 0.0
        glowBg.position = CGPoint.zero
        glowBg.zPosition = 1
        textContainer.addChild(glowBg)
        
        // Giriş animasyonu
        textContainer.setScale(0.1)
        textContainer.alpha = 0.0
        
        let scaleAnimation = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        let fadeInText = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let entryGroup = SKAction.group([scaleAnimation, fadeInText])
        
        // Işıma animasyonu
        let glowIn = SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        let glowOut = SKAction.fadeAlpha(to: 0.0, duration: 0.4)
        let glowSequence = SKAction.sequence([glowIn, glowOut])
        
        // Parçacık efektleri
        for i in 0..<8 {
            let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 4, height: 4))
            let angle = CGFloat(i) * CGFloat.pi * 2 / 8
            let radius: CGFloat = 80
            let startX = cos(angle) * 20
            let startY = sin(angle) * 20
            let endX = cos(angle) * radius
            let endY = sin(angle) * radius
            
            particle.position = CGPoint(x: startX, y: startY)
            particle.zPosition = 4
            particle.alpha = 0.0
            textContainer.addChild(particle)
            
            let particleDelay = SKAction.wait(forDuration: 0.1)
            let particleFadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
            let particleMove = SKAction.moveBy(x: endX - startX, y: endY - startY, duration: 0.3)
            let particleFadeOut = SKAction.fadeOut(withDuration: 0.2)
            let particleRemove = SKAction.removeFromParent()
            
            let particleSequence = SKAction.sequence([
                particleDelay,
                particleFadeIn,
                SKAction.group([particleMove, particleFadeOut]),
                particleRemove
            ])
            
            particle.run(particleSequence)
        }
        
        // Ana animasyon sırası
        textContainer.run(entryGroup)
        glowBg.run(SKAction.sequence([SKAction.wait(forDuration: 0.05), glowSequence]))
        
        // Haptic feedback
        HapticManager.shared.playSimpleHaptic(intensity: 0.8, sharpness: 0.6)
        
        // Temizlik ve oyun başlatma
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let remove = SKAction.removeFromParent()
            let cleanup = SKAction.sequence([fadeOut, remove])
            
            getReadyOverlay.run(cleanup)
            textContainer.run(cleanup) {
                // Oyunu gerçekten başlat
                self.actuallyResumeGame()
            }
        }
    }
    
    // MARK: - Minimal Ses Toggle Efekti
    internal func updateSoundButtonVisual() {
        if let soundButton = childNode(withName: "soundToggleButton") {
            let soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
            let newIcon = soundEnabled ? "🔊" : "🔇"
            
            // İkonu güncelle
            for child in soundButton.children {
                if let label = child as? SKLabelNode {
                    label.text = newIcon
                    
                    // İkon değişim efekti
                    let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
                    let iconChange = SKAction.sequence([scaleDown, scaleUp])
                    label.run(iconChange)
                    break
                }
            }
            
            // Arka plan rengini güncelle
            for child in soundButton.children {
                if let sprite = child as? SKSpriteNode, child.zPosition == 1 {
                    let colorChange = SKAction.colorize(with: soundEnabled ? glowColor : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.2)
                    sprite.run(colorChange)
                    
                    // Highlight ekle/kaldır
                    soundButton.children.filter { $0.zPosition == 2 && $0 is SKSpriteNode && $0.position.y > 0 }.forEach { $0.removeFromParent() }
                    
                    if soundEnabled {
                        let highlight = SKSpriteNode(color: .white, size: CGSize(width: 36, height: 4))
                        highlight.position = CGPoint(x: 0, y: 16)
                        highlight.alpha = 0.6
                        highlight.zPosition = 2
                        soundButton.addChild(highlight)
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Minimal Titreşim Toggle Efekti
    internal func updateHapticButtonVisual() {
        if let hapticButton = childNode(withName: "hapticToggleButton") {
            let hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
            let newIcon = hapticEnabled ? "📳" : "📴"
            
            // İkonu güncelle
            for child in hapticButton.children {
                if let label = child as? SKLabelNode {
                    label.text = newIcon
                    
                    // İkon değişim efekti
                    let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
                    let iconChange = SKAction.sequence([scaleDown, scaleUp])
                    label.run(iconChange)
                    break
                }
            }
            
            // Arka plan rengini güncelle
            for child in hapticButton.children {
                if let sprite = child as? SKSpriteNode, child.zPosition == 1 {
                    let colorChange = SKAction.colorize(with: hapticEnabled ? glowColor : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), colorBlendFactor: 1.0, duration: 0.2)
                    sprite.run(colorChange)
                    
                    // Highlight ekle/kaldır
                    hapticButton.children.filter { $0.zPosition == 2 && $0 is SKSpriteNode && $0.position.y > 0 }.forEach { $0.removeFromParent() }
                    
                    if hapticEnabled {
                        let highlight = SKSpriteNode(color: .white, size: CGSize(width: 36, height: 4))
                        highlight.position = CGPoint(x: 0, y: 16)
                        highlight.alpha = 0.6
                        highlight.zPosition = 2
                        hapticButton.addChild(highlight)
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Gerçek Resume İşlemi (Private)
    private func actuallyResumeGame() {
        isGamePaused = false
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
        let exitGroup = SKAction.group([fadeOut, scaleDown])
        
        let pauseMenuElements = children.filter { node in
            if let nodeName = node.name {
                return (nodeName.contains("pause") && nodeName != "pauseButton") ||
                       nodeName == "playButton" ||
                       nodeName == "menuButtonPause" ||
                       nodeName == "soundToggleButton" ||
                       nodeName == "hapticToggleButton" ||
                       nodeName == "pauseOverlay" ||
                       nodeName == "pauseGradient" ||
                       nodeName == "pauseLabel" ||
                       nodeName == "pauseShadow" ||
                       nodeName == "pauseParticle" ||
                       nodeName == "pauseGlow"
            }
            return false
        }
        
        for element in pauseMenuElements {
            element.run(exitGroup) {
                element.removeFromParent()
            }
        }
    }
}
