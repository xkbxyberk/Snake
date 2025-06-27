import SpriteKit
import GameplayKit

// MARK: - GameScene Countdown Extension
extension GameScene {
    
// MARK: - Geri Sayım
    
    internal func startCountdown() {
        isCountdownActive = true
        countdownNumber = 3
        
        createCountdownBackground()
        createCountdownElements()
        showCountdownNumber()
    }
    
    private func createCountdownBackground() {
        let countdownOverlay = SKSpriteNode(color: .black, size: frame.size)
        countdownOverlay.alpha = 0.0
        countdownOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        countdownOverlay.name = "countdownOverlay"
        countdownOverlay.zPosition = 50
        addChild(countdownOverlay)
        
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        countdownOverlay.run(fadeIn)
        
        let pulseUp = SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        let pulseDown = SKAction.fadeAlpha(to: 0.5, duration: 1.0)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        countdownOverlay.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), pulseRepeat]))
    }
    
    private func createCountdownElements() {
        countdownContainer = SKNode()
        countdownContainer.position = CGPoint(x: frame.midX, y: frame.midY)
        countdownContainer.zPosition = 55
        countdownContainer.name = "countdownContainer"
        addChild(countdownContainer)
        
        countdownLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        countdownLabel.fontSize = 120
        countdownLabel.fontColor = .white
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint.zero
        countdownLabel.zPosition = 3
        countdownContainer.addChild(countdownLabel)
        
        countdownShadow = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        countdownShadow.fontSize = 120
        countdownShadow.fontColor = shadowColor
        countdownShadow.horizontalAlignmentMode = .center
        countdownShadow.verticalAlignmentMode = .center
        countdownShadow.position = CGPoint(x: 6, y: -6)
        countdownShadow.zPosition = 2
        countdownContainer.addChild(countdownShadow)
        
        let glowBg = SKSpriteNode(color: .white, size: CGSize(width: 200, height: 200))
        glowBg.alpha = 0.0
        glowBg.position = CGPoint.zero
        glowBg.zPosition = 1
        countdownContainer.addChild(glowBg)
    }
    
    private func showCountdownNumber() {
        let text: String
        let color: SKColor
        
        if countdownNumber > 0 {
            text = "\(countdownNumber)"
            color = countdownColors[3 - countdownNumber]
        } else {
            text = "GO!"
            color = countdownColors[3]
        }
        
        countdownLabel.text = text
        countdownLabel.fontColor = color
        countdownShadow.text = text
        
        if countdownNumber > 0 {
            countdownLabel.fontSize = 120
            countdownShadow.fontSize = 120
        } else {
            countdownLabel.fontSize = 80
            countdownShadow.fontSize = 80
        }
        
        countdownContainer.setScale(0.1)
        countdownContainer.alpha = 0.0
        
        let scaleAnimation = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        
        let shakeLeft = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 16, y: 0, duration: 0.05)
        let shakeCenter = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        
        let entryGroup = SKAction.group([scaleAnimation, fadeIn])
        let fullAnimation = SKAction.sequence([entryGroup, shakeSequence])
        
        countdownContainer.run(fullAnimation)
        
        if let glowBg = countdownContainer.children.first(where: { $0.zPosition == 1 }) {
            glowBg.removeAllActions()
            let glowIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
            let glowOut = SKAction.fadeAlpha(to: 0.0, duration: 0.6)
            let glowSequence = SKAction.sequence([glowIn, glowOut])
            glowBg.run(glowSequence)
        }
        
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.animateCountdownExit()
        }
    }
    
    private func animateCountdownExit() {
        let scaleOut = SKAction.scale(to: 0.3, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let exitGroup = SKAction.group([scaleOut, fadeOut])
        
        countdownContainer.run(exitGroup) {
            self.countdownNumber -= 1
            
            if self.countdownNumber >= 0 {
                self.showCountdownNumber()
            } else {
                self.finishCountdown()
            }
        }
    }
    
    private func finishCountdown() {
        isCountdownActive = false
        
        let countdownElements = children.filter { node in
            node.name?.contains("countdown") == true
        }
        
        for element in countdownElements {
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            element.run(fadeOut) {
                element.removeFromParent()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startActualGame()
        }
    }
}
