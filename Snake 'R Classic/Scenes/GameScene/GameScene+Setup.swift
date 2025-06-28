import SpriteKit
import GameplayKit
import UIKit

// MARK: - Responsive Layout Architecture
extension GameScene {
    
    // MARK: - Device Detection
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - Main Layout Calculator
    internal func calculateGameArea() {
        let safeAreaInsets = view?.safeAreaInsets ?? UIEdgeInsets.zero
        let screenBounds = UIScreen.main.bounds
        
        let availableWidth = screenBounds.width - safeAreaInsets.left - safeAreaInsets.right
        let availableHeight = screenBounds.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        calculateDynamicCellSize(availableWidth: availableWidth, availableHeight: availableHeight)
        
        let layoutSections = calculateLayoutSections(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            safeAreaInsets: safeAreaInsets
        )
        
        setupTopBar(in: layoutSections.topBarRect)
        setupHeaderLine(at: layoutSections.headerLinePosition, width: layoutSections.headerLineWidth)
        setupGameArea(in: layoutSections.gameAreaRect)
        setupGameBorders()
        setupControlButtons(in: layoutSections.controlsRect)
        
        ensurePixelPerfectAlignment()
    }
    
    // MARK: - Dynamic Cell Size Calculator
    private func calculateDynamicCellSize(availableWidth: CGFloat, availableHeight: CGFloat) {
        let screenSize = max(availableWidth, availableHeight)
        
        let gameAreaPercentage: CGFloat
        let gameWidthPercentage: CGFloat
        
        if isIPad {
            gameAreaPercentage = 0.72
            gameWidthPercentage = 0.90
        } else {
            gameAreaPercentage = 0.85
            gameWidthPercentage = 0.95
        }
        
        let estimatedGameHeight = availableHeight * gameAreaPercentage
        let estimatedGameWidth = availableWidth * gameWidthPercentage
        
        let widthRatio = estimatedGameWidth / CGFloat(gameWidth)
        let heightRatio = estimatedGameHeight / CGFloat(gameHeight)
        
        let preliminarySize = floor(min(widthRatio, heightRatio))
        
        let minCellSize: CGFloat
        let maxCellSize: CGFloat
        
        if isIPad {
            minCellSize = 18.0
            
            if screenSize > 1300 {
                maxCellSize = 200.0
            } else if screenSize > 1100 {
                maxCellSize = 160.0
            } else {
                maxCellSize = 120.0
            }
        } else {
            minCellSize = 12.0
            
            if screenSize > 950 {
                maxCellSize = 100.0
            } else if screenSize > 850 {
                maxCellSize = 80.0
            } else if screenSize > 750 {
                maxCellSize = 65.0
            } else {
                maxCellSize = 50.0
            }
        }
        
        cellSize = floor(preliminarySize / 3.0) * 3.0
        cellSize = max(minCellSize, min(cellSize, maxCellSize))
        
        gameAreaWidth = CGFloat(gameWidth) * cellSize
        gameAreaHeight = CGFloat(gameHeight) * cellSize
    }
    
    // MARK: - Layout Sections Structure
    private struct LayoutSections {
        let topBarRect: CGRect
        let headerLinePosition: CGPoint
        let headerLineWidth: CGFloat
        let gameAreaRect: CGRect
        let controlsRect: CGRect
    }
    
    // MARK: - Layout Sections Calculator
    private func calculateLayoutSections(
            availableWidth: CGFloat,
            availableHeight: CGFloat,
            safeAreaInsets: UIEdgeInsets
        ) -> LayoutSections {

            let screenBounds = UIScreen.main.bounds
            let sectionGap: CGFloat = 10.0

            let topBarHeight = floor(availableHeight * 0.05)
            let topBarY = screenBounds.height - safeAreaInsets.top - topBarHeight
            let topBarRect = CGRect(
                x: safeAreaInsets.left,
                y: topBarY,
                width: availableWidth,
                height: topBarHeight
            )

            let headerLineThickness: CGFloat = 5.0
            let headerLineY = topBarRect.minY - sectionGap - (headerLineThickness / 2)
            let headerLinePosition = CGPoint(x: screenBounds.width / 2, y: headerLineY)
            
            cellSize = floor(cellSize / 3.0) * 3.0

            let finalGameAreaWidth = CGFloat(gameWidth) * cellSize
            let finalGameAreaHeight = CGFloat(gameHeight) * cellSize
            let gameAreaX = floor((screenBounds.width - finalGameAreaWidth) / 2)
            let gameAreaTopY = headerLineY - (headerLineThickness / 2) - sectionGap
            let gameAreaY = gameAreaTopY - finalGameAreaHeight
            let gameAreaRect = CGRect(
                x: gameAreaX,
                y: gameAreaY,
                width: finalGameAreaWidth,
                height: finalGameAreaHeight
            )
            let headerLineWidth = floor(finalGameAreaWidth * 0.98)

            let controlsHeight = floor(availableHeight * 0.25)
            var controlsY = gameAreaRect.minY - (sectionGap / 2) - controlsHeight
            
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
    
    // MARK: - Top Bar Setup
    internal func setupTopBar(in rect: CGRect) {
        let pauseButtonSize = floor(cellSize * 1.8)
        let pausePosition = CGPoint(
            x: rect.minX + pauseButtonSize / 2 + 20,
            y: rect.midY
        )
        createPauseButton(at: pausePosition, size: pauseButtonSize)
        
        let scoreFontSize = floor(cellSize * 1.4)
        let scoreRightMargin = rect.maxX - 20
        
        createScoreLabels(
            rightEdge: scoreRightMargin,
            centerY: rect.midY,
            fontSize: scoreFontSize
        )
    }
    
    private func createPauseButton(at position: CGPoint, size: CGFloat) {
        pauseButton = SKShapeNode(rect: CGRect(x: -size/2, y: -size/2, width: size, height: size))
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.position = position
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 15
        
        let pauseIcon = createPixelPerfectPauseIcon(size: size)
        pauseIcon.position = CGPoint.zero
        pauseButton.addChild(pauseIcon)
        
        addChild(pauseButton)
    }
    
    private func createPixelPerfectPauseIcon(size: CGFloat) -> SKNode {
        let iconContainer = SKNode()
        let pixelSize = floor(size / 8)
        let iconColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
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
    
    private func createScoreLabels(rightEdge: CGFloat, centerY: CGFloat, fontSize: CGFloat) {
        let labelColor = SKColor(red: 51/255, green: 67/255, blue: 0/255, alpha: 1.0)
        let pixelFont = "Doto-Black_ExtraBold"
        
        scoreLabel = SKLabelNode(fontNamed: pixelFont)
        scoreLabel.text = "0"
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = labelColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: rightEdge, y: centerY)
        scoreLabel.zPosition = 15
        addChild(scoreLabel)
        
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
    
    // MARK: - Header Line Setup
    internal func setupHeaderLine(at position: CGPoint, width: CGFloat) {
        let pixelSize = round(cellSize / 3.0)
        let headerThickness = pixelSize
        let darkerColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let gap = calculateBorderGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let headerContainer = SKNode()
        headerContainer.position = position
        headerContainer.name = "headerLineContainer"
        headerContainer.zPosition = 5
        addChild(headerContainer)
        
        let pixelsWide = Int(round(width / pixelSize))
        
        for col in 0..<pixelsWide {
            let pixel = SKSpriteNode(
                color: darkerColor,
                size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap)
            )
            pixel.position = CGPoint(
                x: -width/2 + CGFloat(col) * pixelSize + pixelSize/2,
                y: 0
            )
            headerContainer.addChild(pixel)
        }
        
        headerBar = SKSpriteNode(color: .clear, size: CGSize(width: width, height: headerThickness))
        headerBar.position = position
        headerBar.zPosition = 0
        addChild(headerBar)
    }
    
    // MARK: - Game Area Setup
    internal func setupGameArea(in rect: CGRect) {
    }
    
    // MARK: - Game Borders Setup
    internal func setupGameBorders() {
        let pixelSize = round(cellSize / 3.0)
        let borderThickness = pixelSize
        let borderColor = SKColor(red: 0/255, green: 6/255, blue: 0/255, alpha: 1.0)
        
        let borderContainer = SKNode()
        borderContainer.name = "gameBorderContainer"
        borderContainer.zPosition = 8
        addChild(borderContainer)
        
        let borderSegments = [
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY + gameAreaHeight,
                width: gameAreaWidth + (borderThickness * 2),
                height: borderThickness
            ),
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY - borderThickness,
                width: gameAreaWidth + (borderThickness * 2),
                height: borderThickness
            ),
            BorderSegment(
                x: gameAreaStartX - borderThickness,
                y: gameAreaStartY,
                width: borderThickness,
                height: gameAreaHeight
            ),
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
    
    private struct BorderSegment {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
    }
    
    private func createBorderSegment(
        in container: SKNode,
        segment: BorderSegment,
        pixelSize: CGFloat,
        color: SKColor
    ) {
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
    
    // MARK: - Border Gap Calculator
    private func calculateBorderGap(for pixelSize: CGFloat) -> CGFloat {
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.5
        case 4..<7:   gap = 1.0
        case 7..<10:  gap = 1.5
        case 10..<15: gap = 2.0
        default:      gap = 2.5
        }
        
        let maxGap = pixelSize * 0.8
        gap = min(gap, maxGap)
        
        return round(gap * 2) / 2
    }
    
    // MARK: - Control Buttons Setup
    internal func setupControlButtons(in rect: CGRect) {
        let screenBounds = UIScreen.main.bounds
        
        let isIPhone16Pro = (screenBounds.width == 402.0 && screenBounds.height == 874.0) ||
                            (screenBounds.width == 874.0 && screenBounds.height == 402.0)
        
        let isIPad13Inch = (screenBounds.width == 1032.0 && screenBounds.height == 1376.0) ||
                           (screenBounds.width == 1376.0 && screenBounds.height == 1032.0)
        
        let isIPad11Inch = (screenBounds.width == 834.0 && screenBounds.height == 1210.0) ||
                           (screenBounds.width == 1210.0 && screenBounds.height == 834.0)
        
        let isIPadAir5th = (screenBounds.width == 820.0 && screenBounds.height == 1180.0) ||
                           (screenBounds.width == 1180.0 && screenBounds.height == 820.0)
        
        let needsSpecialHandling = isIPhone16Pro || isIPad13Inch || isIPad11Inch || isIPadAir5th
        
        let buttonSizeFactor: CGFloat = needsSpecialHandling ? 0.75 : 1.0
        
        let buttonSize = floor(cellSize * 5.5 * buttonSizeFactor)
        let centerX = rect.midX
        
        var centerY: CGFloat
        if needsSpecialHandling {
            let offset: CGFloat = isIPhone16Pro ? 30 : 60
            centerY = gameAreaStartY - offset - buttonSize * 0.8
        } else {
            centerY = rect.midY
        }
        
        let verticalSpacing = floor(buttonSize * 0.6)
        let horizontalSpacing = floor(buttonSize * 1.3)
        
        let horizontalButtonSize = CGSize(width: buttonSize * 1.3, height: buttonSize)
        let verticalButtonSize = CGSize(width: buttonSize, height: buttonSize * 1.3)
        
        let buttonColor = SKColor(red: 136/255, green: 180/255, blue: 1/255, alpha: 1.0)
        
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
        
        let hitArea = SKSpriteNode(color: .clear, size: size)
        hitArea.position = CGPoint.zero
        hitArea.zPosition = 15
        hitArea.name = "\(direction)ButtonHitArea"
        buttonContainer.addChild(hitArea)
        
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
        
        let highlight = createButtonHighlight(for: direction, buttonSize: size)
        highlight.zPosition = 1
        buttonContainer.addChild(highlight)
        
        let arrow = createPixelPerfectArrow(direction: direction, buttonSize: size)
        arrow.zPosition = 2
        buttonContainer.addChild(arrow)
        
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
    
    // MARK: - Pixel Perfect Alignment
    private func ensurePixelPerfectAlignment() {
        cellSize = floor(cellSize / 3.0) * 3.0
        
        let minCellSize: CGFloat = isIPad ? 15.0 : 9.0
        cellSize = max(minCellSize, cellSize)
        
        gameAreaStartX = round(gameAreaStartX)
        gameAreaStartY = round(gameAreaStartY)
        headerBarStartY = round(headerBarStartY)
        headerBarHeight = round(headerBarHeight)
        
        gameAreaWidth = round(CGFloat(gameWidth) * cellSize)
        gameAreaHeight = round(CGFloat(gameHeight) * cellSize)
    }
    
    // MARK: - Game Content Creation
    internal func spawnFood() {
        repeat {
            food = CGPoint(
                x: CGFloat(Int.random(in: 0..<gameWidth)),
                y: CGFloat(Int.random(in: 0..<gameHeight))
            )
        } while snake.body.contains(food)
    }
    
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
    
    internal func drawGame() {
        children.forEach { node in
            if node.name == "snake" || node.name == "food" {
                node.removeFromParent()
            }
        }
        
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
        
        let foodNode = createPixelPerfectFlowerFood()
        foodNode.position = CGPoint(
            x: gameAreaStartX + CGFloat(Int(food.x)) * cellSize + cellSize/2,
            y: gameAreaStartY + CGFloat(Int(food.y)) * cellSize + cellSize/2
        )
        foodNode.name = "food"
        foodNode.zPosition = 5
        addChild(foodNode)
    }
    
    internal func createPixelPerfectSnakeSegment() -> SKNode {
        let container = SKNode()
        let pixelSize = round(cellSize / 3.0)
        
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let blockPixels = [
            CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1),
            CGPoint(x: -1, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0),
            CGPoint(x: -1, y: -1), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1)
        ]
        
        for pixelPos in blockPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
    }
    
    internal func createPixelPerfectFlowerFood() -> SKNode {
        let container = SKNode()
        let pixelSize = round(cellSize / 3.0)
        
        let gap = calculatePixelGap(for: pixelSize)
        let pixelSizeWithGap = pixelSize - gap
        
        let plusPixels = [
            CGPoint(x: 0, y: 1),
            CGPoint(x: -1, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 0, y: -1)
        ]
        
        for pixelPos in plusPixels {
            let pixel = SKSpriteNode(color: primaryColor, size: CGSize(width: pixelSizeWithGap, height: pixelSizeWithGap))
            pixel.position = CGPoint(x: pixelPos.x * pixelSize, y: pixelPos.y * pixelSize)
            container.addChild(pixel)
        }
        
        return container
    }
    
    // MARK: - Pixel Gap Calculator
    private func calculatePixelGap(for pixelSize: CGFloat) -> CGFloat {
        var gap: CGFloat
        
        switch pixelSize {
        case 0..<4:   gap = 0.5
        case 4..<7:   gap = 1.0
        case 7..<10:  gap = 1.5
        case 10..<15: gap = 2.0
        default:      gap = 2.5
        }
        
        let maxGap = pixelSize * 0.8
        gap = min(gap, maxGap)
        
        return round(gap * 2) / 2
    }
}
