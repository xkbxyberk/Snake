import SpriteKit
import GameplayKit

class LeaderboardScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var clearButton: SKShapeNode!
    private var scoreCards: [SKNode] = []
    private var emptyStateContainer: SKNode?
    private var currentContentContainer: SKNode?
    
    private var speedTabs: [SKNode] = []
    private var currentSpeedProfile: Int = 1
    private let speedProfileNames = ["SLOW", "NORMAL", "FAST", "VERY FAST"]
    private let speedProfileIcons = ["🐌", "🚶", "🏃", "🚀"]
    
    private var topScoreEntries: [ScoreManager.ScoreEntry] = []
    private let maxScores = 10
    
    private let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    private let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    private let cardColor = SKColor(red: 220/255, green: 240/255, blue: 220/255, alpha: 0.95)
    private let goldColor = SKColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
    private let silverColor = SKColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
    private let bronzeColor = SKColor(red: 205/255, green: 127/255, blue: 50/255, alpha: 1.0)
    private let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    private let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    private let tabActiveColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 1.0)
    private let tabInactiveColor = SKColor(red: 120/255, green: 120/255, blue: 120/255, alpha: 0.8)
    
    override func didMove(to view: SKView) {
        setupLeaderboard()
        createAnimatedBackground()
        startAnimations()
    }
    
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
    
    private func setupLeaderboard() {
        createEnhancedTitle()
        createSpeedTabs()
        loadScoreEntriesForCurrentProfile()
        createContentForCurrentProfile()
        createButtons()
        createDecorations()
    }
    
    private func createEnhancedTitle() {
        titleLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        titleLabel.text = "🏆 LEADERBOARD 🏆"
        titleLabel.fontSize = 28
        titleLabel.fontColor = primaryColor
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 320)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        let titleShadow = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        titleShadow.text = "LEADERBOARD"
        titleShadow.fontSize = 28
        titleShadow.fontColor = shadowColor
        titleShadow.position = CGPoint(x: frame.midX + 3, y: frame.midY + 317)
        titleShadow.zPosition = 9
        addChild(titleShadow)
        
        let float = SKAction.moveBy(x: 0, y: 6, duration: 2.5)
        let floatDown = SKAction.moveBy(x: 0, y: -6, duration: 2.5)
        let floatSequence = SKAction.sequence([float, floatDown])
        let floatRepeat = SKAction.repeatForever(floatSequence)
        titleLabel.run(floatRepeat)
        titleShadow.run(floatRepeat)
    }
    
    private func createSpeedTabs() {
        let tabWidth: CGFloat = 70
        let tabHeight: CGFloat = 45
        let tabSpacing: CGFloat = 75
        let startX = frame.midX - (CGFloat(speedProfileNames.count - 1) * tabSpacing) / 2
        let tabY = frame.midY + 260
        
        for i in 0..<speedProfileNames.count {
            let speedProfile = i + 1
            let tabContainer = SKNode()
            tabContainer.position = CGPoint(x: startX + CGFloat(i) * tabSpacing, y: tabY)
            tabContainer.name = "speedTab\(speedProfile)"
            tabContainer.zPosition = 15
            
            let isActive = speedProfile == currentSpeedProfile
            
            let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: tabWidth + 20, height: tabHeight + 20))
            hitArea.position = CGPoint.zero
            hitArea.zPosition = 10
            hitArea.name = "speedTab\(speedProfile)HitArea"
            tabContainer.addChild(hitArea)
            
            let tabBg = SKShapeNode(rect: CGRect(x: -tabWidth/2, y: -tabHeight/2, width: tabWidth, height: tabHeight))
            tabBg.fillColor = isActive ? tabActiveColor : tabInactiveColor
            tabBg.strokeColor = primaryColor
            tabBg.lineWidth = isActive ? 3 : 2
            tabBg.zPosition = 1
            tabBg.name = "tabBackground"
            tabContainer.addChild(tabBg)
            
            if isActive {
                let highlight = SKShapeNode(rect: CGRect(x: -tabWidth/2 + 3, y: tabHeight/2 - 6, width: tabWidth - 6, height: 3))
                highlight.fillColor = SKColor.white
                highlight.strokeColor = .clear
                highlight.alpha = 0.8
                highlight.zPosition = 2
                tabContainer.addChild(highlight)
            }
            
            let iconLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            iconLabel.text = speedProfileIcons[i]
            iconLabel.fontSize = 16
            iconLabel.position = CGPoint(x: 0, y: 4)
            iconLabel.zPosition = 3
            tabContainer.addChild(iconLabel)
            
            let nameLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            nameLabel.text = speedProfileNames[i]
            nameLabel.fontSize = 9
            nameLabel.fontColor = isActive ? .white : primaryColor
            nameLabel.horizontalAlignmentMode = .center
            nameLabel.position = CGPoint(x: 0, y: -12)
            nameLabel.zPosition = 3
            nameLabel.name = "tabLabel"
            tabContainer.addChild(nameLabel)
            
            addChild(tabContainer)
            speedTabs.append(tabContainer)
            
            tabContainer.alpha = 0.0
            let delay = SKAction.wait(forDuration: Double(i) * 0.1)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            tabContainer.run(SKAction.sequence([delay, fadeIn]))
            
            if isActive {
                let pulseUp = SKAction.scale(to: 1.05, duration: 1.0)
                let pulseDown = SKAction.scale(to: 1.0, duration: 1.0)
                let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
                let pulseRepeat = SKAction.repeatForever(pulseSequence)
                tabContainer.run(SKAction.sequence([delay, SKAction.wait(forDuration: 0.5), pulseRepeat]))
            }
        }
    }
    
    private func loadScoreEntriesForCurrentProfile() {
        topScoreEntries = ScoreManager.shared.getTopScoreEntriesForSpeedProfile(currentSpeedProfile, limit: maxScores)
    }
    
    private func createContentForCurrentProfile() {
        currentContentContainer?.removeFromParent()
        currentContentContainer = SKNode()
        currentContentContainer!.zPosition = 5
        addChild(currentContentContainer!)
        
        if topScoreEntries.isEmpty {
            createEmptyState()
        } else {
            createPodium()
            createScoreCards()
        }
    }
    
    private func createEmptyState() {
        emptyStateContainer = SKNode()
        emptyStateContainer!.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        emptyStateContainer!.zPosition = 5
        currentContentContainer!.addChild(emptyStateContainer!)
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 200
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 5, y: -cardHeight/2 - 5, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        emptyStateContainer!.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        emptyStateContainer!.addChild(card)
        
        let highlight = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 5, y: cardHeight/2 - 8, width: cardWidth - 10, height: 4))
        highlight.fillColor = glowColor
        highlight.strokeColor = .clear
        highlight.zPosition = 3
        emptyStateContainer!.addChild(highlight)
        
        let emptyIcon = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        emptyIcon.text = speedProfileIcons[currentSpeedProfile - 1]
        emptyIcon.fontSize = 50
        emptyIcon.position = CGPoint(x: 0, y: 40)
        emptyIcon.zPosition = 4
        emptyStateContainer!.addChild(emptyIcon)
        
        let mainMessage = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        mainMessage.text = "NO \(speedProfileNames[currentSpeedProfile - 1]) SCORES!"
        mainMessage.fontSize = 18
        mainMessage.fontColor = primaryColor
        mainMessage.horizontalAlignmentMode = .center
        mainMessage.position = CGPoint(x: 0, y: 5)
        mainMessage.zPosition = 4
        emptyStateContainer!.addChild(mainMessage)
        
        let subMessage = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        subMessage.text = "Play on \(speedProfileNames[currentSpeedProfile - 1]) speed"
        subMessage.fontSize = 14
        subMessage.fontColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        subMessage.horizontalAlignmentMode = .center
        subMessage.position = CGPoint(x: 0, y: -15)
        subMessage.zPosition = 4
        emptyStateContainer!.addChild(subMessage)
        
        let playMessage = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        playMessage.text = "🎮 START PLAYING!"
        playMessage.fontSize = 16
        playMessage.fontColor = primaryColor
        playMessage.horizontalAlignmentMode = .center
        playMessage.position = CGPoint(x: 0, y: -40)
        playMessage.zPosition = 4
        emptyStateContainer!.addChild(playMessage)
        
        let gamesPlayed = ScoreManager.shared.getTotalGamesPlayedForSpeedProfile(currentSpeedProfile)
        if gamesPlayed > 0 {
            let statsMessage = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            statsMessage.text = "(\(gamesPlayed) games played on this speed)"
            statsMessage.fontSize = 10
            statsMessage.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            statsMessage.horizontalAlignmentMode = .center
            statsMessage.position = CGPoint(x: 0, y: -65)
            statsMessage.zPosition = 4
            emptyStateContainer!.addChild(statsMessage)
        }
        
        emptyStateContainer!.alpha = 0.0
        emptyStateContainer!.setScale(0.8)
        
        let delay = SKAction.wait(forDuration: 0.15)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        emptyStateContainer!.run(SKAction.sequence([delay, entrance]))
        
        let iconPulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        let iconRepeat = SKAction.repeatForever(iconPulse)
        emptyIcon.run(SKAction.sequence([delay, SKAction.wait(forDuration: 0.4), iconRepeat]))
        
        let playGlow = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 1.0),
            SKAction.fadeAlpha(to: 0.6, duration: 1.0)
        ])
        let playGlowRepeat = SKAction.repeatForever(playGlow)
        playMessage.run(SKAction.sequence([delay, SKAction.wait(forDuration: 0.6), playGlowRepeat]))
    }
    
    private func createPodium() {
        guard topScoreEntries.count > 0 else { return }
        
        let podiumContainer = SKNode()
        podiumContainer.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        podiumContainer.zPosition = 5
        currentContentContainer!.addChild(podiumContainer)
        
        let podiumWidth: CGFloat = 280
        let podiumHeight: CGFloat = 120
        
        let podiumBg = SKShapeNode(rect: CGRect(x: -podiumWidth/2, y: -podiumHeight/2, width: podiumWidth, height: podiumHeight))
        podiumBg.fillColor = cardColor
        podiumBg.strokeColor = goldColor
        podiumBg.lineWidth = 3
        podiumBg.zPosition = 1
        podiumContainer.addChild(podiumBg)
        
        let podiumHighlight = SKShapeNode(rect: CGRect(x: -podiumWidth/2 + 5, y: podiumHeight/2 - 6, width: podiumWidth - 10, height: 4))
        podiumHighlight.fillColor = goldColor
        podiumHighlight.strokeColor = .clear
        podiumHighlight.alpha = 0.8
        podiumHighlight.zPosition = 2
        podiumContainer.addChild(podiumHighlight)
        
        let speedIcon = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        speedIcon.text = speedProfileIcons[currentSpeedProfile - 1]
        speedIcon.fontSize = 20
        speedIcon.position = CGPoint(x: -podiumWidth/2 + 25, y: podiumHeight/2 - 25)
        speedIcon.zPosition = 3
        podiumContainer.addChild(speedIcon)
        
        let speedLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        speedLabel.text = speedProfileNames[currentSpeedProfile - 1]
        speedLabel.fontSize = 12
        speedLabel.fontColor = primaryColor
        speedLabel.position = CGPoint(x: -podiumWidth/2 + 25, y: podiumHeight/2 - 45)
        speedLabel.zPosition = 3
        podiumContainer.addChild(speedLabel)
        
        let positions = [
            CGPoint(x: 0, y: 20),
            CGPoint(x: -80, y: 0),
            CGPoint(x: 80, y: 0)
        ]
        
        let medals = ["🥇", "🥈", "🥉"]
        let colors = [goldColor, silverColor, bronzeColor]
        
        for i in 0..<min(3, topScoreEntries.count) {
            let position = positions[i]
            let medal = medals[i]
            let color = colors[i]
            let scoreEntry = topScoreEntries[i]
            
            let medalLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            medalLabel.text = medal
            medalLabel.fontSize = i == 0 ? 28 : 20
            medalLabel.position = CGPoint(x: position.x, y: position.y + 20)
            medalLabel.zPosition = 3
            podiumContainer.addChild(medalLabel)
            
            let rankLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            rankLabel.text = "\(i + 1)."
            rankLabel.fontSize = 12
            rankLabel.fontColor = color
            rankLabel.position = CGPoint(x: position.x, y: position.y + 2)
            rankLabel.zPosition = 3
            podiumContainer.addChild(rankLabel)
            
            let nameLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            let displayName = scoreEntry.playerName.count > 7 ?
                String(scoreEntry.playerName.prefix(7)) + "..." : scoreEntry.playerName
            nameLabel.text = displayName
            nameLabel.fontSize = i == 0 ? 12 : 9
            nameLabel.fontColor = primaryColor
            nameLabel.position = CGPoint(x: position.x, y: position.y - 12)
            nameLabel.zPosition = 3
            podiumContainer.addChild(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            scoreLabel.text = "\(scoreEntry.score)"
            scoreLabel.fontSize = i == 0 ? 14 : 10
            scoreLabel.fontColor = primaryColor
            scoreLabel.position = CGPoint(x: position.x, y: position.y - 25)
            scoreLabel.zPosition = 3
            podiumContainer.addChild(scoreLabel)
            
            let delay = SKAction.wait(forDuration: 0.2 + Double(i) * 0.1)
            medalLabel.alpha = 0.0
            rankLabel.alpha = 0.0
            nameLabel.alpha = 0.0
            scoreLabel.alpha = 0.0
            
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            let bounceUp = SKAction.moveBy(x: 0, y: 8, duration: 0.2)
            let bounceDown = SKAction.moveBy(x: 0, y: -8, duration: 0.2)
            let bounceSequence = SKAction.sequence([bounceUp, bounceDown])
            let entryAnimation = SKAction.group([fadeIn, bounceSequence])
            
            medalLabel.run(SKAction.sequence([delay, entryAnimation]))
            rankLabel.run(SKAction.sequence([delay, entryAnimation]))
            nameLabel.run(SKAction.sequence([delay, entryAnimation]))
            scoreLabel.run(SKAction.sequence([delay, entryAnimation]))
            
            if i == 0 {
                let glow = SKSpriteNode(color: goldColor, size: CGSize(width: 40, height: 40))
                glow.alpha = 0.0
                glow.position = CGPoint(x: position.x, y: position.y + 20)
                glow.zPosition = 2
                podiumContainer.addChild(glow)
                
                let glowPulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.4, duration: 1.0),
                    SKAction.fadeAlpha(to: 0.1, duration: 1.0)
                ])
                let glowRepeat = SKAction.repeatForever(glowPulse)
                glow.run(SKAction.sequence([delay, SKAction.wait(forDuration: 0.4), glowRepeat]))
            }
        }
        
        podiumContainer.alpha = 0.0
        podiumContainer.setScale(0.8)
        
        let podiumDelay = SKAction.wait(forDuration: 0.1)
        let podiumFadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let podiumScaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let podiumEntrance = SKAction.group([podiumFadeIn, podiumScaleUp])
        podiumContainer.run(SKAction.sequence([podiumDelay, podiumEntrance]))
    }
    
    private func createScoreCards() {
        if topScoreEntries.count <= 3 { return }
        
        let startY = frame.midY - 40
        let cardSpacing: CGFloat = 32
        let cardWidth: CGFloat = 270
        let cardHeight: CGFloat = 30
        
        for i in 3..<min(maxScores, topScoreEntries.count) {
            let rank = i + 1
            let scoreEntry = topScoreEntries[i]
            
            let cardContainer = SKNode()
            cardContainer.position = CGPoint(x: frame.midX, y: startY - CGFloat(i - 3) * cardSpacing)
            cardContainer.zPosition = 5
            currentContentContainer!.addChild(cardContainer)
            scoreCards.append(cardContainer)
            
            let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
            card.fillColor = cardColor
            card.strokeColor = primaryColor
            card.lineWidth = 2
            card.zPosition = 1
            cardContainer.addChild(card)
            
            let rankLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            rankLabel.text = "\(rank)."
            rankLabel.fontSize = 12
            rankLabel.fontColor = primaryColor
            rankLabel.horizontalAlignmentMode = .left
            rankLabel.verticalAlignmentMode = .center
            rankLabel.position = CGPoint(x: -cardWidth/2 + 12, y: 3)
            rankLabel.zPosition = 2
            cardContainer.addChild(rankLabel)
            
            let nameLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            let displayName = scoreEntry.playerName.count > 10 ?
                String(scoreEntry.playerName.prefix(10)) + "..." : scoreEntry.playerName
            nameLabel.text = displayName
            nameLabel.fontSize = 10
            nameLabel.fontColor = primaryColor
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.verticalAlignmentMode = .center
            nameLabel.position = CGPoint(x: -cardWidth/2 + 35, y: 3)
            nameLabel.zPosition = 2
            cardContainer.addChild(nameLabel)
            
            let scoreLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            scoreLabel.text = "\(scoreEntry.score)"
            scoreLabel.fontSize = 12
            scoreLabel.fontColor = primaryColor
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.verticalAlignmentMode = .center
            scoreLabel.position = CGPoint(x: cardWidth/2 - 12, y: 3)
            scoreLabel.zPosition = 2
            cardContainer.addChild(scoreLabel)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let dateText = dateFormatter.string(from: scoreEntry.date)
            
            let dateLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            dateLabel.text = dateText
            dateLabel.fontSize = 8
            dateLabel.fontColor = SKColor.gray
            dateLabel.horizontalAlignmentMode = .right
            dateLabel.verticalAlignmentMode = .center
            dateLabel.position = CGPoint(x: cardWidth/2 - 12, y: -8)
            dateLabel.zPosition = 2
            cardContainer.addChild(dateLabel)
            
            cardContainer.alpha = 0.0
            
            let delay = SKAction.wait(forDuration: 0.3 + Double(i - 3) * 0.04)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            cardContainer.run(SKAction.sequence([delay, fadeIn]))
        }
    }
    
    private func createButtons() {
        let buttonWidth: CGFloat = 130
        let buttonHeight: CGFloat = 40
        
        backButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        backButton.fillColor = primaryColor
        backButton.strokeColor = glowColor
        backButton.lineWidth = 3
        backButton.position = CGPoint(x: frame.midX - 70, y: frame.minY + 70)
        backButton.name = "backButton"
        backButton.zPosition = 20
        
        let backHitArea = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth + 30, height: buttonHeight + 15))
        backHitArea.position = CGPoint.zero
        backHitArea.zPosition = 10
        backHitArea.name = "backButtonHitArea"
        backButton.addChild(backHitArea)
        
        let backShadow = SKShapeNode(rect: CGRect(x: -buttonWidth/2 + 3, y: -buttonHeight/2 - 3, width: buttonWidth, height: buttonHeight))
        backShadow.fillColor = shadowColor
        backShadow.strokeColor = .clear
        backShadow.zPosition = -1
        backButton.addChild(backShadow)
        
        let backLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        backLabel.text = "🏠 BACK"
        backLabel.fontSize = 12
        backLabel.fontColor = backgroundGreen
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backLabel.zPosition = 1
        backButton.addChild(backLabel)
        addChild(backButton)
        
        if !topScoreEntries.isEmpty {
            clearButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
            clearButton.fillColor = SKColor.red
            clearButton.strokeColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
            clearButton.lineWidth = 3
            clearButton.position = CGPoint(x: frame.midX + 70, y: frame.minY + 70)
            clearButton.name = "clearButton"
            clearButton.zPosition = 20
            
            let clearHitArea = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth + 40, height: buttonHeight + 20))
            clearHitArea.position = CGPoint.zero
            clearHitArea.zPosition = 10
            clearHitArea.name = "clearButtonHitArea"
            clearButton.addChild(clearHitArea)
            
            let clearShadow = SKShapeNode(rect: CGRect(x: -buttonWidth/2 + 3, y: -buttonHeight/2 - 3, width: buttonWidth, height: buttonHeight))
            clearShadow.fillColor = shadowColor
            clearShadow.strokeColor = .clear
            clearShadow.zPosition = -1
            clearButton.addChild(clearShadow)
            
            let clearLabel = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            clearLabel.text = "🗑️ CLEAR"
            clearLabel.fontSize = 12
            clearLabel.fontColor = .white
            clearLabel.verticalAlignmentMode = .center
            clearLabel.horizontalAlignmentMode = .center
            clearLabel.zPosition = 1
            clearButton.addChild(clearLabel)
            addChild(clearButton)
        }
        
        backButton.alpha = 0.0
        let buttonDelay = SKAction.wait(forDuration: 0.8)
        let buttonFadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        backButton.run(SKAction.sequence([buttonDelay, buttonFadeIn]))
        
        if let clear = clearButton {
            clear.alpha = 0.0
            clear.run(SKAction.sequence([buttonDelay, SKAction.wait(forDuration: 0.1), buttonFadeIn]))
        }
    }
    
    private func createDecorations() {
        for i in 0..<4 {
            let trophy = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
            trophy.text = ["🏆", "🥇", "🏅", "⭐"][i]
            trophy.fontSize = 16
            let randomX = CGFloat.random(in: 30...(frame.maxX - 30))
            let randomY = CGFloat.random(in: 150...(frame.maxY - 150))
            trophy.position = CGPoint(x: randomX, y: randomY)
            trophy.zPosition = 1
            trophy.alpha = 0.0
            addChild(trophy)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.15 + 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.4)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 8.0)
            let rotateForever = SKAction.repeatForever(rotate)
            
            trophy.run(SKAction.sequence([delay, fadeIn]))
            trophy.run(SKAction.sequence([delay, rotateForever]))
        }
    }
    
    private func switchToSpeedProfile(_ newProfile: Int) {
        if newProfile == currentSpeedProfile { return }
        
        updateTabVisuals(oldProfile: currentSpeedProfile, newProfile: newProfile)
        currentSpeedProfile = newProfile
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        currentContentContainer?.run(fadeOut) {
            self.loadScoreEntriesForCurrentProfile()
            self.createContentForCurrentProfile()
            
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            self.currentContentContainer?.run(fadeIn)
        }
        
        clearButton?.removeFromParent()
        clearButton = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.createButtons()
        }
    }
    
    private func updateTabVisuals(oldProfile: Int, newProfile: Int) {
        let tabHeight: CGFloat = 45
        
        if let oldTab = speedTabs.first(where: { $0.name == "speedTab\(oldProfile)" }) {
            if let bg = oldTab.childNode(withName: "tabBackground") as? SKShapeNode {
                bg.fillColor = tabInactiveColor
                bg.lineWidth = 2
            }
            if let label = oldTab.childNode(withName: "tabLabel") as? SKLabelNode {
                label.fontColor = primaryColor
            }
            oldTab.children.filter { $0.zPosition == 2 }.forEach { $0.removeFromParent() }
            oldTab.removeAllActions()
        }
        
        if let newTab = speedTabs.first(where: { $0.name == "speedTab\(newProfile)" }) {
            if let bg = newTab.childNode(withName: "tabBackground") as? SKShapeNode {
                bg.fillColor = tabActiveColor
                bg.lineWidth = 3
                
                let tabWidth: CGFloat = 70
                let highlight = SKShapeNode(rect: CGRect(x: -tabWidth/2 + 3, y: tabHeight/2 - 6, width: tabWidth - 6, height: 3))
                highlight.fillColor = SKColor.white
                highlight.strokeColor = .clear
                highlight.alpha = 0.8
                highlight.zPosition = 2
                newTab.addChild(highlight)
            }
            if let label = newTab.childNode(withName: "tabLabel") as? SKLabelNode {
                label.fontColor = .white
            }
            
            let pulseUp = SKAction.scale(to: 1.05, duration: 1.0)
            let pulseDown = SKAction.scale(to: 1.0, duration: 1.0)
            let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
            let pulseRepeat = SKAction.repeatForever(pulseSequence)
            newTab.run(pulseRepeat)
        }
        
        HapticManager.shared.playSimpleHaptic(intensity: 0.8, sharpness: 0.6)
    }
    
    private func startAnimations() {
        if !topScoreEntries.isEmpty {
            run(SKAction.repeatForever(SKAction.sequence([
                SKAction.wait(forDuration: 4.0),
                SKAction.run { self.createConfetti() }
            ])))
        }
    }
    
    private func createConfetti() {
        let colors = [goldColor, silverColor, bronzeColor, glowColor]
        
        for _ in 0..<6 {
            let confetti = SKSpriteNode(color: colors.randomElement()!, size: CGSize(width: 3, height: 3))
            confetti.position = CGPoint(x: CGFloat.random(in: 0...frame.maxX), y: frame.maxY + 10)
            confetti.zPosition = 1
            addChild(confetti)
            
            let fall = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: -(frame.height + 20), duration: 2.5)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 3, duration: 2.5)
            let fadeOut = SKAction.fadeOut(withDuration: 2.5)
            let remove = SKAction.removeFromParent()
            
            let group = SKAction.group([fall, rotate, fadeOut])
            let sequence = SKAction.sequence([group, remove])
            confetti.run(sequence)
        }
    }
    
    private func animateTabPress(_ tab: SKNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let normal = SKAction.scale(to: 1.0, duration: 0.1)
        tab.run(SKAction.sequence([scaleDown, scaleUp, normal]))
        
        createInstantGlowEffect(at: tab.position, size: CGSize(width: 90, height: 65))
    }
    
    private func animateButtonPress(_ button: SKShapeNode) {
        let instantScale = SKAction.scale(to: 0.85, duration: 0.04)
        let bounceBack = SKAction.scale(to: 1.15, duration: 0.1)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([instantScale, bounceBack, settle]))
        
        createInstantGlowEffect(at: button.position, size: CGSize(width: 160, height: 60))
        
        triggerInstantHaptic()
    }
    
    private func createInstantGlowEffect(at position: CGPoint, size: CGSize) {
        let glowNode = SKSpriteNode(color: glowColor, size: size)
        glowNode.alpha = 0.0
        glowNode.position = position
        glowNode.zPosition = 25
        addChild(glowNode)
        
        let glowIn = SKAction.fadeAlpha(to: 0.8, duration: 0.02)
        let glowOut = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([glowIn, glowOut, remove])
        glowNode.run(glowSequence)
    }
    
    private func triggerInstantHaptic() {
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 1.0)
    }
    
    private func clearScores() {
        ScoreManager.shared.clearAllScores()
        
        createInstantClearEffect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshScene()
        }
    }
    
    private func createInstantClearEffect() {
        let clearFlash = SKSpriteNode(color: .red, size: frame.size)
        clearFlash.alpha = 0.0
        clearFlash.position = CGPoint(x: frame.midX, y: frame.midY)
        clearFlash.zPosition = 30
        addChild(clearFlash)
        
        let flashIn = SKAction.fadeAlpha(to: 0.6, duration: 0.05)
        let flashOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        let flashSequence = SKAction.sequence([flashIn, flashOut, remove])
        clearFlash.run(flashSequence)
        
        let clearMessage = SKLabelNode(fontNamed: "Doto-Black_ExtraBold")
        clearMessage.text = "✅ CLEARED!"
        clearMessage.fontSize = 20
        clearMessage.fontColor = .white
        clearMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        clearMessage.alpha = 0.0
        clearMessage.zPosition = 35
        addChild(clearMessage)
        
        let messageIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let messageWait = SKAction.wait(forDuration: 0.15)
        let messageOut = SKAction.fadeOut(withDuration: 0.1)
        let messageRemove = SKAction.removeFromParent()
        let messageSequence = SKAction.sequence([messageIn, messageWait, messageOut, messageRemove])
        clearMessage.run(messageSequence)
    }
    
    private func refreshScene() {
        let leaderboardScene = LeaderboardScene()
        leaderboardScene.size = frame.size
        leaderboardScene.scaleMode = .aspectFill
        
        let transition = SKTransition.crossFade(withDuration: 0.2)
        view?.presentScene(leaderboardScene, transition: transition)
    }
    
    private func goBack() {
        let menuScene = MenuScene()
        menuScene.size = frame.size
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.push(with: .right, duration: 0.2)
        view?.presentScene(menuScene, transition: transition)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name ?? touchedNode.parent?.parent?.name {
            
            if nodeName.hasPrefix("speedTab") && nodeName.hasSuffix("HitArea") {
                let profileString = nodeName.replacingOccurrences(of: "speedTab", with: "").replacingOccurrences(of: "HitArea", with: "")
                if let profile = Int(profileString), profile != currentSpeedProfile {
                    if let tab = speedTabs.first(where: { $0.name == "speedTab\(profile)" }) {
                        animateTabPress(tab)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.switchToSpeedProfile(profile)
                        }
                    }
                }
                return
            }
            
            switch nodeName {
            case "backButton", "backButtonHitArea":
                animateButtonPress(backButton)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.goBack()
                }
            case "clearButton", "clearButtonHitArea":
                if let clear = clearButton {
                    animateButtonPress(clear)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.clearScores()
                    }
                }
            default:
                break
            }
        }
    }
}
