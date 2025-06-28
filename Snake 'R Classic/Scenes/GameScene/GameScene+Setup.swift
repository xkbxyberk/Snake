import SpriteKit
import GameplayKit
import UIKit

// MARK: - GameScene Setup Extension - Responsive Layout Architecture (PIXEL PERFECT)
extension GameScene {
    
    // MARK: - iPad Detection Helper
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - Main Layout Orchestrator (Debug Enhanced)
    /// Ana layout hesaplama fonksiyonu - iPhone orjinal, iPad için düzeltme
    internal func calculateGameArea() {
        // Safe area ve ekran boyutlarını al
        let safeAreaInsets = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let screenBounds = UIScreen.main.bounds
        
        // Debug bilgisi
        let deviceType = isIPad ? "iPad" : "iPhone"
        print("🔧 [\(deviceType)] Screen: \(screenBounds.width)x\(screenBounds.height)")
        print("🔧 [\(deviceType)] Safe Area: T:\(safeAreaInsets.top) B:\(safeAreaInsets.bottom) L:\(safeAreaInsets.left) R:\(safeAreaInsets.right)")
        
        // Kullanılabilir ekran alanını hesapla
        let availableWidth = screenBounds.width - safeAreaInsets.left - safeAreaInsets.right
        let availableHeight = screenBounds.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        print("🔧 [\(deviceType)] Available: \(availableWidth)x\(availableHeight)")
        
        // Başlangıç tahmini (orjinal mantık korunuyor)
        calculateDynamicCellSize(availableWidth: availableWidth, availableHeight: availableHeight)
        
        print("🔧 [\(deviceType)] Cell Size: \(cellSize)")
        print("🔧 [\(deviceType)] Game Area: \(gameAreaWidth)x\(gameAreaHeight)")
        
        // Layout bölgelerini hesapla (orjinal mantık + iPad düzeltmeleri)
        let layoutSections = calculateLayoutSections(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            safeAreaInsets: safeAreaInsets
        )
        
        // Her bölümü ayrı ayrı kur (orjinal)
        setupTopBar(in: layoutSections.topBarRect)
        setupHeaderLine(at: layoutSections.headerLinePosition, width: layoutSections.headerLineWidth)
        setupGameArea(in: layoutSections.gameAreaRect)
        setupGameBorders()
        setupControlButtons(in: layoutSections.controlsRect)
        
        // Pixel-perfect hizalama garantisi (orjinal)
        ensurePixelPerfectAlignment()
        
        print("🔧 [\(deviceType)] Final Cell Size: \(cellSize)")
        print("🔧 [\(deviceType)] Final Game Area: \(gameAreaWidth)x\(gameAreaHeight)")
        print("🔧 [\(deviceType)] Game Position: (\(gameAreaStartX), \(gameAreaStartY))")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    // MARK: - Dynamic Cell Size Calculation (ULTIMATE MAXIMUM - Fill The Screen!)
    /// Ekranı maksimum dolduran oyun alanı - sınırları neredeyse kaldırdık!
    private func calculateDynamicCellSize(availableWidth: CGFloat, availableHeight: CGFloat) {
        let deviceType = isIPad ? "iPad" : "iPhone"
        let screenSize = max(availableWidth, availableHeight)
        
        print("🔧 [\(deviceType)] Screen Size: \(screenSize)")
        
        // 🔥 ULTIMATE: Oyun alanını maksimuma çıkarıyoruz!
        let gameAreaPercentage: CGFloat = 0.85  // %70'den %85'e! (Maksimum)
        let gameWidthPercentage: CGFloat = 0.95 // %85'den %95'e! (Neredeyse tüm genişlik)
        
        let estimatedGameHeight = availableHeight * gameAreaPercentage
        let estimatedGameWidth = availableWidth * gameWidthPercentage
        
        print("🔧 [\(deviceType)] Estimated Game: \(estimatedGameWidth)x\(estimatedGameHeight)")
        
        let widthRatio = estimatedGameWidth / CGFloat(gameWidth)
        let heightRatio = estimatedGameHeight / CGFloat(gameHeight)
        
        print("🔧 [\(deviceType)] Ratios: W:\(widthRatio) H:\(heightRatio)")
        
        let preliminarySize = floor(min(widthRatio, heightRatio))
        print("🔧 [\(deviceType)] Preliminary Cell: \(preliminarySize)")
        
        // 🚀 ULTIMATE: Maksimum sınırları ÇILGINLIĞA çıkarıyoruz!
        let minCellSize: CGFloat
        let maxCellSize: CGFloat
        
        if isIPad {
            // iPad: Neredeyse sınırsız!
            minCellSize = 18.0
            
            if screenSize > 1300 {
                maxCellSize = 200.0     // ÇILGIN! (önceden 120)
            } else if screenSize > 1100 {
                maxCellSize = 160.0     // ÇOK ÇILGIN! (önceden 100)
            } else {
                maxCellSize = 120.0     // ÇILGIN! (önceden 80)
            }
        } else {
            // iPhone: Çok çok büyük sınırlar
            minCellSize = 12.0
            
            if screenSize > 950 {
                maxCellSize = 100.0     // ÇILGIN! (önceden 60)
            } else if screenSize > 850 {
                maxCellSize = 80.0      // ÇOK BÜYÜK! (önceden 50)
            } else if screenSize > 750 {
                maxCellSize = 65.0      // BÜYÜK! (önceden 42)
            } else {
                maxCellSize = 50.0      // ORTA! (önceden 35)
            }
        }
        
        print("🔧 [\(deviceType)] Cell Size Range: \(minCellSize) - \(maxCellSize)")
        
        // Pixel-perfect için 3'e bölünebilir yapmaya çalış
        cellSize = floor(preliminarySize / 3.0) * 3.0
        cellSize = max(minCellSize, min(cellSize, maxCellSize))
        
        print("🔧 [\(deviceType)] Calculated Cell Size: \(cellSize)")
        
        // Geçici oyun alanı boyutları
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
        
        print("🔧 [\(deviceType)] Calculated Game Area: \(gameAreaWidth)x\(gameAreaHeight)")
        
        // EKSTRA DEBUG: Oyun alanının ekranın ne kadarını kapladığını göster
        let gameAreaScreenPercentageW = (gameAreaWidth / availableWidth) * 100
        let gameAreaScreenPercentageH = (gameAreaHeight / availableHeight) * 100
        print("🔧 [\(deviceType)] 🔥 ULTIMATE Game Area Usage: W:%.1f%% H:%.1f%% 🔥", gameAreaScreenPercentageW, gameAreaScreenPercentageH)
    }
    
    // MARK: - Layout Sections Structure (Orjinal)
    /// Layout bölümlerini temsil eden yapı
    private struct LayoutSections {
        let topBarRect: CGRect
        let headerLinePosition: CGPoint
        let headerLineWidth: CGFloat
        let gameAreaRect: CGRect
        let controlsRect: CGRect
    }
    
    // MARK: - Layout Hesaplama (Orjinal + iPad Safe Area Fix)
    /// Layout bölümlerini hesapla - iPhone orjinal, iPad için safe area düzeltmesi
    private func calculateLayoutSections(
            availableWidth: CGFloat,
            availableHeight: CGFloat,
            safeAreaInsets: UIEdgeInsets
        ) -> LayoutSections {

            let screenBounds = UIScreen.main.bounds
            let sectionGap: CGFloat = 10.0 // Orjinal değer

            // ADIM 1: Top Bar'ı ekranın en üstüne sabitle (orjinal)
            let topBarHeight = floor(availableHeight * 0.05)
            let topBarY = screenBounds.height - safeAreaInsets.top - topBarHeight
            let topBarRect = CGRect(
                x: safeAreaInsets.left,
                y: topBarY,
                width: availableWidth,
                height: topBarHeight
            )

            // ADIM 2: Ayırıcı çizgiyi (HeaderLine) Top Bar'ın altına sabitle (orjinal)
            let headerLineThickness: CGFloat = 5.0
            let headerLineY = topBarRect.minY - sectionGap - (headerLineThickness / 2)
            let headerLinePosition = CGPoint(x: screenBounds.width / 2, y: headerLineY)

            // ADIM 3: CellSize zaten calculateDynamicCellSize'da hesaplandı - burada DOKUNMA!
            // Bu satırlar önceki hesaplamayı eziyor, bunları kaldırıyoruz
            
            // CellSize artık sabit, sadece pixel-perfect hizalama kontrol et
            cellSize = floor(cellSize / 3.0) * 3.0

            // ADIM 4: Oyun Alanı'nı ayırıcı çizginin altına sabitle (orjinal)
            let finalGameAreaWidth = CGFloat(gameWidth) * cellSize
            let finalGameAreaHeight = CGFloat(gameHeight) * cellSize
            let gameAreaX = floor((screenBounds.width - finalGameAreaWidth) / 2) // Yatayda ortala
            let gameAreaTopY = headerLineY - (headerLineThickness / 2) - sectionGap
            let gameAreaY = gameAreaTopY - finalGameAreaHeight
            let gameAreaRect = CGRect(
                x: gameAreaX,
                y: gameAreaY,
                width: finalGameAreaWidth,
                height: finalGameAreaHeight
            )
            let headerLineWidth = floor(finalGameAreaWidth * 0.98)

            // ADIM 5: Kontrol Butonları - iPad için düzeltme
            let controlsHeight = floor(availableHeight * 0.25) // Orjinal değer
            var controlsY = gameAreaRect.minY - (sectionGap / 2) - controlsHeight // Orjinal hesaplama
            
            // iPad için kontrol alanının ekran altında kalmamasını garanti et
            if isIPad {
                let minControlsY = safeAreaInsets.bottom + 30.0
                controlsY = max(controlsY, minControlsY)
            }
            
            let controlsRect = CGRect(
                x: safeAreaInsets.left,
                y: controlsY,
                width: availableWidth,
                height: controlsHeight
            )

            // ADIM 6: Global değişkenlere ata (orjinal)
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
    
    // MARK: - Section 1: Top Bar Setup (Orjinal)
    /// Top Bar kurulumu (Pause button + skorlar)
    internal func setupTopBar(in rect: CGRect) {
        // Pause button (sol üst) - orjinal
        let pauseButtonSize = floor(cellSize * 1.8)
        let pausePosition = CGPoint(
            x: rect.minX + pauseButtonSize / 2 + 20,
            y: rect.midY
        )
        createPauseButton(at: pausePosition, size: pauseButtonSize)
        
        // Score labels (sağ üst) - orjinal
        let scoreFontSize = floor(cellSize * 1.4)
        let scoreRightMargin = rect.maxX - 20
        
        createScoreLabels(
            rightEdge: scoreRightMargin,
            centerY: rect.midY,
            fontSize: scoreFontSize
        )
    }
    
    /// Pause button oluştur (orjinal)
    private func createPauseButton(at position: CGPoint, size: CGFloat) {
        pauseButton = SKShapeNode(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = position
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 15
        
        // Pixel perfect pause ikonu (orjinal)
        let pauseIcon = createPixelPerfectPauseIcon(size: size)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    /// Pixel perfect pause ikonu (orjinal)
    private func createPixelPerfectPauseIcon(size: CGFloat) -> SKNode {
        let iconContainer = SKNode()
        let pixelSize = floor(size / 8) // İkon boyutuna göre pixel size
        let iconColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Pause ikonu pattern (||) - orjinal
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
    
    /// Score etiketleri oluştur (orjinal)
    private func createScoreLabels(rightEdge: CGFloat, centerY: CGFloat, fontSize: CGFloat) {
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        let pixelFont = "Doto-Black_ExtraBold"
        
        // Ana skor (en sağda) - orjinal
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: rightEdge, y: centerY)
        scoreLabel.zPosition = 15
        addChild(scoreLabel)
        
        // Yüksek skor (solunda) - orjinal
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
    
    // MARK: - Section 2: Header Line Setup (Orjinal)
    /// Header line kurulumu (1 piksel kalınlığında)
    internal func setupHeaderLine(at position: CGPoint, width: CGFloat) {
        // PIXEL PERFECT: 1 piksel kalınlığı için cellSize/3 kullan ve tam sayıya yuvarla (orjinal)
        let pixelSize = round(cellSize / 3.0)
        let headerThickness = pixelSize // 1 piksel kalınlığı
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        // Gap hesaplama - border'lar için daha küçük gap (orjinal)
        let gap = calculateBorderGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let headerContainer = SKNode()
        headerContainer.position = position
        headerContainer.name = "headerLineContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        // 1 piksel kalınlığında çizgi (orjinal)
        let pixelsWide = Int(round(width / pixelSize))
        
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
        
        // Geriye dönük uyumluluk için (orjinal)
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: width, height: headerThickness))
        headerBar.position = position
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Section 3: Game Area Setup (Orjinal)
    /// Oyun alanı kurulumu
    internal func setupGameArea(in rect: CGRect) {
        // Bu metod zaten calculateGameArea tarafından belirlenen değerleri kullanıyor
        // Ek bir işlem gerekmiyor çünkü gameAreaStartX/Y zaten ayarlandı
    }
    
    // MARK: - Game Borders Setup (Orjinal)
    /// Oyun alanı borderleri (1 piksel kalınlığında)
    internal func setupGameBorders() {
        // PIXEL PERFECT: 1 piksel kalınlığı için cellSize/3 kullan ve tam sayıya yuvarla (orjinal)
        let pixelSize = round(cellSize / 3.0)
        let borderThickness = pixelSize // 1 piksel kalınlığı
        let borderColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let borderContainer = SKNode()
        borderContainer.name = "gameBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        // Border segmentleri - sadece oyun alanını çevreleyen (orjinal)
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
    
    /// Border segment yapısı (orjinal)
    private struct BorderSegment {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
    }
    
    /// Border segmenti oluştur (orjinal)
    private func createBorderSegment(
        in container: SKNode,
        segment: BorderSegment,
        pixelSize: CGFloat,
        color: SKColor
    ) {
        // Gap hesaplama - border'lar için daha küçük gap (orjinal)
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
    
    // MARK: - Border Gap Calculation (Orjinal)
    /// Border elementleri için daha küçük gap hesaplama
    private func calculateBorderGap(for pixelSize: CGFloat) -> CGFloat {
        // Border'lar için daha konservatif gap - game elementlerinden daha az (orjinal)
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.5    // Çok küçük ekranlar için minimal gap
        case 4..<7:   gap = 1.0    // Orta ekranlar için 0.5 piksel gap
        case 7..<10:  gap = 1.5    // Büyük ekranlar için 1 piksel gap
        case 10..<15: gap = 2.0    // XL ekranlar için 1.5 piksel gap
        default:      gap = 2.5    // XXL ekranlar için 2 piksel gap
        }
        
        // Gap'in pixelSize'ın %80'ini geçmemesini sağla (border'lar için daha konservatif) (orjinal)
        let maxGap = pixelSize * 0.8
        gap = min(gap, maxGap)
        
        // Gap'i tam sayıya yuvarla (pixel-perfect için) (orjinal)
        return round(gap * 2) / 2 // 0.5'lik adımlarla yuvarla
    }
    
    // MARK: - Section 4: Control Buttons Setup (Orjinal)
    /// Kontrol butonları kurulumu
    internal func setupControlButtons(in rect: CGRect) {
        let buttonSize = floor(cellSize * 5.5) // Pixel perfect button boyutu (orjinal)
        let centerX = rect.midX
        let centerY = rect.midY
        
        // Button spacing hesaplama (orjinal)
        let verticalSpacing = floor(buttonSize * 0.6)
        let horizontalSpacing = floor(buttonSize * 1.3)
        
        // Button boyutları (horizontal vs vertical) (orjinal)
        let horizontalButtonSize = CGSize(width: buttonSize * 1.3, height: buttonSize)
        let verticalButtonSize = CGSize(width: buttonSize, height: buttonSize * 1.3)
        
        let buttonColor = SKColor(red: 136/255, green: 180/255, blue: 1/255, alpha: 1.0)
        
        // Butonları oluştur (orjinal)
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
    
    /// Kontrol butonu oluştur (orjinal)
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
        
        // Hit area (button boyutuyla aynı) (orjinal)
        let hitArea = SKSpriteNode(color: .clear, size: size)
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 15
        hitArea.name = "\(direction)ButtonHitArea"
        buttonContainer.addChild(hitArea)
        
        // Gölge efekti (orjinal)
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
        
        // Highlight efekti (orjinal)
        let highlight = createButtonHighlight(for: direction, buttonSize: size)
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        // Ok işareti (orjinal)
        let arrow = createPixelPerfectArrow(direction: direction, buttonSize: size)
        arrow.zPosition = 2
        buttonContainer.addChild(arrow)
        
        // İç border (orjinal)
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
    
    /// Button highlight oluştur (orjinal)
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
    
    /// Pixel perfect ok işareti oluştur (orjinal)
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
    
    // MARK: - Pixel Perfect Alignment (Enhanced)
    /// Tüm değerlerin kesinlikle pixel-perfect olmasını garanti et
    private func ensurePixelPerfectAlignment() {
        // CellSize'ın 3'e bölünebilir tam sayı olmasını garanti et (ama değeri küçültme!)
        cellSize = floor(cellSize / 3.0) * 3.0
        
        // Minimum değerler - cihaza göre dinamik
        let minCellSize: CGFloat = isIPad ? 15.0 : 9.0
        cellSize = max(minCellSize, cellSize)
        
        // Tüm pozisyonları tam sayılara yuvarla (orjinal)
        gameAreaStartX = round(gameAreaStartX)
        gameAreaStartY = round(gameAreaStartY)
        headerBarStartY = round(headerBarStartY)
        headerBarHeight = round(headerBarHeight)
        
        // Oyun alanı boyutlarını tam cellSize katları olarak yeniden hesapla (orjinal)
        gameAreaWidth = round(CGFloat(gameWidth) * cellSize)
        gameAreaHeight = round(CGFloat(gameHeight) * cellSize)
        
        // Pixel size'ın tam sayı olduğunu garanti et (orjinal)
        let pixelSize = round(cellSize / 3.0)
    }
    
    // MARK: - Game Content Creation (Orjinal)
    /// Oyun içeriği oluşturma (yem, pixel perfect çizim vs.)
    internal func spawnFood() {
        repeat {
            food = CGPoint(
                x: CGFloat(Int.random(in: 0..<gameWidth)),
                y: CGFloat(Int.random(in: 0..<gameHeight))
            )
        } while snake.body.contains(food)
    }
    
    /// Score gösterimini güncelle (orjinal)
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
    
    /// Pixel perfect oyun elemanları çizimi (orjinal)
    internal func drawGame() {
        // Mevcut snake ve food elementlerini temizle (orjinal)
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
        // Snake segmentlerini çiz (orjinal)
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
        
        // Food çiz (orjinal)
        let foodNode = createPixelPerfectFlowerFood()
        foodNode.position = CGPoint(
            x: gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2,
            y: gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2
        )
        foodNode.name = "food"
        foodNode.zPosition = 5
        addChild(foodNode)
    }
    
    /// Pixel perfect snake segmenti (3x3 dolu blok) (orjinal)
    internal func createPixelPerfectSnakeSegment() -> SKNode {
        let container = SKNode()
        // PIXEL PERFECT: 3x3 için cellSize/3 kullan ve tam sayıya yuvarla (orjinal)
        let pixelSize = round(cellSize / 3.0)
        
        // Gap hesaplama - ekran boyutuna göre adaptif (orjinal)
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        // 3x3 dolu blok (9 piksel) (orjinal)
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
    
    /// Pixel perfect artı işareti yemi (3x3'te artı deseni - merkez boş) (orjinal)
    internal func createPixelPerfectFlowerFood() -> SKNode {
        let container = SKNode()
        // PIXEL PERFECT: 3x3 için cellSize/3 kullan ve tam sayıya yuvarla (orjinal)
        let pixelSize = round(cellSize / 3.0)
        
        // Gap hesaplama - ekran boyutuna göre adaptif (orjinal)
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        // Artı (+) deseni (4 piksel: merkez BOŞ, sadece 4 yön) (orjinal)
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
        
        // SEÇENEK 1: Animasyon YOK - En temiz retro görünüm (orjinal)
        return container
    }
    
    // MARK: - Pixel Gap Calculation (Orjinal)
    /// Ekran boyutuna göre optimal gap hesaplama
    private func calculatePixelGap(for pixelSize: CGFloat) -> CGFloat {
        // Adaptif gap hesaplama - pixelSize'a orantılı (orjinal)
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.5    // Çok küçük ekranlar için minimal gap
        case 4..<7:   gap = 1.0    // Orta ekranlar için 1 piksel gap
        case 7..<10:  gap = 1.5    // Büyük ekranlar için 1.5 piksel gap
        case 10..<15: gap = 2.0    // XL ekranlar için 2 piksel gap
        default:      gap = 2.5    // XXL ekranlar için 2.5 piksel gap
        }
        
        // Gap'in pixelSize'ın %85'ini geçmemesini sağla (görsel bozulma önlemi) (orjinal)
        let maxGap = pixelSize * 0.8
        gap = min(gap, maxGap)
        
        // Gap'i tam sayıya yuvarla (pixel-perfect için) (orjinal)
        return round(gap * 2) / 2 // 0.5'lik adımlarla yuvarla
    }
}
