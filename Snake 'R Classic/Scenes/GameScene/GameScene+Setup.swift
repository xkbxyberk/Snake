import SpriteKit
import GameplayKit
import UIKit

// MARK: - Oyun Sahnesi Kurulumu - Universal iPhone 14 Pro Max Standardı
extension GameScene {
    
    // MARK: - Cihaz Tipi Tespiti (UI Adaptasyonu İçin)
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
    
    // MARK: - Universal Device Configuration (iPhone 14 Pro Max Standardı)
    private var deviceConfig: DeviceConfig {
        // iPhone 14 Pro Max standardını temel alan universal konfigürasyon
        let baseConfig = DeviceConfig(
            gameWidth: 27,           // SABİT - Tüm cihazlarda aynı
            gameHeight: 42,          // SABİT - Tüm cihazlarda aynı
            sideMargin: 35,
            topMargin: 75,
            bottomMargin: 55,
            headerBarHeight: 9,
            controlAreaHeight: 215,
            buttonHorizontalSize: CGSize(width: 100, height: 80),
            buttonVerticalSize: CGSize(width: 85, height: 100),
            maxCellSize: 17,         // Maksimum cell boyutu
            buttonSpacingH: 110,
            buttonSpacingV: 45
        )
        
        // Ekran boyutuna göre scale faktörü hesapla (iPhone 14 Pro Max = 430x932 referans)
        let screenScale = min(frame.width / 430.0, frame.height / 932.0)
        let adaptiveScale = max(0.6, min(screenScale, 1.2)) // %60 - %120 arası sınırla
        
        // Sadece UI elementlerini scale et, grid boyutunu değil
        return DeviceConfig(
            gameWidth: baseConfig.gameWidth,           // SABİT
            gameHeight: baseConfig.gameHeight,         // SABİT
            sideMargin: baseConfig.sideMargin * adaptiveScale,
            topMargin: baseConfig.topMargin * adaptiveScale,
            bottomMargin: baseConfig.bottomMargin * adaptiveScale,
            headerBarHeight: baseConfig.headerBarHeight * adaptiveScale,
            controlAreaHeight: baseConfig.controlAreaHeight * adaptiveScale,
            buttonHorizontalSize: CGSize(
                width: baseConfig.buttonHorizontalSize.width * adaptiveScale,
                height: baseConfig.buttonHorizontalSize.height * adaptiveScale
            ),
            buttonVerticalSize: CGSize(
                width: baseConfig.buttonVerticalSize.width * adaptiveScale,
                height: baseConfig.buttonVerticalSize.height * adaptiveScale
            ),
            maxCellSize: baseConfig.maxCellSize * adaptiveScale,
            buttonSpacingH: baseConfig.buttonSpacingH * adaptiveScale,
            buttonSpacingV: baseConfig.buttonSpacingV * adaptiveScale
        )
    }
    
    private struct DeviceConfig {
        let gameWidth: Int          // SABİT
        let gameHeight: Int         // SABİT
        let sideMargin: CGFloat     // Adaptive
        let topMargin: CGFloat      // Adaptive
        let bottomMargin: CGFloat   // Adaptive
        let headerBarHeight: CGFloat // Adaptive
        let controlAreaHeight: CGFloat // Adaptive
        let buttonHorizontalSize: CGSize // Adaptive
        let buttonVerticalSize: CGSize // Adaptive
        let maxCellSize: CGFloat    // Adaptive
        let buttonSpacingH: CGFloat // Adaptive
        let buttonSpacingV: CGFloat // Adaptive
    }
    
    // MARK: - Universal Oyun Alanı Hesaplamaları (Perfect Square Pixels)
    internal func calculateGameArea() {
        let config = deviceConfig
        
        // SABİT GRID BOYUTLARI - TÜM CİHAZLARDA AYNI
        gameWidth = config.gameWidth   // 27
        gameHeight = config.gameHeight // 42
        
        let availableWidth = frame.width - (config.sideMargin * 2)
        let availableHeight = frame.height - config.topMargin - config.bottomMargin - config.controlAreaHeight
        
        let cellSizeByWidth = availableWidth / CGFloat(gameWidth)
        let cellSizeByHeight = availableHeight / CGFloat(gameHeight)
        
        // Mükemmel kare pikseller için: en küçük boyutu al ve tam sayıya yuvarla
        let idealCellSize = min(cellSizeByWidth, cellSizeByHeight, config.maxCellSize)
        
        // TAM SAYI CELL SIZE - Mükemmel kare pikseller garantisi
        cellSize = floor(idealCellSize)
        
        // Minimum cell size koruması
        cellSize = max(cellSize, 6.0) // En az 6 pixel
        
        // Tam sayı cell size ile perfect grid hesapla
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
        
        // Mükemmel merkeze hizalama
        gameAreaStartX = floor((frame.width - gameAreaWidth) / 2)
        gameAreaStartY = config.bottomMargin + config.controlAreaHeight
        
        headerBarHeight = config.headerBarHeight
        headerBarStartY = gameAreaStartY + gameAreaHeight + 16 + headerBarHeight
    }
    
    // MARK: - Header Bar Kurulumu (Responsive)
    internal func createHeaderBar() {
        createPixelatedHeaderBar()
        createPauseButton()
        createScoreLabels()
    }
    
    // MARK: - Perfect Retro Pixel Art Header Bar Oluşturma
    private func createPixelatedHeaderBar() {
        // Tam sayı base pixel boyutu
        let basePixelSize: CGFloat = floor(cellSize / 5)
        // Retro gap için 0.5 çıkar
        let pixelSize = basePixelSize - 0.5
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let headerContainer = SKNode()
        headerContainer.position = CGPoint(x: floor(gameAreaStartX + gameAreaWidth/2), y: floor(headerBarStartY - headerBarHeight/2))
        headerContainer.name = "headerBarContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        let pixelsWide = Int(gameAreaWidth / basePixelSize)
        let pixelsHigh = Int(headerBarHeight / basePixelSize)
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize, height: pixelSize))
                pixel.position = CGPoint(
                    x: floor(-gameAreaWidth/2 + CGFloat(col) * basePixelSize + basePixelSize/2),
                    y: floor(-headerBarHeight/2 + CGFloat(row) * basePixelSize + basePixelSize/2)
                )
                pixel.zPosition = 1
                headerContainer.addChild(pixel)
            }
        }
        
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: gameAreaWidth, height: headerBarHeight))
        headerBar.position = CGPoint(x: floor(gameAreaStartX + gameAreaWidth/2), y: floor(headerBarStartY - headerBarHeight/2))
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Perfect Retro Responsive Duraklatma Butonu Kurulumu
    internal func createPauseButton() {
        // Adaptive button size
        let baseButtonSize: CGFloat = 28
        let screenScale = min(frame.width / 430, frame.height / 932)
        let adaptiveScale = max(0.7, min(screenScale, 1.2))
        let buttonSize = floor(baseButtonSize * adaptiveScale)
        
        pauseButton = SKShapeNode(rect: CGRect(x: -buttonSize/2, y: -buttonSize/2, width: buttonSize, height: buttonSize))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = CGPoint(x: floor(gameAreaStartX + 20 * adaptiveScale), y: floor(headerBarStartY + 8 * adaptiveScale))
        pauseButton.name = "pauseButton"
        
        // Base pixel boyutu (gap olmadan)
        let basePixelSize: CGFloat = floor(cellSize / 5)
        let pauseIcon = createPixelArtPauseIcon(pixelSize: basePixelSize)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    // MARK: - Perfect Retro Pixel Art Pause İkonu Oluşturma (Border Sistemiyle Uyumlu)
    private func createPixelArtPauseIcon(pixelSize: CGFloat) -> SKNode {
        let pauseContainer = SKNode()
        
        let leftBlockPixels = [
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2),
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0),
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1),
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2)
        ]
        
        let rightBlockPixels = [
            CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2),
            CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
            CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),
            CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2)
        ]
        
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Border sistemi ile uyumlu - retro gap
        let retroPixelSize = floor(pixelSize) - 0.5
        let basePixelSize = floor(pixelSize)
        
        for pixelPos in leftBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            pauseContainer.addChild(pixel)
        }
        
        for pixelPos in rightBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            pauseContainer.addChild(pixel)
        }
        
        return pauseContainer
    }
    
    // MARK: - Perfect Responsive Skor Etiketleri Kurulumu
    internal func createScoreLabels() {
        let pixelFont = "Jersey15-Regular"
        
        // Adaptive font size
        let baseFontSize: CGFloat = 18
        let screenScale = min(frame.width / 430, frame.height / 932)
        let adaptiveScale = max(0.7, min(screenScale, 1.2))
        let fontSize = floor(baseFontSize * adaptiveScale)
        
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: floor(gameAreaStartX + gameAreaWidth - 10 * adaptiveScale), y: floor(headerBarStartY + 8 * adaptiveScale))
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: pixelFont)
        highScoreLabel.text = "HI:\(allTimeHighScore)"
        highScoreLabel.fontSize = fontSize
        highScoreLabel.fontColor = labelColor
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
        
        let offsetX: CGFloat = floor(85 * adaptiveScale)
        highScoreLabel.position = CGPoint(x: scoreLabel.position.x - offsetX, y: floor(headerBarStartY + 8 * adaptiveScale))
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
    
    // MARK: - Universal Oyun Alanı Pixel Art Çerçevesi
    internal func createGameAreaBorder() {
        createPixelArtBorder()
    }
    
    // MARK: - Perfect Retro Pixel Art Border Oluşturma
    private func createPixelArtBorder() {
        // Tam sayı base pixel boyutu
        let basePixelSize: CGFloat = floor(cellSize / 5)
        let borderThickness: CGFloat = basePixelSize * 3
        
        let borderContainer = SKNode()
        borderContainer.name = "pixelBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        // Üst border
        createBorderLine(
            container: borderContainer,
            startX: floor(gameAreaStartX - borderThickness),
            startY: floor(gameAreaStartY + gameAreaHeight),
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: basePixelSize
        )
        
        // Alt border
        createBorderLine(
            container: borderContainer,
            startX: floor(gameAreaStartX - borderThickness),
            startY: floor(gameAreaStartY - borderThickness),
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: basePixelSize
        )
        
        // Sol border
        createBorderLine(
            container: borderContainer,
            startX: floor(gameAreaStartX - borderThickness),
            startY: floor(gameAreaStartY),
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: basePixelSize
        )
        
        // Sağ border
        createBorderLine(
            container: borderContainer,
            startX: floor(gameAreaStartX + gameAreaWidth),
            startY: floor(gameAreaStartY),
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: basePixelSize
        )
    }
    
    // MARK: - Perfect Retro Border Çizgisi Oluşturma
    private func createBorderLine(container: SKNode, startX: CGFloat, startY: CGFloat, width: CGFloat, height: CGFloat, pixelSize: CGFloat) {
        let pixelsWide = Int(ceil(width / pixelSize))
        let pixelsHigh = Int(ceil(height / pixelSize))
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Retro gap için pixel boyutunu küçült
        let retroPixelSize = pixelSize - 0.5
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: retroPixelSize, height: retroPixelSize))
                pixel.position = CGPoint(
                    x: floor(startX + CGFloat(col) * pixelSize + pixelSize/2),
                    y: floor(startY + CGFloat(row) * pixelSize + pixelSize/2)
                )
                pixel.zPosition = 1
                container.addChild(pixel)
            }
        }
    }
    
    // MARK: - Responsive Kontrol Butonları Kurulumu
    internal func createControlButtons() {
        let config = deviceConfig
        
        let controlAreaHeight = config.controlAreaHeight
        let controlAreaY = config.bottomMargin + controlAreaHeight / 2
        
        let horizontalButtonSize = config.buttonHorizontalSize
        let verticalButtonSize = config.buttonVerticalSize
        
        let centerX = frame.midX
        
        let verticalSpacing = config.buttonSpacingV
        let horizontalSpacing = config.buttonSpacingH
        
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
    
    // MARK: - Responsive Yön Butonu Oluşturma
    internal func createEnhancedDirectionButton(direction: Direction, size: CGSize, position: CGPoint, color: SKColor) -> SKShapeNode {
        let buttonContainer = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        buttonContainer.fillColor = color
        buttonContainer.strokeColor = .clear
        buttonContainer.position = position
        buttonContainer.name = "\(direction)Button"
        buttonContainer.zPosition = 10
        
        // Adaptive shadow
        let screenScale = min(frame.width / 430, frame.height / 932)
        let shadowOffset: CGFloat = 5 * max(0.7, min(screenScale, 1.2))
        
        let shadow = SKShapeNode(rect: CGRect(x: -size.width/2 + shadowOffset, y: -size.height/2 - shadowOffset, width: size.width, height: size.height))
        shadow.fillColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        buttonContainer.addChild(shadow)
        
        // Adaptive highlight
        let highlightThickness: CGFloat = 8 * max(0.7, min(screenScale, 1.2))
        
        var highlight: SKSpriteNode
        
        switch direction {
        case .up:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - 8, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: size.height/2 - highlightThickness/2 - 4)
        case .down:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - 8, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: -size.height/2 + highlightThickness/2 + 4)
        case .left:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - 8))
            highlight.position = CGPoint(x: -size.width/2 + highlightThickness/2 + 4, y: 0)
        case .right:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - 8))
            highlight.position = CGPoint(x: size.width/2 - highlightThickness/2 - 4, y: 0)
        }
        
        highlight.alpha = 0.5
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        let arrowNode = createPixelArtArrow(direction: direction, buttonSize: size)
        arrowNode.zPosition = 2
        buttonContainer.addChild(arrowNode)
        
        // Adaptive inner border
        let innerBorderThickness: CGFloat = 3 * max(0.7, min(screenScale, 1.2))
        let innerBorder = SKShapeNode(rect: CGRect(
            x: -size.width/2 + innerBorderThickness,
            y: -size.height/2 + innerBorderThickness,
            width: size.width - innerBorderThickness*2,
            height: size.height - innerBorderThickness*2
        ))
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = primaryColor
        innerBorder.lineWidth = 2
        innerBorder.alpha = 0.6
        innerBorder.zPosition = 1
        buttonContainer.addChild(innerBorder)
        
        return buttonContainer
    }
    
    // MARK: - Perfect Retro Responsive Piksel Sanatı Ok Oluşturma
    internal func createPixelArtArrow(direction: Direction, buttonSize: CGSize) -> SKNode {
        let arrowContainer = SKNode()
        
        // Base pixel size (border ile aynı sistem)
        let basePixelSize: CGFloat = floor(cellSize / 5)
        let scale: CGFloat = min(buttonSize.width, buttonSize.height) / 100 // Daha küçük scale factor
        let adjustedPixelSize = max(basePixelSize * scale, 4.0) // Minimum 4 pixel
        
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
            createPerfectPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .down:
            let arrowPixels = [
                CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
                CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 0, y: -2)
            ]
            createPerfectPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .left:
            let arrowPixels = [
                CGPoint(x: -2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: -1), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1)
            ]
            createPerfectPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
            
        case .right:
            let arrowPixels = [
                CGPoint(x: -2, y: -1), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: 1),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 0)
            ]
            createPerfectPixelsFromArray(arrowPixels, in: arrowContainer, pixelSize: adjustedPixelSize, color: arrowColor)
        }
        
        return arrowContainer
    }
    
    // MARK: - Perfect Retro Arrow Piksel Oluşturma (Border Sistemiyle Uyumlu)
    private func createPerfectPixelsFromArray(_ pixels: [CGPoint], in container: SKNode, pixelSize: CGFloat, color: SKColor) {
        // Border sistemi ile uyumlu retro gap sistem
        let retroPixelSize = floor(pixelSize) - 0.8 // Oklar için daha belirgin gap
        let basePixelSize = floor(pixelSize)
        
        for pixelPos in pixels {
            let pixel = SKSpriteNode(color: color, size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            container.addChild(pixel)
        }
    }
    
    // MARK: - Eski Piksel Sistemi (Artık Kullanılmıyor - Geriye Dönük Uyumluluk İçin)
    internal func createPixelsFromArray(_ pixels: [CGPoint], in container: SKNode, pixelSize: CGFloat, color: SKColor) {
        // Bu fonksiyon artık kullanılmıyor, perfect pixel sistemine geçildi
        // Geriye dönük uyumluluk için bırakıldı
        createPerfectPixelsFromArray(pixels, in: container, pixelSize: pixelSize, color: color)
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
    
    // MARK: - Yem Oluşturma (SABİT GRID İÇİN)
    internal func spawnFood() {
        repeat {
            food = CGPoint(
                x: CGFloat(Int.random(in: 0..<gameWidth)),   // 0-26 arası
                y: CGFloat(Int.random(in: 0..<gameHeight))   // 0-41 arası
            )
        } while snake.body.contains(food)
    }
    
    // MARK: - Perfect Retro Pixelated Çiçek Yemi (Border Sistemiyle Uyumlu)
    internal func createFlowerFood() -> SKNode {
        let container = SKNode()
        
        // Border ile aynı sistem - tam sayı pixel boyutu
        let basePixelSize: CGFloat = floor(cellSize / 5)
        
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
        
        // Border sistemi ile aynı - retro gap için piksel boyutunu küçült
        let retroPixelSize = basePixelSize - 0.5
        
        for pixelPos in flowerPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: retroPixelSize, height: retroPixelSize))
            pixel.position = CGPoint(
                x: floor(pixelPos.x * basePixelSize),
                y: floor(pixelPos.y * basePixelSize)
            )
            container.addChild(pixel)
        }
        
        // Yem için hafif parlama efekti (animasyon korunuyor)
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        container.run(pulseRepeat)
        
        return container
    }
    
    // MARK: - Perfect Retro Pixelated Yılan Segmenti (Border Sistemiyle Uyumlu)
    internal func createSnakeSegment() -> SKNode {
        let container = SKNode()
        
        // Border ile aynı sistem - tam sayı pixel boyutu
        let basePixelSize: CGFloat = floor(cellSize / 5)
        
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
        
        // Border sistemi ile aynı - retro gap için piksel boyutunu küçült
        let retroPixelSize = basePixelSize - 0.5
        
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
    
    // MARK: - Perfect Retro Game Elements Çizme (SABİT GRID İÇİN)
    internal func drawGame() {
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
        // Perfect positioned yılan segmentlerini çiz (SABİT GRID)
        for segment in snake.body {
            let segmentNode = createSnakeSegment()
            
            let basePixelSize = floor(cellSize / 5)
            let segmentRenderedSize = 5 * basePixelSize
            
            // Sadece boşluk oluşacaksa ölçekleme yap
            if segmentRenderedSize > 0 && segmentRenderedSize < cellSize {
                let scale = cellSize / segmentRenderedSize
                segmentNode.setScale(scale)
            }
            
            // Perfect grid positioning
            let perfectX = floor(gameAreaStartX + CGFloat(Int(segment.x)) * cellSize + cellSize/2)
            let perfectY = floor(gameAreaStartY + CGFloat(Int(segment.y)) * cellSize + cellSize/2)
            segmentNode.position = CGPoint(x: perfectX, y: perfectY)
            segmentNode.name = "snake"
            addChild(segmentNode)
        }
        
        // Perfect positioned çiçek yemi çiz (SABİT GRID)
        let flowerFoodNode = createFlowerFood()
        // Perfect grid positioning
        let perfectFoodX = floor(gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2)
        let perfectFoodY = floor(gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2)
        flowerFoodNode.position = CGPoint(x: perfectFoodX, y: perfectFoodY)
        flowerFoodNode.name = "food"
        addChild(flowerFoodNode)
    }
}
