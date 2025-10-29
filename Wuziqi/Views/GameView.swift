//
//  GameView.swift
//  Wuziqi
//
//  游戏主界面
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showSettings = false
    @State private var showGameOver = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 游戏信息栏
                gameInfoBar

                // 棋盘
                BoardView(gameBoard: viewModel.gameBoard) { position in
                    viewModel.playerMove(at: position)
                }
                .padding()

                // 控制按钮
                controlButtons
            }
            .navigationTitle("五子棋对战")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .alert("游戏结束", isPresented: $showGameOver) {
                Button("再来一局") {
                    viewModel.startNewGame()
                }
                Button("返回", role: .cancel) {}
            } message: {
                Text(gameOverMessage)
            }
            .onChange(of: viewModel.gameBoard.gameState) { newState in
                if newState != .playing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showGameOver = true
                    }
                }
            }
        }
    }

    // 游戏信息栏
    private var gameInfoBar: some View {
        HStack(spacing: 20) {
            // 当前回合
            VStack(spacing: 4) {
                Text("当前回合")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.gameBoard.currentPlayer == .black ? Color.black : Color.white)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text(viewModel.gameBoard.currentPlayer == .black ? "黑棋" : "白棋")
                        .font(.subheadline)
                        .bold()
                }
            }

            Divider()
                .frame(height: 40)

            // 玩家信息
            VStack(spacing: 4) {
                Text("玩家")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.playerPiece == .black ? Color.black : Color.white)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text(viewModel.playerPiece == .black ? "黑棋" : "白棋")
                        .font(.subheadline)
                }
            }

            Divider()
                .frame(height: 40)

            // 步数
            VStack(spacing: 4) {
                Text("步数")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.moveCount)")
                    .font(.subheadline)
                    .bold()
            }

            if viewModel.isThinking {
                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("AI思考中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // 控制按钮
    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                viewModel.startNewGame()
            }) {
                Label("新游戏", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                viewModel.undoMove()
            }) {
                Label("悔棋", systemImage: "arrow.uturn.backward")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    // 游戏结束消息
    private var gameOverMessage: String {
        switch viewModel.gameBoard.gameState {
        case .won(let winner):
            if winner == viewModel.playerPiece {
                return "恭喜你获得胜利！共用了\(viewModel.moveCount)步"
            } else {
                return "很遗憾，AI获得了胜利！共用了\(viewModel.moveCount)步"
            }
        case .draw:
            return "平局！双方势均力敌"
        case .playing:
            return ""
        }
    }
}

// 设置视图
struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("游戏设置")) {
                    Picker("AI难度", selection: $viewModel.aiDifficulty) {
                        Text("简单").tag(GomokuAI.Difficulty.easy)
                        Text("中等").tag(GomokuAI.Difficulty.medium)
                        Text("困难").tag(GomokuAI.Difficulty.hard)
                    }
                    .onChange(of: viewModel.aiDifficulty) { newValue in
                        viewModel.setDifficulty(newValue)
                    }

                    Picker("执棋颜色", selection: $viewModel.playerPiece) {
                        Text("黑棋（先手）").tag(Piece.black)
                        Text("白棋（后手）").tag(Piece.white)
                    }
                    .onChange(of: viewModel.playerPiece) { newValue in
                        viewModel.setPlayerPiece(newValue)
                    }
                }

                Section(header: Text("统计数据")) {
                    HStack {
                        Text("总场次")
                        Spacer()
                        Text("\(viewModel.statistics.totalGames)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("胜率")
                        Spacer()
                        Text(String(format: "%.1f%%", viewModel.statistics.winRate))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("连胜纪录")
                        Spacer()
                        Text("\(viewModel.statistics.longestWinStreak)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
