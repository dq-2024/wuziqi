//
//  GomokuAI.swift
//  Wuziqi
//
//  五子棋 AI 算法
//

import Foundation

class GomokuAI {
    // AI 难度级别
    enum Difficulty {
        case easy
        case medium
        case hard
    }

    private let difficulty: Difficulty
    private let aiPiece: Piece
    private let opponentPiece: Piece

    init(difficulty: Difficulty = .medium, aiPiece: Piece = .white) {
        self.difficulty = difficulty
        self.aiPiece = aiPiece
        self.opponentPiece = aiPiece.opposite
    }

    // 计算最佳落子位置
    func bestMove(for board: GameBoard) -> Position? {
        switch difficulty {
        case .easy:
            return easyMove(for: board)
        case .medium:
            return mediumMove(for: board)
        case .hard:
            return hardMove(for: board)
        }
    }

    // 简单难度：随机选择靠近已有棋子的位置
    private func easyMove(for board: GameBoard) -> Position? {
        if let lastMove = board.lastMove {
            let nearby = board.getNearbyPositions(around: lastMove, distance: 2)
            return nearby.randomElement()
        }
        return board.getEmptyPositions().randomElement()
    }

    // 中等难度：基本防守和进攻
    private func mediumMove(for board: GameBoard) -> Position? {
        // 首先检查是否能一步获胜
        if let winMove = findWinningMove(for: board, piece: aiPiece) {
            return winMove
        }

        // 检查是否需要防守
        if let blockMove = findWinningMove(for: board, piece: opponentPiece) {
            return blockMove
        }

        // 否则选择得分最高的位置
        return findBestScoredMove(for: board)
    }

    // 困难难度：更深的搜索和评估
    private func hardMove(for board: GameBoard) -> Position? {
        // 检查是否能一步获胜
        if let winMove = findWinningMove(for: board, piece: aiPiece) {
            return winMove
        }

        // 检查对手是否能一步获胜，需要防守
        if let blockMove = findWinningMove(for: board, piece: opponentPiece) {
            return blockMove
        }

        // 检查是否能形成双三或双四
        if let multiThreatMove = findMultiThreatMove(for: board) {
            return multiThreatMove
        }

        // 使用评分系统选择最佳位置
        return findBestScoredMove(for: board)
    }

    // 查找可以获胜的位置
    private func findWinningMove(for board: GameBoard, piece: Piece) -> Position? {
        let candidates = getCandidatePositions(for: board)

        for position in candidates {
            // 模拟下棋
            let originalPiece = board.board[position.row][position.col]
            board.board[position.row][position.col] = piece

            // 检查是否形成五连
            let isWin = checkFiveInRow(at: position, for: board, piece: piece)

            // 恢复
            board.board[position.row][position.col] = originalPiece

            if isWin {
                return position
            }
        }

        return nil
    }

    // 查找能形成多重威胁的位置
    private func findMultiThreatMove(for board: GameBoard) -> Position? {
        let candidates = getCandidatePositions(for: board)

        for position in candidates {
            board.board[position.row][position.col] = aiPiece

            let threats = countThreats(at: position, for: board, piece: aiPiece)

            board.board[position.row][position.col] = .empty

            if threats >= 2 {
                return position
            }
        }

        return nil
    }

    // 计算某个位置能形成的威胁数量（活三、活四等）
    private func countThreats(at position: Position, for board: GameBoard, piece: Piece) -> Int {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        var threats = 0

        for (dx, dy) in directions {
            let count = countConsecutive(at: position, direction: (dx, dy), for: board, piece: piece)
            if count >= 3 {
                threats += 1
            }
        }

        return threats
    }

    // 查找得分最高的位置
    private func findBestScoredMove(for board: GameBoard) -> Position? {
        let candidates = getCandidatePositions(for: board)
        var bestScore = Int.min
        var bestMove: Position?

        for position in candidates {
            let score = evaluatePosition(position, for: board)
            if score > bestScore {
                bestScore = score
                bestMove = position
            }
        }

        return bestMove ?? candidates.randomElement()
    }

    // 获取候选位置（已有棋子周围的空位）
    private func getCandidatePositions(for board: GameBoard) -> [Position] {
        var candidates = Set<Position>()

        // 如果棋盘为空，从中心开始
        if board.lastMove == nil {
            return [Position(row: GameBoard.boardSize / 2, col: GameBoard.boardSize / 2)]
        }

        // 获取所有已有棋子周围2格内的空位
        for row in 0..<GameBoard.boardSize {
            for col in 0..<GameBoard.boardSize {
                if board.board[row][col] != .empty {
                    let nearby = board.getNearbyPositions(around: Position(row: row, col: col), distance: 2)
                    candidates.formUnion(nearby)
                }
            }
        }

        return Array(candidates)
    }

    // 评估某个位置的得分
    private func evaluatePosition(_ position: Position, for board: GameBoard) -> Int {
        var score = 0

        // 模拟 AI 下棋
        board.board[position.row][position.col] = aiPiece
        score += evaluateAllDirections(at: position, for: board, piece: aiPiece) * 2
        board.board[position.row][position.col] = .empty

        // 模拟对手下棋（防守分数）
        board.board[position.row][position.col] = opponentPiece
        score += evaluateAllDirections(at: position, for: board, piece: opponentPiece)
        board.board[position.row][position.col] = .empty

        return score
    }

    // 评估所有方向的分数
    private func evaluateAllDirections(at position: Position, for board: GameBoard, piece: Piece) -> Int {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        var totalScore = 0

        for (dx, dy) in directions {
            let count = countConsecutive(at: position, direction: (dx, dy), for: board, piece: piece)
            let openEnds = countOpenEnds(at: position, direction: (dx, dy), for: board, piece: piece)

            totalScore += scorePattern(count: count, openEnds: openEnds)
        }

        return totalScore
    }

    // 根据棋型打分
    private func scorePattern(count: Int, openEnds: Int) -> Int {
        switch (count, openEnds) {
        case (5..., _):
            return 100000  // 五连
        case (4, 2):
            return 10000   // 活四
        case (4, 1):
            return 1000    // 冲四
        case (3, 2):
            return 1000    // 活三
        case (3, 1):
            return 100     // 眠三
        case (2, 2):
            return 100     // 活二
        case (2, 1):
            return 10      // 眠二
        default:
            return 1
        }
    }

    // 检查是否形成五连
    private func checkFiveInRow(at position: Position, for board: GameBoard, piece: Piece) -> Bool {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]

        for (dx, dy) in directions {
            let count = countConsecutive(at: position, direction: (dx, dy), for: board, piece: piece)
            if count >= 5 {
                return true
            }
        }

        return false
    }

    // 计算某个方向上的连续棋子数
    private func countConsecutive(at position: Position, direction: (Int, Int), for board: GameBoard, piece: Piece) -> Int {
        var count = 1

        // 正方向
        var row = position.row + direction.0
        var col = position.col + direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board.board[row][col] == piece {
            count += 1
            row += direction.0
            col += direction.1
        }

        // 反方向
        row = position.row - direction.0
        col = position.col - direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board.board[row][col] == piece {
            count += 1
            row -= direction.0
            col -= direction.1
        }

        return count
    }

    // 计算某个方向上的开口数（0、1或2）
    private func countOpenEnds(at position: Position, direction: (Int, Int), for board: GameBoard, piece: Piece) -> Int {
        var openEnds = 0

        // 正方向
        var row = position.row + direction.0
        var col = position.col + direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board.board[row][col] == piece {
            row += direction.0
            col += direction.1
        }
        if row >= 0 && row < GameBoard.boardSize &&
           col >= 0 && col < GameBoard.boardSize &&
           board.board[row][col] == .empty {
            openEnds += 1
        }

        // 反方向
        row = position.row - direction.0
        col = position.col - direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board.board[row][col] == piece {
            row -= direction.0
            col -= direction.1
        }
        if row >= 0 && row < GameBoard.boardSize &&
           col >= 0 && col < GameBoard.boardSize &&
           board.board[row][col] == .empty {
            openEnds += 1
        }

        return openEnds
    }
}
