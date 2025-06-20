import Foundation

class ScoreManager {
    static let shared = ScoreManager()
    
    private let allTimeHighScoreKey = "AllTimeHighScore"
    private let allScoresKey = "AllGameScoresWithNames"
    private let maxStoredScores = 50
    
    private init() {}
    
    struct ScoreEntry: Codable {
        let playerName: String
        let score: Int
        let speedProfile: Int
        let date: Date
        
        init(playerName: String, score: Int, speedProfile: Int) {
            self.playerName = playerName
            self.score = score
            self.speedProfile = speedProfile
            self.date = Date()
        }
    }
    
    func getAllTimeHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: allTimeHighScoreKey)
    }
    
    func saveAllTimeHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: allTimeHighScoreKey)
    }
    
    func saveScore(_ score: Int, playerName: String, speedProfile: Int) {
        var allScores = getAllScoreEntries()
        let newEntry = ScoreEntry(playerName: playerName, score: score, speedProfile: speedProfile)
        allScores.append(newEntry)
        
        if allScores.count > maxStoredScores {
            allScores = Array(allScores.suffix(maxStoredScores))
        }
        
        if let encoded = try? JSONEncoder().encode(allScores) {
            UserDefaults.standard.set(encoded, forKey: allScoresKey)
        }
        
        updateLeaderboard(allScores)
    }
    
    func getAllScoreEntries() -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: allScoresKey),
              let entries = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func getTopScoreEntries(limit: Int = 10) -> [ScoreEntry] {
        let allEntries = getAllScoreEntries()
        let sortedEntries = allEntries.sorted { $0.score > $1.score }
        return Array(sortedEntries.prefix(limit))
    }
    
    func getTopScoreEntriesForSpeedProfile(_ speedProfile: Int, limit: Int = 10) -> [ScoreEntry] {
        let allEntries = getAllScoreEntries()
        let filteredEntries = allEntries.filter { $0.speedProfile == speedProfile }
        let sortedEntries = filteredEntries.sorted { $0.score > $1.score }
        return Array(sortedEntries.prefix(limit))
    }
    
    func getAllScores() -> [Int] {
        return getAllScoreEntries().map { $0.score }
    }
    
    private func updateLeaderboard(_ allEntries: [ScoreEntry]) {
        let topEntries = Array(allEntries.sorted { $0.score > $1.score }.prefix(10))
        
        let leaderboardData = topEntries.map { ["name": $0.playerName, "score": $0.score] }
        UserDefaults.standard.set(leaderboardData, forKey: "TopScoresWithNames")
        
        let topScoresOnly = topEntries.map { $0.score }
        UserDefaults.standard.set(topScoresOnly, forKey: "TopScores")
    }
    
    func getAverageScore() -> Double {
        let scores = getAllScores()
        guard !scores.isEmpty else { return 0.0 }
        let sum = scores.reduce(0, +)
        return Double(sum) / Double(scores.count)
    }
    
    func getTotalGamesPlayed() -> Int {
        return getAllScoreEntries().count
    }
    
    func getTotalGamesPlayedForSpeedProfile(_ speedProfile: Int) -> Int {
        return getAllScoreEntries().filter { $0.speedProfile == speedProfile }.count
    }
    
    func clearAllScores() {
        UserDefaults.standard.removeObject(forKey: allScoresKey)
        UserDefaults.standard.removeObject(forKey: allTimeHighScoreKey)
        UserDefaults.standard.removeObject(forKey: "TopScores")
        UserDefaults.standard.removeObject(forKey: "TopScoresWithNames")
    }
}
