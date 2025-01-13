import SwiftUI

class GameManager: ObservableObject {
    @Published var board: [[Token?]]
    @Published var tilePositions: [UUID: CGPoint] = [:]
    @Published var moves: Int = 0
    @Published var isGameOver: Bool = false

    init() {
        board = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        addRandomTile()
        addRandomTile()
    }

    func restartGame() {
        board = Array(repeating: Array(repeating: nil, count: 4), count: 4)
        moves = 0
        isGameOver = false
        addRandomTile()
        addRandomTile()
    }

    func handleSwipe(_ translation: CGSize) {
        let direction = detectSwipeDirection(translation)

        switch direction {
        case .up: swipeUp()
        case .down: swipeDown()
        case .left: swipeLeft()
        case .right: swipeRight()
        case .none: return
        }
        if canMove() {
            moves += 1
        }
        if !canMove() {
            isGameOver = true
        
            
        }
    }

    func detectSwipeDirection(_ translation: CGSize) -> SwipeDirection {
        if abs(translation.width) > abs(translation.height) {
            return translation.width > 0 ? .right : .left
        } else {
            return translation.height > 0 ? .down : .up
        }
    }

    func swipeLeft() {
        var moved = false
        for row in 0..<4 {
            var newRow: [Token?] = board[row].compactMap { $0 }
            let previousRow = newRow

            merge(&newRow)

            while newRow.count < 4 {
                newRow.append(nil)
            }

            if newRow != previousRow {
                moved = true
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                board[row] = newRow
            }
        }
        if moved {
            withAnimation(.easeInOut(duration: 0.3)) {
                addRandomTile()
            }
            playMoveSound()
        }
    }

    func swipeRight() {
        var moved = false
        for row in 0..<4 {
            var newRow: [Token?] = board[row].compactMap { $0 }
            newRow.reverse()
            let previousRow = newRow

            merge(&newRow)

            newRow.reverse()

            while newRow.count < 4 {
                newRow.insert(nil, at: 0)
            }

            if newRow != previousRow {
                moved = true
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                board[row] = newRow
            }
        }
        if moved {
            withAnimation(.easeInOut(duration: 0.3)) {
                addRandomTile()
            }
            playMoveSound()
        }
    }

    func swipeUp() {
        var moved = false
        for col in 0..<4 {
            var newCol = [Token?]()
            for row in 0..<4 {
                if let tile = board[row][col] {
                    newCol.append(tile)
                }
            }
            let previousCol = newCol

            merge(&newCol)

            while newCol.count < 4 {
                newCol.append(nil)
            }

            if newCol != previousCol {
                moved = true
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                for row in 0..<4 {
                    board[row][col] = row < newCol.count ? newCol[row] : nil
                }
            }
        }
        if moved {
            withAnimation(.easeInOut(duration: 0.3)) {
                addRandomTile()
            }
            playMoveSound()
        }
    }

    func swipeDown() {
        var moved = false
        for col in 0..<4 {
            var newCol = [Token?]()
            for row in (0..<4).reversed() {
                if let tile = board[row][col] {
                    newCol.append(tile)
                }
            }
            let previousCol = newCol

            merge(&newCol)

            while newCol.count < 4 {
                newCol.insert(nil, at: 0)
            }

            if newCol != previousCol {
                moved = true
            }

            withAnimation(.easeInOut(duration: 0.2)) {
                for row in 0..<4 {
                    board[row][col] = row < newCol.count ? newCol[row] : nil
                }
            }
        }
        if moved {
            withAnimation(.easeInOut(duration: 0.3)) {
                addRandomTile()
            }
            playMoveSound()
        }
    }



    func canMove() -> Bool {
        for row in 0..<4 {
            for col in 0..<4 {
                if board[row][col] == nil {
                    return true
                }
                if col < 3, let currentTile = board[row][col], let nextTile = board[row][col + 1], currentTile.value == nextTile.value {
                    return true
                }
                if row < 3, let currentTile = board[row][col], let nextTile = board[row + 1][col], currentTile.value == nextTile.value {
                    return true
                }
            }
        }
        return false
    }


    func merge(_ line: inout [Token?]) {
        var newLine = [Token?]()
        
        for tile in line {
            if let tile = tile {
                newLine.append(tile)
            }
        }
        
        var i = 0
        while i < newLine.count - 1 {
            if newLine[i]?.value == newLine[i + 1]?.value {
                newLine[i] = Token(value: newLine[i]!.value * 2)
                newLine[i + 1] = nil
                i += 1
            }
            i += 1
        }
        
        line = newLine.compactMap { $0 }
    }


    func addRandomTile() {
        var emptyTiles = [(Int, Int)]()
        for row in 0..<4 {
            for col in 0..<4 {
                if board[row][col] == nil {
                    emptyTiles.append((row, col))
                }
            }
        }

        if let randomTile = emptyTiles.randomElement() {
            let (row, col) = randomTile
            let value = Int.random(in: 1...10) == 1 ? 4 : 2
            board[row][col] = Token(value: value)
            withAnimation(.easeIn(duration: 0.2)) {
                    }
        }
    }
}

class Token: Identifiable, Equatable {
    var id = UUID()
    var value: Int

    init(value: Int) {
        self.value = value
    }

    static func ==(lhs: Token, rhs: Token) -> Bool {
        lhs.value == rhs.value
    }
}

enum SwipeDirection {
    case up, down, left, right, none
}
