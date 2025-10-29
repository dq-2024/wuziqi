//
//  GameViewModel.swift
//  Wuziqi
//
//  游戏视图模型
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var gameBoard = GameBoard()
    @Published var isPlayerTurn = true
    @Published var aiDifficulty: GomokuAI.Difficulty = .medium
    @Published var playerPiece: Piece = .black
    @Published var gameStartTime: Date?
    @Published var moveCount = 0
    @Published var isThinking = false

    private var ai: GomokuAI
    var statistics = GameStatistics()

    init() {
        self.ai = GomokuAI(difficulty: aiDifficulty, aiPiece: playerPiece.opposite)
    }

    // 开始新游戏
    func startNewGame() {
        gameBoard.reset()
        isPlayerTurn = (playerPiece == .black)
        gameStartTime = Date()
        moveCount = 0
        ai = GomokuAI(difficulty: aiDifficulty, aiPiece: playerPiece.opposite)

        // 如果玩家选择白棋，AI先手
        if !isPlayerTurn {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.aiMove()
            }
        }
    }

    // 玩家落子
    func playerMove(at position: Position) {
        guard isPlayerTurn && !isThinking else { return }

        if gameBoard.placePiece(at: position) {
            moveCount += 1
            isPlayerTurn = false

            // 检查游戏是否结束
            if case .won(let winner) = gameBoard.gameState {
                handleGameEnd(winner: winner)
                return
            }

            if case .draw = gameBoard.gameState {
                handleGameEnd(winner: nil)
                return
            }

            // AI 回合
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.aiMove()
            }
        }
    }

    // AI 落子
    private func aiMove() {
        isThinking = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            if let move = self.ai.bestMove(for: self.gameBoard) {
                DispatchQueue.main.async {
                    if self.gameBoard.placePiece(at: move) {
                        self.moveCount += 1
                        self.isThinking = false

                        // 检查游戏是否结束
                        if case .won(let winner) = self.gameBoard.gameState {
                            self.handleGameEnd(winner: winner)
                            return
                        }

                        if case .draw = self.gameBoard.gameState {
                            self.handleGameEnd(winner: nil)
                            return
                        }

                        self.isPlayerTurn = true
                    }
                }
            }
        }
    }

    // 处理游戏结束
    private func handleGameEnd(winner: Piece?) {
        guard let startTime = gameStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)
        let result: GameRecord.GameResult

        if let winner = winner {
            result = (winner == playerPiece) ? .win : .lose
        } else {
            result = .draw
        }

        let record = GameRecord(
            id: UUID(),
            date: Date(),
            playerPiece: playerPiece,
            aiDifficulty: difficultyString(aiDifficulty),
            result: result,
            moves: moveCount,
            duration: duration
        )

        statistics.addRecord(record)
    }

    // 难度转字符串
    private func difficultyString(_ difficulty: GomokuAI.Difficulty) -> String {
        switch difficulty {
        case .easy: return "简单"
        case .medium: return "中等"
        case .hard: return "困难"
        }
    }

    // 设置难度
    func setDifficulty(_ difficulty: GomokuAI.Difficulty) {
        aiDifficulty = difficulty
        ai = GomokuAI(difficulty: difficulty, aiPiece: playerPiece.opposite)
    }

    // 设置玩家棋子颜色
    func setPlayerPiece(_ piece: Piece) {
        playerPiece = piece
        ai = GomokuAI(difficulty: aiDifficulty, aiPiece: piece.opposite)
    }

    // 悔棋（撤销最近两步）
    func undoMove() {
        // 简单实现：重新开始游戏
        // 完整实现需要保存历史状态
        startNewGame()
    }
}
