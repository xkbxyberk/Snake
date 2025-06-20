import Foundation
import AVFoundation

class SoundManager {

    // MARK: - Properties
    
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Belirtilen ses dosyasını çalar.
    /// - Parameter fileName: Projenizdeki ses dosyasının adı (uzantısıyla birlikte, örn: "eat.wav").
    func playSound(named fileName: String) {
        let soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        guard soundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // Hata yönetimi burada yapılabilir.
        }
    }
}
