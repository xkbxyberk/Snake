import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    // MARK: - Arayüz Elemanları
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var playButton: SKNode!
    private var settingsButton: SKNode!
    private var leaderboardButton: SKNode!
    private var aboutButton: SKNode!
    
    // MARK: - Animasyon Elemanları
    private var floatingFoods: [SKSpriteNode] = []
    private var decorativeSnakes: [SKSpriteNode] = []
    private var glowNodes: [SKSpriteNode] = []
    
    // MARK: - Arka Plan Yılan Sistemi
    private var animatedSnake: [SKSpriteNode] = []
    private var snakeFood: SKSpriteNode?
    private var snakeDirection: Direction = .right
    private var snakeTimer: Timer?
    private let snakeSegmentSize: CGFloat = 12
    private let snakeSpeed: TimeInterval = 0.35
    private var targetDirection: Direction?
    
    // MARK: - Renk Paleti
    private let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    private let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    private let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    private let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    
    override func didMove(to view: SKView) {
        setupMenu()
        startAnimations()
        startAnimatedSnake()
    }
    
    // MARK: - Kurulum
    private func setupMenu() {
        self.backgroundColor = backgroundGreen
        
        createAnimatedBackground()
        createEnhancedTitle()
        createStylizedMenuButtons()
        createFloatingElements()
        createSnakeDecorations()
    }
    
    // MARK: - Arka Plan Kurulumu
    private func createAnimatedBackground() {
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
    
    // MARK: - Başlık Kurulumu
    private func createEnhancedTitle() {
        titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "SNAKE"
        titleLabel.fontSize = 80
        titleLabel.fontColor = primaryColor
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 220)
        titleLabel.zPosition = 10
        addChild(titleLabel)
        
        let titleShadow = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleShadow.text = "SNAKE"
        titleShadow.fontSize = 80
        titleShadow.fontColor = shadowColor
        titleShadow.position = CGPoint(x: frame.midX + 3, y: frame.midY + 217)
        titleShadow.zPosition = 9
        addChild(titleShadow)
        
        subtitleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        subtitleLabel.text = "RETRO EDITION"
        subtitleLabel.fontSize = 18
        subtitleLabel.fontColor = primaryColor
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 180)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
        
        let titleFloat = SKAction.moveBy(x: 0, y: 8, duration: 2.5)
        let titleFloatDown = SKAction.moveBy(x: 0, y: -8, duration: 2.5)
        let titleSequence = SKAction.sequence([titleFloat, titleFloatDown])
        let titleRepeat = SKAction.repeatForever(titleSequence)
        titleLabel.run(titleRepeat)
        titleShadow.run(titleRepeat)
        
        let glowUp = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let glowDown = SKAction.fadeAlpha(to: 0.6, duration: 1.5)
        let glowSequence = SKAction.sequence([glowUp, glowDown])
        let glowRepeat = SKAction.repeatForever(glowSequence)
        subtitleLabel.run(glowRepeat)
    }
    
    // MARK: - Butonların Kurulumu
    private func createStylizedMenuButtons() {
        let buttonWidth: CGFloat = 220
        let buttonHeight: CGFloat = 55
        let buttonSpacing: CGFloat = 75
        let startY = frame.midY + 60
        
        playButton = createEnhancedButton(
            text: "🎮 PLAY GAME",
            position: CGPoint(x: frame.midX, y: startY),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "playButton",
            isMainButton: true
        )
        addChild(playButton)
        
        settingsButton = createEnhancedButton(
            text: "⚙️ SETTINGS",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "settingsButton",
            isMainButton: false
        )
        addChild(settingsButton)
        
        leaderboardButton = createEnhancedButton(
            text: "🏆 LEADERBOARD",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing * 2),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "leaderboardButton",
            isMainButton: false
        )
        addChild(leaderboardButton)
        
        aboutButton = createEnhancedButton(
            text: "ℹ️ ABOUT",
            position: CGPoint(x: frame.midX, y: startY - buttonSpacing * 3),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            name: "aboutButton",
            isMainButton: false
        )
        addChild(aboutButton)
    }
    
    // MARK: - Buton Oluşturma Metodu
    private func createEnhancedButton(text: String, position: CGPoint, size: CGSize, name: String, isMainButton: Bool) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.position = position
        buttonContainer.name = name
        
        let hitArea = SKSpriteNode(color: .clear, size: CGSize(width: size.width + 40, height: size.height + 20))
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 10
        hitArea.name = name + "HitArea"
        buttonContainer.addChild(hitArea)
        
        let shadowButton = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: -size.height/2 - 4, width: size.width, height: size.height))
        shadowButton.fillColor = shadowColor
        shadowButton.strokeColor = .clear
        shadowButton.zPosition = 1
        buttonContainer.addChild(shadowButton)
        
        let button = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        
        if isMainButton {
            button.fillColor = primaryColor
            button.strokeColor = glowColor
            button.lineWidth = 4
        } else {
            button.fillColor = SKColor(red: 220/255, green: 240/255, blue: 220/255, alpha: 0.9)
            button.strokeColor = primaryColor
            button.lineWidth = 3
        }
        
        button.zPosition = 2
        buttonContainer.addChild(button)
        
        if isMainButton {
            let highlight = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: size.height/2 - 8, width: size.width - 8, height: 4))
            highlight.fillColor = glowColor
            highlight.strokeColor = .clear
            highlight.zPosition = 3
            buttonContainer.addChild(highlight)
        } else {
            let highlight = SKShapeNode(rect: CGRect(x: -size.width/2 + 4, y: size.height/2 - 6, width: size.width - 8, height: 3))
            highlight.fillColor = SKColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
            highlight.strokeColor = .clear
            highlight.zPosition = 3
            buttonContainer.addChild(highlight)
        }
        
        let label = SKLabelNode(fontNamed: "Jersey15-Regular")
        label.text = text
        label.fontSize = isMainButton ? 18 : 16
        
        if isMainButton {
            label.fontColor = backgroundGreen
        } else {
            label.fontColor = primaryColor
        }
        
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 4
        buttonContainer.addChild(label)
        
        if isMainButton {
            let scaleUp = SKAction.scale(to: 1.05, duration: 1.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            let scaleRepeat = SKAction.repeatForever(scaleSequence)
            buttonContainer.run(scaleRepeat)
        } else {
            let fadeUp = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
            let fadeDown = SKAction.fadeAlpha(to: 0.85, duration: 2.0)
            let fadeSequence = SKAction.sequence([fadeUp, fadeDown])
            let fadeRepeat = SKAction.repeatForever(fadeSequence)
            buttonContainer.run(fadeRepeat)
        }
        
        return buttonContainer
    }
    
    // MARK: - Yüzen Dekor Elementleri
    private func createFloatingElements() {
        for i in 0..<8 {
            let food = SKSpriteNode(color: primaryColor, size: CGSize(width: 6, height: 6))
            let randomX = CGFloat.random(in: 50...(frame.maxX - 50))
            let randomY = CGFloat.random(in: 100...(frame.maxY - 100))
            food.position = CGPoint(x: randomX, y: randomY)
            food.zPosition = 5
            food.name = "floatingFood"
            addChild(food)
            floatingFoods.append(food)
            
            let moveX = CGFloat.random(in: -30...30)
            let moveY = CGFloat.random(in: -30...30)
            let duration = Double.random(in: 3...6)
            
            let moveAction = SKAction.moveBy(x: moveX, y: moveY, duration: duration)
            let returnAction = SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            let sequence = SKAction.sequence([moveAction, returnAction])
            let repeatAction = SKAction.repeatForever(sequence)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.5)
            let delayedAction = SKAction.sequence([delay, repeatAction])
            food.run(delayedAction)
            
            let scaleUp = SKAction.scale(to: 1.3, duration: 1.0)
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
            let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
            let pulseRepeat = SKAction.repeatForever(pulseSequence)
            food.run(pulseRepeat)
        }
    }
    
    // MARK: - Dekoratif Yılanlar
    private func createSnakeDecorations() {
        createAnimatedSnake(startPosition: CGPoint(x: 60, y: frame.maxY - 60), direction: .right, segments: 6)
        createAnimatedSnake(startPosition: CGPoint(x: frame.maxX - 60, y: 120), direction: .left, segments: 5)
        createAnimatedSnake(startPosition: CGPoint(x: 40, y: frame.midY), direction: .down, segments: 4)
        createAnimatedSnake(startPosition: CGPoint(x: frame.maxX - 40, y: frame.midY + 50), direction: .up, segments: 4)
    }
    
    // MARK: - Dekoratif Yılan Oluşturma
    private func createAnimatedSnake(startPosition: CGPoint, direction: Direction, segments: Int) {
        let segmentSize: CGFloat = 10
        let spacing: CGFloat = 12
        
        for i in 0..<segments {
            let segment = SKSpriteNode(color: primaryColor, size: CGSize(width: segmentSize, height: segmentSize))
            
            var offsetX: CGFloat = 0
            var offsetY: CGFloat = 0
            
            switch direction {
            case .right:
                offsetX = -CGFloat(i) * spacing
            case .left:
                offsetX = CGFloat(i) * spacing
            case .up:
                offsetY = -CGFloat(i) * spacing
            case .down:
                offsetY = CGFloat(i) * spacing
            }
            
            segment.position = CGPoint(x: startPosition.x + offsetX, y: startPosition.y + offsetY)
            segment.zPosition = 3
            segment.name = "decorativeSnake"
            addChild(segment)
            decorativeSnakes.append(segment)
            
            let amplitude: CGFloat = 15
            let frequency: Double = 2.0 + Double(i) * 0.3
            
            let moveUp = SKAction.moveBy(x: 0, y: amplitude, duration: frequency)
            let moveDown = SKAction.moveBy(x: 0, y: -amplitude, duration: frequency)
            let waveSequence = SKAction.sequence([moveUp, moveDown])
            let waveRepeat = SKAction.repeatForever(waveSequence)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.2)
            let delayedWave = SKAction.sequence([delay, waveRepeat])
            segment.run(delayedWave)
            
            let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 1.5)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
            let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
            let fadeRepeat = SKAction.repeatForever(fadeSequence)
            segment.run(fadeRepeat)
        }
    }
    
    // MARK: - Ana Menü Yılan Sistemi
    
    // MARK: - Yılan Animasyonu Başlatma
    private func startAnimatedSnake() {
        createBackgroundSnake()
        createSnakeFood()
        
        snakeTimer = Timer.scheduledTimer(withTimeInterval: snakeSpeed, repeats: true) { _ in
            self.updateBackgroundSnake()
        }
    }
    
    // MARK: - Arka Plan Yılanı Oluşturma
    private func createBackgroundSnake() {
        let startX: CGFloat = 50
        let startY: CGFloat = 150
        let initialLength = 5
        
        for i in 0..<initialLength {
            let segment = SKSpriteNode(color: primaryColor, size: CGSize(width: snakeSegmentSize - 1, height: snakeSegmentSize - 1))
            segment.position = CGPoint(x: startX - CGFloat(i) * snakeSegmentSize, y: startY)
            segment.zPosition = -5
            segment.name = "backgroundSnake"
            segment.alpha = 0.8
            addChild(segment)
            animatedSnake.append(segment)
            
            segment.texture = nil
        }
        
        snakeDirection = .right
    }
    
    // MARK: - Yılan Yemi Oluşturma
    private func createSnakeFood() {
        snakeFood = SKSpriteNode(color: primaryColor, size: CGSize(width: snakeSegmentSize - 1, height: snakeSegmentSize - 1))
        spawnSnakeFood()
        snakeFood!.zPosition = -5
        snakeFood!.name = "backgroundSnakeFood"
        snakeFood!.alpha = 0.9
        snakeFood!.texture = nil
        addChild(snakeFood!)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.6)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.6)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        snakeFood!.run(pulseRepeat)
    }
    
    // MARK: - Yem Konumlandırma
    private func spawnSnakeFood() {
        guard let food = snakeFood else { return }
        
        var validPosition = false
        var newPosition = CGPoint.zero
        
        while !validPosition {
            let gridX = Int.random(in: 4...(Int(frame.maxX / snakeSegmentSize) - 4))
            let gridY = Int.random(in: 10...(Int((frame.maxY - 200) / snakeSegmentSize)))
            
            newPosition = CGPoint(
                x: CGFloat(gridX) * snakeSegmentSize + snakeSegmentSize/2,
                y: CGFloat(gridY) * snakeSegmentSize + snakeSegmentSize/2
            )
            
            validPosition = true
            for segment in animatedSnake {
                let distance = sqrt(pow(segment.position.x - newPosition.x, 2) + pow(segment.position.y - newPosition.y, 2))
                if distance < snakeSegmentSize * 1.5 {
                    validPosition = false
                    break
                }
            }
            
            let buttonPositions = [
                playButton.position,
                settingsButton.position,
                leaderboardButton.position,
                aboutButton.position
            ]
            
            for buttonPos in buttonPositions {
                let distance = sqrt(pow(buttonPos.x - newPosition.x, 2) + pow(buttonPos.y - newPosition.y, 2))
                if distance < 140 {
                    validPosition = false
                    break
                }
            }
        }
        
        food.position = newPosition
    }
    
    // MARK: - Arka Plan Yılanı Güncelleme
    private func updateBackgroundSnake() {
        guard let head = animatedSnake.first, let food = snakeFood else { return }
        
        calculateTargetDirection(headPosition: head.position, foodPosition: food.position)
        
        checkScreenBounds()
        
        if let target = targetDirection {
            let oppositeDirection: Direction
            switch snakeDirection {
            case .up: oppositeDirection = .down
            case .down: oppositeDirection = .up
            case .left: oppositeDirection = .right
            case .right: oppositeDirection = .left
            }
            
            if target != oppositeDirection {
                snakeDirection = target
            }
            targetDirection = nil
        }
        
        var newHeadPosition = head.position
        
        switch snakeDirection {
        case .up:
            newHeadPosition.y += snakeSegmentSize
        case .down:
            newHeadPosition.y -= snakeSegmentSize
        case .left:
            newHeadPosition.x -= snakeSegmentSize
        case .right:
            newHeadPosition.x += snakeSegmentSize
        }
        
        let distanceToFood = sqrt(pow(newHeadPosition.x - food.position.x, 2) + pow(newHeadPosition.y - food.position.y, 2))
        let shouldEatFood = distanceToFood < snakeSegmentSize * 0.8
        
        for i in stride(from: animatedSnake.count - 1, through: 1, by: -1) {
            animatedSnake[i].position = animatedSnake[i - 1].position
        }
        
        head.position = newHeadPosition
        
        if shouldEatFood {
            growBackgroundSnake()
            spawnSnakeFood()
            
            createEatEffect(at: food.position)
        }
    }
    
    // MARK: - Yön Hesaplama
    private func calculateTargetDirection(headPosition: CGPoint, foodPosition: CGPoint) {
        let deltaX = foodPosition.x - headPosition.x
        let deltaY = foodPosition.y - headPosition.y
        
        if abs(deltaX) > abs(deltaY) {
            if deltaX > 0 {
                targetDirection = .right
            } else {
                targetDirection = .left
            }
        } else {
            if deltaY > 0 {
                targetDirection = .up
            } else {
                targetDirection = .down
            }
        }
        
        if Int.random(in: 1...100) <= 25 {
            let randomDirections: [Direction] = [.up, .down, .left, .right]
            targetDirection = randomDirections.randomElement()
        }
    }
    
    // MARK: - Ekran Sınır Kontrolü
    private func checkScreenBounds() {
        guard let head = animatedSnake.first else { return }
        
        let margin: CGFloat = 40
        
        if head.position.x <= margin {
            targetDirection = .right
        } else if head.position.x >= frame.maxX - margin {
            targetDirection = .left
        } else if head.position.y <= margin {
            targetDirection = .up
        } else if head.position.y >= frame.maxY - margin {
            targetDirection = .down
        }
    }
    
    // MARK: - Yılanı Büyütme
    private func growBackgroundSnake() {
        guard let tail = animatedSnake.last else { return }
        
        let newSegment = SKSpriteNode(color: primaryColor, size: CGSize(width: snakeSegmentSize - 1, height: snakeSegmentSize - 1))
        newSegment.position = tail.position
        newSegment.zPosition = -5
        newSegment.name = "backgroundSnake"
        newSegment.alpha = 0.8
        newSegment.texture = nil
        addChild(newSegment)
        animatedSnake.append(newSegment)
        
        if animatedSnake.count > 20 {
            let segmentToRemove = animatedSnake.removeFirst()
            segmentToRemove.removeFromParent()
        }
    }
    
    // MARK: - Yem Yeme Efekti
    private func createEatEffect(at position: CGPoint) {
        for _ in 0..<4 {
            let particle = SKSpriteNode(color: primaryColor, size: CGSize(width: 3, height: 3))
            particle.position = position
            particle.zPosition = -4
            particle.alpha = 0.8
            addChild(particle)
            
            let randomX = CGFloat.random(in: -20...20)
            let randomY = CGFloat.random(in: -20...20)
            let spread = SKAction.moveBy(x: randomX, y: randomY, duration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([SKAction.group([spread, fadeOut]), remove])
            particle.run(sequence)
        }
    }
    
    // MARK: - Genel Animasyonlar
    private func startAnimations() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { self.createFloatingParticle() }
        ])))
    }
    
    // MARK: - Yüzen Parçacık Oluşturma
    private func createFloatingParticle() {
        let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 4, height: 4))
        particle.position = CGPoint(x: CGFloat.random(in: 0...frame.maxX), y: -10)
        particle.zPosition = 1
        addChild(particle)
        
        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -50...50), y: frame.height + 20, duration: 8.0)
        let fadeOut = SKAction.fadeOut(withDuration: 8.0)
        let remove = SKAction.removeFromParent()
        
        let group = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([group, remove])
        particle.run(sequence)
    }
    
    // MARK: - Buton Etkileşim Animasyonu
    private func animateButtonPress(_ button: SKNode) {
        let instantScale = SKAction.scale(to: 0.88, duration: 0.03)
        let bounceBack = SKAction.scale(to: 1.12, duration: 0.08)
        let settle = SKAction.scale(to: 1.0, duration: 0.12)
        let buttonSequence = SKAction.sequence([instantScale, bounceBack, settle])
        button.run(buttonSequence)
        
        createInstantGlowEffect(at: button.position, size: CGSize(width: 280, height: 85))
        
        triggerInstantHaptic()
    }
    
    // MARK: - Anlık Işıma Efekti
    private func createInstantGlowEffect(at position: CGPoint, size: CGSize) {
        let glowNode = SKSpriteNode(color: glowColor, size: size)
        glowNode.alpha = 0.0
        glowNode.position = position
        glowNode.zPosition = 15
        addChild(glowNode)
        
        let instantGlow = SKAction.fadeAlpha(to: 0.8, duration: 0.02)
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let glowSequence = SKAction.sequence([instantGlow, fadeOut, remove])
        glowNode.run(glowSequence)
    }
    
    // MARK: - Haptic Geri Bildirim
    private func triggerInstantHaptic() {
        HapticManager.shared.playSimpleHaptic(intensity: 1.0, sharpness: 1.0)
    }
    
    // MARK: - Dokunma Yönetimi
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        var buttonNode: SKNode?
        var actionToPerform: (() -> Void)?
        
        if let nodeName = touchedNode.name ?? touchedNode.parent?.name ?? touchedNode.parent?.parent?.name {
            switch nodeName {
            case "playButton", "playButtonHitArea":
                buttonNode = playButton
                actionToPerform = { self.startGame() }
            case "settingsButton", "settingsButtonHitArea":
                buttonNode = settingsButton
                actionToPerform = { self.showSettings() }
            case "leaderboardButton", "leaderboardButtonHitArea":
                buttonNode = leaderboardButton
                actionToPerform = { self.showLeaderboard() }
            case "aboutButton", "aboutButtonHitArea":
                buttonNode = aboutButton
                actionToPerform = { self.showAbout() }
            default:
                break
            }
        }
        
        if let button = buttonNode, let action = actionToPerform {
            animateButtonPress(button)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
            }
        }
    }
    
    // MARK: - Sahne Geçişleri
    private func startGame() {
        snakeTimer?.invalidate()
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.15)
        let exitGroup = SKAction.group([fadeOut, scaleDown])
        
        run(exitGroup) {
            let gameScene = GameScene()
            gameScene.size = self.frame.size
            gameScene.scaleMode = .aspectFill
            
            let transition = SKTransition.flipHorizontal(withDuration: 0.25)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    private func showSettings() {
        snakeTimer?.invalidate()
        
        let settingsScene = SettingsScene()
        settingsScene.size = frame.size
        settingsScene.scaleMode = .aspectFill
        
        let transition = SKTransition.moveIn(with: .left, duration: 0.2)
        view?.presentScene(settingsScene, transition: transition)
    }
    
    private func showLeaderboard() {
        snakeTimer?.invalidate()
        
        let leaderboardScene = LeaderboardScene()
        leaderboardScene.size = frame.size
        leaderboardScene.scaleMode = .aspectFill
        
        let transition = SKTransition.moveIn(with: .up, duration: 0.2)
        view?.presentScene(leaderboardScene, transition: transition)
    }
    
    private func showAbout() {
        snakeTimer?.invalidate()
        
        let aboutScene = AboutScene()
        aboutScene.size = frame.size
        aboutScene.scaleMode = .aspectFill
        
        let transition = SKTransition.moveIn(with: .right, duration: 0.2)
        view?.presentScene(aboutScene, transition: transition)
    }
    
    // MARK: - Temizleme
    deinit {
        snakeTimer?.invalidate()
    }
}
