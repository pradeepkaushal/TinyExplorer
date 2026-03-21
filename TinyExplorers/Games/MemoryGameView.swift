import SwiftUI

struct MemoryCard: Identifiable {
    let id = UUID()
    let emoji: String
    var isFaceUp = false
    var isMatched = false
}

struct MemoryGameView: View {
    @State private var cards: [MemoryCard] = []
    @State private var firstFlippedIndex: Int? = nil
    @State private var isProcessing = false
    @State private var moves = 0
    @State private var matchedPairs = 0
    @State private var showWin = false
    @State private var difficulty: Difficulty = .easy

    enum Difficulty: String, CaseIterable {
        case easy = "Easy (6)"
        case medium = "Medium (8)"
        case hard = "Hard (12)"

        var pairCount: Int {
            switch self {
            case .easy: return 6
            case .medium: return 8
            case .hard: return 12
            }
        }

        var columns: Int {
            switch self {
            case .easy: return 3
            case .medium: return 4
            case .hard: return 6
            }
        }
    }

    let allEmojis = ["🐶", "🐱", "🐸", "🦊", "🐻", "🐼",
                     "🦁", "🐮", "🐷", "🐵", "🐧", "🦄",
                     "🐝", "🐢", "🐙", "🦋"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.93, blue: 0.8), Color(red: 1.0, green: 0.85, blue: 0.7)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                // Controls
                HStack {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 300)
                    .onChange(of: difficulty) { _ in startNewGame() }

                    Spacer()

                    HStack(spacing: 16) {
                        Label("\(moves) Moves", systemImage: "hand.tap")
                        Label("\(matchedPairs)/\(difficulty.pairCount) Pairs", systemImage: "checkmark.circle")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                    Spacer()

                    Button(action: startNewGame) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New Game")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.orange))
                    }
                }
                .padding(.horizontal, 16)

                // Cards grid — fills all remaining space
                GeometryReader { geo in
                    let cols = difficulty.columns
                    let rows = (cards.count + cols - 1) / cols
                    let spacing: CGFloat = 10
                    let totalHSpacing = spacing * CGFloat(cols - 1)
                    let totalVSpacing = spacing * CGFloat(rows - 1)
                    let cardWidth = (geo.size.width - totalHSpacing - 24) / CGFloat(cols)
                    let cardHeight = (geo.size.height - totalVSpacing - 12) / CGFloat(rows)
                    let cardSize = min(cardWidth, cardHeight)

                    let gridWidth = cardSize * CGFloat(cols) + totalHSpacing
                    let gridHeight = cardSize * CGFloat(rows) + totalVSpacing

                    VStack(spacing: spacing) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<cols, id: \.self) { col in
                                    let index = row * cols + col
                                    if index < cards.count {
                                        CardView(card: cards[index])
                                            .frame(width: cardSize, height: cardSize)
                                            .onTapGesture {
                                                flipCard(at: index)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: gridWidth, height: gridHeight)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .padding(.top, 8)

            if showWin {
                VStack(spacing: 16) {
                    Text("🎉 You Win! 🎉")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Text("Completed in \(moves) moves!")
                        .font(.system(size: 22, weight: .medium, design: .rounded))

                    Button("Play Again") {
                        withAnimation { showWin = false }
                        startNewGame()
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.green))
                }
                .padding(32)
                .background(RoundedRectangle(cornerRadius: 24).fill(.white).shadow(radius: 20))
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationTitle("Memory Match")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startNewGame() }
    }

    func startNewGame() {
        let emojis = Array(allEmojis.shuffled().prefix(difficulty.pairCount))
        let paired = (emojis + emojis).shuffled()
        cards = paired.map { MemoryCard(emoji: $0) }
        firstFlippedIndex = nil
        isProcessing = false
        moves = 0
        matchedPairs = 0
        showWin = false
    }

    func flipCard(at index: Int) {
        guard !isProcessing,
              !cards[index].isFaceUp,
              !cards[index].isMatched else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            cards[index].isFaceUp = true
        }

        if let firstIndex = firstFlippedIndex {
            moves += 1
            isProcessing = true

            if cards[firstIndex].emoji == cards[index].emoji {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        cards[firstIndex].isMatched = true
                        cards[index].isMatched = true
                        matchedPairs += 1
                    }
                    firstFlippedIndex = nil
                    isProcessing = false

                    if matchedPairs == difficulty.pairCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring()) { showWin = true }
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        cards[firstIndex].isFaceUp = false
                        cards[index].isFaceUp = false
                    }
                    firstFlippedIndex = nil
                    isProcessing = false
                }
            }
        } else {
            firstFlippedIndex = index
        }
    }
}

struct CardView: View {
    let card: MemoryCard

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 14)
                    .fill(card.isMatched ? Color.green.opacity(0.3) : Color.white)
                    .shadow(radius: 4)

                Text(card.emoji)
                    .font(.system(size: 56))
                    .minimumScaleFactor(0.4)
                    .opacity(card.isMatched ? 0.6 : 1.0)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 4)

                Text("❓")
                    .font(.system(size: 44))
                    .minimumScaleFactor(0.4)
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

#Preview {
    NavigationStack {
        MemoryGameView()
    }
}
