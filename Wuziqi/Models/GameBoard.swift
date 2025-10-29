//
//  GameBoard.swift
//  Wuziqi
//
//  五子棋游戏棋盘模型
//

import Foundation

// 棋子类型
enum Piece: Int, Codable {
    case empty = 0
    case black = 1
    case white = 2

    var opposite: Piece {
        switch self {
        case .black: return .white
        case .white: return .black
        case .empty: return .empty
        }
    }
}

// 游戏状态
enum GameState: Equatable {
    case playing
    case won(Piece)
    case draw
}

// 棋盘位置
struct Position: Hashable, Codable {
    let row: Int
    let col: Int
}

// 游戏棋盘
class GameBoard: ObservableObject {
    static let boardSize = 15

    @Published var board: [[Piece]]
    @Published var gameState: GameState = .playing
    @Published var currentPlayer: Piece = .black
    @Published var lastMove: Position?
    @Published var winningLine: [Position] = []

    init() {
        board = Array(repeating: Array(repeating: Piece.empty, count: GameBoard.boardSize),
                     count: GameBoard.boardSize)
    }

    // 重置游戏
    func reset() {
        board = Array(repeating: Array(repeating: Piece.empty, count: GameBoard.boardSize),
                     count: GameBoard.boardSize)
        gameState = .playing
        currentPlayer = .black
        lastMove = nil
        winningLine = []
    }

    // 下棋
    func placePiece(at position: Position) -> Bool {
        guard isValidMove(at: position) else { return false }

        board[position.row][position.col] = currentPlayer
        lastMove = position

        if checkWin(at: position) {
            gameState = .won(currentPlayer)
            return true
        }

        if isBoardFull() {
            gameState = .draw
            return true
        }

        currentPlayer = currentPlayer.opposite
        return true
    }

    // 检查是否是有效落子
    func isValidMove(at position: Position) -> Bool {
        guard position.row >= 0 && position.row < GameBoard.boardSize &&
              position.col >= 0 && position.col < GameBoard.boardSize else {
            return false
        }
        return board[position.row][position.col] == .empty && gameState == .playing
    }

    // 检查是否获胜
    private func checkWin(at position: Position) -> Bool {
        let directions = [
            (0, 1),   // 水平
            (1, 0),   // 垂直
            (1, 1),   // 对角线 \
            (1, -1)   // 对角线 /
        ]

        for (dx, dy) in directions {
            let line = countLine(at: position, direction: (dx, dy))
            if line.count >= 5 {
                winningLine = line
                return true
            }
        }

        return false
    }

    // 计算某个方向上的连续棋子
    private func countLine(at position: Position, direction: (Int, Int)) -> [Position] {
        let piece = board[position.row][position.col]
        var positions = [position]

        // 正方向
        var row = position.row + direction.0
        var col = position.col + direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board[row][col] == piece {
            positions.append(Position(row: row, col: col))
            row += direction.0
            col += direction.1
        }

        // 反方向
        row = position.row - direction.0
        col = position.col - direction.1
        while row >= 0 && row < GameBoard.boardSize &&
              col >= 0 && col < GameBoard.boardSize &&
              board[row][col] == piece {
            positions.insert(Position(row: row, col: col), at: 0)
            row -= direction.0
            col -= direction.1
        }

        return positions
    }

    // 检查棋盘是否已满
    private func isBoardFull() -> Bool {
        for row in board {
            if row.contains(.empty) {
                return false
            }
        }
        return true
    }

    // 获取所有空位置
    func getEmptyPositions() -> [Position] {
        var positions: [Position] = []
        for row in 0..<GameBoard.boardSize {
            for col in 0..<GameBoard.boardSize {
                if board[row][col] == .empty {
                    positions.append(Position(row: row, col: col))
                }
            }
        }
        return positions
    }

    // 获取某个位置周围的位置（用于AI优化）
    func getNearbyPositions(around position: Position, distance: Int = 2) -> [Position] {
        var positions: [Position] = []
        let minRow = max(0, position.row - distance)
        let maxRow = min(GameBoard.boardSize - 1, position.row + distance)
        let minCol = max(0, position.col - distance)
        let maxCol = min(GameBoard.boardSize - 1, position.col + distance)

        for row in minRow...maxRow {
            for col in minCol...maxCol {
                let pos = Position(row: row, col: col)
                if board[row][col] == .empty {
                    positions.append(pos)
                }
            }
        }
        return positions
    }
}
