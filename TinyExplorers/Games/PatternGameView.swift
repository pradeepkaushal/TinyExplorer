import SwiftUI

struct PatternGameView: View {
    let patternSets: [[(emoji: String, name: String)]] = [
        [("🔴", "red circle"), ("🔵", "blue circle"), ("🔴", "red circle"), ("🔵", "blue circle")],
        [("⭐", "star"), ("🌙", "moon"), ("⭐", "star"), ("🌙", "moon")],
        [("🐶", "dog"), ("🐱", "cat"), ("🐶", "dog"), ("🐱", "cat")],
        [("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon"), ("🍎", "apple")],
        [("❤️", "heart"), ("💛", "yellow heart"), ("💚", "green heart"), ("❤️", "heart")],
        [("🌺", "flower"), ("🌺", "flower"), ("🌿", "leaf"), ("🌺", "flower")],
        [("🐸", "frog"), ("🐸", "frog"), ("🦋", "butterfly"), ("🐸", "frog")],
        [("🔺", "triangle"), ("🟦", "square"), ("🔺", "triangle"), ("🟦", "square")],
        [("☀️", "sun"), ("☁️", "cloud"), ("☀️", "sun"), ("☁️", "cloud")],
        [("🚗", "car"), ("🚌", "bus"), ("🚗", "car"), ("🚌", "bus")],
        [("🎈", "balloon"), ("🎈", "balloon"), ("🎈", "balloon"), ("🎁", "gift")],
        [("🐻", "bear"), ("🐻", "bear"), ("🐰", "rabbit"), ("🐻", "bear")],
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

    private let theme = GameTheme.pattern

    var currentPattern: [(emoji: String, name: String)] {
        guard !shuffledPatterns.isEmpty else { return patternSets[0] }
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
                // Score
                HStack(spacing: 14) {
                    StarCounterChip(count: score)
                    StreakBadge(streak: streak)

                    Spacer()

                    Text("Pattern \(totalAttempts + 1)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.8)))
                }
                .padding(.horizontal, 50)
                .padding(.top, 12)

                Spacer(minLength: 16)

                VStack(spacing: 30) {
                    MascotBubble(theme: theme, text: "What comes next?")

                    // Pattern display
                    HStack(spacing: 14) {
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

                    // Answer options
                    Text("Choose the right answer:")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    HStack(spacing: 30) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                checkAnswer(option)
                            }) {
                                Text(option.emoji)
                                    .font(.system(size: 92))
                                    .frame(width: 165, height: 165)
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
                CelebrationOverlay(message: celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Pattern Fun")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledPatterns = patternSets.shuffled()
            setupRound()
        }
        .onDisappear { SpeechHelper.stop() }
    }

    func setupRound() {
        showResult = nil
        roundNumber += 1
        let base = currentPattern

        // The answer is the next in the repeating pattern.
        let cycleLength = findCycleLength(base)

        // Patterns get longer as the player answers more correctly:
        // 4 tiles to start, 5 after 3 correct, 6 after 6 correct.
        let length = 4 + min(score / 3, 2)
        displayedPattern = (0..<length).map { base[$0 % cycleLength] }
        correctAnswer = base[length % cycleLength]

        // Generate wrong options
        let allEmojis: [(emoji: String, name: String)] = [
            ("🔴", "red"), ("🔵", "blue"), ("⭐", "star"), ("🌙", "moon"),
            ("🐶", "dog"), ("🐱", "cat"), ("🍎", "apple"), ("🍊", "orange"),
            ("❤️", "heart"), ("💚", "green heart"), ("🌺", "flower"), ("🦋", "butterfly"),
            ("🔺", "triangle"), ("🟦", "square"), ("☀️", "sun"), ("☁️", "cloud"),
        ]

        var opts = [correctAnswer]
        while opts.count < 3 {
            if let random = allEmojis.randomElement(),
               !opts.contains(where: { $0.emoji == random.emoji }) {
                opts.append(random)
            }
        }
        options = opts.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SpeechHelper.speak("What comes next?")
        }
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
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                showResult = true
                score += 1
                streak += 1
            }
            if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.pattern.key)
                SoundEngine.shared.play(.streak)
            }
            SpeechHelper.speak("Yes, it's the \(correctAnswer.name)!")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    currentPatternIndex += 1
                    if currentPatternIndex >= shuffledPatterns.count {
                        shuffledPatterns = patternSets.shuffled()
                        currentPatternIndex = 0
                    }
                    setupRound()
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
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
