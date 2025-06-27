import SpriteKit
import GameplayKit
import UIKit

// MARK: - GameScene Setup Extension - Responsive Layout Architecture (DÜZELTILMIŞ)
extension GameScene {
    
    // MARK: - Main Layout Orchestrator (Güncellenmiş)
    /// Ana layout hesaplama fonksiyonu - artık deterministik sıralı yaklaşımla
    internal func calculateGameArea() {
        // Safe area ve ekran boyutlarını al
        let safeAreaInsets = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let screenBounds = UIScreen.main.bounds
        
        // Kullanılabilir ekran alanını hesapla
        let availableWidth = screenBounds.width - safeAreaInsets.left - safeAreaInsets.right
        let availableHeight = screenBounds.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        // Başlangıç tahmini (artık sadece başlangıç için)
        calculateDynamicCellSize(availableWidth: availableWidth, availableHeight: availableHeight)
        
        // YENİ SAĞLAM YAKLAŞIM: Layout bölgelerini hesapla (tersten: alanlar önce, cellSize sonra)
        let layoutSections = calculateLayoutSections(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            safeAreaInsets: safeAreaInsets
        )
        
        // Her bölümü ayrı ayrı kur
        setupTopBar(in: layoutSections.topBarRect)
        setupHeaderLine(at: layoutSections.headerLinePosition, width: layoutSections.headerLineWidth)
        setupGameArea(in: layoutSections.gameAreaRect)
        setupGameBorders()
        setupControlButtons(in: layoutSections.controlsRect)
        
        // Pixel-perfect hizalama garantisi
        ensurePixelPerfectAlignment()
    }
    
    // MARK: - Basitleştirilmiş Dynamic Cell Size Calculation (Güncellendi)
    /// Başlangıç tahmini için cell size hesaplama - gerçek hesaplama calculateLayoutSections'ta
    private func calculateDynamicCellSize(availableWidth: CGFloat, availableHeight: CGFloat) {
        // Bu artık sadece başlangıç tahmini yapıyor
        // Gerçek cellSize calculateLayoutSections içinde NET alan bilgisiyle hesaplanacak
        
        // Geçici tahmin değerleri
        let estimatedGameHeight = availableHeight * 0.55 // %55 oyun alanı tahmini
        let estimatedGameWidth = availableWidth * 0.85   // %85 oyun alanı tahmini
        
        let widthRatio = estimatedGameWidth / CGFloat(gameWidth)
        let heightRatio = estimatedGameHeight / CGFloat(gameHeight)
        
        // Geçici cellSize (calculateLayoutSections override edecek)
        cellSize = floor(min(widthRatio, heightRatio))
        cellSize = max(8.0, min(cellSize, 28.0))
        
        // Geçici oyun alanı boyutları (calculateLayoutSections override edecek)
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
    }
    
    // MARK: - Layout Sections Structure (Aynı)
    /// Layout bölümlerini temsil eden yapı
    private struct LayoutSections {
        let topBarRect: CGRect
        let headerLinePosition: CGPoint
        let headerLineWidth: CGFloat
        let gameAreaRect: CGRect
        let controlsRect: CGRect
    }
    
    // MARK: - YENİ SAĞLAM YAKLAŞIM: Layout Hesaplama (TAMAMEN YENİDEN YAZILDI)
    /// Layout bölümlerini hesapla - Sabit alanlar önce, sonra cellSize
    private func calculateLayoutSections(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        safeAreaInsets: UIEdgeInsets
    ) -> LayoutSections {
        
        let screenBounds = UIScreen.main.bounds
        
        // ADIM 1: Sabit Dikey Alanları Tanımla
        let topBarHeight = floor(availableHeight * 0.05)
        let topBarY = screenBounds.height - safeAreaInsets.top - topBarHeight
        let topBarRect = CGRect(
            x: safeAreaInsets.left,
            y: topBarY,
            width: availableWidth,
            height: topBarHeight
        )
        
        // Controls Area - ekranın %25'i (sabit)
        let controlsHeight = floor(availableHeight * 0.25)
        let controlsY = safeAreaInsets.bottom
        let controlsRect = CGRect(
            x: safeAreaInsets.left,
            y: controlsY,
            width: availableWidth,
            height: controlsHeight
        )
        
        // ADIM 2: Boşlukları ve Ayırıcıları Tanımla (SABİT DEĞERLER)
        let sectionGap: CGFloat = 10.0 // Sabit bölüm arası boşluk
        let headerLineThickness: CGFloat = 5.0 // Sabit HeaderLine kalınlığı
        
        // HeaderLine pozisyonunu TopBar'ın altında, kesin olarak hesapla
        let headerLineY = topBarRect.minY - sectionGap - (headerLineThickness / 2)
        let headerLinePosition = CGPoint(x: screenBounds.width / 2, y: headerLineY)
        
        // ADIM 3: Net Kullanılabilir Oyun Alanı Yüksekliğini Hesapla
        // GameArea'nın üst sınırı: HeaderLine'ın altından başlar
        let gameAreaTopY = headerLineY - (headerLineThickness / 2) - sectionGap
        
        // GameArea'nın alt sınırı: Controls'ın üstünde biter
        let gameAreaBottomY = controlsRect.maxY + sectionGap
        
        // NET kullanılabilir yükseklik - bu kesin değer!
        let netGameAreaHeight = gameAreaTopY - gameAreaBottomY
        
        // ADIM 4: Kesin cellSize ve Oyun Alanı Boyutlarını Hesapla
        // Artık NET alanı biliyoruz, cellSize'ı buna göre hesaplıyoruz
        let availableGameWidth = availableWidth - (sectionGap * 2) // Yan margin'lar için
        
        // 25x35 grid için optimal cell size - NET alana göre
        let widthRatio = availableGameWidth / CGFloat(gameWidth)
        let heightRatio = netGameAreaHeight / CGFloat(gameHeight)
        
        // En küçük oranı al ve pixel-perfect yap
        let finalCellSize = floor(min(widthRatio, heightRatio))
        
        // Global cellSize'ı güncelle - bu artık KESİN değer
        cellSize = max(8.0, min(finalCellSize, 28.0))
        
        // Final game area boyutları
        let finalGameAreaWidth = CGFloat(gameWidth) * cellSize
        let finalGameAreaHeight = CGFloat(gameHeight) * cellSize
        
        // ADIM 5: Final GameArea'yı NET Alan İçinde Konumlandır
        // Yatayda ortala
        let gameAreaX = floor((screenBounds.width - finalGameAreaWidth) / 2)
        
        // Dikeyde NET kullanılabilir alan içinde ortala
        let availableVerticalSpace = netGameAreaHeight
        let verticalCenterOffset = (availableVerticalSpace - finalGameAreaHeight) / 2
        let gameAreaY = gameAreaBottomY + verticalCenterOffset
        
        let gameAreaRect = CGRect(
            x: gameAreaX,
            y: gameAreaY,
            width: finalGameAreaWidth,
            height: finalGameAreaHeight
        )
        
        // HeaderLine genişliği - GameArea'dan bağımsız, daha kısa bir ayırıcı
        let headerLineWidth = floor(finalGameAreaWidth * 0.95)
        
        // Global değişkenleri güncelle
        gameAreaStartX = gameAreaRect.minX
        gameAreaStartY = gameAreaRect.minY
        gameAreaWidth = finalGameAreaWidth
        gameAreaHeight = finalGameAreaHeight
        headerBarStartY = headerLineY
        headerBarHeight = headerLineThickness
        
        return LayoutSections(
            topBarRect: topBarRect,
            headerLinePosition: headerLinePosition,
            headerLineWidth: headerLineWidth,
            gameAreaRect: gameAreaRect,
            controlsRect: controlsRect
        )
    }
    
    // MARK: - Section 1: Top Bar Setup (Aynı)
    /// Top Bar kurulumu (Pause button + skorlar)
    internal func setupTopBar(in rect: CGRect) {
        // Pause button (sol üst)
        let pauseButtonSize = floor(cellSize * 1.8)
        let pausePosition = CGPoint(
            x: rect.minX + pauseButtonSize / 2 + floor(cellSize * 0.5),
            y: rect.midY
        )
        createPauseButton(at: pausePosition, size: pauseButtonSize)
        
        // Score labels (sağ üst)
        let scoreFontSize = floor(cellSize * 1.4)
        let scoreRightMargin = rect.maxX - floor(cellSize * 0.5)
        
        createScoreLabels(
            rightEdge: scoreRightMargin,
            centerY: rect.midY,
            fontSize: scoreFontSize
        )
    }
    
    /// Pause button oluştur
    private func createPauseButton(at position: CGPoint, size: CGFloat) {
        pauseButton = SKShapeNode(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = position
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 15
        
        // Pixel perfect pause ikonu
        let pauseIcon = createPixelPerfectPauseIcon(size: size)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    /// Pixel perfect pause ikonu
    private func createPixelPerfectPauseIcon(size: CGFloat) -> SKNode {
        let iconContainer = SKNode()
        let pixelSize = floor(size / 8) // İkon boyutuna göre pixel size
        let iconColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Pause ikonu pattern (||)
        let leftBarPixels = [
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2),
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0),
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1),
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2)
        ]
        
        let rightBarPixels = [
            CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2),
            CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
            CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),
            CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2)
        ]
        
        for pixelPos in leftBarPixels + rightBarPixels {
            let pixel = SKSpriteNode(color: iconColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            iconContainer.addChild(pixel)
        }
        
        return iconContainer
    }
    
    /// Score etiketleri oluştur
    private func createScoreLabels(rightEdge: CGFloat, centerY: CGFloat, fontSize: CGFloat) {
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        let pixelFont = "Jersey15-Regular"
        
        // Ana skor (en sağda)
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: rightEdge, y: centerY)
        scoreLabel.zPosition = 15
        addChild(scoreLabel)
        
        // Yüksek skor (solunda)
        highScoreLabel = SKLabelNode(fontNamed: pixelFont)
        highScoreLabel.text = "HI:\(allTimeHighScore)"
        highScoreLabel.fontSize = fontSize
        highScoreLabel.fontColor = labelColor
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.position = CGPoint(
            x: rightEdge - floor(cellSize * 4),
            y: centerY
        )
        highScoreLabel.zPosition = 15
        addChild(highScoreLabel)
    }
    
    // MARK: - Section 2: Header Line Setup (Güncellendi)
    /// Header line kurulumu (Bağımsız Divider - Artık asla GameArea'ya dokunmaz)
    internal func setupHeaderLine(at position: CGPoint, width: CGFloat) {
        let pixelSize = floor(cellSize / 5)
        let headerThickness = floor(cellSize * 0.6)
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let headerContainer = SKNode()
        headerContainer.position = position
        headerContainer.name = "headerLineContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        // Bağımsız divider - oyun alanından daha kısa ve tamamen ayrı
        let pixelsWide = Int(floor(width / pixelSize))
        let pixelsHigh = max(1, Int(floor(headerThickness / pixelSize)))
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(
                    color: darkerColor,
                    size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5)
                )
                pixel.position = CGPoint(
                    x: -width/2 + CGFloat(col) * pixelSize + pixelSize/2,
                    y: -headerThickness/2 + CGFloat(row) * pixelSize + pixelSize/2
                )
                headerContainer.addChild(pixel)
            }
        }
        
        // Geriye dönük uyumluluk için
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: width, height: headerThickness))
        headerBar.position = position
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Section 3: Game Area Setup (Aynı)
    /// Oyun alanı kurulumu
    internal func setupGameArea(in rect: CGRect) {
        // Bu metod zaten calculateGameArea tarafından belirlenen değerleri kullanıyor
        // Ek bir işlem gerekmiyor çünkü gameAreaStartX/Y zaten ayarlandı
    }
    
    // MARK: - Game Borders Setup (Aynı)
    /// Oyun alanı borderleri (Header Line'dan tamamen bağımsız)
    internal func setupGameBorders() {
        let pixelSize = floor(cellSize / 5)
        let borderThickness = floor(cellSize * 0.6)
        let borderColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let borderContainer = SKNode()
        borderContainer.name = "gameBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        // Border segmentleri - sadece oyun alanını çevreleyen
        let borderSegments = [
            // Üst border (header line'dan tamamen ayrı)
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY + gameAreaHeight,
                width: gameAreaWidth + (borderThickness * 2),
                height: borderThickness
            ),
            // Alt border
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY - borderThickness,
                width: gameAreaWidth + (borderThickness * 2),
                height: borderThickness
            ),
            // Sol border
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY,
                width: borderThickness,
                height: gameAreaHeight
            ),
            // Sağ border
            BorderSegment(
                x: gameAreaStartX + gameAreaWidth,
                y: gameAreaStartY,
                width: borderThickness,
                height: gameAreaHeight
            )
        ]
        
        for segment in borderSegments {
            createBorderSegment(
                in: borderContainer,
                segment: segment,
                pixelSize: pixelSize,
                color: borderColor
            )
        }
    }
    
    /// Border segment yapısı
    private struct BorderSegment {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
    }
    
    /// Border segmenti oluştur
    private func createBorderSegment(
        in container: SKNode,
        segment: BorderSegment,
        pixelSize: CGFloat,
        color: SKColor
    ) {
        let pixelsWide = Int(floor(segment.width / pixelSize))
        let pixelsHigh = Int(floor(segment.height / pixelSize))
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(
                    color: color,
                    size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5)
                )
                pixel.position = CGPoint(
                    x: segment.x + CGFloat(col) * pixelSize + pixelSize/2,
                    y: segment.y + CGFloat(row) * pixelSize + pixelSize/2
                )
                pixel.zPosition = 1
                container.addChild(pixel)
            }
        }
    }
    
    // MARK: - Section 4: Control Buttons Setup (Aynı)
    /// Kontrol butonları kurulumu
    internal func setupControlButtons(in rect: CGRect) {
        let buttonSize = floor(cellSize * 5.0) // Pixel perfect button boyutu
        let centerX = rect.midX
        let centerY = rect.midY
        
        // Button spacing hesaplama
        let verticalSpacing = floor(buttonSize * 0.6)
        let horizontalSpacing = floor(buttonSize * 1.3)
        
        // Button boyutları (horizontal vs vertical)
        let horizontalButtonSize = CGSize(width: buttonSize * 1.3, height: buttonSize)
        let verticalButtonSize = CGSize(width: buttonSize, height: buttonSize * 1.3)
        
        let buttonColor = SKColor(red: 136/255, green: 180/255, blue: 1/255, alpha: 1.0)
        
        // Butonları oluştur
        upButton = createControlButton(
            direction: .up,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: centerY + verticalSpacing),
            color: buttonColor
        )
        addChild(upButton)
        
        downButton = createControlButton(
            direction: .down,
            size: horizontalButtonSize,
            position: CGPoint(x: centerX, y: centerY - verticalSpacing),
            color: buttonColor
        )
        addChild(downButton)
        
        leftButton = createControlButton(
            direction: .left,
            size: verticalButtonSize,
            position: CGPoint(x: centerX - horizontalSpacing, y: centerY),
            color: buttonColor
        )
        addChild(leftButton)
        
        rightButton = createControlButton(
            direction: .right,
            size: verticalButtonSize,
            position: CGPoint(x: centerX + horizontalSpacing, y: centerY),
            color: buttonColor
        )
        addChild(rightButton)
    }
    
    /// Kontrol butonu oluştur
    private func createControlButton(
        direction: Direction,
        size: CGSize,
        position: CGPoint,
        color: SKColor
    ) -> SKShapeNode {
        
        let buttonContainer = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        buttonContainer.fillColor = color
        buttonContainer.strokeColor = .clear
        buttonContainer.position = position
        buttonContainer.name = "\(direction)Button"
        buttonContainer.zPosition = 10
        
        // Hit area (button boyutuyla aynı)
        let hitArea = SKSpriteNode(color: .clear, size: size)
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 15
        hitArea.name = "\(direction)ButtonHitArea"
        buttonContainer.addChild(hitArea)
        
        // Gölge efekti
        let shadowOffset = floor(cellSize * 0.3)
        let shadow = SKShapeNode(rect: CGRect(
            x: -size.width/2 + shadowOffset,
            y: -size.height/2 - shadowOffset,
            width: size.width,
            height: size.height
        ))
        shadow.fillColor = SKColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        buttonContainer.addChild(shadow)
        
        // Highlight efekti
        let highlight = createButtonHighlight(for: direction, buttonSize: size)
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        // Ok işareti
        let arrow = createPixelPerfectArrow(direction: direction, buttonSize: size)
        arrow.zPosition = 2
        buttonContainer.addChild(arrow)
        
        // İç border
        let innerBorderThickness = floor(cellSize * 0.2)
        let innerBorder = SKShapeNode(rect: CGRect(
            x: -size.width/2 + innerBorderThickness,
            y: -size.height/2 + innerBorderThickness,
            width: size.width - innerBorderThickness*2,
            height: size.height - innerBorderThickness*2
        ))
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = primaryColor
        innerBorder.lineWidth = max(2, floor(cellSize * 0.15))
        innerBorder.alpha = 0.6
        innerBorder.zPosition = 1
        buttonContainer.addChild(innerBorder)
        
        return buttonContainer
    }
    
    /// Button highlight oluştur
    private func createButtonHighlight(for direction: Direction, buttonSize: CGSize) -> SKSpriteNode {
        let highlightThickness = floor(cellSize * 0.4)
        var highlight: SKSpriteNode
        
        switch direction {
        case .up:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: buttonSize.width - cellSize, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: buttonSize.height/2 - highlightThickness/2 - cellSize/2)
        case .down:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: buttonSize.width - cellSize, height: highlightThickness))
            highlight.position = CGPoint(x: 0, y: -buttonSize.height/2 + highlightThickness/2 + cellSize/2)
        case .left:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: buttonSize.height - cellSize))
            highlight.position = CGPoint(x: -buttonSize.width/2 + highlightThickness/2 + cellSize/2, y: 0)
        case .right:
            highlight = SKSpriteNode(color: SKColor.white, size: CGSize(width: highlightThickness, height: buttonSize.height - cellSize))
            highlight.position = CGPoint(x: buttonSize.width/2 - highlightThickness/2 - cellSize/2, y: 0)
        }
        
        highlight.alpha = 0.5
        return highlight
    }
    
    /// Pixel perfect ok işareti oluştur
    private func createPixelPerfectArrow(direction: Direction, buttonSize: CGSize) -> SKNode {
        let arrowContainer = SKNode()
        let pixelSize = floor(cellSize * 0.4)
        let arrowColor = SKColor(red: 68/255, green: 90/255, blue: 0/255, alpha: 1.0)
        
        var arrowPixels: [CGPoint] = []
        
        switch direction {
        case .up:
            arrowPixels = [
                CGPoint(x: 0, y: 2),
                CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: -1, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2)
            ]
        case .down:
            arrowPixels = [
                CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
                CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
                CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
                CGPoint(x: 0, y: -2)
            ]
        case .left:
            arrowPixels = [
                CGPoint(x: -2, y: 0),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: -1), CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1)
            ]
        case .right:
            arrowPixels = [
                CGPoint(x: -2, y: -1), CGPoint(x: -2, y: 0), CGPoint(x: -2, y: 1),
                CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1),
                CGPoint(x: 0, y: -2), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: 0, y: 2),
                CGPoint(x: 1, y: -1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
                CGPoint(x: 2, y: 0)
            ]
        }
        
        for pixelPos in arrowPixels {
            let pixel = SKSpriteNode(color: arrowColor, size: CGSize(width: pixelSize-1, height: pixelSize-1))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            arrowContainer.addChild(pixel)
        }
        
        return arrowContainer
    }
    
    // MARK: - Pixel Perfect Alignment (Aynı)
    /// Tüm değerlerin pixel-perfect olmasını garanti et
    private func ensurePixelPerfectAlignment() {
        // Tüm pozisyonları tam sayılara yuvarla
        gameAreaStartX = round(gameAreaStartX)
        gameAreaStartY = round(gameAreaStartY)
        headerBarStartY = round(headerBarStartY)
        headerBarHeight = round(headerBarHeight)
        cellSize = round(cellSize)
        
        // Oyun alanı boyutlarını yeniden hesapla
        gameAreaWidth = round(CGFloat(gameWidth) * cellSize)
        gameAreaHeight = round(CGFloat(gameHeight) * cellSize)
    }
    
    // MARK: - Game Content Creation (Aynı)
    /// Oyun içeriği oluşturma (yem, pixel perfect çizim vs.)
    internal func spawnFood() {
        repeat {
            food = CGPoint(
                x: CGFloat(Int.random(in: 0..<gameWidth)),
                y: CGFloat(Int.random(in: 0..<gameHeight))
            )
        } while snake.body.contains(food)
    }
    
    /// Score gösterimini güncelle
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
    
    /// Pixel perfect oyun elemanları çizimi
    internal func drawGame() {
        // Mevcut snake ve food elementlerini temizle
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
        // Snake segmentlerini çiz
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
        
        // Food çiz
        let foodNode = createPixelPerfectFlowerFood()
        foodNode.position = CGPoint(
            x: gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2,
            y: gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2
        )
        foodNode.name = "food"
        foodNode.zPosition = 5
        addChild(foodNode)
    }
    
    /// Pixel perfect snake segmenti
    internal func createPixelPerfectSnakeSegment() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5
        
        // 5x5 dolu blok
        let blockPixels = [
            CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2),
            CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: -2, y: -1), CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1), CGPoint(x: 2, y: -1),
            CGPoint(x: -2, y: -2), CGPoint(x: -1, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 1, y: -2), CGPoint(x: 2, y: -2)
        ]
        
        for pixelPos in blockPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
    }
    
    /// Pixel perfect çiçek yemi
    internal func createPixelPerfectFlowerFood() -> SKNode {
        let container = SKNode()
        let pixelSize = cellSize / 5
        
        // Çiçek deseni
        let flowerPixels = [
            CGPoint(x: 0, y: 2),
            CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
            CGPoint(x: -2, y: 0), CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0),
            CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1),
            CGPoint(x: 0, y: -2)
        ]
        
        for pixelPos in flowerPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSize - 0.5, height: pixelSize - 0.5))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        // Animasyon
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseRepeat = SKAction.repeatForever(pulseSequence)
        container.run(pulseRepeat)
        
        return container
    }
}
