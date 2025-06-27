import SpriteKit
import GameplayKit

extension GameScene {
    
    internal func createNameInputDialog() {
        nameInputContainer = SKNode()
        nameInputContainer!.position = CGPoint(x: frame.midX, y: frame.midY)
        nameInputContainer!.zPosition = 110
        nameInputContainer!.alpha = 0.0
        addChild(nameInputContainer!)
        
        let dialogWidth: CGFloat = 300
        let dialogHeight: CGFloat = 180
        
        let dialogBg = SKShapeNode(rect: CGRect(x: -dialogWidth/2, y: -dialogHeight/2, width: dialogWidth, height: dialogHeight))
        dialogBg.fillColor = primaryColor
        dialogBg.strokeColor = glowColor
        dialogBg.lineWidth = 4
        dialogBg.zPosition = 1
        nameInputContainer!.addChild(dialogBg)
        
        let titleLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        titleLabel.text = "🏆 SAVE YOUR SCORE"
        titleLabel.fontSize = 18
        titleLabel.fontColor = backgroundGreen
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 2
        nameInputContainer!.addChild(titleLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        scoreLabel.text = "SCORE: \(currentGameScore)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = backgroundGreen
        scoreLabel.position = CGPoint(x: 0, y: 30)
        scoreLabel.zPosition = 2
        nameInputContainer!.addChild(scoreLabel)
        
        let inputBg = SKShapeNode(rect: CGRect(x: -120, y: -15, width: 240, height: 30))
        inputBg.fillColor = backgroundGreen
        inputBg.strokeColor = .clear
        inputBg.zPosition = 2
        nameInputContainer!.addChild(inputBg)
        
        let placeholderLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        placeholderLabel.text = "ENTER YOUR NAME..."
        placeholderLabel.fontSize = 14
        placeholderLabel.fontColor = SKColor.gray
        placeholderLabel.position = CGPoint(x: 0, y: -5)
        placeholderLabel.zPosition = 3
        placeholderLabel.name = "placeholderText"
        nameInputContainer!.addChild(placeholderLabel)
        
        let nameDisplayLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        nameDisplayLabel.text = ""
        nameDisplayLabel.fontSize = 16
        nameDisplayLabel.fontColor = primaryColor
        nameDisplayLabel.position = CGPoint(x: 0, y: -5)
        nameDisplayLabel.zPosition = 4
        nameDisplayLabel.name = "nameDisplayLabel"
        nameInputContainer!.addChild(nameDisplayLabel)
        
        // YENI EKLENEN KOD: Hit area ekle
        let inputHitArea = SKSpriteNode(color: .clear, size: CGSize(width: 240, height: 30))
        inputHitArea.position = CGPoint(x: 0, y: -5)
        inputHitArea.zPosition = 5
        inputHitArea.name = "nameInputHitArea"
        nameInputContainer!.addChild(inputHitArea)
        
        createNameInputButtons()
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        
        nameInputContainer!.setScale(0.8)
        nameInputContainer!.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), entrance]))
        
        isNameInputActive = true
        playerName = ""
        
        createInvisibleTextField()
    }
    
    internal func createNameInputButtons() {
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 35
        
        let saveButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        saveButton.fillColor = glowColor
        saveButton.strokeColor = .clear
        saveButton.position = CGPoint(x: -70, y: -60)
        saveButton.name = "saveScoreButton"
        saveButton.zPosition = 2
        nameInputContainer!.addChild(saveButton)
        
        let saveLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        saveLabel.text = "💾 SAVE"
        saveLabel.fontSize = 12
        saveLabel.fontColor = primaryColor
        saveLabel.verticalAlignmentMode = .center
        saveLabel.zPosition = 3
        saveButton.addChild(saveLabel)
        
        let anonButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        anonButton.fillColor = SKColor.gray
        anonButton.strokeColor = .clear
        anonButton.position = CGPoint(x: 70, y: -60)
        anonButton.name = "anonScoreButton"
        anonButton.zPosition = 2
        nameInputContainer!.addChild(anonButton)
        
        let anonLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        anonLabel.text = "👤 ANONYMOUS"
        anonLabel.fontSize = 12
        anonLabel.fontColor = .white
        anonLabel.verticalAlignmentMode = .center
        anonLabel.zPosition = 3
        anonButton.addChild(anonLabel)
    }
    
    internal func createInvisibleTextField() {
        guard let view = self.view else { return }
        
        nameTextField = UITextField()
        nameTextField!.isHidden = true
        nameTextField!.becomeFirstResponder()
        nameTextField!.delegate = self
        nameTextField!.autocorrectionType = .no
        nameTextField!.autocapitalizationType = .words
        nameTextField!.returnKeyType = .done
        view.addSubview(nameTextField!)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow() {
        if let container = nameInputContainer {
            let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.3)
            container.run(moveUp)
        }
    }
    
    internal func updateNameDisplay() {
        if let container = nameInputContainer,
           let nameLabel = container.childNode(withName: "nameDisplayLabel") as? SKLabelNode,
           let placeholder = container.childNode(withName: "placeholderText") as? SKLabelNode {
            
            if playerName.isEmpty {
                nameLabel.text = ""
                placeholder.alpha = 1.0
            } else {
                nameLabel.text = playerName
                placeholder.alpha = 0.0
            }
        }
    }
    
    internal func saveScoreWithName(_ name: String) {
        let finalName = name.isEmpty ? "Anonymous" : name
        
        ScoreManager.shared.saveScore(currentGameScore, playerName: finalName, speedProfile: speedSetting)
        
        if currentGameScore > allTimeHighScore {
            allTimeHighScore = currentGameScore
            ScoreManager.shared.saveAllTimeHighScore(currentGameScore)
        }
        
        if currentGameScore > sessionHighScore {
            sessionHighScore = currentGameScore
        }
        
        closeNameInput()
        showGameOverResults()
    }
    
    internal func closeNameInput() {
        isNameInputActive = false
        
        nameTextField?.removeFromSuperview()
        nameTextField = nil
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        if let container = nameInputContainer {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            container.run(fadeOut) {
                container.removeFromParent()
            }
        }
    }
    
    internal func showGameOverResults() {
        createScoreDisplay()
        createActionButtons()
        createGameOverDecorations()
    }
    
    internal func createGameOverBackground() {
        let gameOverOverlay = SKSpriteNode(color: .black, size: frame.size)
        gameOverOverlay.alpha = 0.0
        gameOverOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverOverlay.name = "gameOverOverlay"
        gameOverOverlay.zPosition = 100
        addChild(gameOverOverlay)
        
        let gradientOverlay = SKSpriteNode(color: SKColor(red: 0.2, green: 0.0, blue: 0.0, alpha: 1.0), size: frame.size)
        gradientOverlay.alpha = 0.0
        gradientOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        gradientOverlay.zPosition = 101
        addChild(gradientOverlay)
        
        let fadeIn1 = SKAction.fadeAlpha(to: 0.8, duration: 0.25)
        let fadeIn2 = SKAction.fadeAlpha(to: 0.4, duration: 0.15)
        
        gameOverOverlay.run(fadeIn1)
        gradientOverlay.run(SKAction.sequence([SKAction.wait(forDuration: 0.1), fadeIn2]))
    }
    
    internal func createGameOverAnimation() {
        gameOverLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        gameOverLabel.text = "💀 GAME OVER 💀"
        gameOverLabel.fontSize = 36
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
        gameOverLabel.zPosition = 105
        gameOverLabel.alpha = 0.0
        addChild(gameOverLabel)
        
        let shadowLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        shadowLabel.text = "GAME OVER"
        shadowLabel.fontSize = 36
        shadowLabel.fontColor = shadowColor
        shadowLabel.position = CGPoint(x: frame.midX + 4, y: frame.midY + 196)
        shadowLabel.zPosition = 104
        shadowLabel.alpha = 0.0
        addChild(shadowLabel)
        
        let scaleUp = SKAction.sequence([
            SKAction.scale(to: 0.1, duration: 0.0),
            SKAction.scale(to: 1.2, duration: 0.25)
        ])
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        ])
        
        let introSequence = SKAction.sequence([
            SKAction.group([scaleUp, fadeIn]),
            scaleDown,
            shake
        ])
        
        gameOverLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), introSequence]))
        shadowLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.3), introSequence]))
        
        let pulseUp = SKAction.scale(to: 1.05, duration: 1.0)
        let pulseDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        
        gameOverLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.8), pulseRepeat]))
    }
    
    internal func createScoreDisplay() {
        let scoreContainer = SKNode()
        scoreContainer.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        scoreContainer.zPosition = 103
        scoreContainer.alpha = 0.0
        addChild(scoreContainer)
        
        let scoreBg = SKShapeNode(rect: CGRect(x: -140, y: -50, width: 280, height: 100))
        scoreBg.fillColor = primaryColor
        scoreBg.strokeColor = glowColor
        scoreBg.lineWidth = 3
        scoreContainer.addChild(scoreBg)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        finalScoreLabel.text = "SCORE: \(currentGameScore)"
        finalScoreLabel.fontSize = 20
        finalScoreLabel.fontColor = backgroundGreen
        finalScoreLabel.position = CGPoint(x: 0, y: 15)
        scoreContainer.addChild(finalScoreLabel)
        
        let bestScoreLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        bestScoreLabel.text = "BEST: \(allTimeHighScore)"
        bestScoreLabel.fontSize = 16
        bestScoreLabel.fontColor = backgroundGreen
        bestScoreLabel.position = CGPoint(x: 0, y: -10)
        scoreContainer.addChild(bestScoreLabel)
        
        if isNewRecord {
            let newRecordLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            newRecordLabel.text = "🏆 NEW RECORD! 🏆"
            newRecordLabel.fontSize = 14
            newRecordLabel.fontColor = SKColor.yellow
            newRecordLabel.position = CGPoint(x: 0, y: -30)
            scoreContainer.addChild(newRecordLabel)
            
            let glowUp = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            let glowDown = SKAction.fadeAlpha(to: 0.6, duration: 0.5)
            let glowSequence = SKAction.sequence([glowUp, glowDown])
            let glowRepeat = SKAction.repeatForever(glowSequence)
            newRecordLabel.run(glowRepeat)
        }
        
        let slideIn = SKAction.moveBy(x: 0, y: -50, duration: 0.3)
        let fadeInScore = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scoreAnimation = SKAction.group([slideIn, fadeInScore])
        
        scoreContainer.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), scoreAnimation]))
    }
    
    internal func createActionButtons() {
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 50
        
        let restartButton = createEnhancedGameOverButton(
            text: "🔄 PLAY AGAIN",
            position: CGPoint(x: frame.midX, y: frame.midY - 100),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "restartButton",
            isPrimary: true
        )
        addChild(restartButton)
        
        let menuButton = createEnhancedGameOverButton(
            text: "🏠 MAIN MENU",
            position: CGPoint(x: frame.midX, y: frame.midY - 160),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "menuButton",
            isPrimary: false
        )
        addChild(menuButton)
        
        let delay1 = SKAction.wait(forDuration: 1.0)
        let delay2 = SKAction.wait(forDuration: 1.2)
        
        let slideFromLeft = SKAction.moveBy(x: 300, y: 0, duration: 0.25)
        let slideFromRight = SKAction.moveBy(x: -300, y: 0, duration: 0.25)
        
        restartButton.position.x -= 300
        menuButton.position.x += 300
        
        restartButton.run(SKAction.sequence([delay1, slideFromLeft]))
        menuButton.run(SKAction.sequence([delay2, slideFromRight]))
    }
    
    internal func createEnhancedGameOverButton(text: String, position: CGPoint, size: CGSize, name: String, isPrimary: Bool) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.position = position
        buttonContainer.name = name
        buttonContainer.zPosition = 103
        
        let shadow = SKShapeNode(rect: CGRect(x: -size.width/2 + 5, y: -size.height/2 - 5, width: size.width, height: size.height))
        shadow.fillColor = shadowColor
        shadow.strokeColor = .clear
        buttonContainer.addChild(shadow)
        
        let button = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        button.fillColor = isPrimary ? primaryColor : SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        button.strokeColor = isPrimary ? glowColor : primaryColor
        button.lineWidth = 3
        buttonContainer.addChild(button)
        
        if isPrimary {
            let highlight = SKShapeNode(rect: CGRect(x: -size.width/2 + 5, y: size.height/2 - 10, width: size.width - 10, height: 5))
            highlight.fillColor = glowColor
            highlight.strokeColor = .clear
            buttonContainer.addChild(highlight)
        }
        
        let label = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        label.text = text
        label.fontSize = 18
        label.fontColor = isPrimary ? backgroundGreen : .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        buttonContainer.addChild(label)
        
        if isPrimary {
            let scaleUp = SKAction.scale(to: 1.03, duration: 0.8)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            let repeatAction = SKAction.repeatForever(sequence)
            buttonContainer.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), repeatAction]))
        }
        
        return buttonContainer
    }
    
    internal func createGameOverDecorations() {
        for _ in 0..<12 {
            let segment = SKSpriteNode(color: SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.7),
                                         size: CGSize(width: 8, height: 8))
            let randomX = CGFloat.random(in: 50...(frame.maxX - 50))
            let randomY = CGFloat.random(in: 100...(frame.maxY - 100))
            segment.position = CGPoint(x: randomX, y: randomY)
            segment.zPosition = 102
            segment.alpha = 0.0
            addChild(segment)
            
            let delay = SKAction.wait(forDuration: Double.random(in: 0.4...1.5))
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.25)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi...CGFloat.pi), duration: 2.0)
            let float = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -20...20), duration: 3.0)
            
            segment.run(SKAction.sequence([delay, SKAction.group([fadeIn, rotate, float])]))
        }
        
        for i in 0..<20 {
            let particle = SKSpriteNode(color: SKColor.red, size: CGSize(width: 3, height: 3))
            particle.position = CGPoint(x: frame.midX, y: frame.midY + 200)
            particle.zPosition = 106
            particle.alpha = 0.0
            addChild(particle)
            
            let delay = SKAction.wait(forDuration: 0.4 + Double(i) * 0.05)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
            let spread = SKAction.moveBy(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -100...100),
                duration: 2.0
            )
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([delay, fadeIn, SKAction.group([spread, fadeOut]), remove])
            particle.run(sequence)
        }
    }
}
