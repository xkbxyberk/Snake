import SpriteKit
import GameplayKit

class AboutScene: SKScene {
    
    // MARK: - Arayüz Elementleri
    private var titleLabel: SKLabelNode!
    private var backButton: SKShapeNode!
    private var infoCards: [SKNode] = []
    private var fontCard: SKNode!
    private var privacyCard: SKNode!
    private var licenseOverlay: SKNode!
    private var privacyOverlay: SKNode!
    private var isLicenseOverlayVisible = false
    private var isPrivacyOverlayVisible = false
    private var currentPage = 0
    private var totalPages = 0
    private var currentPages: [String] = []
    private var pageLabel: SKLabelNode!
    private var textDisplayLabel: SKLabelNode!
    private var prevButton: SKShapeNode!
    private var nextButton: SKShapeNode!
    private var overlayTitle: SKLabelNode!
    
    // MARK: - Renk Paleti
    private let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    private let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    private let cardColor = SKColor(red: 220/255, green: 240/255, blue: 220/255, alpha: 0.95)
    private let accentColor = SKColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
    private let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    private let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    
    override func didMove(to view: SKView) {
        setupAbout()
        createAnimatedBackground()
        createLicenseOverlay()
        createPrivacyOverlay()
    }
    
    // MARK: - Kurulum Metotları
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
    
    private func setupAbout() {
        createEnhancedTitle()
        createInfoCards()
        createBackButton()
    }
    
    private func createEnhancedTitle() {
        titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "ℹ️ ABOUT ℹ️"
        titleLabel.fontSize = 36
        titleLabel.fontColor = primaryColor
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 310)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        let titleShadow = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleShadow.text = "ABOUT"
        titleShadow.fontSize = 36
        titleShadow.fontColor = shadowColor
        titleShadow.position = CGPoint(x: frame.midX + 3, y: titleLabel.position.y - 3)
        titleShadow.zPosition = 9
        addChild(titleShadow)
        
        let float = SKAction.moveBy(x: 0, y: 8, duration: 2.5)
        let floatDown = SKAction.moveBy(x: 0, y: -8, duration: 2.5)
        let floatSequence = SKAction.sequence([float, floatDown])
        let floatRepeat = SKAction.repeatForever(floatSequence)
        titleLabel.run(floatRepeat)
        titleShadow.run(floatRepeat)
    }
    
    private func createInfoCards() {
        let positions = [
            CGPoint(x: frame.midX, y: frame.midY + 190),
            CGPoint(x: frame.midX, y: frame.midY + 70),
            CGPoint(x: frame.midX, y: frame.midY - 30),
            CGPoint(x: frame.midX, y: frame.midY - 130),
            CGPoint(x: frame.midX, y: frame.midY - 230)
        ]
        
        let cardFunctions = [createGameInfoCard, createControlsCard, createDeveloperCard, createFontCard, createPrivacyCard]
        
        for (index, createCard) in cardFunctions.enumerated() {
            let card = createCard()
            card.position = positions[index]
            addChild(card)
            infoCards.append(card)
        }
    }

    // MARK: - Bilgi Kartları Oluşturma
    private func createGameInfoCard() -> SKNode {
        let cardContainer = SKNode()
        cardContainer.name = "gameCard"
        cardContainer.zPosition = 5
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 100
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: cardWidth + 40, height: cardHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "gameCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 4, y: -cardHeight/2 - 4, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let highlight = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 5, y: cardHeight/2 - 8, width: cardWidth - 10, height: 4))
        highlight.fillColor = glowColor
        highlight.strokeColor = .clear
        highlight.zPosition = 3
        cardContainer.addChild(highlight)
        
        let gameIcon = SKLabelNode(fontNamed: "Jersey15-Regular")
        gameIcon.text = "🐍"
        gameIcon.fontSize = 24
        gameIcon.position = CGPoint(x: -cardWidth/2 + 35, y: 5)
        gameIcon.zPosition = 4
        cardContainer.addChild(gameIcon)
        
        let gameTitle = SKLabelNode(fontNamed: "Jersey15-Regular")
        gameTitle.text = "SNAKE"
        gameTitle.fontSize = 18
        gameTitle.fontColor = primaryColor
        gameTitle.horizontalAlignmentMode = .left
        gameTitle.position = CGPoint(x: -cardWidth/2 + 70, y: 20)
        gameTitle.zPosition = 4
        cardContainer.addChild(gameTitle)
        
        let version = SKLabelNode(fontNamed: "Jersey15-Regular")
        version.text = "'Retro Classic v1.0"
        version.fontSize = 12
        version.fontColor = accentColor
        version.horizontalAlignmentMode = .left
        version.position = CGPoint(x: -cardWidth/2 + 70, y: 5)
        version.zPosition = 4
        cardContainer.addChild(version)
        
        let description = SKLabelNode(fontNamed: "Jersey15-Regular")
        description.text = "The classic snake game with modern PixelArt!"
        description.fontSize = 10
        description.fontColor = accentColor
        description.horizontalAlignmentMode = .left
        description.position = CGPoint(x: -cardWidth/2 + 70, y: -12)
        description.zPosition = 4
        cardContainer.addChild(description)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        let delay = SKAction.wait(forDuration: 0.15)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        cardContainer.run(SKAction.sequence([delay, entrance]))
        
        return cardContainer
    }
    
    private func createControlsCard() -> SKNode {
        let cardContainer = SKNode()
        cardContainer.name = "controlsCard"
        cardContainer.zPosition = 5
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 100
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: cardWidth + 40, height: cardHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "controlsCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 4, y: -cardHeight/2 - 4, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let title = SKLabelNode(fontNamed: "Jersey15-Regular")
        title.text = "🎮 CONTROLS"
        title.fontSize = 16
        title.fontColor = primaryColor
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: cardHeight/2 - 20)
        title.zPosition = 4
        cardContainer.addChild(title)
        
        let controls = [
            "📱 Use the on-screen arrow keys",
            "⏸️ Tap the ⏸ button or double tap game area to pause",
            "🔄 Restart from the game over screen"
        ]
        
        for (index, control) in controls.enumerated() {
            let controlLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
            controlLabel.text = control
            controlLabel.fontSize = 10
            controlLabel.fontColor = accentColor
            controlLabel.horizontalAlignmentMode = .left
            controlLabel.position = CGPoint(x: -cardWidth/2 + 20, y: 10 - CGFloat(index) * 15)
            controlLabel.zPosition = 4
            cardContainer.addChild(controlLabel)
        }
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        let delay = SKAction.wait(forDuration: 0.25)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        cardContainer.run(SKAction.sequence([delay, entrance]))
        
        return cardContainer
    }
    
    private func createDeveloperCard() -> SKNode {
        let cardContainer = SKNode()
        cardContainer.name = "developerCard"
        cardContainer.zPosition = 5
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 85
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: cardWidth + 40, height: cardHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "developerCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 4, y: -cardHeight/2 - 4, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let specialHighlight = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 3, y: cardHeight/2 - 6, width: cardWidth - 6, height: 3))
        specialHighlight.fillColor = SKColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 0.8)
        specialHighlight.strokeColor = .clear
        specialHighlight.zPosition = 3
        cardContainer.addChild(specialHighlight)
        
        let devIcon = SKLabelNode(fontNamed: "Jersey15-Regular")
        devIcon.text = "👨‍💻"
        devIcon.fontSize = 20
        devIcon.position = CGPoint(x: -cardWidth/2 + 35, y: 5)
        devIcon.zPosition = 4
        cardContainer.addChild(devIcon)
        
        let devLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        devLabel.text = "DEVELOPED BY:"
        devLabel.fontSize = 12
        devLabel.fontColor = accentColor
        devLabel.horizontalAlignmentMode = .left
        devLabel.position = CGPoint(x: -cardWidth/2 + 70, y: 18)
        devLabel.zPosition = 4
        cardContainer.addChild(devLabel)
        
        let devName = SKLabelNode(fontNamed: "Jersey15-Regular")
        devName.text = "BERK AKBAY"
        devName.fontSize = 16
        devName.fontColor = primaryColor
        devName.horizontalAlignmentMode = .left
        devName.position = CGPoint(x: -cardWidth/2 + 70, y: 2)
        devName.zPosition = 4
        cardContainer.addChild(devName)
        
        let copyright = SKLabelNode(fontNamed: "Jersey15-Regular")
        copyright.text = "© 2025 - Made with ❤️"
        copyright.fontSize = 10
        copyright.fontColor = accentColor
        copyright.horizontalAlignmentMode = .left
        copyright.position = CGPoint(x: -cardWidth/2 + 70, y: -15)
        copyright.zPosition = 4
        cardContainer.addChild(copyright)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        let delay = SKAction.wait(forDuration: 0.35)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        cardContainer.run(SKAction.sequence([delay, entrance]))
        
        return cardContainer
    }
    
    private func createFontCard() -> SKNode {
        let cardContainer = SKNode()
        cardContainer.name = "fontCard"
        cardContainer.zPosition = 5
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 85
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: cardWidth + 40, height: cardHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "fontCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 4, y: -cardHeight/2 - 4, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let fontTitle = SKLabelNode(fontNamed: "Jersey15-Regular")
        fontTitle.text = "🔤 Font: Jersey 15"
        fontTitle.fontSize = 14
        fontTitle.fontColor = primaryColor
        fontTitle.horizontalAlignmentMode = .left
        fontTitle.position = CGPoint(x: -cardWidth/2 + 20, y: 20)
        fontTitle.zPosition = 4
        cardContainer.addChild(fontTitle)

        let copyrightNotice = SKLabelNode(fontNamed: "Jersey15-Regular")
        copyrightNotice.text = "Copyright 2023 The Soft Type Project Authors"
        copyrightNotice.fontSize = 10
        copyrightNotice.fontColor = accentColor
        copyrightNotice.horizontalAlignmentMode = .left
        copyrightNotice.position = CGPoint(x: -cardWidth/2 + 20, y: 5)
        copyrightNotice.zPosition = 4
        cardContainer.addChild(copyrightNotice)

        let licenseNotice = SKLabelNode(fontNamed: "Jersey15-Regular")
        licenseNotice.text = "Licensed under SIL Open Font License 1.1"
        licenseNotice.fontSize = 10
        licenseNotice.fontColor = accentColor
        licenseNotice.horizontalAlignmentMode = .left
        licenseNotice.position = CGPoint(x: -cardWidth/2 + 20, y: -8)
        licenseNotice.zPosition = 4
        cardContainer.addChild(licenseNotice)
        
        let tapHintLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        tapHintLabel.text = "(Tap for License text)"
        tapHintLabel.fontSize = 10
        tapHintLabel.fontColor = primaryColor.withAlphaComponent(0.7)
        tapHintLabel.horizontalAlignmentMode = .center
        tapHintLabel.position = CGPoint(x: 0, y: -28)
        tapHintLabel.zPosition = 4
        cardContainer.addChild(tapHintLabel)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        let delay = SKAction.wait(forDuration: 0.45)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        cardContainer.run(SKAction.sequence([delay, entrance]))
        
        return cardContainer
    }

    private func createPrivacyCard() -> SKNode {
        let cardContainer = SKNode()
        cardContainer.name = "privacyCard"
        cardContainer.zPosition = 5
        
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 85
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: cardWidth + 40, height: cardHeight + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = "privacyCardHitArea"
        cardContainer.addChild(hitArea)
        
        let shadowCard = SKShapeNode(rect: CGRect(x: -cardWidth/2 + 4, y: -cardHeight/2 - 4, width: cardWidth, height: cardHeight))
        shadowCard.fillColor = shadowColor
        shadowCard.strokeColor = .clear
        shadowCard.zPosition = 1
        cardContainer.addChild(shadowCard)
        
        let card = SKShapeNode(rect: CGRect(x: -cardWidth/2, y: -cardHeight/2, width: cardWidth, height: cardHeight))
        card.fillColor = cardColor
        card.strokeColor = primaryColor
        card.lineWidth = 3
        card.zPosition = 2
        cardContainer.addChild(card)
        
        let privacyIcon = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyIcon.text = "🔒"
        privacyIcon.fontSize = 16
        privacyIcon.position = CGPoint(x: -cardWidth/2 + 30, y: 5)
        privacyIcon.zPosition = 4
        cardContainer.addChild(privacyIcon)
        
        let privacyTitle = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyTitle.text = "PRIVACY POLICY"
        privacyTitle.fontSize = 14
        privacyTitle.fontColor = primaryColor
        privacyTitle.horizontalAlignmentMode = .left
        privacyTitle.position = CGPoint(x: -cardWidth/2 + 60, y: 20)
        privacyTitle.zPosition = 4
        cardContainer.addChild(privacyTitle)

        let privacyDesc = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyDesc.text = "Your privacy is important to us"
        privacyDesc.fontSize = 10
        privacyDesc.fontColor = accentColor
        privacyDesc.horizontalAlignmentMode = .left
        privacyDesc.position = CGPoint(x: -cardWidth/2 + 60, y: 5)
        privacyDesc.zPosition = 4
        cardContainer.addChild(privacyDesc)

        let privacyInfo = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyInfo.text = "All data stays on your device"
        privacyInfo.fontSize = 10
        privacyInfo.fontColor = accentColor
        privacyInfo.horizontalAlignmentMode = .left
        privacyInfo.position = CGPoint(x: -cardWidth/2 + 60, y: -8)
        privacyInfo.zPosition = 4
        cardContainer.addChild(privacyInfo)
        
        let tapHintLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        tapHintLabel.text = "(Tap for Privacy Policy)"
        tapHintLabel.fontSize = 10
        tapHintLabel.fontColor = primaryColor.withAlphaComponent(0.7)
        tapHintLabel.horizontalAlignmentMode = .center
        tapHintLabel.position = CGPoint(x: 0, y: -28)
        tapHintLabel.zPosition = 4
        cardContainer.addChild(tapHintLabel)
        
        cardContainer.alpha = 0.0
        cardContainer.setScale(0.8)
        let delay = SKAction.wait(forDuration: 0.55)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.25)
        let entrance = SKAction.group([fadeIn, scaleUp])
        cardContainer.run(SKAction.sequence([delay, entrance]))
        
        return cardContainer
    }

    // MARK: - Lisans Görüntüleyici
    private func createLicenseOverlay() {
        licenseOverlay = SKNode()
        licenseOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        licenseOverlay.zPosition = 50
        licenseOverlay.alpha = 0.0
        addChild(licenseOverlay)

        let backgroundDim = SKSpriteNode(color: .black, size: frame.size)
        backgroundDim.alpha = 0.7
        licenseOverlay.addChild(backgroundDim)

        let panelWidth = frame.width - 40
        let panelHeight = frame.height - 120
        let panel = SKShapeNode(rect: CGRect(x: -panelWidth/2, y: -panelHeight/2, width: panelWidth, height: panelHeight), cornerRadius: 10)
        panel.fillColor = cardColor
        panel.strokeColor = primaryColor
        panel.lineWidth = 4
        licenseOverlay.addChild(panel)
        
        overlayTitle = SKLabelNode(fontNamed: "Jersey15-Regular")
        overlayTitle.text = "🔤 FONT LICENSE"
        overlayTitle.fontSize = 20
        overlayTitle.fontColor = primaryColor
        overlayTitle.horizontalAlignmentMode = .center
        overlayTitle.position = CGPoint(x: 0, y: panelHeight/2 - 30)
        overlayTitle.zPosition = 2
        panel.addChild(overlayTitle)
        
        let closeButton = SKLabelNode(fontNamed: "Jersey15-Regular")
        closeButton.text = "[ X ]"
        closeButton.fontSize = 24
        closeButton.fontColor = primaryColor
        closeButton.name = "closeLicenseButton"
        closeButton.position = CGPoint(x: panelWidth/2 - 30, y: panelHeight/2 - 30)
        closeButton.zPosition = 2
        panel.addChild(closeButton)
        
        pageLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        pageLabel.fontSize = 14
        pageLabel.fontColor = primaryColor
        pageLabel.horizontalAlignmentMode = .center
        pageLabel.position = CGPoint(x: 0, y: panelHeight/2 - 55)
        pageLabel.zPosition = 2
        panel.addChild(pageLabel)
        
        let textFrameWidth = panelWidth - 40
        let textFrameHeight = panelHeight - 140
        
        textDisplayLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        textDisplayLabel.fontSize = 11
        textDisplayLabel.fontColor = primaryColor
        textDisplayLabel.numberOfLines = 0
        textDisplayLabel.horizontalAlignmentMode = .left
        textDisplayLabel.verticalAlignmentMode = .top
        textDisplayLabel.preferredMaxLayoutWidth = textFrameWidth
        textDisplayLabel.position = CGPoint(x: -textFrameWidth/2, y: textFrameHeight/2 - 60)
        textDisplayLabel.zPosition = 2
        panel.addChild(textDisplayLabel)
        
        createNavigationButtons(panelWidth: panelWidth, panelHeight: panelHeight, panel: panel)
    }

    // MARK: - Privacy Policy Görüntüleyici
    private func createPrivacyOverlay() {
        privacyOverlay = SKNode()
        privacyOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        privacyOverlay.zPosition = 50
        privacyOverlay.alpha = 0.0
        addChild(privacyOverlay)

        let backgroundDim = SKSpriteNode(color: .black, size: frame.size)
        backgroundDim.alpha = 0.7
        privacyOverlay.addChild(backgroundDim)

        let panelWidth = frame.width - 40
        let panelHeight = frame.height - 120
        let panel = SKShapeNode(rect: CGRect(x: -panelWidth/2, y: -panelHeight/2, width: panelWidth, height: panelHeight), cornerRadius: 10)
        panel.fillColor = cardColor
        panel.strokeColor = primaryColor
        panel.lineWidth = 4
        privacyOverlay.addChild(panel)
        
        let privacyTitle = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyTitle.text = "🔒 PRIVACY POLICY"
        privacyTitle.fontSize = 20
        privacyTitle.fontColor = primaryColor
        privacyTitle.horizontalAlignmentMode = .center
        privacyTitle.position = CGPoint(x: 0, y: panelHeight/2 - 30)
        privacyTitle.zPosition = 2
        privacyTitle.name = "privacyOverlayTitle"
        panel.addChild(privacyTitle)
        
        let closePrivacyButton = SKLabelNode(fontNamed: "Jersey15-Regular")
        closePrivacyButton.text = "[ X ]"
        closePrivacyButton.fontSize = 24
        closePrivacyButton.fontColor = primaryColor
        closePrivacyButton.name = "closePrivacyButton"
        closePrivacyButton.position = CGPoint(x: panelWidth/2 - 30, y: panelHeight/2 - 30)
        closePrivacyButton.zPosition = 2
        panel.addChild(closePrivacyButton)
        
        let privacyPageLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyPageLabel.fontSize = 14
        privacyPageLabel.fontColor = primaryColor
        privacyPageLabel.horizontalAlignmentMode = .center
        privacyPageLabel.position = CGPoint(x: 0, y: panelHeight/2 - 55)
        privacyPageLabel.zPosition = 2
        privacyPageLabel.name = "privacyPageLabel"
        panel.addChild(privacyPageLabel)
        
        let textFrameWidth = panelWidth - 40
        let textFrameHeight = panelHeight - 140
        
        let privacyTextLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyTextLabel.fontSize = 11
        privacyTextLabel.fontColor = primaryColor
        privacyTextLabel.numberOfLines = 0
        privacyTextLabel.horizontalAlignmentMode = .left
        privacyTextLabel.verticalAlignmentMode = .top
        privacyTextLabel.preferredMaxLayoutWidth = textFrameWidth
        privacyTextLabel.position = CGPoint(x: -textFrameWidth/2, y: textFrameHeight/2 - 60)
        privacyTextLabel.zPosition = 2
        privacyTextLabel.name = "privacyTextLabel"
        panel.addChild(privacyTextLabel)
        
        createPrivacyNavigationButtons(panelWidth: panelWidth, panelHeight: panelHeight, panel: panel)
    }
    
    private func createNavigationButtons(panelWidth: CGFloat, panelHeight: CGFloat, panel: SKShapeNode) {
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let buttonY = -panelHeight/2 + 30
        
        prevButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        prevButton.fillColor = primaryColor
        prevButton.strokeColor = glowColor
        prevButton.lineWidth = 2
        prevButton.position = CGPoint(x: -120, y: buttonY)
        prevButton.name = "prevPageButton"
        prevButton.zPosition = 2
        panel.addChild(prevButton)
        
        let prevLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        prevLabel.text = "◀ PREV"
        prevLabel.fontSize = 14
        prevLabel.fontColor = backgroundGreen
        prevLabel.verticalAlignmentMode = .center
        prevLabel.horizontalAlignmentMode = .center
        prevLabel.zPosition = 3
        prevButton.addChild(prevLabel)
        
        nextButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        nextButton.fillColor = primaryColor
        nextButton.strokeColor = glowColor
        nextButton.lineWidth = 2
        nextButton.position = CGPoint(x: 120, y: buttonY)
        nextButton.name = "nextPageButton"
        nextButton.zPosition = 2
        panel.addChild(nextButton)
        
        let nextLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        nextLabel.text = "NEXT ▶"
        nextLabel.fontSize = 14
        nextLabel.fontColor = backgroundGreen
        nextLabel.verticalAlignmentMode = .center
        nextLabel.horizontalAlignmentMode = .center
        nextLabel.zPosition = 3
        nextButton.addChild(nextLabel)
    }

    private func createPrivacyNavigationButtons(panelWidth: CGFloat, panelHeight: CGFloat, panel: SKShapeNode) {
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let buttonY = -panelHeight/2 + 30
        
        let privacyPrevButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        privacyPrevButton.fillColor = primaryColor
        privacyPrevButton.strokeColor = glowColor
        privacyPrevButton.lineWidth = 2
        privacyPrevButton.position = CGPoint(x: -120, y: buttonY)
        privacyPrevButton.name = "prevPrivacyPageButton"
        privacyPrevButton.zPosition = 2
        panel.addChild(privacyPrevButton)
        
        let privacyPrevLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyPrevLabel.text = "◀ PREV"
        privacyPrevLabel.fontSize = 14
        privacyPrevLabel.fontColor = backgroundGreen
        privacyPrevLabel.verticalAlignmentMode = .center
        privacyPrevLabel.horizontalAlignmentMode = .center
        privacyPrevLabel.zPosition = 3
        privacyPrevButton.addChild(privacyPrevLabel)
        
        let privacyNextButton = SKShapeNode(rect: CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight))
        privacyNextButton.fillColor = primaryColor
        privacyNextButton.strokeColor = glowColor
        privacyNextButton.lineWidth = 2
        privacyNextButton.position = CGPoint(x: 120, y: buttonY)
        privacyNextButton.name = "nextPrivacyPageButton"
        privacyNextButton.zPosition = 2
        panel.addChild(privacyNextButton)
        
        let privacyNextLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        privacyNextLabel.text = "NEXT ▶"
        privacyNextLabel.fontSize = 14
        privacyNextLabel.fontColor = backgroundGreen
        privacyNextLabel.verticalAlignmentMode = .center
        privacyNextLabel.horizontalAlignmentMode = .center
        privacyNextLabel.zPosition = 3
        privacyNextButton.addChild(privacyNextLabel)
    }
    
    private func createLicensePages() {
        let fullLicenseText = """
        Copyright 2023 The Soft Type Project Authors
        (https://github.com/scfried/soft-type-jersey)

        This Font Software is licensed under the SIL Open Font License, Version 1.1.

        This license is copied below, and is also available with a FAQ at: https://openfontlicense.org
        
        ═══════════════════════════════════════════════════════════════════════════════════════
        SIL OPEN FONT LICENSE
        Version 1.1 - 26 February 2007
        ═══════════════════════════════════════════════════════════════════════════════════════
        
        PREAMBLE

        The goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects, to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework in which fonts may be shared and improved in partnership with others.

        The OFL allows the licensed fonts to be used, studied, modified and redistributed freely as long as they are not sold by themselves.
        """
        
        let page2Text = """
        The fonts, including any derivative works, can be bundled, embedded, redistributed and/or sold with any software provided that any reserved names are not used by derivative works.

        The fonts and derivatives, however, cannot be released under any other type of license.

        The requirement for fonts to remain under this license does not apply to any document created using the fonts or their derivatives.

        DEFINITIONS

        "Font Software" refers to the set of files released by the Copyright Holder(s) under this license and clearly marked as such.

        This may include source files, build scripts and documentation.
        """
        
        let page3Text = """
        "Reserved Font Name" refers to any names specified as such after the copyright statement(s).

        "Original Version" refers to the collection of Font Software components as distributed by the Copyright Holder(s).

        "Modified Version" refers to any derivative made by adding to, deleting, or substituting -- in part or in whole -- any of the components of the Original Version, by changing formats or by porting the Font Software to a new environment.

        "Author" refers to any designer, engineer, programmer, technical writer or other person who contributed to the Font Software.

        PERMISSION & CONDITIONS

        Permission is hereby granted, free of charge, to any person obtaining a copy of the Font Software, to use, study, copy, merge, embed, modify, redistribute, and sell modified and unmodified copies of the Font Software, subject to the following conditions:
        """
        
        let page4Text = """
        1) Neither the Font Software nor any of its individual components, in Original or Modified Versions, may be sold by itself.

        2) Original or Modified Versions of the Font Software may be bundled, redistributed and/or sold with any software, provided that each copy contains the above copyright notice and this license.

        These can be included either as stand-alone text files, human-readable headers or in the appropriate machine-readable metadata fields within text or binary files as long as those fields can be easily viewed by the user.

        3) No Modified Version of the Font Software may use the Reserved Font Name(s) unless explicit written permission is granted by the corresponding Copyright Holder.

        This restriction only applies to the primary font name as presented to the users.
        """
        
        let page5Text = """
        4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font Software shall not be used to promote, endorse or advertise any Modified Version, except to acknowledge the contribution(s) of the Copyright Holder(s) and the Author(s) or with their explicit written permission.

        5) The Font Software, modified or unmodified, in part or in whole, must be distributed entirely under this license, and must not be distributed under any other license.

        The requirement for fonts to remain under this license does not apply to any document created using the Font Software.

        TERMINATION

        This license becomes null and void if any of the above conditions are not met.
        """
        
        let page6Text = """
        DISCLAIMER

        THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT.

        IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE.

        Thank you for reading!
        """
        
        currentPages = [fullLicenseText, page2Text, page3Text, page4Text, page5Text, page6Text]
        totalPages = currentPages.count
        currentPage = 0
        
        updatePageDisplay()
    }

    private func createPrivacyPages() {
        let page1Text = """
        PRIVACY POLICY - SNAKE: RETRO CLASSIC

        Effective Date: 20/06/2025
        Developer: Berk Akbay
        Contact: sberkakbay@gmail.com

        INTRODUCTION

        This Privacy Policy explains how Snake: Retro Classic handles information when you use our mobile game.

        Your privacy is important to us. This Game is designed to be a simple, offline Snake game that collects minimal information and stores all data locally on your device.
        """
        
        let page2Text = """
        INFORMATION WE COLLECT

        Information You Provide Directly:
        • Player Name (Optional): When you achieve a high score, you may choose to enter your name (up to 15 characters) to save with your score. This is completely optional.

        Information Automatically Collected:
        • Game Scores: Your game scores and dates
        • Game Statistics: Number of games played on different difficulty levels  
        • Game Settings: Your preferences for sound, haptic feedback, and game speed
        • High Score Records: Your personal best scores

        Information We Do NOT Collect:
        • Personal information (real name, email, contact info)
        • Device camera, microphone, contacts, photos, location
        • Device identifiers or advertising IDs
        • Behavior tracking or usage patterns
        • Biometric data
        """
        
        let page3Text = """
        HOW WE USE INFORMATION

        The limited information collected is used solely to:
        • Enhance Gaming Experience: Save your progress, high scores, and game statistics
        • Maintain Game Settings: Remember your preferences
        • Local Leaderboards: Display your personal best scores

        All data processing occurs entirely on your device. We do not transmit, upload, or share any of your information with external servers or third parties.

        INFORMATION SHARING AND DISCLOSURE

        We do not share, sell, rent, or disclose any of your information to third parties. All data remains stored locally on your device and is never transmitted outside of your device.

        The Game does not connect to the internet and does not communicate with any external servers.
        """
        
        let page4Text = """
        DATA STORAGE AND SECURITY

        • Local Storage Only: All game data is stored exclusively on your device using iOS's standard UserDefaults system
        • No Cloud Backup: Game data is not automatically backed up to iCloud
        • Device Security: Data security depends on your device's built-in iOS security features
        • Data Isolation: Game data cannot be accessed by other apps

        CHILDREN'S PRIVACY (COPPA COMPLIANCE)

        • No Data Collection from Children: We do not knowingly collect personal information from children under 13
        • Parental Control: Parents can delete all game data by deleting and reinstalling the app
        • Safe Gaming: The game contains no social features, chat functions, or external links
        • No Advertising: The game contains no advertisements or in-app purchases
        """
        
        let page5Text = """
        YOUR PRIVACY RIGHTS

        Since all data is stored locally on your device, you have complete control:
        • Access: View your scores and settings within the game
        • Modify: Change your player name and game settings at any time
        • Delete: Clear all your score data from the 'Clear' button on the 'Leaderboard' screen, or delete and reinstall the app
        • Portability: Game data remains on your device

        HAPTIC FEEDBACK (VIBRATION)

        The Game uses your device's haptic feedback capabilities to enhance the gaming experience with vibration effects. This feature:
        • Can be turned on or off in the game settings
        • Does not collect any data about your device or usage
        • Only provides tactile feedback during gameplay
        """
        
        let page6Text = """
        CHANGES TO THIS PRIVACY POLICY

        We may update this Privacy Policy from time to time. When we make changes, we will:
        • Update the "Effective Date" at the top of this policy
        • Notify users through the App Store update description
        • Post the updated policy within the app

        THIRD-PARTY SERVICES

        This Game does not integrate with any third-party services, including:
        • No analytics services
        • No advertising networks
        • No crash reporting services
        • No social media integration
        • No payment processors
        • No cloud storage services

        DATA RETENTION

        Since all data is stored locally on your device:
        • Data is retained until you delete it manually or delete the app
        • No automatic data expiration occurs
        • We do not have access to delete your data remotely
        """
        
        let page7Text = """
        INTERNATIONAL DATA TRANSFERS

        Since no data leaves your device, there are no international data transfers to worry about.

        CONTACT US

        If you have any questions, concerns, or requests regarding this Privacy Policy or your privacy rights, please contact us:

        Email: xberkakbay@outlook.com

        We will respond to your inquiry within a reasonable timeframe.

        TECHNICAL INFORMATION

        For transparency, here are the technical details of our data practices:
        • Data Storage: iOS UserDefaults (local device storage only)
        • Data Transmission: None (completely offline app)
        • Encryption: Protected by iOS device-level encryption
        • Network Access: The app does not access the internet

        Last updated: 20/06/2025
        """
        
        currentPages = [page1Text, page2Text, page3Text, page4Text, page5Text, page6Text, page7Text]
        totalPages = currentPages.count
        currentPage = 0
        
        updatePrivacyPageDisplay()
    }
    
    private func updatePageDisplay() {
        textDisplayLabel.text = currentPages[currentPage]
        
        pageLabel.text = "Page \(currentPage + 1) of \(totalPages)"
        
        prevButton.alpha = currentPage > 0 ? 1.0 : 0.5
        nextButton.alpha = currentPage < totalPages - 1 ? 1.0 : 0.5
        
        let fadeOut = SKAction.fadeAlpha(to: 0.7, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        textDisplayLabel.run(sequence)
    }

    private func updatePrivacyPageDisplay() {
        if let privacyTextLabel = privacyOverlay.childNode(withName: "//privacyTextLabel") as? SKLabelNode {
            privacyTextLabel.text = currentPages[currentPage]
        }
        
        if let privacyPageLabel = privacyOverlay.childNode(withName: "//privacyPageLabel") as? SKLabelNode {
            privacyPageLabel.text = "Page \(currentPage + 1) of \(totalPages)"
        }
        
        if let prevBtn = privacyOverlay.childNode(withName: "//prevPrivacyPageButton") as? SKShapeNode {
            prevBtn.alpha = currentPage > 0 ? 1.0 : 0.5
        }
        
        if let nextBtn = privacyOverlay.childNode(withName: "//nextPrivacyPageButton") as? SKShapeNode {
            nextBtn.alpha = currentPage < totalPages - 1 ? 1.0 : 0.5
        }
        
        if let privacyTextLabel = privacyOverlay.childNode(withName: "//privacyTextLabel") as? SKLabelNode {
            let fadeOut = SKAction.fadeAlpha(to: 0.7, duration: 0.1)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            privacyTextLabel.run(sequence)
        }
    }
    
    private func goToPreviousPage() {
        if currentPage > 0 {
            currentPage -= 1
            if isLicenseOverlayVisible {
                updatePageDisplay()
            } else if isPrivacyOverlayVisible {
                updatePrivacyPageDisplay()
            }
            HapticManager.shared.playSimpleHaptic(intensity: 0.6, sharpness: 0.5)
        }
    }
    
    private func goToNextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
            if isLicenseOverlayVisible {
                updatePageDisplay()
            } else if isPrivacyOverlayVisible {
                updatePrivacyPageDisplay()
            }
            HapticManager.shared.playSimpleHaptic(intensity: 0.6, sharpness: 0.5)
        }
    }
    
    private func showLicenseOverlay() {
        if isLicenseOverlayVisible || isPrivacyOverlayVisible { return }
        isLicenseOverlayVisible = true
        
        createLicensePages()
        
        licenseOverlay.setScale(0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        entrance.timingMode = .easeOut
        
        licenseOverlay.run(entrance)
    }

    private func hideLicenseOverlay() {
        if !isLicenseOverlayVisible { return }
        isLicenseOverlayVisible = false
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let exit = SKAction.group([fadeOut, scaleDown])
        exit.timingMode = .easeIn
        
        licenseOverlay.run(exit) {
            self.currentPage = 0
        }
    }

    private func showPrivacyOverlay() {
        if isPrivacyOverlayVisible || isLicenseOverlayVisible { return }
        isPrivacyOverlayVisible = true
        
        createPrivacyPages()
        
        privacyOverlay.setScale(0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        entrance.timingMode = .easeOut
        
        privacyOverlay.run(entrance)
    }

    private func hidePrivacyOverlay() {
        if !isPrivacyOverlayVisible { return }
        isPrivacyOverlayVisible = false
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let exit = SKAction.group([fadeOut, scaleDown])
        exit.timingMode = .easeIn
        
        privacyOverlay.run(exit) {
            self.currentPage = 0
        }
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
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth + 60, height: buttonHeight + 40))
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
        label.zPosition = 2
        backButton.addChild(label)
        
        addChild(backButton)
    }
    
    private func animateCardPress(_ card: SKNode) {
        let scaleDown = SKAction.scale(to: 0.92, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.1)
        let normal = SKAction.scale(to: 1.0, duration: 0.1)
        
        card.run(SKAction.sequence([scaleDown, scaleUp, normal]))
        HapticManager.shared.playSimpleHaptic(intensity: 0.7, sharpness: 0.4)
    }
    
    private func animateButtonPress(_ button: SKNode) {
        let instantScale = SKAction.scale(to: 0.85, duration: 0.04)
        let bounceBack = SKAction.scale(to: 1.15, duration: 0.1)
        let settle = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([instantScale, bounceBack, settle]))
        
        let glowNode = SKSpriteNode(color: glowColor, size: CGSize(width: 120, height: 60))
        glowNode.alpha = 0.0
        glowNode.position = button.position
        glowNode.zPosition = button.zPosition - 1
        button.parent?.addChild(glowNode)
        
        let glowIn = SKAction.fadeAlpha(to: 0.8, duration: 0.05)
        let glowOut = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([glowIn, glowOut, remove])
        glowNode.run(glowSequence)
        
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 1.0)
    }
    
    // MARK: - Dokunma Yönetimi
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if isLicenseOverlayVisible {
            let overlayTouchLocation = touch.location(in: licenseOverlay)
            let touchedNodeInOverlay = licenseOverlay.atPoint(overlayTouchLocation)
            
            if let nodeName = touchedNodeInOverlay.name ?? touchedNodeInOverlay.parent?.name {
                switch nodeName {
                case "closeLicenseButton":
                    hideLicenseOverlay()
                case "prevPageButton":
                    if currentPage > 0 {
                        animateButtonPress(prevButton)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.goToPreviousPage()
                        }
                    }
                case "nextPageButton":
                    if currentPage < totalPages - 1 {
                        animateButtonPress(nextButton)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.goToNextPage()
                        }
                    }
                default:
                    break
                }
            }
            return
        }
        
        if isPrivacyOverlayVisible {
            let overlayTouchLocation = touch.location(in: privacyOverlay)
            let touchedNodeInOverlay = privacyOverlay.atPoint(overlayTouchLocation)
            
            if let nodeName = touchedNodeInOverlay.name ?? touchedNodeInOverlay.parent?.name {
                switch nodeName {
                case "closePrivacyButton":
                    hidePrivacyOverlay()
                case "prevPrivacyPageButton":
                    if currentPage > 0 {
                        if let prevBtn = privacyOverlay.childNode(withName: "//prevPrivacyPageButton") as? SKShapeNode {
                            animateButtonPress(prevBtn)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.goToPreviousPage()
                        }
                    }
                case "nextPrivacyPageButton":
                    if currentPage < totalPages - 1 {
                        if let nextBtn = privacyOverlay.childNode(withName: "//nextPrivacyPageButton") as? SKShapeNode {
                            animateButtonPress(nextBtn)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.goToNextPage()
                        }
                    }
                default:
                    break
                }
            }
            return
        }
        
        let touchedNode = atPoint(touchLocation)
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name ?? touchedNode.parent?.parent?.name {
            if nodeName == "backButton" || nodeName == "backButtonHitArea" {
                animateButtonPress(backButton)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.goBack()
                }
                return
            }
            
            if nodeName.contains("Card") || nodeName.contains("CardHitArea") {
                let cardName = nodeName.replacingOccurrences(of: "HitArea", with: "")
                if let cardNode = self.childNode(withName: cardName) {
                    animateCardPress(cardNode)
                    if cardName == "fontCard" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            self.showLicenseOverlay()
                        }
                    } else if cardName == "privacyCard" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            self.showPrivacyOverlay()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Dokunma Olayları (Kullanılmıyor)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    private func goBack() {
        let menuScene = MenuScene()
        menuScene.size = frame.size
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.push(with: .right, duration: 0.2)
        view?.presentScene(menuScene, transition: transition)
    }
}
