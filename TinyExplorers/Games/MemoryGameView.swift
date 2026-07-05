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
    @State private var newGamePulse = false
    @State private var isPeeking = false
    @State private var peekCountdown = 0
    /// Invalidates scheduled peek callbacks when a new game starts mid-peek.
    @State private var gameGeneration = 0
    @State private var progression = GameProgression()

    private let hints = [
        "Look closely during the peek time!",
        "Remember where each animal is!",
        "Flip cards two at a time to match!",
        "You have a super memory now!",
    ]

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

        /// How long the cards stay revealed to memorize before covering.
        var peekSeconds: Int {
            switch self {
            case .easy: return 6
            case .medium: return 9
            case .hard: return 12
            }
        }
    }

    let allEmojis = ["🐶", "🐱", "🐸", "🦊", "🐻", "🐼",
                     "🦁", "🐮", "🐷", "🐵", "🐧", "🦄",
                     "🐝", "🐢", "🐙", "🦋"]

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .memory)

            VStack(spacing: 10) {
                // Controls
                HStack {
                    ThemedSegmentedPicker(
                        items: Difficulty.allCases.map { (title: $0.rawValue, value: $0) },
                        selection: $difficulty,
                        accent: GameTheme.memory.accent
                    )
                    .onChange(of: difficulty) { _ in
                        SoundEngine.shared.play(.tap)
                        startNewGame()
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Label("\(moves) Moves", systemImage: "hand.tap")
                        Label("\(matchedPairs)/\(difficulty.pairCount) Pairs", systemImage: "checkmark.circle")
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
                    )

                    Spacer()

                    Button(action: {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        startNewGame()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New Game")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(GameTheme.memory.accent))
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .scaleEffect(newGamePulse ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: newGamePulse)
                }
                .padding(.horizontal, 16)

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: .memory,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                MascotBubble(
                    theme: .memory,
                    text: isPeeking
                        ? "👀 Look and remember… \(peekCountdown)"
                        : "Find all the matching pairs!",
                    mascotSize: 44
                )
                .popIn(delay: 0.1)

                // Cards grid — fills all remaining space, centered
                GeometryReader { geo in
                    let cols = difficulty.columns
                    let rows = (cards.count + cols - 1) / cols
                    let spacing: CGFloat = 12
                    let totalHSpacing = spacing * CGFloat(cols - 1)
                    let totalVSpacing = spacing * CGFloat(rows - 1)
                    let cardWidth = (geo.size.width - totalHSpacing - 32) / CGFloat(cols)
                    let cardHeight = (geo.size.height - totalVSpacing - 16) / CGFloat(rows)
                    let cardSize = min(cardWidth, cardHeight)

                    let gridWidth = cardSize * CGFloat(cols) + totalHSpacing
                    let gridHeight = cardSize * CGFloat(rows) + totalVSpacing

                    VStack(spacing: spacing) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<cols, id: \.self) { col in
                                    let index = row * cols + col
                                    if index < cards.count {
                                        Button(action: { flipCard(at: index) }) {
                                            CardView(card: cards[index])
                                                .frame(width: cardSize, height: cardSize)
                                        }
                                        .buttonStyle(SquishyButtonStyle())
                                        .popIn(delay: Double(index) * 0.04)
                                        .id(cards[index].id)
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
                VStack(spacing: 20) {
                    CelebrationOverlayEnhanced(message: "You did it in \(moves) moves!")

                    Button("Play Again") {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        withAnimation { showWin = false }
                        startNewGame()
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(GameTheme.memory.accent))
                    .buttonStyle(SquishyButtonStyle())
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: .memory)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Memory Match", theme: .memory)
        .onAppear {
            startNewGame()
            newGamePulse = true
        }
        .onDisappear { SpeechHelper.stop() }
    }

    func startNewGame() {
        gameGeneration += 1
        let generation = gameGeneration
        let emojis = Array(allEmojis.shuffled().prefix(difficulty.pairCount))
        let paired = (emojis + emojis).shuffled()
        // Start face-up: the kid gets a few seconds to memorize the board.
        cards = paired.map { MemoryCard(emoji: $0, isFaceUp: true) }
        firstFlippedIndex = nil
        isProcessing = false
        moves = 0
        matchedPairs = 0
        showWin = false

        isPeeking = true
        let peekSeconds = difficulty.peekSeconds
        peekCountdown = peekSeconds
        SpeechHelper.speak("Look closely and remember the cards!")

        for second in 1...peekSeconds {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(second)) {
                guard gameGeneration == generation else { return }
                peekCountdown = peekSeconds - second
                if peekCountdown > 0 { SoundEngine.shared.play(.tap) }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(peekSeconds)) {
            guard gameGeneration == generation else { return }
            withAnimation(.easeInOut(duration: 0.45)) {
                for i in cards.indices { cards[i].isFaceUp = false }
            }
            SoundEngine.shared.play(.pop)
            isPeeking = false
            SpeechHelper.speak("Now find the pairs!")
        }
    }

    func flipCard(at index: Int) {
        guard !isPeeking,
              !isProcessing,
              !cards[index].isFaceUp,
              !cards[index].isMatched else { return }

        Haptics.tap()
        SoundEngine.shared.play(.tap)
        withAnimation(.easeInOut(duration: 0.35)) {
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
                    Haptics.success()
                    SoundEngine.shared.play(.correct)

                    if matchedPairs == difficulty.pairCount {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            StarBank.shared.award(1, to: GameTheme.memory.key)
                            progression.registerCorrect()
                            SoundEngine.shared.play(.win)
                            if !progression.showLevelUp {
                                SpeechHelper.cheer(Encouragement.random())
                            }
                            withAnimation(.spring()) { showWin = true }
                        }
                    }
                }
            } else {
                Haptics.error()
                SoundEngine.shared.play(.wrong)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.35)) {
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

/// A proper two-sided flip card: the back is shown at 0° and the face is
/// pre-rotated 180° so that when the container flips, neither side ever
/// renders mirrored.
struct CardView: View {
    let card: MemoryCard

    private var showsFace: Bool { card.isFaceUp || card.isMatched }

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                cardBack(size: s)
                    .opacity(showsFace ? 0 : 1)
                cardFace(size: s)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(showsFace ? 1 : 0)
            }
            .rotation3DEffect(
                .degrees(showsFace ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - Face: white card with a big emoji

    private func cardFace(size s: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(card.isMatched ? GameTheme.memory.accent.opacity(0.12) : Color.white)
                .shadow(color: GameTheme.memory.accent.opacity(0.3), radius: 6, y: 3)
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    card.isMatched ? Color.green.opacity(0.55) : GameTheme.memory.accent.opacity(0.55),
                    lineWidth: 2.5
                )
            Text(card.emoji)
                .font(.system(size: s * 0.52))
                .minimumScaleFactor(0.4)
                .opacity(card.isMatched ? 0.65 : 1.0)
        }
    }

    // MARK: - Back: accent gradient, white "?" badge, sparkle corners

    private func cardBack(size s: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            GameTheme.memory.accent,
                            Color(red: 0.93, green: 0.40, blue: 0.15),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: GameTheme.memory.accent.opacity(0.4), radius: 6, y: 3)

            // Inner white frame, like the printed border of a real playing card
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.55), lineWidth: 2)
                .padding(s * 0.07)

            Circle()
                .fill(Color.white)
                .frame(width: s * 0.46, height: s * 0.46)
                .shadow(color: .black.opacity(0.18), radius: 3, y: 2)

            Text("?")
                .font(.system(size: s * 0.3, weight: .heavy, design: .rounded))
                .foregroundColor(GameTheme.memory.accent)

            // Sparkles in the corners
            VStack {
                HStack {
                    sparkle(s)
                    Spacer()
                    sparkle(s)
                }
                Spacer()
                HStack {
                    sparkle(s)
                    Spacer()
                    sparkle(s)
                }
            }
            .padding(s * 0.11)
        }
    }

    private func sparkle(_ s: CGFloat) -> some View {
        Text("✦")
            .font(.system(size: max(9, s * 0.11), weight: .bold))
            .foregroundColor(.white.opacity(0.85))
    }
}

#Preview {
    NavigationStack {
        MemoryGameView()
    }
}
