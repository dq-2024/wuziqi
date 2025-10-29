//
//  StatisticsView.swift
//  Wuziqi
//
//  个人统计页面
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var statistics = GameStatistics()
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 总览卡片
                    overviewCard

                    // 战绩统计
                    recordCard

                    // 游戏时长
                    timeCard

                    // 最近战绩
                    recentGamesCard

                    // 按难度统计
                    difficultyStatsCard
                }
                .padding()
            }
            .navigationTitle("个人统计")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showResetAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("重置统计", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) {}
                Button("确认重置", role: .destructive) {
                    statistics.resetStatistics()
                }
            } message: {
                Text("确定要重置所有统计数据吗？此操作无法撤销。")
            }
        }
    }

    // 总览卡片
    private var overviewCard: some View {
        VStack(spacing: 16) {
            Text("总览")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatBox(
                    title: "总场次",
                    value: "\(statistics.totalGames)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )

                StatBox(
                    title: "胜率",
                    value: String(format: "%.1f%%", statistics.winRate),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }

            HStack(spacing: 16) {
                StatBox(
                    title: "最长连胜",
                    value: "\(statistics.longestWinStreak)",
                    icon: "flame.fill",
                    color: .orange
                )

                StatBox(
                    title: "当前连胜",
                    value: "\(statistics.currentWinStreak)",
                    icon: "arrow.up.circle.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // 战绩统计卡片
    private var recordCard: some View {
        VStack(spacing: 16) {
            Text("战绩统计")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                VStack {
                    Text("\(statistics.wins)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.green)
                    Text("胜")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.losses)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.red)
                    Text("负")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("\(statistics.draws)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.gray)
                    Text("平")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            // 胜负比例图
            if statistics.totalGames > 0 {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if statistics.wins > 0 {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(statistics.wins) / CGFloat(statistics.totalGames))
                        }

                        if statistics.losses > 0 {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: geometry.size.width * CGFloat(statistics.losses) / CGFloat(statistics.totalGames))
                        }

                        if statistics.draws > 0 {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: geometry.size.width * CGFloat(statistics.draws) / CGFloat(statistics.totalGames))
                        }
                    }
                    .cornerRadius(4)
                }
                .frame(height: 20)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // 游戏时长卡片
    private var timeCard: some View {
        VStack(spacing: 12) {
            Text("游戏时长")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))

                Text(statistics.formatTime(statistics.totalPlayTime))
                    .font(.title2)
                    .bold()

                Spacer()

                if statistics.totalGames > 0 {
                    VStack(alignment: .trailing) {
                        Text("平均时长")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(statistics.formatTime(statistics.totalPlayTime / Double(statistics.totalGames)))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // 最近战绩卡片
    private var recentGamesCard: some View {
        VStack(spacing: 12) {
            Text("最近战绩")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if statistics.records.isEmpty {
                Text("暂无游戏记录")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(statistics.getRecentGames(count: 10)) { record in
                    GameRecordRow(record: record)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // 按难度统计卡片
    private var difficultyStatsCard: some View {
        VStack(spacing: 12) {
            Text("按难度统计")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            let difficultyStats = statistics.getWinRateByDifficulty()

            if difficultyStats.isEmpty {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(["简单", "中等", "困难"], id: \.self) { difficulty in
                    if let winRate = difficultyStats[difficulty] {
                        HStack {
                            Text(difficulty)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "%.1f%%", winRate))
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 统计框组件
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// 游戏记录行组件
struct GameRecordRow: View {
    let record: GameRecord

    var body: some View {
        HStack {
            // 结果图标
            Image(systemName: resultIcon)
                .foregroundColor(resultColor)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.result.rawValue)
                        .font(.subheadline)
                        .bold()
                    Text("vs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(record.aiDifficulty + "AI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(formatDate(record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(record.moves)步")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatDuration(record.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private var resultIcon: String {
        switch record.result {
        case .win: return "checkmark.circle.fill"
        case .lose: return "xmark.circle.fill"
        case .draw: return "minus.circle.fill"
        }
    }

    private var resultColor: Color {
        switch record.result {
        case .win: return .green
        case .lose: return .red
        case .draw: return .gray
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
