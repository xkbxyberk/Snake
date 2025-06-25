import SpriteKit
import GameplayKit
import UIKit

// MARK: - Oyun Sahnesi Kurulumu - Ergonomik Cihaz Desteği
extension GameScene {
    
    // MARK: - Cihaz Tipi Tespiti
    private var deviceType: DeviceType {
        let idiom = UIDevice.current.userInterfaceIdiom
        let screenSize = UIScreen.main.bounds
        let screenHeight = max(screenSize.width, screenSize.height)
        let screenWidth = min(screenSize.width, screenSize.height)
        let screenDiagonal = sqrt(pow(screenHeight, 2) + pow(screenWidth, 2))
        
        switch idiom {
        case .phone:
            if screenDiagonal <= 568 {
                return .iPhoneSmall
            } else if screenDiagonal <= 667 {
                return .iPhoneMedium
            } else if screenDiagonal <= 736 {
                return .iPhoneLarge
            } else if screenDiagonal <= 812 {
                return .iPhoneX
            } else if screenDiagonal <= 844 {
                return .iPhone12
            } else if screenDiagonal <= 852 {
                return .iPhone14Pro
            } else if screenDiagonal <= 896 {
                return .iPhoneMax
            } else {
                return .iPhoneProMax
            }
        case .pad:
            if screenHeight >= 1366 {
                return .iPadLarge
            } else if screenHeight >= 1194 {
                return .iPadMedium
            } else {
                return .iPadSmall
            }
        default:
            return .iPhoneMedium
        }
    }
    
    private enum DeviceType {
        // iPhone kategorileri
        case iPhoneSmall      // 4" - iPhone SE 1st
        case iPhoneMedium     // 4.7" - iPhone 6/7/8, SE 2nd/3rd
        case iPhoneLarge      // 5.5" - iPhone 6+/7+/8+
        case iPhoneX          // 5.4"-5.8" - iPhone X/XS/11 Pro, 12/13 mini
        case iPhone12         // 6.1" - iPhone 12/13/14/15
        case iPhone14Pro      // 6.1" - iPhone 14 Pro/15 Pro (Dynamic Island)
        case iPhoneMax        // 6.1"-6.5" - iPhone XR/11, XS Max/11 Pro Max
        case iPhoneProMax     // 6.7"+ - iPhone 12/13/14/15 Pro Max
        
        // iPad kategorileri
        case iPadSmall        // iPad Mini
        case iPadMedium       // 11" iPad
        case iPadLarge        // 12.9" iPad Pro
        
        // Helper properties
        var isIPhone: Bool {
            switch self {
            case .iPhoneSmall, .iPhoneMedium, .iPhoneLarge, .iPhoneX, .iPhone12, .iPhone14Pro, .iPhoneMax, .iPhoneProMax:
                return true
            case .iPadSmall, .iPadMedium, .iPadLarge:
                return false
            }
        }
        
        var isIPad: Bool {
            return !isIPhone
        }
    }
    
    // MARK: - Cihaz Yapılandırması
    private var deviceConfig: DeviceConfig {
        switch deviceType {
        // MARK: iPhone Konfigürasyonları
        case .iPhoneSmall:
            return DeviceConfig(
                gameWidth: 20, gameHeight: 28,
                sideMargin: 15, topMargin: 40, bottomMargin: 25,
                headerBarHeight: 6, controlAreaHeight: 160,
                buttonHorizontalSize: CGSize(width: 70, height: 50),
                buttonVerticalSize: CGSize(width: 55, height: 70),
                maxCellSize: 12, buttonSpacingH: 80, buttonSpacingV: 20
            )
        case .iPhoneMedium:
            return DeviceConfig(
                gameWidth: 22, gameHeight: 32,
                sideMargin: 20, topMargin: 50, bottomMargin: 30,
                headerBarHeight: 7, controlAreaHeight: 180,
                buttonHorizontalSize: CGSize(width: 80, height: 60),
                buttonVerticalSize: CGSize(width: 65, height: 80),
                maxCellSize: 13, buttonSpacingH: 90, buttonSpacingV: 25
            )
        case .iPhoneLarge:
            return DeviceConfig(
                gameWidth: 24, gameHeight: 34,
                sideMargin: 25, topMargin: 55, bottomMargin: 35,
                headerBarHeight: 8, controlAreaHeight: 190,
                buttonHorizontalSize: CGSize(width: 85, height: 65),
                buttonVerticalSize: CGSize(width: 70, height: 85),
                maxCellSize: 14, buttonSpacingH: 95, buttonSpacingV: 30
            )
        case .iPhoneX:
            return DeviceConfig(
                gameWidth: 23, gameHeight: 36,
                sideMargin: 20, topMargin: 60, bottomMargin: 40,
                headerBarHeight: 8, controlAreaHeight: 195,
                buttonHorizontalSize: CGSize(width: 85, height: 65),
                buttonVerticalSize: CGSize(width: 70, height: 85),
                maxCellSize: 14, buttonSpacingH: 95, buttonSpacingV: 30
            )
        case .iPhone12:
            return DeviceConfig(
                gameWidth: 25, gameHeight: 38,
                sideMargin: 25, topMargin: 65, bottomMargin: 45,
                headerBarHeight: 8, controlAreaHeight: 200,
                buttonHorizontalSize: CGSize(width: 90, height: 70),
                buttonVerticalSize: CGSize(width: 75, height: 90),
                maxCellSize: 15, buttonSpacingH: 100, buttonSpacingV: 35
            )
        case .iPhone14Pro:
            return DeviceConfig(
                gameWidth: 25, gameHeight: 38,
                sideMargin: 25, topMargin: 70, bottomMargin: 45,
                headerBarHeight: 8, controlAreaHeight: 200,
                buttonHorizontalSize: CGSize(width: 90, height: 70),
                buttonVerticalSize: CGSize(width: 75, height: 90),
                maxCellSize: 15, buttonSpacingH: 100, buttonSpacingV: 35
            )
        case .iPhoneMax:
            return DeviceConfig(
                gameWidth: 26, gameHeight: 40,
                sideMargin: 30, topMargin: 70, bottomMargin: 50,
                headerBarHeight: 9, controlAreaHeight: 210,
                buttonHorizontalSize: CGSize(width: 95, height: 75),
                buttonVerticalSize: CGSize(width: 80, height: 95),
                maxCellSize: 16, buttonSpacingH: 105, buttonSpacingV: 40
            )
        case .iPhoneProMax:
            return DeviceConfig(
                gameWidth: 27, gameHeight: 42,
                sideMargin: 35, topMargin: 75, bottomMargin: 55,
                headerBarHeight: 9, controlAreaHeight: 215,
                buttonHorizontalSize: CGSize(width: 100, height: 80),
                buttonVerticalSize: CGSize(width: 85, height: 100),
                maxCellSize: 17, buttonSpacingH: 110, buttonSpacingV: 45
            )
            
        // MARK: iPad Konfigürasyonları
        case .iPadSmall:
            return DeviceConfig(
                gameWidth: 18, gameHeight: 22,
                sideMargin: 80, topMargin: 60, bottomMargin: 60,
                headerBarHeight: 10, controlAreaHeight: 220,
                buttonHorizontalSize: CGSize(width: 85, height: 65),
                buttonVerticalSize: CGSize(width: 70, height: 85),
                maxCellSize: 18, buttonSpacingH: 100, buttonSpacingV: 30
            )
        case .iPadMedium:
            return DeviceConfig(
                gameWidth: 20, gameHeight: 25,
                sideMargin: 100, topMargin: 80, bottomMargin: 80,
                headerBarHeight: 12, controlAreaHeight: 240,
                buttonHorizontalSize: CGSize(width: 95, height: 70),
                buttonVerticalSize: CGSize(width: 80, height: 95),
                maxCellSize: 20, buttonSpacingH: 110, buttonSpacingV: 35
            )
        case .iPadLarge:
            return DeviceConfig(
                gameWidth: 22, gameHeight: 28,
                sideMargin: 120, topMargin: 100, bottomMargin: 100,
                headerBarHeight: 14, controlAreaHeight: 260,
                buttonHorizontalSize: CGSize(width: 105, height: 75),
                buttonVerticalSize: CGSize(width: 90, height: 105),
                maxCellSize: 22, buttonSpacingH: 120, buttonSpacingV: 40
            )
        }
    }
    
    private struct DeviceConfig {
        let gameWidth: Int
        let gameHeight: Int
        let sideMargin: CGFloat
        let topMargin: CGFloat
        let bottomMargin: CGFloat
        let headerBarHeight: CGFloat
        let controlAreaHeight: CGFloat
        let buttonHorizontalSize: CGSize
        let buttonVerticalSize: CGSize
        let maxCellSize: CGFloat
        let buttonSpacingH: CGFloat
        let buttonSpacingV: CGFloat
    }
    
    // MARK: - Oyun Alanı Hesaplamaları
    internal func calculateGameArea() {
        let config = deviceConfig
        
        gameWidth = config.gameWidth
        gameHeight = config.gameHeight
        
        let availableWidth = frame.width - (config.sideMargin * 2)
        let availableHeight = frame.height - config.topMargin - config.bottomMargin - config.controlAreaHeight
        
        let cellSizeByWidth = availableWidth / CGFloat(gameWidth)
        let cellSizeByHeight = availableHeight / CGFloat(gameHeight)
        
        cellSize = min(cellSizeByWidth, cellSizeByHeight, config.maxCellSize)
        
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
        
        gameAreaStartX = (frame.width - gameAreaWidth) / 2
        gameAreaStartY = config.bottomMargin + config.controlAreaHeight
        
        headerBarHeight = config.headerBarHeight
        headerBarStartY = gameAreaStartY + gameAreaHeight + 16 + headerBarHeight
    }
    
    // MARK: - Header Bar Kurulumu (YENİ: Pixel Art Tarzında)
    internal func createHeaderBar() {
        createPixelatedHeaderBar()
        createPauseButton()
        createScoreLabels()
    }
    
    // MARK: - Pixel Art Header Bar Oluşturma (YENİ FONKSİYON)
    private func createPixelatedHeaderBar() {
        let pixelSize: CGFloat = cellSize / 5 // Yılan segmentiyle aynı pixel boyutu
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0) // Çok daha koyu renk
        
        let headerContainer = SKNode()
        headerContainer.position = CGPoint(x: gameAreaStartX + gameAreaWidth/2, y: headerBarStartY - headerBarHeight/2)
        headerContainer.name = "headerBarContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        // Header bar'ı pixel bloklar halinde oluştur
        let pixelsWide = Int(gameAreaWidth / pixelSize)
        let pixelsHigh = Int(headerBarHeight / pixelSize)
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
                pixel.position = CGPoint(
                    x: -gameAreaWidth/2 + CGFloat(col) * pixelSize + pixelSize/2,
                    y: -headerBarHeight/2 + CGFloat(row) * pixelSize + pixelSize/2
                )
                pixel.zPosition = 1
                headerContainer.addChild(pixel)
            }
        }
        
        // Geriye dönük uyumluluk için ana header bar referansı
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: gameAreaWidth, height: headerBarHeight))
        headerBar.position = CGPoint(x: gameAreaStartX + gameAreaWidth/2, y: headerBarStartY - headerBarHeight/2)
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Duraklatma Butonu Kurulumu (YENİ: Pixel Art Tarzında)
    internal func createPauseButton() {
        let buttonSize: CGFloat = deviceType.isIPhone ?
            (deviceType == .iPhoneSmall ? 20 : 28) : 36
        
        pauseButton = SKShapeNode(rect: CGRect(x: -buttonSize/2, y: -buttonSize/2, width: buttonSize, height: buttonSize))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = CGPoint(x: gameAreaStartX + 20, y: headerBarStartY + 8)
        pauseButton.name = "pauseButton"
        
        // Pixel Art Pause İkonu Oluştur
        let pixelSize: CGFloat = cellSize / 5 // Yılan ile aynı pixel boyutu
        let pauseIcon = createPixelArtPauseIcon(pixelSize: pixelSize)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    // MARK: - Pixel Art Pause İkonu Oluşturma (YENİ FONKSİYON)
    private func createPixelArtPauseIcon(pixelSize: CGFloat) -> SKNode {
        let pauseContainer = SKNode()
        
        // 5x5 pause ikonu - Sol blok (2 piksel genişlik, 5 piksel yükseklik)
        let leftBlockPixels = [
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2),  // Alt sıra
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1),  // Orta alt
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0),    // Merkez
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1),    // Orta üst
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2)     // Üst sıra
        ]
        
        // Sağ blok (2 piksel genişlik, 5 piksel yükseklik) - 1 piksel boşluk bırakarak
        let rightBlockPixels = [
            CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2),    // Alt sıra
            CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),    // Orta alt
            CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),      // Merkez
            CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),      // Orta üst
            CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2)       // Üst sıra
        ]
        
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0) // Header/border ile aynı çok koyu renk
        
        // Sol blok piksellerini oluştur
        for pixelPos in leftBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            pauseContainer.addChild(pixel)
        }
        
        // Sağ blok piksellerini oluştur
        for pixelPos in rightBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            pauseContainer.addChild(pixel)
        }
        
        return pauseContainer
    }
    
    // MARK: - Skor Etiketleri Kurulumu
    internal func createScoreLabels() {
        let pixelFont = "Jersey15-Regular"
        var fontSize: CGFloat = 16
        
        switch deviceType {
        case .iPhoneSmall:
            fontSize = 14
        case .iPhoneMedium, .iPhoneLarge:
            fontSize = 16
        case .iPhoneX, .iPhone12, .iPhone14Pro:
            fontSize = 17
        case .iPhoneMax, .iPhoneProMax:
            fontSize = 18
        case .iPadSmall:
            fontSize = 20
        case .iPadMedium:
            fontSize = 22
        case .iPadLarge:
            fontSize = 24
        }
        
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: gameAreaStartX + gameAreaWidth - 10, y: headerBarStartY + 8)
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: pixelFont)
        highScoreLabel.text = "HI:\(allTimeHighScore)"
        highScoreLabel.fontSize = fontSize
        highScoreLabel.fontColor = labelColor
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
        
        let offsetX: CGFloat = deviceType.isIPhone ?
            (deviceType == .iPhoneSmall ? 70 : 85) : 110
        highScoreLabel.position = CGPoint(x: scoreLabel.position.x - offsetX, y: headerBarStartY + 8)
        addChild(highScoreLabel)
    }
    
    // MARK: - Skor Gösterimini Güncelleme
    internal func updateScoreDisplay() {
        scoreLabel.text = "\(currentGameScore)"
        
        if currentGameScore > sessionHighScore {
            sessionHighScore = currentGameScore
        }
        
        let currentDisplayHighScore: Int
        if currentGameScore > allTimeHighScore {
            currentDisplayHighScore = currentGameScore
            isNewRecord = true
        } else {
            currentDisplayHighScore = max(allTimeHighScore, sessionHighScore)
        }
        
        highScoreLabel.text = "HI:\(currentDisplayHighScore)"
        
        if currentGameScore > allTimeHighScore && !isNewRecord {
            isNewRecord = true
            let glowUp = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            let glowDown = SKAction.fadeAlpha(to: 0.8, duration: 0.2)
            let glowSequence = SKAction.sequence([glowUp, glowDown])
            let glowRepeat = SKAction.repeat(glowSequence, count: 3)
            highScoreLabel.run(glowRepeat)
        }
    }
    
    // MARK: - Oyun Alanı Pixel Art Çerçevesi Kurulumu (YENİ: Pixel Art Tarzında)
    internal func createGameAreaBorder() {
        createPixelArtBorder()
    }
    
    // MARK: - Pixel Art Border Oluşturma (YENİ FONKSİYON)
    private func createPixelArtBorder() {
        let pixelSize: CGFloat = cellSize / 5 // Yılan segmentiyle aynı pixel boyutu
        let borderThickness: CGFloat = pixelSize * 3 // 3 piksel kalınlığında border (header ile aynı)
        
        let borderContainer = SKNode()
        borderContainer.name = "pixelBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        // Üst border (köşeleri dahil ederek)
        createBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY + gameAreaHeight,
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: pixelSize
        )
        
        // Alt border (köşeleri dahil ederek)
        createBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY - borderThickness,
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: pixelSize
        )
        
        // Sol border (köşeleri hariç)
        createBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY,
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: pixelSize
        )
        
        // Sağ border (köşeleri hariç)
        createBorderLine(
            container: borderContainer,
            startX: gameAreaStartX + gameAreaWidth,
            startY: gameAreaStartY,
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: pixelSize
        )
    }
    
    // MARK: - Border Çizgisi Oluşturma (YENİ FONKSİYON)
    private func createBorderLine(container: SKNode, startX: CGFloat, startY: CGFloat, width: CGFloat, height: CGFloat, pixelSize: CGFloat) {
        let pixelsWide = Int(ceil(width / pixelSize))
        let pixelsHigh = Int(ceil(height / pixelSize))
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0) // Çok daha koyu renk
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
                pixel.position = CGPoint(
                    x: startX + CGFloat(col) * pixelSize + pixelSize/2,
                    y: startY + CGFloat(row) * pixelSize + pixelSize/2
                )
                pixel.zPosition = 1
                container.addChild(pixel)
            }
        }
    }
    
    // MARK: - Kontrol Butonları Kurulumu
    internal func createControlButtons() {
        let config = deviceConfig
        
        let controlAreaHeight = config.controlAreaHeight
        let controlAreaY = config.bottomMargin + controlAreaHeight / 2
        
        let horizontalButtonSize = config.buttonHorizontalSize
        let verticalButtonSize = config.buttonVerticalSize
        
        let centerX = frame.midX
        
        let verticalSpacing = config.buttonSpacingV
        let horizontalSpacing = config.buttonSpacingH
        
        // Biraz daha koyu arka plan rengi
        let buttonBackgroundColor = SKColor(red: 136/255, green: 180/255, blue: 1/255, alpha: 1.0)
        
        upButton = createEnhancedDirectionButton(
            direction: .up,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: controlAreaY + verticalSpacing),
            color: buttonBackgroundColor
        )
        addChild(upButton)
        
        downButton = createEnhancedDirectionButton(
            direction: .down,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: controlAreaY - verticalSpacing),
            color: buttonBackgroundColor
        )
        addChild(downButton)
        
        leftButton = createEnhancedDirectionButton(
            direction: .left,
            size: verticalButtonSize,
            position: CGPoint(x: centerX - horizontalSpacing, y: controlAreaY),
            color: buttonBackgroundColor
        )
        addChild(leftButton)
        
        rightButton = createEnhancedDirectionButton(
            direction: .right,
            size: verticalButtonSize,
            position: CGPoint(x: centerX + horizontalSpacing, y: controlAreaY),
            color: buttonBackgroundColor
        )
        addChild(rightButton)
    }
    
    // MARK: - Yön Butonu Oluşturma
    internal func createEnhancedDirectionButton(direction: Direction, size: CGSize, position: CGPoint, color: SKColor) -> SKShapeNode {
        let buttonContainer = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        buttonContainer.fillColor = color
        buttonContainer.strokeColor = .clear
        buttonContainer.position = position
        buttonContainer.name = "\(direction)Button"
        buttonContainer.zPosition = 10
        
        // İyileştirilmiş gölge efekti
        let shadowOffset: CGFloat = deviceType.isIPhone ?
            (deviceType == .iPhoneSmall ? 4 : 5) : 6
        let shadow = SKShapeNode(rect: CGRect(x: -size.width/2 + shadowOffset, y: -size.height/2 - shadowOffset, width: size.width, height: size.height))
        shadow.fillColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4) // Daha belirgin gölge
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        buttonContainer.addChild(shadow)
        
        // Yönsel highlight efekti
        let highlightThickness: CGFloat = deviceType.isIPhone ?
            (deviceType == .iPhoneSmall ? 6 : 8) : 10
        
        var highlight: SKSpriteNode
        
        switch direction {
        case .up:
            // Üst tarafta highlight
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - 8, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: size.height/2 - highlightThickness/2 - 4)
        case .down:
            // Alt tarafta highlight
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - 8, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: -size.height/2 + highlightThickness/2 + 4)
        case .left:
            // Sol tarafta highlight
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - 8))
            highlight.position = CGPoint(x: -size.width/2 + highlightThickness/2 + 4, y: 0)
        case .right:
            // Sağ tarafta highlight
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - 8))
            highlight.position = CGPoint(x: size.width/2 - highlightThickness/2 - 4, y: 0)
        }
        
        highlight.alpha = 0.5
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        let arrowNode = createPixelArtArrow(direction: direction, buttonSize: size)
        arrowNode.zPosition = 2
        buttonContainer.addChild(arrowNode)
        
        let innerBorderThickness: CGFloat = deviceType.isIPhone ?
            (deviceType == .iPhoneSmall ? 2 : 3) : 4
        let innerBorder = SKShapeNode(rect: CGRect(
            x: -size.width/2 + innerBorderThickness,
            y: -size.height/2 + innerBorderThickness,
            width: size.width - innerBorderThickness*2,
            height: size.height - innerBorderThickness*2
        ))
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = primaryColor
        innerBorder.lineWidth = 2
        innerBorder.alpha = 0.6 // Biraz daha belirgin
        innerBorder.zPosition = 1
        buttonContainer.addChild(innerBorder)
        
        return buttonContainer
    }
    
    // MARK: - Piksel Sanatı Ok Oluşturma
    internal func createPixelArtArrow(direction: Direction, buttonSize: CGSize) -> SKNode {
        let arrowContainer = SKNode()
        
        var basePixelSize: CGFloat = 6
        
        switch deviceType {
        case .iPhoneSmall:
            basePixelSize = 5
        case .iPhoneMedium, .iPhoneLarge:
            basePixelSize = 6
        case .iPhoneX, .iPhone12, .iPhone14Pro:
            basePixelSize = 6.5
        case .iPhoneMax, .iPhoneProMax:
            basePixelSize = 7
        case .iPadSmall:
            basePixelSize = 7.5
        case .iPadMedium:
            basePixelSize = 8
        case .iPadLarge:
            basePixelSize = 9
        }
        
        let scale: CGFloat = min(buttonSize.width, buttonSize.height) / 80
        let adjustedPixelSize = basePixelSize * scale
        let arrowColor = SKColor(red: 68/255, green: 90/255, blue: 0/255, alpha: 1.0)
        
        switch direction {
        case .up:
            let arrowPixels = [
                CGPoint(x: 0, y: 2),
                CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: -1, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)
            ]
            createPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .down:
            let arrowPixels = [
                CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
                CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 0, y: -2)
            ]
            createPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .left:
            let arrowPixels = [
                CGPoint(x: -2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: -1), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1)
            ]
            createPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .right:
            let arrowPixels = [
                CGPoint(x: -2, y: -1), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: 1),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 0)
            ]
            createPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
        }
        
        return arrowContainer
    }
    
    // MARK: - Piksel Dizisinden Sprite Oluşturma
    internal func createPixelsFromArray(_ pixels: [CGPoint], in container: SKNode, pixelSize: CGFloat, color: SKColor) {
        for pixelPos in pixels {
            let pixel = SKSpriteNode(color: color, size: CGSize(width: pixelSize-1, height: pixelSize-1))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
    }
    
    // MARK: - Yön Butonu Yardımcısı (Geriye Dönük Uyumluluk)
    internal func createDirectionButton(direction: Direction, color: SKColor, size: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        button.fillColor = color
        button.strokeColor = .clear
        button.name = "\(direction)Button"
        return button
    }
    
    // MARK: - Ok Çizimi (Geriye Dönük Uyumluluk)
    internal func createArrowPath(direction: Direction, size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let halfSize = size / 2
        
        switch direction {
        case .up:
            path.move(to: CGPoint(x: 0, y: halfSize))
            path.addLine(to: CGPoint(x: -halfSize, y: -halfSize))
            path.addLine(to: CGPoint(x: halfSize, y: -halfSize))
            path.closeSubpath()
        case .down:
            path.move(to: CGPoint(x: 0, y: -halfSize))
            path.addLine(to: CGPoint(x: -halfSize, y: halfSize))
            path.addLine(to: CGPoint(x: halfSize, y: halfSize))
            path.closeSubpath()
        case .left:
            path.move(to: CGPoint(x: -halfSize, y: 0))
            path.addLine(to: CGPoint(x: halfSize, y: -halfSize))
            path.addLine(to: CGPoint(x: halfSize, y: halfSize))
            path.closeSubpath()
        case .right:
            path.move(to: CGPoint(x: halfSize, y: 0))
            path.addLine(to: CGPoint(x: -halfSize, y: -halfSize))
            path.addLine(to: CGPoint(x: -halfSize, y: halfSize))
            path.closeSubpath()
        }
        
        return path
    }
    
    // MARK: - Arayüz Elementleri Oluşturma
    internal func createUI() {
        // Gerektiğinde oluşturulacak
    }
    
    // MARK: - Yem Oluşturma
    internal func spawnFood() {
        repeat {
            food = CGPoint(
                x: CGFloat(Int.random(in: 0..<gameWidth)),
                y: CGFloat(Int.random(in: 0..<gameHeight))
            )
        } while snake.body.contains(food)
    }
    
    // MARK: - Çiçek Yem Oluşturma (YENİ FONKSİYON)
    internal func createFlowerFood() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5
        
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
        
        // Her piksel için bir mini sprite oluştur
        for pixelPos in flowerPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        // Çiçek yemine hafif parıldama efekti ekle
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        container.run(pulseRepeat)
        
        return container
    }
    
    // MARK: - Yılan Segmenti Oluşturma (YENİ FONKSİYON)
    internal func createSnakeSegment() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5
        
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
        
        // Her piksel için bir mini sprite oluştur (hiç efekt yok)
        for pixelPos in fullBlockPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
    }
    
    // MARK: - Oyun Elementlerini Çizme (GÜNCELLENDİ)
    internal func drawGame() {
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
        // YENİ: Piksel art yılan segmentlerini çiz (eski basit kare yerine)
        for segment in snake.body {
            let segmentNode = createSnakeSegment()
            segmentNode.position = CGPoint(
                x: gameAreaStartX + CGFloat(Int(segment.x)) * cellSize + cellSize/2,
                y: gameAreaStartY + CGFloat(Int(segment.y)) * cellSize + cellSize/2
            )
            segmentNode.name = "snake"
            addChild(segmentNode)
        }
        
        // YENİ: Çiçek yemi çiz (eski kare yem yerine)
        let flowerFoodNode = createFlowerFood()
        flowerFoodNode.position = CGPoint(
            x: gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2,
            y: gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2
        )
        flowerFoodNode.name = "food"
        addChild(flowerFoodNode)
    }
}
