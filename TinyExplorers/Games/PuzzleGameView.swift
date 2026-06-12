import SwiftUI

struct PuzzlePiece: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let correctSlot: Int
    var currentSlot: Int?

    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        lhs.id == rhs.id
    }
}

struct PuzzleGameView: View {
    enum PuzzleSize: String, CaseIterable {
        case easy = "Easy (6)"
        case medium = "Medium (8)"
        case hard = "Hard (12)"

        var count: Int {
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

        var maxSlotSize: CGFloat {
            switch self {
            case .easy: return 150
            case .medium: return 125
            case .hard: return 100
            }
        }
    }

    // 12 emojis per theme so every difficulty has enough pieces.
    let puzzleThemes: [(name: String, emojis: [String])] = [
        ("Farm Animals", ["🐄", "🐔", "🐷", "🐑", "🐴", "🐰", "🐐", "🦆", "🦃", "🐕", "🐈", "🐭"]),
        ("Sea Creatures", ["🐟", "🐙", "🦀", "🐳", "🦈", "🐠", "🐬", "🦞", "🐡", "🦑", "🐚", "🦭"]),
        ("Fruits", ["🍎", "🍊", "🍋", "🍇", "🍓", "🍌", "🍉", "🍑", "🍍", "🥝", "🍒", "🥭"]),
        ("Vehicles", ["🚗", "🚌", "🚂", "✈️", "🚁", "🚀", "🚜", "🚒", "🛵", "🚲", "⛵", "🚕"]),
        ("Weather", ["☀️", "🌧️", "⛈️", "🌈", "❄️", "🌤️", "🌪️", "⚡", "🌙", "💨", "🌊", "🌫️"]),
        ("Food", ["🍕", "🍔", "🌮", "🍩", "🍪", "🧁", "🍦", "🥨", "🍿", "🥞", "🍝", "🌭"]),
    ]

    @State private var currentThemeIndex = 0
    @State private var puzzleSize: PuzzleSize = .easy
    @State private var pieces: [PuzzlePiece] = []
    @State private var slots: [PuzzlePiece?] = Array(repeating: nil, count: 6)
    @State private var selectedPieceId: UUID? = nil
    @State private var completed = false
    @State private var score = 0
    @State private var showWrongFeedback = false
    @State private var nextThemePulse = false

    var currentTheme: (name: String, emojis: [String]) {
        puzzleThemes[currentThemeIndex]
    }

    var currentEmojis: [String] {
        Array(currentTheme.emojis.prefix(puzzleSize.count))
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .puzzle)

            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("Theme: \(currentTheme.name)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Spacer()

                    StarCounterChip(count: score)

                    Spacer()

                    Button(action: {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        nextTheme()
                    }) {
                        HStack {
                            Text("Next Theme")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(GameTheme.puzzle.accent))
                    }
                    .buttonStyle(SquishyButtonStyle())
                }
                .padding(.horizontal, 40)

                ThemedSegmentedPicker(
                    items: PuzzleSize.allCases.map { (title: $0.rawValue, value: $0) },
                    selection: $puzzleSize,
                    accent: GameTheme.puzzle.accent
                )
                .onChange(of: puzzleSize) { _ in
                    SoundEngine.shared.play(.tap)
                    resetPuzzle()
                }

                // Main play area — vertically centered in the remaining space
                GeometryReader { geo in
                    let spacing: CGFloat = 14
                    let cols = CGFloat(puzzleSize.columns)
                    let widthLimit = (geo.size.width - 64 - spacing * (cols - 1)) / cols
                    let heightLimit = (geo.size.height - 210) / 4 // mascot bubble + 2 slot rows + 2 tray rows
                    let slotSize = max(64, min(puzzleSize.maxSlotSize, widthLimit, heightLimit))

                    VStack(spacing: 22) {
                        MascotBubble(
                            theme: .puzzle,
                            text: selectedPieceId != nil
                                ? "Now tap the matching spot above!"
                                : "Tap a piece below, then tap its matching spot!",
                            mascotSize: 48
                        )
                        .animation(.easeInOut, value: selectedPieceId)

                        slotGrid(slotSize: slotSize, spacing: spacing)

                        pieceTray(slotSize: slotSize, spacing: spacing)

                        if showWrongFeedback {
                            Text("Hmm, try a different spot!")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                                .transition(.scale.combined(with: .opacity))
                        }

                        Button(action: {
                            Haptics.tap()
                            SoundEngine.shared.play(.tap)
                            resetPuzzle()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Puzzle")
                            }
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(GameTheme.puzzle.accent))
                        }
                        .buttonStyle(SquishyButtonStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)

            if completed {
                VStack(spacing: 20) {
                    CelebrationOverlay(message: "Puzzle Complete!", emoji: "🧩")

                    Button("Next Puzzle") {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        withAnimation { completed = false }
                        nextTheme()
                    }
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(GameTheme.puzzle.accent))
                    .buttonStyle(SquishyButtonStyle())
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationTitle("Puzzle Time")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resetPuzzle()
            nextThemePulse = true
        }
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Subviews

    private func slotGrid(slotSize: CGFloat, spacing: CGFloat) -> some View {
        let columns = Array(
            repeating: GridItem(.fixed(slotSize), spacing: spacing),
            count: puzzleSize.columns
        )
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(slots.indices, id: \.self) { slotIndex in
                Button(action: { tapSlot(slotIndex) }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                slots[slotIndex] != nil
                                    ? Color.green.opacity(0.18)
                                    : GameTheme.puzzle.accent.opacity(0.08)
                            )
                            .shadow(color: GameTheme.puzzle.accent.opacity(0.15), radius: 5, y: 2)

                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                style: StrokeStyle(lineWidth: 2.5, dash: slots[slotIndex] != nil ? [] : [9])
                            )
                            .foregroundColor(
                                slots[slotIndex] != nil
                                    ? .green
                                    : GameTheme.puzzle.accent.opacity(selectedPieceId != nil ? 0.9 : 0.45)
                            )

                        if let piece = slots[slotIndex] {
                            Text(piece.emoji)
                                .font(.system(size: slotSize * 0.62))
                                .transition(.scale)
                        } else if slotIndex < currentEmojis.count {
                            Text(currentEmojis[slotIndex])
                                .font(.system(size: slotSize * 0.62))
                                .opacity(0.18)
                        }
                    }
                    .frame(width: slotSize, height: slotSize)
                }
                .buttonStyle(SquishyButtonStyle())
                .disabled(slots[slotIndex] != nil)
                .popIn(delay: Double(slotIndex) * 0.04)
            }
        }
    }

    private func pieceTray(slotSize: CGFloat, spacing: CGFloat) -> some View {
        let columns = Array(
            repeating: GridItem(.fixed(slotSize), spacing: spacing),
            count: puzzleSize.columns
        )
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(Array(pieces.filter({ $0.currentSlot == nil }).enumerated()), id: \.element.id) { trayIndex, piece in
                let isSelected = selectedPieceId == piece.id
                Button(action: {
                    Haptics.tap()
                    SoundEngine.shared.play(.tap)
                    withAnimation(.spring(response: 0.3)) {
                        selectedPieceId = isSelected ? nil : piece.id
                    }
                }) {
                    Text(piece.emoji)
                        .font(.system(size: slotSize * 0.6))
                        .frame(width: slotSize, height: slotSize)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? GameTheme.puzzle.accent.opacity(0.18) : Color.white)
                                .shadow(
                                    color: GameTheme.puzzle.accent.opacity(isSelected ? 0.5 : 0.25),
                                    radius: isSelected ? 10 : 6,
                                    y: 3
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    GameTheme.puzzle.accent.opacity(isSelected ? 1.0 : 0.35),
                                    lineWidth: isSelected ? 3 : 2.5
                                )
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .buttonStyle(SquishyButtonStyle())
                .popIn(delay: Double(trayIndex) * 0.04)
            }
        }
    }

    // MARK: - Game logic

    func resetPuzzle() {
        let emojis = currentEmojis
        pieces = emojis.enumerated().map { index, emoji in
            PuzzlePiece(emoji: emoji, correctSlot: index)
        }.shuffled()
        slots = Array(repeating: nil, count: emojis.count)
        selectedPieceId = nil
        completed = false
    }

    func nextTheme() {
        currentThemeIndex = (currentThemeIndex + 1) % puzzleThemes.count
        resetPuzzle()
    }

    func tapSlot(_ slotIndex: Int) {
        guard let pieceId = selectedPieceId,
              let pieceIndex = pieces.firstIndex(where: { $0.id == pieceId }),
              slots[slotIndex] == nil else { return }

        let piece = pieces[pieceIndex]

        if piece.correctSlot == slotIndex {
            withAnimation(.spring()) {
                pieces[pieceIndex].currentSlot = slotIndex
                slots[slotIndex] = pieces[pieceIndex]
                selectedPieceId = nil
            }
            score += 10
            Haptics.success()
            SoundEngine.shared.play(.correct)

            if slots.allSatisfy({ $0 != nil }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    StarBank.shared.award(1, to: GameTheme.puzzle.key)
                    SoundEngine.shared.play(.win)
                    SpeechHelper.cheer(Encouragement.random())
                    withAnimation(.spring()) { completed = true }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation { showWrongFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showWrongFeedback = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleGameView()
    }
}
