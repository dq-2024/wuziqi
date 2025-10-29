//
//  BoardView.swift
//  Wuziqi
//
//  棋盘视图
//

import SwiftUI

struct BoardView: View {
    @ObservedObject var gameBoard: GameBoard
    let onTap: (Position) -> Void

    private let cellSize: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let actualCellSize = boardSize / CGFloat(GameBoard.boardSize + 1)

            ZStack {
                // 背景
                Color(red: 0.85, green: 0.7, blue: 0.4)
                    .cornerRadius(12)

                // 网格线
                ForEach(0..<GameBoard.boardSize, id: \.self) { index in
                    // 横线
                    Path { path in
                        let y = actualCellSize * CGFloat(index + 1)
                        path.move(to: CGPoint(x: actualCellSize, y: y))
                        path.addLine(to: CGPoint(x: boardSize - actualCellSize, y: y))
                    }
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)

                    // 竖线
                    Path { path in
                        let x = actualCellSize * CGFloat(index + 1)
                        path.move(to: CGPoint(x: x, y: actualCellSize))
                        path.addLine(to: CGPoint(x: x, y: boardSize - actualCellSize))
                    }
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)
                }

                // 星位（天元和四个角）
                ForEach([3, 7, 11], id: \.self) { row in
                    ForEach([3, 7, 11], id: \.self) { col in
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 5, height: 5)
                            .position(
                                x: actualCellSize * CGFloat(col + 1),
                                y: actualCellSize * CGFloat(row + 1)
                            )
                    }
                }

                // 棋子
                ForEach(0..<GameBoard.boardSize, id: \.self) { row in
                    ForEach(0..<GameBoard.boardSize, id: \.self) { col in
                        let piece = gameBoard.board[row][col]
                        let position = Position(row: row, col: col)

                        if piece != .empty {
                            PieceView(
                                piece: piece,
                                isLastMove: gameBoard.lastMove == position,
                                isWinning: gameBoard.winningLine.contains(position)
                            )
                            .frame(width: actualCellSize * 0.8, height: actualCellSize * 0.8)
                            .position(
                                x: actualCellSize * CGFloat(col + 1),
                                y: actualCellSize * CGFloat(row + 1)
                            )
                        }
                    }
                }

                // 触摸区域
                ForEach(0..<GameBoard.boardSize, id: \.self) { row in
                    ForEach(0..<GameBoard.boardSize, id: \.self) { col in
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: actualCellSize, height: actualCellSize)
                            .position(
                                x: actualCellSize * CGFloat(col + 1),
                                y: actualCellSize * CGFloat(row + 1)
                            )
                            .onTapGesture {
                                onTap(Position(row: row, col: col))
                            }
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// 棋子视图
struct PieceView: View {
    let piece: Piece
    let isLastMove: Bool
    let isWinning: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: piece == .black ? [
                            Color.black,
                            Color.gray.opacity(0.8)
                        ] : [
                            Color.white,
                            Color.gray.opacity(0.3)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)

            if isLastMove {
                Circle()
                    .stroke(Color.red, lineWidth: 2)
            }

            if isWinning {
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
            }
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(gameBoard: GameBoard()) { _ in }
            .frame(width: 350, height: 350)
    }
}
