import SpriteKit
import GameplayKit

extension GameScene {
    
    internal func gameLoop() {
        if isInGracePeriod {
            let currentTime = CACurrentMediaTime()
            if currentTime - gracePeriodStartTime >= gracePeriodDuration {
                if willCollideInDirection(currentDirection) {
                    gameOver()
                    return
                } else {
                    isInGracePeriod = false
                    gracePeriodStartTime = 0
                }
            } else {
                currentDirection = nextDirection
                return
            }
        }
        
        currentDirection = nextDirection
        
        if willCollideInDirection(currentDirection) {
            if !isInGracePeriod {
                isInGracePeriod = true
                gracePeriodStartTime = CACurrentMediaTime()
                return
            }
        }
        
        snake.move(direction: currentDirection)
        
        if snake.head == food {
            eatFood()
        }
        
        drawGame()
    }
    
    internal func willCollideInDirection(_ direction: Direction) -> Bool {
        let head = snake.head
        var nextHead = head
        
        switch direction {
        case .up:
            nextHead.y += 1
        case .down:
            nextHead.y -= 1
        case .left:
            nextHead.x -= 1
        case .right:
            nextHead.x += 1
        }
        
        let willHitWall = nextHead.x < 0 || nextHead.x >= CGFloat(gameWidth) ||
                          nextHead.y < 0 || nextHead.y >= CGFloat(gameHeight)
        
        var willHitTail = false
        for i in 1..<snake.body.count {
            if snake.body[i] == nextHead {
                willHitTail = true
                break
            }
        }
        
        return willHitWall || willHitTail
    }
    
    internal func eatFood() {
        currentGameScore += 10
        score = currentGameScore
        
        updateScoreDisplay()
        
        if currentGameScore > allTimeHighScore && !isNewRecord {
            isNewRecord = true
            createNewRecordEffect()
        }
        
        snake.grow()
        spawnFood()
        
        updateGameSpeedAndGracePeriod()
        
        SoundManager.shared.playSound(named: "eat.wav")
    }
    
    internal func updateGameSpeedAndGracePeriod() {
        let profileIndex = max(0, min(speedSetting - 1, speedProfiles.count - 1))
        let profile = speedProfiles[profileIndex]
        
        var currentPhase = profile.phases.last!
        var newPhaseIndex = profile.phases.count - 1
        
        for (index, phase) in profile.phases.enumerated() {
            if currentGameScore < phase.threshold * 10 {
                currentPhase = phase
                newPhaseIndex = index
                break
            }
        }
        
        if newPhaseIndex > currentPhaseIndex {
            currentPhaseIndex = newPhaseIndex
            
            let speedReduction = currentPhase.speedRate
            currentGameSpeed = max(profile.minSpeed, currentGameSpeed - speedReduction)
            
            let gracePeriodReduction = currentPhase.gracePeriodRate
            gracePeriodDuration = max(profile.minGracePeriod, gracePeriodDuration - gracePeriodReduction)
            
            restartTimer()
        }
    }
    
    internal func restartTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: currentGameSpeed, repeats: true) { _ in
            if !self.isGamePaused {
                self.gameLoop()
            }
        }
    }
    
    internal func playEatSoundEffect() {
        if soundEnabled {
            // AudioService.shared.playEatSound()
        }
    }
    
    internal func startActualGame() {
        isGameRunning = true
        isGamePaused = false
        
        isInGracePeriod = false
        gracePeriodStartTime = 0
        
        currentPhaseIndex = 0
        
        currentGameScore = 0
        score = 0
        updateScoreDisplay()
        
        drawGame()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: currentGameSpeed, repeats: true) { _ in
            if !self.isGamePaused {
                self.gameLoop()
            }
        }
        
        createGameStartEffect()
    }
    
    internal func restartGame() {
        children.filter { node in
            node.name?.contains("gameOver") == true ||
            node.name == "restartButton" ||
            node.name == "menuButton" ||
            node.zPosition >= 100
        }.forEach { $0.removeFromParent() }
        
        isInGracePeriod = false
        gracePeriodStartTime = 0
        
        currentPhaseIndex = 0
        
        currentGameScore = 0
        score = 0
        isNewRecord = false
        playerName = ""
        
        updateScoreDisplay()
        
        applySpeedProfile()
        
        currentDirection = .right
        nextDirection = .right
        
        snake = Snake()
        spawnFood()
        
        startCountdown()
    }
    
    internal func pauseGame() {
        if isCountdownActive {
            return
        }
        
        isGamePaused = true
        createEnhancedPauseMenu()
    }
    
    // MARK: - Güncellenen Resume Game Metodu
    internal func resumeGame() {
        // Önce "Get Ready" efektini göster
        createGetReadyEffect()
        // actuallyResumeGame() metodu Get Ready efekti bittiğinde çağrılacak
    }
    
    internal func gameOver() {
        HapticManager.shared.playContinuousHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.6)
        
        isGameRunning = false
        gameTimer?.invalidate()
        
        isInGracePeriod = false
        gracePeriodStartTime = 0
        
        currentPhaseIndex = 0
        
        createGameOverBackground()
        createGameOverAnimation()
        createNameInputDialog()
        
        SoundManager.shared.playSound(named: "die.wav")
    }
    
    internal func goToMenu() {
        let menuScene = MenuScene()
        menuScene.size = frame.size
        menuScene.scaleMode = .aspectFill
        
        let transition = SKTransition.crossFade(withDuration: 0.8)
        view?.presentScene(menuScene, transition: transition)
    }
}
