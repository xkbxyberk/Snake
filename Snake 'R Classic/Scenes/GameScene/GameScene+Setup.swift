import SpriteKit
import GameplayKit
import UIKit

// MARK: - GameScene Setup Extension - Responsive Layout Architecture (PIXEL PERFECT)
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
    
    // MARK: - Basitleştirilmiş Dynamic Cell Size Calculation (Pixel Perfect Güncellendi)
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
        let preliminarySize = floor(min(widthRatio, heightRatio))
        
        // Pixel-perfect için 3'e bölünebilir yapmaya çalış
        cellSize = floor(preliminarySize / 3.0) * 3.0
        cellSize = max(9.0, min(cellSize, 30.0)) // 9-30 arası sınırla
        
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
        
        // En küçük oranı al ve KESINLIKLE tam sayıya yuvarla (pixel-perfect için kritik)
        let preliminaryCellSize = min(widthRatio, heightRatio)
        let roundedCellSize = floor(preliminaryCellSize)
        
        // Global cellSize'ı güncelle - bu artık KESİN tam sayı değer
        cellSize = max(9.0, min(roundedCellSize, 30.0)) // Minimum 9 (3'e bölünebilir), maksimum 30
        
        // CellSize'ın 3'e tam bölünebilir olmasını garanti et (pixel-perfect için)
        cellSize = floor(cellSize / 3.0) * 3.0
        
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
        let scoreFontSize = floor(cellSize * 1.2)
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
        let pixelFont = "Doto-Black_ExtraBold"
        
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
    
    // MARK: - Section 2: Header Line Setup (Pixel Perfect + Gap Hesaplama)
    /// Header line kurulumu (1 piksel kalınlığında)
    internal func setupHeaderLine(at position: CGPoint, width: CGFloat) {
        // PIXEL PERFECT: 1 piksel kalınlığı için cellSize/3 kullan ve tam sayıya yuvarla
        let pixelSize = round(cellSize / 3.0)
        let headerThickness = pixelSize // 1 piksel kalınlığı
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Gap hesaplama - border'lar için daha küçük gap
        let gap = calculateBorderGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let headerContainer = SKNode()
        headerContainer.position = position
        headerContainer.name = "headerLineContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        // 1 piksel kalınlığında çizgi
        let pixelsWide = Int(round(width / pixelSize))
        let pixelsHigh = 1 // Sadece 1 piksel yükseklik
        
        for col in 0..<pixelsWide {
            let pixel = SKSpriteNode(
                color: darkerColor,
                size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap)
            )
            pixel.position = CGPoint(
                x: -width/2 + CGFloat(col) * pixelSize + pixelSize/2,
                y: 0 // Merkeze hizala
            )
            headerContainer.addChild(pixel)
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
    
    // MARK: - Game Borders Setup (Pixel Perfect Güncellendi)
    /// Oyun alanı borderleri (1 piksel kalınlığında)
    internal func setupGameBorders() {
        // PIXEL PERFECT: 1 piksel kalınlığı için cellSize/3 kullan ve tam sayıya yuvarla
        let pixelSize = round(cellSize / 3.0)
        let borderThickness = pixelSize // 1 piksel kalınlığı
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
        // Gap hesaplama - border'lar için daha küçük gap
        let gap = calculateBorderGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let pixelsWide = Int(round(segment.width / pixelSize))
        let pixelsHigh = Int(round(segment.height / pixelSize))
        
        for row in 0..<pixelsHigh {
            for col in 0..<pixelsWide {
                let pixel = SKSpriteNode(
                    color: color,
                    size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap)
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
    
    // MARK: - Border Gap Calculation (Daha Konservatif)
    /// Border elementleri için daha küçük gap hesaplama
    private func calculateBorderGap(for pixelSize: CGFloat) -> CGFloat {
        // Border'lar için daha konservatif gap - game elementlerinden daha az
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.3    // Çok küçük ekranlar için minimal gap
        case 4..<7:   gap = 0.5    // Orta ekranlar için 0.5 piksel gap
        case 7..<10:  gap = 1.0    // Büyük ekranlar için 1 piksel gap
        case 10..<15: gap = 1.5    // XL ekranlar için 1.5 piksel gap
        default:      gap = 2.0    // XXL ekranlar için 2 piksel gap
        }
        
        // Gap'in pixelSize'ın %80'ini geçmemesini sağla (border'lar için daha konservatif)
        let maxGap = pixelSize * 0.8
        gap = min(gap, maxGap)
        
        // Gap'i tam sayıya yuvarla (pixel-perfect için)
        return round(gap * 2) / 2 // 0.5'lik adımlarla yuvarla
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
    
    // MARK: - Pixel Perfect Alignment (Güçlendirilmiş)
    /// Tüm değerlerin kesinlikle pixel-perfect olmasını garanti et
    private func ensurePixelPerfectAlignment() {
        // CellSize'ın 3'e bölünebilir tam sayı olmasını garanti et
        cellSize = floor(cellSize / 3.0) * 3.0
        cellSize = max(9.0, cellSize) // Minimum 9 (3x3 = 9)
        
        // Tüm pozisyonları tam sayılara yuvarla
        gameAreaStartX = round(gameAreaStartX)
        gameAreaStartY = round(gameAreaStartY)
        headerBarStartY = round(headerBarStartY)
        headerBarHeight = round(headerBarHeight)
        
        // Oyun alanı boyutlarını tam cellSize katları olarak yeniden hesapla
        gameAreaWidth = round(CGFloat(gameWidth) * cellSize)
        gameAreaHeight = round(CGFloat(gameHeight) * cellSize)
        
        // Pixel size'ın tam sayı olduğunu garanti et
        let pixelSize = round(cellSize / 3.0)
        let gameGap = calculatePixelGap(for: pixelSize)
        let borderGap = calculateBorderGap(for: pixelSize)
    }
    
    // MARK: - Game Content Creation (Pixel Perfect Güncellenmiş)
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
    
    /// Pixel perfect snake segmenti (3x3 dolu blok)
    internal func createPixelPerfectSnakeSegment() -> SKNode {
        let container = SKNode()
        // PIXEL PERFECT: 3x3 için cellSize/3 kullan ve tam sayıya yuvarla
        let pixelSize = round(cellSize / 3.0)
        
        // Gap hesaplama - ekran boyutuna göre adaptif
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        // 3x3 dolu blok (9 piksel)
        let blockPixels = [
            // Üst sıra
            CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
            // Orta sıra
            CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
            // Alt sıra
            CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1)
        ]
        
        for pixelPos in blockPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
    }
    
    /// Pixel perfect artı işareti yemi (3x3'te artı deseni - merkez boş)
    internal func createPixelPerfectFlowerFood() -> SKNode {
        let container = SKNode()
        // PIXEL PERFECT: 3x3 için cellSize/3 kullan ve tam sayıya yuvarla
        let pixelSize = round(cellSize / 3.0)
        
        // Gap hesaplama - ekran boyutuna göre adaptif
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        // Artı (+) deseni (4 piksel: merkez BOŞ, sadece 4 yön)
        let plusPixels = [
            CGPoint(x: 0, y: 1),   // Üst
            CGPoint(x: -1, y: 0),  // Sol
            CGPoint(x: 1, y: 0),   // Sağ
            CGPoint(x: 0, y: -1)   // Alt
            // Merkez (0,0) KASITLI OLARAK BOŞ
        ]
        
        for pixelPos in plusPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap))
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
    
    // MARK: - Pixel Gap Calculation (Adaptive)
    /// Ekran boyutuna göre optimal gap hesaplama
    private func calculatePixelGap(for pixelSize: CGFloat) -> CGFloat {
        // Adaptif gap hesaplama - pixelSize'a orantılı
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.5    // Çok küçük ekranlar için minimal gap
        case 4..<7:   gap = 1.0    // Orta ekranlar için 1 piksel gap
        case 7..<10:  gap = 1.5    // Büyük ekranlar için 1.5 piksel gap
        case 10..<15: gap = 2.0    // XL ekranlar için 2 piksel gap
        default:      gap = 2.5    // XXL ekranlar için 2.5 piksel gap
        }
        
        // Gap'in pixelSize'ın %85'ini geçmemesini sağla (görsel bozulma önlemi)
        let maxGap = pixelSize * 0.85
        gap = min(gap, maxGap)
        
        // Gap'i tam sayıya yuvarla (pixel-perfect için)
        return round(gap * 2) / 2 // 0.5'lik adımlarla yuvarla
    }
}
