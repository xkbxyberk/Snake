import Foundation
import CoreGraphics

// MARK: - Yön Enum
enum Direction {
    case up, down, left, right
}

// MARK: - Snake Sınıfı
class Snake {
    
    // MARK: - Özellikler (Properties)
    var body: [CGPoint] = []
    
    var head: CGPoint {
        return body.first ?? CGPoint.zero
    }
    
    // MARK: - Başlatıcı (Initializer)
    init() {
        body = [
            CGPoint(x: 12, y: 17),
            CGPoint(x: 11, y: 17),
            CGPoint(x: 10, y: 17)
        ]
    }
    
    // MARK: - Hareket Metodu (Movement Method)
    func move(direction: Direction) {
        let currentHead = head
        var newHead = currentHead
        
        switch direction {
        case .up:
            newHead.y += 1
        case .down:
            newHead.y -= 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        
        body.insert(newHead, at: 0)
        
        if !shouldGrow {
            body.removeLast()
        } else {
            shouldGrow = false
        }
    }
    
    // MARK: - Büyüme Mantığı (Growth Logic)
    private var shouldGrow = false
    
    func grow() {
        shouldGrow = true
    }
}
