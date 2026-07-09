import SwiftUI

struct PatternGameView: View {
    // Patterns are authored as clean SINGLE cycles so `findCycleLength` always
    // recovers the true period (short periods are detected, and a whole single
    // cycle is returned via the fallback). This keeps every prompt legible: the
    // "next" tile is never arbitrary. Structures unlock by difficulty tier.
    //
    // Tier A (L1-2): period-2 ABAB.
    private let tierA: [[(emoji: String, name: String)]] = [
        [("🔴", "red circle"), ("🔵", "blue circle")],
        [("⭐", "star"), ("🌙", "moon")],
        [("🐶", "dog"), ("🐱", "cat")],
        [("🔺", "triangle"), ("🟦", "square")],
        [("☀️", "sun"), ("☁️", "cloud")],
        [("🚗", "car"), ("🚌", "bus")],
    ]

    // Tier B (L3-4): period-3 ABC / AAB, plus AABB run patterns.
    private let tierB: [[(emoji: String, name: String)]] = [
        [("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon")],
        [("❤️", "red heart"), ("💛", "yellow heart"), ("💚", "green heart")],
        [("🌺", "flower"), ("🌺", "flower"), ("🌿", "leaf")],
        [("🐸", "frog"), ("🐸", "frog"), ("🦋", "butterfly")],
        [("🐻", "bear"), ("🐻", "bear"), ("🐰", "rabbit")],
        [("🔴", "red circle"), ("🔴", "red circle"), ("🔵", "blue circle"), ("🔵", "blue circle")],
    ]

    // Tier C (L5+): period-4+ varied and growing-run patterns.
    private let tierC: [[(emoji: String, name: String)]] = [
        [("❤️", "red heart"), ("💛", "yellow heart"), ("💚", "green heart"), ("💙", "blue heart")],
        [("🔴", "red circle"), ("🔵", "blue circle"), ("🟡", "yellow circle"), ("🟢", "green circle")],
        [("⭐", "star"), ("🌙", "moon"), ("☀️", "sun"), ("🌙", "moon")],
        [("🐶", "dog"), ("🐶", "dog"), ("🐱", "cat"), ("🐱", "cat")],
        [("🔺", "triangle"), ("🔺", "triangle"), ("🔺", "triangle"), ("🟦", "square")],
        [("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon"), ("🍇", "grapes")],
    ]

    @State private var currentPatternIndex = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var totalAttempts = 0
    @State private var showResult: Bool? = nil
    @State private var options: [(emoji: String, name: String)] = []
    @State private var correctAnswer: (emoji: String, name: String) = ("", "")
    @State private var displayedPattern: [(emoji: String, name: String)] = []
    @State private var shuffledPatterns: [[( emoji: String, name: String)]] = []
    @State private var celebrationMessage = ""
    @State private var roundNumber = 0
    @State private var progression = GameProgression(key: GameTheme.pattern.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @State private var currentTier = 0
    @State private var lastPatternSignature = ""
    // Per-round lockout: a single unsolved round must never be scored as more
    // than one miss, no matter how many times the child re-taps a wrong option.
    @State private var missRecordedThisRound = false

    private let hints = [
        "Look for what repeats in the pattern!",
        "Say the pattern out loud: red, blue, red…",
        "Find the thing that comes again and again!",
        "You're a pattern detective now!",
    ]

    private let theme = GameTheme.pattern

    var currentPattern: [(emoji: String, name: String)] {
        guard !shuffledPatterns.isEmpty else { return tierA[0] }
        return shuffledPatterns[currentPatternIndex % shuffledPatterns.count]
    }

    /// Pattern tiles shrink a little when the pattern grows longer.
    private var tileSize: CGFloat {
        displayedPattern.count >= 6 ? 92 : 108
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .pattern)

            VStack(spacing: 0) {
                // Score + progression
                HStack(spacing: 14) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)
    AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)

                    Spacer()

                    Text("Pattern \(score + 1)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.8)))
                }
                .padding(.horizontal, 50)
                .padding(.top, 12)

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer(minLength: 16)

                VStack(spacing: 30) {
                    MascotBubble(theme: theme, text: "What comes next?")

                    // Pattern display. A wrapping grid of uniform tiles keeps the
                    // sequence readable left-to-right yet reflows onto extra rows
                    // so a long pattern (up to 8 tiles + mystery) never clips off
                    // a portrait iPad's edges.
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: tileSize, maximum: tileSize), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(0..<displayedPattern.count, id: \.self) { i in
                            Text(displayedPattern[i].emoji)
                                .font(.system(size: tileSize * 0.62))
                                .frame(width: tileSize, height: tileSize)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white, theme.accent.opacity(0.1)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(theme.accent.opacity(0.35), lineWidth: 2.5)
                                        )
                                        .shadow(color: theme.accent.opacity(0.2), radius: 6, y: 3)
                                )
                                .popIn(delay: Double(i) * 0.04)
                        }

                        // Mystery slot
                        Text("❓")
                            .font(.system(size: tileSize * 0.62))
                            .frame(width: tileSize, height: tileSize)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.accent.opacity(0.16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                                            .foregroundColor(theme.accent)
                                    )
                            )
                            .modifier(MysteryTileWobble())
                            .popIn(delay: Double(displayedPattern.count) * 0.04)
                    }
                    .id(roundNumber)
                    .padding(.horizontal, 20)

                    // Answer options
                    Text("Choose the right answer:")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    // One centered row of option buttons that shares the width
                    // evenly, so even at the maximum of 5 options each button
                    // stays fully on-screen (never clipped) with a large touch
                    // target. Buttons cap at 165pt and shrink to fit if narrower.
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: max(options.count, 1)),
                        spacing: 20
                    ) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                checkAnswer(option)
                            }) {
                                Text(option.emoji)
                                    .font(.system(size: 92))
                                    .minimumScaleFactor(0.6)
                                    .frame(maxWidth: 165)
                                    .frame(height: 165)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.white, theme.accent.opacity(0.12)],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(theme.accent.opacity(0.45), lineWidth: 2.5)
                                            )
                                            .shadow(color: theme.accent.opacity(0.3), radius: 10, y: 5)
                                    )
                            }
                            .buttonStyle(SquishyButtonStyle())
                            .disabled(showResult != nil)
                            .popIn(delay: 0.15 + Double(index) * 0.04)
                        }
                    }
                    .id(roundNumber)
                    .padding(.horizontal, 20)

                    // Feedback
                    Group {
                        if showResult == false {
                            Text("Not quite. Look at the pattern again!")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 44)
                }

                Spacer(minLength: 24)
            }

            if showResult == true {
                CelebrationOverlayEnhanced(message: celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    withAnimation {
                        showAdventureComplete = false
                        advancePattern()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Pattern Fun", theme: theme)
        .onAppear {
            buildDeck(forTier: tier(for: progression.level), avoiding: "")
            setupRound()
        }
        .onDisappear { SpeechHelper.stop() }
    }

    func advancePattern() {
        let desiredTier = tier(for: progression.level)
        if desiredTier != currentTier {
            // The child crossed into a new difficulty tier: rebuild the deck.
            buildDeck(forTier: desiredTier, avoiding: lastPatternSignature)
        } else {
            currentPatternIndex += 1
            if currentPatternIndex >= shuffledPatterns.count {
                // Deck exhausted: reshuffle, guarding against a back-to-back
                // repeat of the pattern just shown.
                buildDeck(forTier: desiredTier, avoiding: lastPatternSignature)
            }
        }
        setupRound()
    }

    /// Difficulty tier for the current level. Harder pattern STRUCTURES unlock
    /// as the child levels up: 0 = period-2 (L1-2), 1 = period-3/AABB (L3-4),
    /// 2 = period-4+ and procedurally generated patterns (L5+).
    private func tier(for level: Int) -> Int {
        if level <= 2 { return 0 }
        if level <= 4 { return 1 }
        return 2
    }

    private func patterns(forTier tier: Int) -> [[(emoji: String, name: String)]] {
        switch tier {
        case 0: return tierA
        case 1: return tierB
        default: return tierC
        }
    }

    /// A stable identity for a pattern (its emoji sequence), used to prevent a
    /// pattern from appearing twice in a row across a reshuffle boundary.
    private func signature(_ pattern: [(emoji: String, name: String)]) -> String {
        pattern.map { $0.emoji }.joined(separator: "|")
    }

    /// Build (or reshuffle) the working deck for a tier. If the new first
    /// pattern would repeat the one just shown, it is swapped with a later one.
    private func buildDeck(forTier tier: Int, avoiding lastSig: String) {
        var deck = patterns(forTier: tier).shuffled()
        if deck.count > 1, !lastSig.isEmpty, signature(deck[0]) == lastSig,
           let swapIndex = deck.indices.dropFirst().first(where: { signature(deck[$0]) != lastSig }) {
            deck.swapAt(0, swapIndex)
        }
        shuffledPatterns = deck
        currentTier = tier
        currentPatternIndex = 0
    }

    func setupRound() {
        showResult = nil
        roundNumber += 1
        missRecordedThisRound = false

        // Select the difficulty tier from the current level BEFORE choosing a
        // pattern, so the prediction task itself gets harder as the child levels
        // up. At the top tier we sometimes emit a freshly generated pattern so
        // high-level play stays novel and never runs out.
        let currentLevelTier = tier(for: progression.level)
        let base: [(emoji: String, name: String)]
        if currentLevelTier >= 2 && Int.random(in: 0..<2) == 0 {
            base = generatedTopTierPattern()
        } else {
            base = currentPattern
        }

        // The answer is the next element in the repeating pattern.
        let cycleLength = findCycleLength(base)

        // Patterns get longer as the player levels up:
        // 4 tiles to start, +1 every 2 levels (max 8).
        let length = 4 + min(progression.level / 2, 4)
        displayedPattern = (0..<length).map { base[$0 % cycleLength] }
        correctAnswer = base[length % cycleLength]
        lastPatternSignature = signature(Array(base.prefix(cycleLength)))

        // More options as the level rises: 3 (L1-2), 4 (L3-5), 5 (L6+).
        let optionCount = 3 + min(progression.level / 3, 2)

        // Draw wrong options from the pattern itself first so they are genuinely
        // confusable (the off-by-one "wrong phase" pick a child would make),
        // then same-family look-alikes, and only fall back to a global pool.
        let globalPool: [(emoji: String, name: String)] = [
            ("🔴", "red circle"), ("🔵", "blue circle"), ("⭐", "star"), ("🌙", "moon"),
            ("🐶", "dog"), ("🐱", "cat"), ("🍎", "apple"), ("🍊", "orange"),
            ("❤️", "red heart"), ("💚", "green heart"), ("🌺", "flower"), ("🦋", "butterfly"),
            ("🔺", "triangle"), ("🟦", "square"), ("☀️", "sun"), ("☁️", "cloud"),
        ]

        var distractorPool: [(emoji: String, name: String)] = []
        func offer(_ candidate: (emoji: String, name: String)) {
            guard candidate.emoji != correctAnswer.emoji,
                  !distractorPool.contains(where: { $0.emoji == candidate.emoji }) else { return }
            distractorPool.append(candidate)
        }

        // The tile right before the mystery slot is the most tempting wrong pick.
        if let last = displayedPattern.last { offer(last) }
        // Other elements of the cycle are the wrong-phase confusables.
        for element in base.prefix(cycleLength) { offer(element) }
        // Same-family look-alikes.
        for element in lookAlikes(for: correctAnswer) { offer(element) }
        // Global fallback when the pattern can't supply enough distractors.
        for element in globalPool { offer(element) }

        var opts: [(emoji: String, name: String)] = [correctAnswer]
        for candidate in distractorPool where opts.count < optionCount {
            opts.append(candidate)
        }
        options = opts.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SpeechHelper.speak("What comes next?")
        }
    }

    /// Same-family look-alikes for a pattern element, used as second-choice
    /// distractors (harder to eliminate than an unrelated emoji).
    private func lookAlikes(for element: (emoji: String, name: String)) -> [(emoji: String, name: String)] {
        let families: [[(emoji: String, name: String)]] = [
            [("🔴", "red circle"), ("🔵", "blue circle"), ("🟡", "yellow circle"), ("🟢", "green circle"), ("🟠", "orange circle"), ("🟣", "purple circle")],
            [("❤️", "red heart"), ("💛", "yellow heart"), ("💚", "green heart"), ("💙", "blue heart"), ("💜", "purple heart"), ("🧡", "orange heart")],
            [("⭐", "star"), ("🌙", "moon"), ("☀️", "sun"), ("☁️", "cloud"), ("🌟", "sparkle star")],
            [("🐶", "dog"), ("🐱", "cat"), ("🐰", "rabbit"), ("🐻", "bear"), ("🐸", "frog"), ("🦋", "butterfly")],
            [("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon"), ("🍇", "grapes"), ("🍓", "strawberry"), ("🍌", "banana")],
            [("🔺", "triangle"), ("🟦", "square"), ("🔷", "diamond"), ("🔶", "orange diamond"), ("🟥", "red square")],
            [("🚗", "car"), ("🚌", "bus"), ("🚕", "taxi"), ("🚙", "jeep")],
            [("🌺", "flower"), ("🌸", "blossom"), ("🌼", "daisy"), ("🌿", "leaf"), ("🍀", "clover")],
        ]
        for family in families where family.contains(where: { $0.emoji == element.emoji }) {
            return family.filter { $0.emoji != element.emoji }
        }
        return []
    }

    /// Small procedural generator for the top tier: pick 2-3 distinct emoji and
    /// emit one clean repeating cycle of period >= 3. Routed through the same
    /// findCycleLength / correctAnswer path as the authored patterns.
    private func generatedTopTierPattern() -> [(emoji: String, name: String)] {
        let palette: [(emoji: String, name: String)] = [
            ("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon"), ("🍇", "grapes"),
            ("⭐", "star"), ("🌙", "moon"), ("☀️", "sun"), ("☁️", "cloud"),
            ("🐶", "dog"), ("🐱", "cat"), ("🐰", "rabbit"), ("🐻", "bear"),
            ("🔴", "red circle"), ("🔵", "blue circle"), ("🟡", "yellow circle"), ("🟢", "green circle"),
        ]
        var pool = palette.shuffled()
        let elementCount = Int.random(in: 2...3)
        var chosen: [(emoji: String, name: String)] = []
        while chosen.count < elementCount, let next = pool.popLast() {
            if !chosen.contains(where: { $0.emoji == next.emoji }) {
                chosen.append(next)
            }
        }
        guard chosen.count >= 2 else {
            return [("🔴", "red circle"), ("🔵", "blue circle"), ("🟡", "yellow circle")]
        }
        let templates: [[Int]] = chosen.count == 2
            ? [[0, 0, 1], [0, 1, 1], [0, 0, 1, 1]]
            : [[0, 1, 2], [0, 0, 1, 2], [0, 1, 2, 1], [0, 1, 1, 2]]
        let template = templates.randomElement() ?? [0, 1, 2]
        return template.map { chosen[$0] }
    }

    func findCycleLength(_ pattern: [(emoji: String, name: String)]) -> Int {
        for length in 1...pattern.count / 2 {
            var isCycle = true
            for i in 0..<pattern.count {
                if pattern[i].emoji != pattern[i % length].emoji {
                    isCycle = false
                    break
                }
            }
            if isCycle { return length }
        }
        return pattern.count
    }

    func checkAnswer(_ option: (emoji: String, name: String)) {
        totalAttempts += 1

        if option.emoji == correctAnswer.emoji {
            celebrationMessage = Encouragement.random()
            StarBank.shared.award(1, to: GameTheme.pattern.key)
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                showResult = true
                score += 1
                streak += 1
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.pattern.key)
                SoundEngine.shared.play(.streak)
            }
            if !progression.showLevelUp {
                SpeechHelper.speak("Yes, it's the \(correctAnswer.name)!")
            }

            let delay = progression.showLevelUp ? 2.5 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { advancePattern() }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            // Only the FIRST wrong tap of a round is scored, so re-tapping the
            // same unsolved round can't rack up extra misses or an unwarranted
            // level-down. Feedback below still fires on every tap.
            if !missRecordedThisRound {
                progression.registerWrong()
                adventure.recordMiss()
                missRecordedThisRound = true
            }
            withAnimation {
                showResult = false
                streak = 0
            }
            SpeechHelper.speak("Try again!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showResult = nil }
            }
        }
    }
}

/// Gentle, repeating ±4° wobble for the mystery "?" tile.
private struct MysteryTileWobble: ViewModifier {
    @State private var wobble = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(wobble ? 4 : -4))
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: wobble)
            .onAppear { wobble = true }
    }
}

#Preview {
    NavigationStack {
        PatternGameView()
    }
}
