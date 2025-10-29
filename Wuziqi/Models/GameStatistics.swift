//
//  GameStatistics.swift
//  Wuziqi
//
//  游戏统计数据模型
//

import Foundation

// 游戏记录
struct GameRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let playerPiece: Piece
    let aiDifficulty: String
    let result: GameResult
    let moves: Int
    let duration: TimeInterval

    enum GameResult: String, Codable {
        case win = "胜利"
        case lose = "失败"
        case draw = "平局"
    }
}

// 游戏统计
class GameStatistics: ObservableObject {
    @Published var records: [GameRecord] = []
    @Published var totalGames: Int = 0
    @Published var wins: Int = 0
    @Published var losses: Int = 0
    @Published var draws: Int = 0
    @Published var winRate: Double = 0.0
    @Published var totalPlayTime: TimeInterval = 0
    @Published var longestWinStreak: Int = 0
    @Published var currentWinStreak: Int = 0

    private let userDefaultsKey = "GameStatistics"
    private let recordsKey = "GameRecords"

    init() {
        loadStatistics()
    }

    // 添加游戏记录
    func addRecord(_ record: GameRecord) {
        records.insert(record, at: 0)
        totalGames += 1
        totalPlayTime += record.duration

        switch record.result {
        case .win:
            wins += 1
            currentWinStreak += 1
            longestWinStreak = max(longestWinStreak, currentWinStreak)
        case .lose:
            losses += 1
            currentWinStreak = 0
        case .draw:
            draws += 1
            currentWinStreak = 0
        }

        calculateWinRate()
        saveStatistics()
    }

    // 计算胜率
    private func calculateWinRate() {
        if totalGames > 0 {
            winRate = Double(wins) / Double(totalGames) * 100
        } else {
            winRate = 0
        }
    }

    // 保存统计数据
    private func saveStatistics() {
        let defaults = UserDefaults.standard

        // 保存基本统计
        defaults.set(totalGames, forKey: "totalGames")
        defaults.set(wins, forKey: "wins")
        defaults.set(losses, forKey: "losses")
        defaults.set(draws, forKey: "draws")
        defaults.set(winRate, forKey: "winRate")
        defaults.set(totalPlayTime, forKey: "totalPlayTime")
        defaults.set(longestWinStreak, forKey: "longestWinStreak")
        defaults.set(currentWinStreak, forKey: "currentWinStreak")

        // 保存游戏记录（最多保存100条）
        let recordsToSave = Array(records.prefix(100))
        if let encoded = try? JSONEncoder().encode(recordsToSave) {
            defaults.set(encoded, forKey: recordsKey)
        }
    }

    // 加载统计数据
    private func loadStatistics() {
        let defaults = UserDefaults.standard

        totalGames = defaults.integer(forKey: "totalGames")
        wins = defaults.integer(forKey: "wins")
        losses = defaults.integer(forKey: "losses")
        draws = defaults.integer(forKey: "draws")
        winRate = defaults.double(forKey: "winRate")
        totalPlayTime = defaults.double(forKey: "totalPlayTime")
        longestWinStreak = defaults.integer(forKey: "longestWinStreak")
        currentWinStreak = defaults.integer(forKey: "currentWinStreak")

        // 加载游戏记录
        if let data = defaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([GameRecord].self, from: data) {
            records = decoded
        }
    }

    // 重置统计数据
    func resetStatistics() {
        records = []
        totalGames = 0
        wins = 0
        losses = 0
        draws = 0
        winRate = 0.0
        totalPlayTime = 0
        longestWinStreak = 0
        currentWinStreak = 0
        saveStatistics()
    }

    // 获取最近N场比赛
    func getRecentGames(count: Int = 10) -> [GameRecord] {
        return Array(records.prefix(count))
    }

    // 获取按难度统计的胜率
    func getWinRateByDifficulty() -> [String: Double] {
        var difficultyStats: [String: (wins: Int, total: Int)] = [:]

        for record in records {
            let difficulty = record.aiDifficulty
            if difficultyStats[difficulty] == nil {
                difficultyStats[difficulty] = (0, 0)
            }

            var stats = difficultyStats[difficulty]!
            stats.total += 1
            if record.result == .win {
                stats.wins += 1
            }
            difficultyStats[difficulty] = stats
        }

        var winRates: [String: Double] = [:]
        for (difficulty, stats) in difficultyStats {
            winRates[difficulty] = stats.total > 0 ? Double(stats.wins) / Double(stats.total) * 100 : 0
        }

        return winRates
    }

    // 格式化时间
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%d小时%d分钟", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d分钟%d秒", minutes, secs)
        } else {
            return String(format: "%d秒", secs)
        }
    }
}
