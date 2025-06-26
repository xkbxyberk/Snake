import SpriteKit
import GameplayKit
import UIKit

// MARK: - Oyun Sahnesi Kurulumu - Pixel Perfect Layout Sistemi
extension GameScene {
    
    // MARK: - Sabit Grid Boyutları için Layout Hesaplama Sistemi
    internal func calculateGameArea() {
        // Safe area hesaplama
        let safeAreaInsets = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let screenBounds = UIScreen.main.bounds
        
        // Temel boyutlar
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        
        // Safe area'ları hesaba katarak kullanılabilir alan
        let safeWidth = screenWidth - safeAreaInsets.left - safeAreaInsets.right
        let safeHeight = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
        
        calculateOptimalCellSizeForFixedGrid(availableWidth: safeWidth, availableHeight: safeHeight)
        
        // Layout elemanları için pixel perfect boyutlar
        let minimumMargin: CGFloat = 12
        let controlAreaHeightRatio: CGFloat = 0.25 // Kontrol alanı büyütüldü
        let scoreAreaHeight: CGFloat = cellSize * 2.5 // Score area'yı cell size'a göre hesapla
        let pixelGap: CGFloat = cellSize * 0.3 // Gap'i pixel perfect yap
        let headerBarHeight: CGFloat = cellSize * 0.6 // Header'ı border ile aynı kalınlıkta yap
        
        // Kontrol alanı yüksekliği
        let controlAreaHeight = safeHeight * controlAreaHeightRatio
        
        // Layout hesaplama - Yukarıdan aşağıya:
        // scoreArea + gap + header + gap + border + gameArea + border + gap + controlArea
        let borderThickness = cellSize * 0.6 // Border kalınlığı
        let reservedHeight = scoreAreaHeight + pixelGap + headerBarHeight + pixelGap +
                           (borderThickness * 2) + controlAreaHeight + (minimumMargin * 2)
        
        let availableGameHeight = safeHeight - reservedHeight
        let availableGameWidth = safeWidth - (minimumMargin * 2) - (borderThickness * 2)
        
        // Gerçek oyun alanı boyutları (pixel perfect) - sabit grid boyutlarından hesapla
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
        
        // Eğer hesaplanan oyun alanı kullanılabilir alandan büyükse cell size'ı küçült
        if gameAreaWidth > availableGameWidth || gameAreaHeight > availableGameHeight {
            let maxCellSizeForWidth = availableGameWidth / CGFloat(gameWidth)
            let maxCellSizeForHeight = availableGameHeight / CGFloat(gameHeight)
            cellSize = min(maxCellSizeForWidth, maxCellSizeForHeight)
            
            // Cell size minimumunu koru
            cellSize = max(8, cellSize) // En az 8 pixel
            
            // Oyun alanını yeniden hesapla
            gameAreaWidth = CGFloat(gameWidth) * cellSize
            gameAreaHeight = CGFloat(gameHeight) * cellSize
        }
        
        // Pozisyon hesaplamaları (pixel perfect - merkeze yerleştir)
        gameAreaStartX = round((screenWidth - gameAreaWidth) / 2)
        gameAreaStartY = safeAreaInsets.bottom + minimumMargin + controlAreaHeight + borderThickness - 30
        
        // Border'ın üst kısmının Y pozisyonu
        let borderTopY = gameAreaStartY + gameAreaHeight + borderThickness
        
        // Score area Y pozisyonu (header bar'dan bağımsız hesapla)
        let scoreY = borderTopY + pixelGap + headerBarHeight + pixelGap + scoreAreaHeight/2
        
        // Header bar pozisyonu - skorlar ile border arasının TAM ORTASINDA
        headerBarStartY = (scoreY + borderTopY) / 2
        
        // Header bar height'ı ayarla
        self.headerBarHeight = headerBarHeight
        
        // Pixel perfect hizalama
        alignToPixelGrid()
    }
    
    // MARK: - Sabit Grid İçin Optimal Cell Size Hesaplama
    private func calculateOptimalCellSizeForFixedGrid(availableWidth: CGFloat, availableHeight: CGFloat) {
        // Sabit grid boyutları için optimal cell size hesapla
        let targetCellSizeForWidth = availableWidth * 0.8 / CGFloat(gameWidth) // %80'ini kullan
        let targetCellSizeForHeight = availableHeight * 0.6 / CGFloat(gameHeight) // %60'ını kullan
        
        // İkisinden küçük olanı al
        let targetCellSize = min(targetCellSizeForWidth, targetCellSizeForHeight)
        
        // Pixel perfect için tam sayıya yuvarla ve sınırları koru
        cellSize = round(max(8, min(targetCellSize, 28))) // 8-28 arası
        
        // Çok küçük ekranlar için minimum boyut garantisi
        if cellSize < 10 {
            cellSize = 10
        }
    }
    
    // MARK: - Score Area Y Pozisyonu (Computed - Pixel Perfect)
    private var scoreAreaY: CGFloat {
        // Header bar'ın üstüne sabit bir mesafe ile yerleştir
        let distanceFromHeader = cellSize * 2.0 // Sabit ve yeterli mesafe
        return headerBarStartY + headerBarHeight/2 + distanceFromHeader
    }
    
    // MARK: - Pixel Perfect Hizalama
    private func alignToPixelGrid() {
        // Tüm pozisyonları tam pixel'lere hizala
        gameAreaStartX = round(gameAreaStartX)
        gameAreaStartY = round(gameAreaStartY)
        headerBarStartY = round(headerBarStartY)
        headerBarHeight = round(headerBarHeight)
        cellSize = round(cellSize)
        
        // Oyun alanı boyutlarını yeniden hesapla
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
    }
    
    // MARK: - Header Bar Kurulumu (Pixel Perfect)
    internal func createHeaderBar() {
        createTopScoreElements() // Pause button + skorlar (en üstte)
        createPixelPerfectHeaderBar() // Header bar (skorların altında)
    }
    
    // MARK: - Üst Skor Elemanları (Pause + Skorlar)
    private func createTopScoreElements() {
        createPixelPerfectPauseButton()
        createPixelPerfectScoreLabels()
    }
    
    // MARK: - Pixel Perfect Header Bar (Border ile aynı kalınlık)
    private func createPixelPerfectHeaderBar() {
        let pixelSize = cellSize / 5 // Pixel boyutu
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let headerContainer = SKNode()
        headerContainer.position = CGPoint(x: gameAreaStartX + gameAreaWidth/2, y: headerBarStartY)
        headerContainer.name = "headerBarContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        // Header bar kalınlığı = border kalınlığı
        let headerThickness = cellSize * 0.6 // Border ile aynı
        
        // Header bar'ı pixel bloklar halinde oluştur
        let pixelsWide = Int(round(gameAreaWidth / pixelSize))
        let pixelsHigh = max(1, Int(round(headerThickness / pixelSize))) // En az 1 piksel
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
                pixel.position = CGPoint(
                    x: -gameAreaWidth/2 + CGFloat(col) * pixelSize + pixelSize/2,
                    y: -headerThickness/2 + CGFloat(row) * pixelSize + pixelSize/2
                )
                pixel.zPosition = 1
                headerContainer.addChild(pixel)
            }
        }
        
        // Geriye dönük uyumluluk için ana header bar referansı
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: gameAreaWidth, height: headerThickness))
        headerBar.position = CGPoint(x: gameAreaStartX + gameAreaWidth/2, y: headerBarStartY)
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Pixel Perfect Pause Button (En Üstte Sol)
    internal func createPixelPerfectPauseButton() {
        // Boyutu cell size'a göre pixel perfect yap
        let buttonSize = cellSize * 1.8
        
        pauseButton = SKShapeNode(rect: CGRect(x: -buttonSize/2, y: -buttonSize/2, width: buttonSize, height: buttonSize))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = CGPoint(x: gameAreaStartX + cellSize * 1.5, y: scoreAreaY)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 15
        
        // Pixel Perfect Pause İkonu
        let pixelSize = cellSize / 5
        let pauseIcon = createPixelPerfectPauseIcon(pixelSize: pixelSize)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    // MARK: - Pixel Perfect Pause İkonu
    private func createPixelPerfectPauseIcon(pixelSize: CGFloat) -> SKNode {
        let pauseContainer = SKNode()
        
        // Pause ikonu - Sol ve sağ bloklar (||) - 2x5 her biri
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
        
        // Sol blok
        for pixelPos in leftBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            pauseContainer.addChild(pixel)
        }
        
        // Sağ blok
        for pixelPos in rightBlockPixels {
            let pixel = SKSpriteNode(color: darkerColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            pauseContainer.addChild(pixel)
        }
        
        return pauseContainer
    }
    
    // MARK: - Pixel Perfect Skor Etiketleri (En Üstte Sağ)
    internal func createPixelPerfectScoreLabels() {
        let pixelFont = "Jersey15-Regular"
        
        // Font boyutunu cell size'a göre pixel perfect yap
        let fontSize = cellSize * 1.3 // Cell size'ın %130'u
        
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        
        // Score label (sağ üstte)
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: gameAreaStartX + gameAreaWidth - cellSize, y: scoreAreaY)
        scoreLabel.zPosition = 15
        addChild(scoreLabel)
        
        // High score label (score'un solunda)
        highScoreLabel = SKLabelNode(fontNamed: pixelFont)
        highScoreLabel.text = "HI:\(allTimeHighScore)"
        highScoreLabel.fontSize = fontSize
        highScoreLabel.fontColor = labelColor
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
        
        // High score pozisyonu (pixel perfect spacing)
        let spacing = cellSize * 4
        highScoreLabel.position = CGPoint(x: scoreLabel.position.x - spacing, y: scoreAreaY)
        highScoreLabel.zPosition = 15
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
    
    // MARK: - Oyun Alanı Border (Header ile aynı kalınlık)
    internal func createGameAreaBorder() {
        createPixelPerfectBorder()
    }
    
    // MARK: - Pixel Perfect Border Oluşturma
    private func createPixelPerfectBorder() {
        let pixelSize = cellSize / 5 // Header ile aynı pixel boyutu
        let borderThickness = cellSize * 0.6 // Header ile aynı kalınlık
        
        let borderContainer = SKNode()
        borderContainer.name = "pixelBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        // Üst border
        createPixelPerfectBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY + gameAreaHeight,
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: pixelSize
        )
        
        // Alt border
        createPixelPerfectBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY - borderThickness,
            width: gameAreaWidth + (borderThickness * 2),
            height: borderThickness,
            pixelSize: pixelSize
        )
        
        // Sol border
        createPixelPerfectBorderLine(
            container: borderContainer,
            startX: gameAreaStartX - borderThickness,
            startY: gameAreaStartY,
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: pixelSize
        )
        
        // Sağ border
        createPixelPerfectBorderLine(
            container: borderContainer,
            startX: gameAreaStartX + gameAreaWidth,
            startY: gameAreaStartY,
            width: borderThickness,
            height: gameAreaHeight,
            pixelSize: pixelSize
        )
    }
    
    // MARK: - Pixel Perfect Border Çizgisi
    private func createPixelPerfectBorderLine(container: SKNode, startX: CGFloat, startY: CGFloat, width: CGFloat, height: CGFloat, pixelSize: CGFloat) {
        let pixelsWide = Int(round(width / pixelSize))
        let pixelsHigh = Int(round(height / pixelSize))
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
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
    
    // MARK: - Büyük Kontrol Butonları (Pixel Perfect) - GÜNCELLENMIŞ KONUMLAR
    internal func createControlButtons() {
        // Safe area hesaplama
        let safeAreaInsets = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let screenHeight = UIScreen.main.bounds.height
        let safeHeight = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
        
        // Kontrol alanı boyutları
        let controlAreaHeight = safeHeight * 0.25
        let controlAreaY = safeAreaInsets.bottom + controlAreaHeight / 2 - 15
        
        // Büyük buton boyutları (pixel perfect) - %10 BÜYÜTÜLDÜ
        let buttonSize = cellSize * 5.0 // 4.5'ten 5.0'a çıkarıldı (%11 artış)
        
        let horizontalButtonSize = CGSize(width: buttonSize * 1.3, height: buttonSize)
        let verticalButtonSize = CGSize(width: buttonSize, height: buttonSize * 1.3)
        
        let centerX = frame.midX
        
        // GÜNCELLENMIŞ spacing - Sol/Sağ daha uzak, Yukarı/Aşağı daha yakın
        let verticalSpacing = buttonSize * 0.6   // 1.1'den 0.9'a azaltıldı (yukarı/aşağı yaklaştı)
        let horizontalSpacing = buttonSize * 1.3 // 1.2'den 1.5'e çıkarıldı (sol/sağ uzaklaştı)
        
        // Buton arka plan rengi
        let buttonBackgroundColor = SKColor(red: 136/255, green: 180/255, blue: 1/255, alpha: 1.0)
        
        upButton = createLargePixelPerfectButton(
            direction: .up,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: controlAreaY + verticalSpacing),
            color: buttonBackgroundColor
        )
        addChild(upButton)
        
        downButton = createLargePixelPerfectButton(
            direction: .down,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: controlAreaY - verticalSpacing),
            color: buttonBackgroundColor
        )
        addChild(downButton)
        
        leftButton = createLargePixelPerfectButton(
            direction: .left,
            size: verticalButtonSize,
            position: CGPoint(x: centerX - horizontalSpacing, y: controlAreaY),
            color: buttonBackgroundColor
        )
        addChild(leftButton)
        
        rightButton = createLargePixelPerfectButton(
            direction: .right,
            size: verticalButtonSize,
            position: CGPoint(x: centerX + horizontalSpacing, y: controlAreaY),
            color: buttonBackgroundColor
        )
        addChild(rightButton)
    }
    
    // MARK: - Büyük Pixel Perfect Yön Butonu - DÜZELTİLMİŞ
    internal func createLargePixelPerfectButton(direction: Direction, size: CGSize, position: CGPoint, color: SKColor) -> SKShapeNode {
        let buttonContainer = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        buttonContainer.fillColor = color
        buttonContainer.strokeColor = .clear
        buttonContainer.position = position
        buttonContainer.name = "\(direction)Button"
        buttonContainer.zPosition = 10
        
        // DÜZELTİLDİ: Hit area artık buton boyutuyla AYNI (görsel alan = dokunma alanı)
        let hitArea = SKSpriteNode(color: .clear, size: size) // 1.3 çarpanı kaldırıldı
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 15
        hitArea.name = "\(direction)ButtonHitArea"
        buttonContainer.addChild(hitArea)
        
        // Pixel perfect gölge
        let shadowOffset = cellSize * 0.3
        let shadow = SKShapeNode(rect: CGRect(x: -size.width/2 + shadowOffset, y: -size.height/2 - shadowOffset, width: size.width, height: size.height))
        shadow.fillColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        buttonContainer.addChild(shadow)
        
        // Pixel perfect highlight
        let highlightThickness = cellSize * 0.4
        
        var highlight: SKSpriteNode
        
        switch direction {
        case .up:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - cellSize, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: size.height/2 - highlightThickness/2 - cellSize/2)
        case .down:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: size.width - cellSize, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: -size.height/2 + highlightThickness/2 + cellSize/2)
        case .left:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - cellSize))
            highlight.position = CGPoint(x: -size.width/2 + highlightThickness/2 + cellSize/2, y: 0)
        case .right:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: size.height - cellSize))
            highlight.position = CGPoint(x: size.width/2 - highlightThickness/2 - cellSize/2, y: 0)
        }
        
        highlight.alpha = 0.5
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        let arrowNode = createLargePixelPerfectArrow(direction: direction, buttonSize: size)
        arrowNode.zPosition = 2
        buttonContainer.addChild(arrowNode)
        
        // Pixel perfect inner border
        let innerBorderThickness = cellSize * 0.2
        let innerBorder = SKShapeNode(rect: CGRect(
            x: -size.width/2 + innerBorderThickness,
            y: -size.height/2 + innerBorderThickness,
            width: size.width - innerBorderThickness*2,
            height: size.height - innerBorderThickness*2
        ))
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = primaryColor
        innerBorder.lineWidth = max(2, cellSize * 0.15)
        innerBorder.alpha = 0.6
        innerBorder.zPosition = 1
        buttonContainer.addChild(innerBorder)
        
        return buttonContainer
    }
    
    // MARK: - Büyük Pixel Perfect Ok Oluşturma
    internal func createLargePixelPerfectArrow(direction: Direction, buttonSize: CGSize) -> SKNode {
        let arrowContainer = SKNode()
        
        // Büyük pixel boyutu
        let adjustedPixelSize = cellSize * 0.4
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
    
    // MARK: - Pixel Perfect Çiçek Yemi
    internal func createPixelPerfectFlowerFood() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5 // Pixel boyutu
        
        // Çiçek desenini tanımlayan piksel pozisyonları
        let flowerPixels = [
            CGPoint(x: 0, y: 2),
            CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
            CGPoint(x: 0, y: -2)
        ]
        
        for pixelPos in flowerPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        container.run(pulseRepeat)
        
        return container
    }
    
    // MARK: - Pixel Perfect Yılan Segmenti
    internal func createPixelPerfectSnakeSegment() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5 // Pixel boyutu
        
        // 5x5 tamamen dolu piksel deseni
        let fullBlockPixels = [
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2),
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2)
        ]
        
        for pixelPos in fullBlockPixels {
            let pixel = SKSpriteNode(color: primaryColor,
                                   size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
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
    
    // MARK: - Pixel Perfect Oyun Elementlerini Çizme
    internal func drawGame() {
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
        // Pixel perfect yılan segmentlerini çiz
        for segment in snake.body {
            let segmentNode = createPixelPerfectSnakeSegment()
            segmentNode.position = CGPoint(
                x: gameAreaStartX + CGFloat(Int(segment.x)) * cellSize + cellSize/2,
                y: gameAreaStartY + CGFloat(Int(segment.y)) * cellSize + cellSize/2
            )
            segmentNode.name = "snake"
            segmentNode.zPosition = 5
            addChild(segmentNode)
        }
        
        // Pixel perfect çiçek yemi çiz
        let flowerFoodNode = createPixelPerfectFlowerFood()
        flowerFoodNode.position = CGPoint(
            x: gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2,
            y: gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2
        )
        flowerFoodNode.name = "food"
        flowerFoodNode.zPosition = 5
        addChild(flowerFoodNode)
    }
}
