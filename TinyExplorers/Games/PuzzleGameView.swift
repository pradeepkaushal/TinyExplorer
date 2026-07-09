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
    @State private var pieces: [PuzzlePiece] = []
    @State private var slots: [PuzzlePiece?] = []
    @State private var selectedPieceId: UUID? = nil
    @State private var completed = false
    @State private var score = 0
    @State private var showWrongFeedback = false
    @State private var nextThemePulse = false
    @State private var progression = GameProgression(key: GameTheme.puzzle.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    // The difficulty for the puzzle currently on screen, snapshotted at reset
    // so a mid-puzzle level-up never reflows the grid under the child's hands.
    @State private var activeLevel = 1
    // Bumped on every puzzle load. Deferred celebration/advance closures capture
    // the value at schedule time and refuse to fire if the board has since been
    // reloaded (Next Theme / Reset / manual advance), so a stale timer can never
    // award, celebrate, or skip a puzzle the child is actually playing.
    @State private var puzzleGeneration = 0

    private let hints = [
        "Tap a piece, then tap its matching spot!",
        "Look at the faint picture for a clue!",
        "Match all pieces to win!",
        "You're a puzzle master now!",
    ]

    var currentTheme: (name: String, emojis: [String]) {
        puzzleThemes[currentThemeIndex]
    }

    // Difficulty auto-scales with the level — no manual picker. All layout is
    // derived from `activeLevel` (the level captured when this puzzle loaded).
    private var pieceCount: Int {
        switch activeLevel {
        case 1: return 4
        case 2, 3: return 6
        case 4: return 8
        case 5: return 9
        default: return 12
        }
    }

    private var columnCount: Int {
        switch activeLevel {
        case 1: return 2
        case 2, 3: return 3
        case 4: return 4
        case 5: return 3
        default: return 6
        }
    }

    private var maxSlotSize: CGFloat {
        switch columnCount {
        case 2: return 150
        case 3: return 130
        case 4: return 115
        default: return 100
        }
    }

    /// The faint outline cue fades out as the level rises, so higher levels
    /// ask the child to remember which emoji belongs in each slot rather than
    /// matching a direct overlay.
    private var cueOpacity: Double {
        max(0, 0.18 - Double(activeLevel - 1) * 0.05)
    }

    var currentEmojis: [String] {
        Array(currentTheme.emojis.prefix(pieceCount))
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

                    StarCounterChipEnhanced(count: score)

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

                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: .puzzle)

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: .puzzle,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                // Main play area — vertically centered in the remaining space
                GeometryReader { geo in
                    let spacing: CGFloat = 14
                    let cols = CGFloat(columnCount)
                    let rows = CGFloat(max(1, (pieceCount + columnCount - 1) / columnCount))
                    let widthLimit = (geo.size.width - 64 - spacing * (cols - 1)) / cols
                    let heightLimit = (geo.size.height - 210) / (rows * 2) // slot rows + tray rows
                    let slotSize = max(64, min(maxSlotSize, widthLimit, heightLimit))

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
                    CelebrationOverlayEnhanced(message: "Puzzle Complete!", emoji: "🧩")

                    Button("Next Puzzle") {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        advanceAfterCelebration()
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: .puzzle) {
                    adventure.reset()
                    withAnimation { showAdventureComplete = false }
                    nextTheme()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: .puzzle)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(30)
            }
        }
        .kidNavigation(title: "Puzzle Time", theme: .puzzle)
        .onChange(of: selectedPieceId) { _ in
            // A pre-reader hears what to do the moment they pick a piece up.
            if selectedPieceId != nil {
                SpeechHelper.speak("Now tap the matching spot above!")
            }
        }
        .onAppear {
            resetPuzzle()
            nextThemePulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SpeechHelper.speak("\(currentTheme.name). Tap a piece below, then tap its matching spot!")
            }
        }
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Subviews

    private func slotGrid(slotSize: CGFloat, spacing: CGFloat) -> some View {
        let columns = Array(
            repeating: GridItem(.fixed(slotSize), spacing: spacing),
            count: columnCount
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
                                .opacity(cueOpacity)
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
            count: columnCount
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
        // Lock the difficulty for this puzzle to the current level.
        activeLevel = progression.level
        let emojis = currentEmojis
        pieces = emojis.enumerated().map { index, emoji in
            PuzzlePiece(emoji: emoji, correctSlot: index)
        }.shuffled()
        slots = Array(repeating: nil, count: emojis.count)
        selectedPieceId = nil
        completed = false
        // Invalidate any celebration/advance timer left over from a prior board.
        puzzleGeneration += 1
    }

    func nextTheme() {
        currentThemeIndex = (currentThemeIndex + 1) % puzzleThemes.count
        resetPuzzle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SpeechHelper.speak("\(currentTheme.name). Find the matching spots!")
        }
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
            // Per-decision progress signal — symmetric with the per-tap wrong
            // signal, so a child finishing puzzles isn't spuriously stepped down.
            progression.registerCorrect()

            let puzzleComplete = slots.allSatisfy { $0 != nil }
            let leveledUp = progression.showLevelUp
            if leveledUp {
                SoundEngine.shared.play(.streak)
            }

            if puzzleComplete {
                adventure.recordCorrect()
                // Never stack the level-up badge with the completion overlay:
                // wait for the badge to auto-clear before celebrating the puzzle.
                let delay = leveledUp ? 2.5 : 0.5
                // If the child taps Next Theme / Reset during this delay, a new
                // puzzle loads (generation bumps) and this stale finish is dropped
                // so it can't award or celebrate against the fresh board.
                let generation = puzzleGeneration
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    guard generation == puzzleGeneration else { return }
                    progression.clearLevelUp()
                    finishPuzzle()
                }
            } else if leveledUp {
                // A mid-puzzle level-up: show the badge briefly, then clear it
                // so play resumes (LevelUpOverlay has no self-dismiss timer).
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    progression.clearLevelUp()
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation { showWrongFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showWrongFeedback = false }
            }
        }
    }

    /// Called once a puzzle is fully solved (after any level-up badge clears).
    /// Pops the treasure chest on the fifth solve, otherwise a brief puzzle
    /// celebration that auto-advances so a pre-reader never hunts for a button.
    private func finishPuzzle() {
        StarBank.shared.award(1, to: GameTheme.puzzle.key)
        SoundEngine.shared.play(.win)
        SpeechHelper.cheer(Encouragement.random())
        if adventure.isComplete {
            StarBank.shared.award(adventure.chestStars, to: GameTheme.puzzle.key)
            withAnimation(.spring()) { showAdventureComplete = true }
        } else {
            withAnimation(.spring()) { completed = true }
            // Tie this auto-advance to the puzzle being celebrated. If the child
            // manually advances (or reloads) first, the generation moves on and
            // this timer no longer cuts off the next puzzle's celebration.
            let generation = puzzleGeneration
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                guard generation == puzzleGeneration else { return }
                advanceAfterCelebration()
            }
        }
    }

    /// Advances to the next puzzle from the completion celebration. Guards on
    /// `completed` so the auto-advance timer and the manual button can't both
    /// fire and skip a puzzle.
    private func advanceAfterCelebration() {
        guard completed else { return }
        withAnimation { completed = false }
        nextTheme()
    }
}

#Preview {
    NavigationStack {
        PuzzleGameView()
    }
}
