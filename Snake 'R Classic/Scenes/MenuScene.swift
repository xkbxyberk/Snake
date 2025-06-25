import SpriteKit
import GameplayKit

class MenuScene: SKScene {
    
    // MARK: - Arayüz Elemanları
    private var titleContainer: SKNode!
    private var titleLetters: [SKLabelNode] = []
    private var subtitleLabel: SKLabelNode!
    private var playButton: SKNode!
    private var settingsButton: SKNode!
    private var leaderboardButton: SKNode!
    private var aboutButton: SKNode!
    
    // MARK: - Pixel Art Animasyon Elemanları
    private var floatingFoods: [SKNode] = []
    private var decorativeSnakes: [SKNode] = []
    private var glowNodes: [SKSpriteNode] = []
    
    // MARK: - Gelişmiş Arka Plan Yılan Sistemi
    private var animatedSnake: [SKNode] = []
    private var snakeFood: SKNode?
    private var snakeDirection: Direction = .right
    private var snakeTimer: Timer?
    private let snakeSegmentSize: CGFloat = 15
    private let snakeSpeed: TimeInterval = 0.4
    private var targetDirection: Direction?
    
    // MARK: - Pixel Art Ayarları
    private let pixelSize: CGFloat = 3 // Pixel art için temel birim
    
    // MARK: - Renk Paleti
    private let primaryColor = SKColor(red: 2/255, green: 19/255, blue: 0/255, alpha: 1.0)
    private let backgroundGreen = SKColor(red: 170/255, green: 225/255, blue: 1/255, alpha: 1.0)
    private let glowColor = SKColor(red: 50/255, green: 200/255, blue: 50/255, alpha: 0.8)
    private let shadowColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.3)
    
    override func didMove(to view: SKView) {
        setupMenu()
        startAnimations()
        startPixelArtSnake()
    }
    
    // MARK: - Kurulum
    private func setupMenu() {
        self.backgroundColor = backgroundGreen
        
        createAnimatedBackground()
        createWavyAnimatedTitle()
        createStylizedMenuButtons()
        createPixelArtFloatingElements()
        createPixelArtSnakeDecorations()
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
    
    // MARK: - Gelişmiş Animasyonlu Başlık (Kıvrımlı SNAKE)
    private func createWavyAnimatedTitle() {
        titleContainer = SKNode()
        titleContainer.position = CGPoint(x: frame.midX, y: frame.midY + 220)
        titleContainer.zPosition = 10
        addChild(titleContainer)
        
        // SNAKE harflerini ayrı ayrı oluştur
        let letters = Array("SNAKE")
        let letterSpacing: CGFloat = 65
        let totalWidth = CGFloat(letters.count - 1) * letterSpacing
        let startX = -totalWidth / 2
        
        for (index, letter) in letters.enumerated() {
            // Ana harf
            let letterNode = SKLabelNode(fontNamed: "Jersey15-Regular")
            letterNode.text = String(letter)
            letterNode.fontSize = 80
            letterNode.fontColor = primaryColor
            letterNode.position = CGPoint(x: startX + CGFloat(index) * letterSpacing, y: 0)
            letterNode.zPosition = 3
            titleContainer.addChild(letterNode)
            titleLetters.append(letterNode)
            
            // Gölge efekti
            let shadowNode = SKLabelNode(fontNamed: "Jersey15-Regular")
            shadowNode.text = String(letter)
            shadowNode.fontSize = 80
            shadowNode.fontColor = shadowColor
            shadowNode.position = CGPoint(x: startX + CGFloat(index) * letterSpacing + 3, y: -3)
            shadowNode.zPosition = 2
            titleContainer.addChild(shadowNode)
            
            // Parlama efekti ekle
            let glowNode = SKSpriteNode(color: glowColor, size: CGSize(width: 60, height: 80))
            glowNode.alpha = 0.0
            glowNode.position = letterNode.position
            glowNode.zPosition = 1
            titleContainer.addChild(glowNode)
            
            // Her harf için dalga animasyonu (farklı gecikmelerle)
            let waveDelay = Double(index) * 0.2
            let waveUp = SKAction.moveBy(x: 0, y: 15, duration: 1.5)
            let waveDown = SKAction.moveBy(x: 0, y: -15, duration: 1.5)
            let waveSequence = SKAction.sequence([waveUp, waveDown])
            let waveRepeat = SKAction.repeatForever(waveSequence)
            
            let delayedWave = SKAction.sequence([
                SKAction.wait(forDuration: waveDelay),
                waveRepeat
            ])
            
            letterNode.run(delayedWave)
            shadowNode.run(delayedWave)
            
            // Rastgele parlama efekti
            let randomGlowDelay = Double.random(in: 2.0...6.0)
            let glowIn = SKAction.fadeAlpha(to: 0.4, duration: 0.3)
            let glowOut = SKAction.fadeOut(withDuration: 0.8)
            let glowSequence = SKAction.sequence([glowIn, glowOut])
            let glowWait = SKAction.wait(forDuration: randomGlowDelay)
            let glowCycle = SKAction.sequence([glowWait, glowSequence])
            let glowRepeat = SKAction.repeatForever(glowCycle)
            
            glowNode.run(glowRepeat)
            
            // Harflere hafif döndürme efekti
            let rotateLeft = SKAction.rotate(byAngle: -0.1, duration: 2.0)
            let rotateRight = SKAction.rotate(byAngle: 0.1, duration: 2.0)
            let rotateSequence = SKAction.sequence([rotateLeft, rotateRight])
            let rotateRepeat = SKAction.repeatForever(rotateSequence)
            
            let rotateDelay = SKAction.wait(forDuration: waveDelay * 1.5)
            letterNode.run(SKAction.sequence([rotateDelay, rotateRepeat]))
            shadowNode.run(SKAction.sequence([rotateDelay, rotateRepeat]))
        }
        
        // Alt başlık
        subtitleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        subtitleLabel.text = "'RETRO CLASSIC"
        subtitleLabel.fontSize = 18
        subtitleLabel.fontColor = primaryColor
        subtitleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 180)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
        
        let subtitleGlow = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let subtitleDim = SKAction.fadeAlpha(to: 0.6, duration: 1.5)
        let subtitleSequence = SKAction.sequence([subtitleGlow, subtitleDim])
        let subtitleRepeat = SKAction.repeatForever(subtitleSequence)
        subtitleLabel.run(subtitleRepeat)
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
    
    // MARK: - Gelişmiş Buton Oluşturma
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
            
            // Ana buton için ekstra parlama efekti
            let mainButtonGlow = SKSpriteNode(color: glowColor, size: CGSize(width: size.width + 20, height: size.height + 20))
            mainButtonGlow.alpha = 0.0
            mainButtonGlow.position = CGPoint.zero
            mainButtonGlow.zPosition = 0
            buttonContainer.addChild(mainButtonGlow)
            
            let glowPulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 2.0),
                SKAction.fadeAlpha(to: 0.0, duration: 2.0)
            ])
            let glowPulseRepeat = SKAction.repeatForever(glowPulse)
            mainButtonGlow.run(glowPulseRepeat)
        } else {
            let fadeUp = SKAction.fadeAlpha(to: 1.0, duration: 2.0)
            let fadeDown = SKAction.fadeAlpha(to: 0.85, duration: 2.0)
            let fadeSequence = SKAction.sequence([fadeUp, fadeDown])
            let fadeRepeat = SKAction.repeatForever(fadeSequence)
            buttonContainer.run(fadeRepeat)
        }
        
        return buttonContainer
    }
    
    // MARK: - Pixel Art Yüzen Yemler (Arttırılmış Sayı)
    private func createPixelArtFloatingElements() {
        for i in 0..<8 { // Daha fazla yem
            let food = createPixelArtFlowerFood()
            
            let randomX = CGFloat.random(in: 80...(frame.maxX - 80))
            let randomY = CGFloat.random(in: 150...(frame.maxY - 150))
            food.position = CGPoint(x: randomX, y: randomY)
            food.zPosition = 4
            food.name = "floatingFood"
            food.alpha = 0.8
            addChild(food)
            floatingFoods.append(food)
            
            // Yumuşak ve yavaş hareketler (değişmedi)
            let moveX = CGFloat.random(in: -25...25)
            let moveY = CGFloat.random(in: -25...25)
            let duration = Double.random(in: 6...9)
            
            let moveAction = SKAction.moveBy(x: moveX, y: moveY, duration: duration)
            let returnAction = SKAction.moveBy(x: -moveX, y: -moveY, duration: duration)
            moveAction.timingMode = .easeInEaseOut
            returnAction.timingMode = .easeInEaseOut
            
            let sequence = SKAction.sequence([moveAction, returnAction])
            let repeatAction = SKAction.repeatForever(sequence)
            
            let delay = SKAction.wait(forDuration: Double(i) * 1.0)
            let delayedAction = SKAction.sequence([delay, repeatAction])
            food.run(delayedAction)
            
            // Daha yavaş ve hafif parlama efekti
            let scaleUp = SKAction.scale(to: 1.1, duration: 2.5)
            let scaleDown = SKAction.scale(to: 1.0, duration: 2.5)
            scaleUp.timingMode = .easeInEaseOut
            scaleDown.timingMode = .easeInEaseOut
            
            let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
            let pulseRepeat = SKAction.repeatForever(pulseSequence)
            
            let pulseDelay = SKAction.wait(forDuration: Double(i) * 0.5)
            food.run(SKAction.sequence([pulseDelay, pulseRepeat]))
            
            // Hafif fade in/out efekti
            let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 4.0)
            let fadeIn = SKAction.fadeAlpha(to: 0.9, duration: 4.0)
            fadeOut.timingMode = .easeInEaseOut
            fadeIn.timingMode = .easeInEaseOut
            
            let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
            let fadeRepeat = SKAction.repeatForever(fadeSequence)
            
            let fadeDelay = SKAction.wait(forDuration: Double(i) * 1.2)
            food.run(SKAction.sequence([fadeDelay, fadeRepeat]))
        }
    }
    
    // MARK: - Pixel Art Çiçek Yemi Oluşturma (Retro Gap Sistemiyle)
    private func createPixelArtFlowerFood() -> SKNode {
        let container = SKNode()
        let basePixelSize = self.pixelSize // MenuScene'deki pixelSize (3.0)
        
        // Çiçek desenini tanımlayan piksel pozisyonları (merkez boş)
        let flowerPixels = [
            // Üst yaprak
            CGPoint(x: 0, y: 2),
            // Orta sıra - yatay çizgi
            CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
            // Merkez sıra - ortası boş (en geniş kısım)
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            // Alt orta sıra
            CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
            // Alt yaprak
            CGPoint(x: 0, y: -2)
        ]
        
        // MenuScene için de retro gap uygula
        let retroPixelSize = basePixelSize - 0.5
        
        // Her piksel için bir mini sprite oluştur
        for pixelPos in flowerPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            container.addChild(pixel)
        }
        
        return container
    }
    
    // MARK: - Pixel Art Dekoratif Yılanlar (Arttırılmış ve Uzatılmış)
    private func createPixelArtSnakeDecorations() {
        // Daha fazla ve daha uzun yılanlar
        createSmoothPixelArtSnake(startPosition: CGPoint(x: 70, y: frame.maxY - 80), direction: .right, segments: 7)
        createSmoothPixelArtSnake(startPosition: CGPoint(x: frame.maxX - 70, y: frame.maxY - 120), direction: .left, segments: 6)
        createSmoothPixelArtSnake(startPosition: CGPoint(x: frame.maxX - 90, y: 180), direction: .left, segments: 5)
        createSmoothPixelArtSnake(startPosition: CGPoint(x: 50, y: frame.midY + 100), direction: .down, segments: 6)
        createSmoothPixelArtSnake(startPosition: CGPoint(x: frame.maxX - 50, y: frame.midY), direction: .up, segments: 5)
    }
    
    // MARK: - Yumuşak Pixel Art Dekoratif Yılan Oluşturma
    private func createSmoothPixelArtSnake(startPosition: CGPoint, direction: Direction, segments: Int) {
        let spacing: CGFloat = 18
        
        for i in 0..<segments {
            let segment = createPixelArtSnakeSegment()
            
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
            segment.zPosition = 2
            segment.name = "decorativeSnake"
            segment.alpha = 0.7 // Başlangıçta daha şeffaf
            addChild(segment)
            decorativeSnakes.append(segment)
            
            // Çok daha yumuşak ve yavaş animasyonlar
            let amplitude: CGFloat = 8 // Daha az hareket
            let baseDuration: Double = 4.0 // Daha yavaş
            let frequency: Double = baseDuration + Double(i) * 0.8
            
            let moveUp = SKAction.moveBy(x: 0, y: amplitude, duration: frequency)
            let moveDown = SKAction.moveBy(x: 0, y: -amplitude, duration: frequency)
            moveUp.timingMode = .easeInEaseOut // Yumuşak geçişler
            moveDown.timingMode = .easeInEaseOut
            
            let waveSequence = SKAction.sequence([moveUp, moveDown])
            let waveRepeat = SKAction.repeatForever(waveSequence)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.6)
            let delayedWave = SKAction.sequence([delay, waveRepeat])
            segment.run(delayedWave)
            
            // Daha yavaş ve hafif soluk verme efekti
            let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 3.0)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 3.0)
            fadeOut.timingMode = .easeInEaseOut
            fadeIn.timingMode = .easeInEaseOut
            
            let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
            let fadeRepeat = SKAction.repeatForever(fadeSequence)
            segment.run(fadeRepeat)
            
            // Her segmente çok hafif döndürme efekti
            let rotateLeft = SKAction.rotate(byAngle: -0.05, duration: frequency * 1.5)
            let rotateRight = SKAction.rotate(byAngle: 0.05, duration: frequency * 1.5)
            rotateLeft.timingMode = .easeInEaseOut
            rotateRight.timingMode = .easeInEaseOut
            
            let rotateSequence = SKAction.sequence([rotateLeft, rotateRight])
            let rotateRepeat = SKAction.repeatForever(rotateSequence)
            
            let rotateDelay = SKAction.wait(forDuration: Double(i) * 0.8)
            segment.run(SKAction.sequence([rotateDelay, rotateRepeat]))
        }
    }
    
    // MARK: - Pixel Art Yılan Segmenti Oluşturma (Retro Gap Sistemiyle)
    private func createPixelArtSnakeSegment() -> SKNode {
        let container = SKNode()
        let basePixelSize = self.pixelSize // MenuScene'deki pixelSize (3.0)
        
        // 5x5 tamamen dolu piksel deseni (25 piksel)
        let fullBlockPixels = [
            // 1. sıra (en üst)
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2),
            // 2. sıra
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),
            // 3. sıra (merkez)
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            // 4. sıra
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
            // 5. sıra (en alt)
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2)
        ]
        
        // MenuScene için de retro gap uygula
        let retroPixelSize = basePixelSize - 0.5
        
        // Her piksel için bir mini sprite oluştur (retro gap ile)
        for pixelPos in fullBlockPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            container.addChild(pixel)
        }
        
        return container
    }
    
    // MARK: - Ana Menü Pixel Art Yılan Sistemi
    
    // MARK: - Pixel Art Yılan Animasyonu Başlatma
    private func startPixelArtSnake() {
        createPixelArtBackgroundSnake()
        createPixelArtSnakeFood()
        
        snakeTimer = Timer.scheduledTimer(withTimeInterval: snakeSpeed, repeats: true) { _ in
            self.updatePixelArtBackgroundSnake()
        }
    }
    
    // MARK: - Pixel Art Arka Plan Yılanı Oluşturma (Daha Uzun Başlangıç)
    private func createPixelArtBackgroundSnake() {
        let startX: CGFloat = 70
        let startY: CGFloat = 180
        let initialLength = 8 // Daha uzun başlangıç
        
        for i in 0..<initialLength {
            let segment = createPixelArtSnakeSegment()
            segment.position = CGPoint(x: startX - CGFloat(i) * snakeSegmentSize, y: startY)
            segment.zPosition = -5
            segment.name = "backgroundSnake"
            segment.alpha = 0.8
            addChild(segment)
            animatedSnake.append(segment)
        }
        
        snakeDirection = .right
    }
    
    // MARK: - Pixel Art Yılan Yemi Oluşturma
    private func createPixelArtSnakeFood() {
        snakeFood = createPixelArtFlowerFood()
        spawnPixelArtSnakeFood()
        snakeFood!.zPosition = -5
        snakeFood!.name = "backgroundSnakeFood"
        snakeFood!.alpha = 0.9
        addChild(snakeFood!)
        
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        snakeFood!.run(pulseRepeat)
    }
    
    // MARK: - Güvenli Pixel Art Yem Konumlandırma (Sadece Ekran İçi)
    private func spawnPixelArtSnakeFood() {
        guard let food = snakeFood else { return }
        
        // Yem için güvenli alan hesapla
        let safeMargin: CGFloat = snakeSegmentSize * 3
        let minX = safeMargin
        let maxX = frame.maxX - safeMargin
        let minY = safeMargin
        let maxY = frame.maxY - safeMargin
        
        var validPosition = false
        var newPosition = CGPoint.zero
        var attempts = 0
        let maxAttempts = 30
        
        while !validPosition && attempts < maxAttempts {
            attempts += 1
            
            // Grid hesaplaması - kesinlikle ekran içinde
            let gridMinX = Int(minX / snakeSegmentSize) + 1
            let gridMaxX = Int(maxX / snakeSegmentSize) - 1
            let gridMinY = Int(minY / snakeSegmentSize) + 1
            let gridMaxY = Int(maxY / snakeSegmentSize) - 1
            
            let gridX = Int.random(in: gridMinX...gridMaxX)
            let gridY = Int.random(in: gridMinY...gridMaxY)
            
            newPosition = CGPoint(
                x: CGFloat(gridX) * snakeSegmentSize + snakeSegmentSize/2,
                y: CGFloat(gridY) * snakeSegmentSize + snakeSegmentSize/2
            )
            
            // Pozisyon kontrolü - kesinlikle ekran içinde mi?
            if newPosition.x < minX || newPosition.x > maxX ||
               newPosition.y < minY || newPosition.y > maxY {
                continue
            }
            
            validPosition = true
            
            // Sadece yılan segmentlerinden uzak olsun
            for segment in animatedSnake {
                let distance = sqrt(pow(segment.position.x - newPosition.x, 2) + pow(segment.position.y - newPosition.y, 2))
                if distance < snakeSegmentSize * 2 {
                    validPosition = false
                    break
                }
            }
        }
        
        // Eğer hala geçerli pozisyon bulunamazsa, ekranın merkezine yakın güvenli bir yer seç
        if !validPosition {
            newPosition = CGPoint(x: frame.midX, y: frame.midY - 50)
        }
        
        // Son kontrol - kesinlikle ekran içinde olmalı
        newPosition.x = max(safeMargin, min(newPosition.x, frame.maxX - safeMargin))
        newPosition.y = max(safeMargin, min(newPosition.y, frame.maxY - safeMargin))
        
        food.position = newPosition
    }
    
    // MARK: - Pixel Art Arka Plan Yılanı Güncelleme (Güvenli Hareket)
    private func updatePixelArtBackgroundSnake() {
        guard let head = animatedSnake.first, let food = snakeFood else { return }
        
        // Önce ekran sınırlarını kontrol et - bu en önemli
        checkScreenBounds()
        
        // Sonra yem takibi
        calculateTargetDirection(headPosition: head.position, foodPosition: food.position)
        
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
        
        // Yeni pozisyon ekran içinde mi? Değilse zorla ekran içine al
        let margin: CGFloat = snakeSegmentSize
        newHeadPosition.x = max(margin, min(newHeadPosition.x, frame.maxX - margin))
        newHeadPosition.y = max(margin, min(newHeadPosition.y, frame.maxY - margin))
        
        let distanceToFood = sqrt(pow(newHeadPosition.x - food.position.x, 2) + pow(newHeadPosition.y - food.position.y, 2))
        let shouldEatFood = distanceToFood < snakeSegmentSize * 1.2
        
        for i in stride(from: animatedSnake.count - 1, through: 1, by: -1) {
            animatedSnake[i].position = animatedSnake[i - 1].position
        }
        
        head.position = newHeadPosition
        
        if shouldEatFood {
            growPixelArtBackgroundSnake()
            spawnPixelArtSnakeFood()
            createPixelArtEatEffect(at: food.position)
        }
    }
    
    // MARK: - Gelişmiş Yön Hesaplama (Ekran Sınırları Öncelikli)
    private func calculateTargetDirection(headPosition: CGPoint, foodPosition: CGPoint) {
        // Önce ekran sınırına yakın mıyız kontrol et
        let urgentMargin: CGFloat = snakeSegmentSize * 3
        
        // Acil durum - ekran kenarına çok yakınız
        if headPosition.x <= urgentMargin {
            targetDirection = .right
            return
        }
        if headPosition.x >= frame.maxX - urgentMargin {
            targetDirection = .left
            return
        }
        if headPosition.y <= urgentMargin {
            targetDirection = .up
            return
        }
        if headPosition.y >= frame.maxY - urgentMargin {
            targetDirection = .down
            return
        }
        
        // Güvenli alandaysak normal yem takibi yap
        // %90 ihtimalle yem peşinde git, %10 ihtimalle random
        let chaseFood = Int.random(in: 1...100) <= 90
        
        if chaseFood {
            // Yem peşinde git
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
        } else {
            // Random hareket ama ekran sınırlarına doğru gitme
            var validDirections: [Direction] = []
            
            if headPosition.x > urgentMargin * 2 {
                validDirections.append(.left)
            }
            if headPosition.x < frame.maxX - urgentMargin * 2 {
                validDirections.append(.right)
            }
            if headPosition.y > urgentMargin * 2 {
                validDirections.append(.down)
            }
            if headPosition.y < frame.maxY - urgentMargin * 2 {
                validDirections.append(.up)
            }
            
            if !validDirections.isEmpty {
                targetDirection = validDirections.randomElement()
            }
        }
    }
    
    // MARK: - Basit Ama Etkili Ekran Sınır Kontrolü
    private func checkScreenBounds() {
        guard let head = animatedSnake.first else { return }
        
        let margin: CGFloat = snakeSegmentSize * 2 // Yılan boyutunun 2 katı güvenli mesafe
        
        // Sol kenar - ani yön değişimi
        if head.position.x <= margin {
            targetDirection = .right
            return
        }
        
        // Sağ kenar - ani yön değişimi
        if head.position.x >= frame.maxX - margin {
            targetDirection = .left
            return
        }
        
        // Alt kenar - ani yön değişimi
        if head.position.y <= margin {
            targetDirection = .up
            return
        }
        
        // Üst kenar - ani yön değişimi
        if head.position.y >= frame.maxY - margin {
            targetDirection = .down
            return
        }
    }
    
    // MARK: - Pixel Art Yılanı Büyütme (Daha Uzun Maksimum)
    private func growPixelArtBackgroundSnake() {
        guard let tail = animatedSnake.last else { return }
        
        let newSegment = createPixelArtSnakeSegment()
        newSegment.position = tail.position
        newSegment.zPosition = -5
        newSegment.name = "backgroundSnake"
        newSegment.alpha = 0.8
        addChild(newSegment)
        animatedSnake.append(newSegment)
        
        // Maksimum uzunluğu 20'ye çıkardık (önceden 15'ti)
        if animatedSnake.count > 20 {
            let segmentToRemove = animatedSnake.removeFirst()
            segmentToRemove.removeFromParent()
        }
    }
    
    // MARK: - Pixel Art Yem Yeme Efekti
    private func createPixelArtEatEffect(at position: CGPoint) {
        for _ in 0..<6 {
            let particle = createPixelArtSnakeSegment()
            particle.position = position
            particle.zPosition = -4
            particle.alpha = 0.8
            particle.setScale(0.5)
            addChild(particle)
            
            let randomX = CGFloat.random(in: -30...30)
            let randomY = CGFloat.random(in: -30...30)
            let spread = SKAction.moveBy(x: randomX, y: randomY, duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi...CGFloat.pi), duration: 0.5)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([SKAction.group([spread, fadeOut, rotate]), remove])
            particle.run(sequence)
        }
        
        // Parıldama efekti
        let sparkle = SKLabelNode(fontNamed: "Jersey15-Regular")
        sparkle.text = "✨"
        sparkle.fontSize = 20
        sparkle.position = position
        sparkle.zPosition = -3
        sparkle.alpha = 0.0
        addChild(sparkle)
        
        let sparkleIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let sparkleOut = SKAction.fadeOut(withDuration: 0.4)
        let sparkleScale = SKAction.scale(to: 1.5, duration: 0.2)
        let sparkleRemove = SKAction.removeFromParent()
        
        let sparkleSequence = SKAction.sequence([sparkleIn, SKAction.group([sparkleOut, sparkleScale]), sparkleRemove])
        sparkle.run(sparkleSequence)
    }
    
    // MARK: - Genel Animasyonlar (Gelişmiş - Daha Sakin)
    private func startAnimations() {
        // Daha seyrek parçacık oluşturma
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 3.0), // Daha uzun bekleme
            SKAction.run { self.createFloatingParticle() }
        ])))
        
        // Daha seyrek büyülü patlamalar
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 8.0), // Daha uzun bekleme
            SKAction.run { self.createMagicalBurst() }
        ])))
    }
    
    // MARK: - Yüzen Parçacık Oluşturma (Gelişmiş)
    private func createFloatingParticle() {
        let particle = SKSpriteNode(color: glowColor, size: CGSize(width: 3, height: 3)) // Daha küçük
        particle.position = CGPoint(x: CGFloat.random(in: 0...frame.maxX), y: -10)
        particle.zPosition = 1
        particle.alpha = 0.6 // Daha şeffaf
        addChild(particle)
        
        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -40...40), y: frame.height + 20, duration: 15.0) // Daha yavaş
        let fadeOut = SKAction.fadeOut(withDuration: 15.0)
        let remove = SKAction.removeFromParent()
        
        moveUp.timingMode = .easeInEaseOut // Yumuşak hareket
        
        let group = SKAction.group([moveUp, fadeOut])
        let sequence = SKAction.sequence([group, remove])
        particle.run(sequence)
    }
    
    // MARK: - Büyülü Patlama Efekti (Gelişmiş)
    private func createMagicalBurst() {
        let burstPosition = CGPoint(
            x: CGFloat.random(in: 100...(frame.maxX - 100)),
            y: CGFloat.random(in: 250...(frame.maxY - 250))
        )
        
        for i in 0..<6 { // Daha az parçacık
            let burst = SKLabelNode(fontNamed: "Jersey15-Regular")
            burst.text = ["✨", "⭐", "💫"].randomElement()! // Daha az çeşit
            burst.fontSize = 14 // Daha küçük
            burst.position = burstPosition
            burst.zPosition = 6
            burst.alpha = 0.0
            addChild(burst)
            
            let angle = CGFloat(i) * CGFloat.pi * 2 / 6
            let distance: CGFloat = 45 // Daha az yayılma
            let targetX = burstPosition.x + cos(angle) * distance
            let targetY = burstPosition.y + sin(angle) * distance
            
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.3)
            let spread = SKAction.move(to: CGPoint(x: targetX, y: targetY), duration: 1.8) // Daha yavaş
            let fadeOut = SKAction.fadeOut(withDuration: 1.2)
            let remove = SKAction.removeFromParent()
            
            fadeIn.timingMode = .easeOut
            spread.timingMode = .easeInEaseOut
            fadeOut.timingMode = .easeIn
            
            let sequence = SKAction.sequence([fadeIn, SKAction.group([spread, fadeOut]), remove])
            burst.run(sequence)
        }
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
