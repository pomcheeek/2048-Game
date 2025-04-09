import SwiftUI
import AVFoundation




struct ContentView: View {
    @StateObject private var gameManager = GameManager()

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                
                Text("2046")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .bold()
            }

            Text("Moves: \(gameManager.moves)")
                .font(.headline)

            GameBoardView(gameManager: gameManager)
                .gesture(DragGesture()
                            .onEnded { value in
                                gameManager.handleSwipe(value.translation)
                            })

            Button("Restart") {
                gameManager.restartGame()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .alert(isPresented: $gameManager.isGameOver) {
            Alert(
                title: Text("Game Over"),
                message: Text("Try Again?"),
                primaryButton: .default(Text("Restart")) {
                    gameManager.restartGame()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct GameBoardView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 300, height: 300)
                .foregroundColor(Color.gray)
                .cornerRadius(10)
            
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<4, id: \.self) { col in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.secondary)
                        .frame(width: 60, height: 60)
                        .position(positionForTile(row: row, col: col))
                }
            }
            
            
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<4, id: \.self) { col in
                    if let tile = gameManager.board[row][col] {
                        TileView(
                            value: tile.value,
                            position: positionForTile(row: row, col: col)
                        )
                    }
                }
            }
        }
        .frame(width: 300, height: 300)
        .background(Color.gray)
        .cornerRadius(10)
    }

    func positionForTile(row: Int, col: Int) -> CGPoint {
        let tileSize: CGFloat = 70
        let spacing: CGFloat = 5
        let x = CGFloat(col) * (tileSize + spacing) + tileSize / 2
        let y = CGFloat(row) * (tileSize + spacing) + tileSize / 2
        return CGPoint(x: x, y: y)
    }
}


struct TileView: View {
    let value: Int?
    let position: CGPoint

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(value == nil ? Color.white : colorForValue(value!))
                .frame(width: 70, height: 70)
            
            

            if let value = value {
                Text("\(value)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .position(position)
        .animation(.easeInOut(duration: 0.2), value: position)
    }

    func colorForValue(_ value: Int) -> Color {
        switch value {
        case 2: return .yellow
        case 4: return .orange
        case 8: return .red
        case 16: return .pink
        case 32: return .purple
        case 64: return .blue
        case 128: return .green
        case 256: return .teal
        case 512: return .brown
        case 1024: return .cyan
        case 2048: return .white
        default: return .black
        }
    }
}

#Preview {
    ContentView()
}
