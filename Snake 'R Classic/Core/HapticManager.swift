import CoreHaptics
import UIKit

class HapticManager {
    
    // MARK: - Singleton
    
    static let shared = HapticManager()
    
    // MARK: - Properties
    
    private var engine: CHHapticEngine?
    
    // MARK: - Initialization
    
    private init() {
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.stoppedHandler = { reason in
                // Gerekirse burada motor durduğunda yapılacak ek işlemler olabilir.
            }
            
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    // Motor yeniden başlatılamazsa hata yönetimi.
                }
            }
            
        } catch {
            // Motor oluşturulamazsa hata yönetimi.
        }
    }
    
    // MARK: - Engine Lifecycle
    
    func start() {
        do {
            try engine?.start()
        } catch {
            // Motor başlatılamazsa hata yönetimi.
        }
    }
    
    func stop() {
        engine?.stop(completionHandler: { error in
            if let _ = error {
                // Motor durdurulamazsa hata yönetimi.
            }
        })
    }
    
    // MARK: - Haptic Patterns
    
    func playSimpleHaptic(intensity: Float = 0.8, sharpness: Float = 0.5) {
        let hapticEnabledInSettings = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        
        guard hapticEnabledInSettings, let engine = engine else { return }
        
        do {
            try engine.start()
        } catch {
            return
        }
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Desen oynatılamazsa hata yönetimi.
        }
    }
    
    func playContinuousHaptic(intensity: Float, sharpness: Float, duration: TimeInterval) {
        let hapticEnabledInSettings = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        
        guard hapticEnabledInSettings, let engine = engine else { return }
        
        do {
            try engine.start()
        } catch {
            return
        }
        
        let hapticEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Desen oynatılamazsa hata yönetimi.
        }
    }
}
