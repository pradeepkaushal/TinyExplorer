import SwiftUI

/// A themed pool of items the generator draws from. Every emoji appears in
/// exactly one category so a generated round can never be ambiguous.
struct OddCategory {
    let name: String       // chip label, e.g. "Fruits"
    let singular: String   // for explanations, e.g. "fruit"
    let items: [(emoji: String, name: String)]

    static let all: [OddCategory] = [
        OddCategory(name: "Fruits", singular: "fruit", items: [
            ("🍎", "apple"), ("🍊", "orange"), ("🍋", "lemon"), ("🍓", "strawberry"),
            ("🍇", "grapes"), ("🍌", "banana"), ("🍉", "watermelon"), ("🍑", "peach"),
        ]),
        OddCategory(name: "Animals", singular: "animal", items: [
            ("🐶", "dog"), ("🐱", "cat"), ("🐸", "frog"), ("🐰", "bunny"),
            ("🐻", "bear"), ("🐮", "cow"), ("🐷", "pig"), ("🦁", "lion"),
        ]),
        OddCategory(name: "Vehicles", singular: "vehicle", items: [
            ("🚗", "car"), ("🚌", "bus"), ("🚂", "train"), ("✈️", "plane"),
            ("🚁", "helicopter"), ("🚜", "tractor"), ("🛵", "scooter"),
        ]),
        OddCategory(name: "Flowers", singular: "flower", items: [
            ("🌸", "blossom"), ("🌻", "sunflower"), ("🌺", "hibiscus"),
            ("🌷", "tulip"), ("🌹", "rose"),
        ]),
        OddCategory(name: "Sky Things", singular: "sky thing", items: [
            ("☀️", "sun"), ("🌙", "moon"), ("⭐", "star"), ("☁️", "cloud"), ("🌈", "rainbow"),
        ]),
        OddCategory(name: "Sea Friends", singular: "sea friend", items: [
            ("🐟", "fish"), ("🐬", "dolphin"), ("🐙", "octopus"),
            ("🦀", "crab"), ("🐳", "whale"), ("🐚", "seashell"),
        ]),
        OddCategory(name: "Sweet Treats", singular: "sweet treat", items: [
            ("🍦", "ice cream"), ("🧁", "cupcake"), ("🍰", "cake"),
            ("🍭", "lollipop"), ("🍩", "donut"), ("🍪", "cookie"),
        ]),
        OddCategory(name: "Vegetables", singular: "vegetable", items: [
            ("🥦", "broccoli"), ("🥕", "carrot"), ("🌽", "corn"),
            ("🍅", "tomato"), ("🥒", "cucumber"),
        ]),
        OddCategory(name: "Clothes", singular: "piece of clothing", items: [
            ("👟", "sneaker"), ("🧢", "cap"), ("🧤", "glove"),
            ("🧦", "sock"), ("👗", "dress"), ("🧥", "coat"),
        ]),
        OddCategory(name: "Instruments", singular: "instrument", items: [
            ("🎹", "piano"), ("🎸", "guitar"), ("🎺", "trumpet"),
            ("🥁", "drum"), ("🎻", "violin"),
        ]),
        OddCategory(name: "Little Bugs", singular: "bug", items: [
            ("🐝", "bee"), ("🐞", "ladybug"), ("🦋", "butterfly"),
            ("🐛", "caterpillar"), ("🐜", "ant"),
        ]),
        OddCategory(name: "Sports Balls", singular: "ball", items: [
            ("⚽", "soccer ball"), ("🏀", "basketball"), ("🎾", "tennis ball"), ("⚾", "baseball"),
        ]),
        OddCategory(name: "Yummy Food", singular: "food", items: [
            ("🍕", "pizza"), ("🍔", "burger"), ("🌮", "taco"), ("🥪", "sandwich"), ("🍝", "spaghetti"),
        ]),
    ]
}

struct OddOneOutRound {
    let items: [String]
    let oddIndex: Int
    let category: String
    let explanation: String
}

struct OddOneOutGameView: View {
    @State private var currentRound = OddOneOutRound(items: [], oddIndex: 0, category: "", explanation: "")
    @State private var lastCategoryName = ""
    @State private var score = 0
    @State private var streak = 0
    @State private var totalAttempts = 0
    @State private var tappedIndex: Int? = nil
    @State private var showResult: Bool? = nil
    @State private var showExplanation = false
    @State private var missedOnce = false
    @State private var shuffledItems: [(item: String, originalIndex: Int)] = []
    @State private var roundNumber = 0
    @State private var progression = GameProgression(key: GameTheme.oddOneOut.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false

    private let hints = [
        "Find the one that doesn't belong!",
        "What's different about one of these?",
        "Think about what group they belong to!",
        "You're a spotting superstar now!",
    ]

    private let theme = GameTheme.oddOneOut

    /// More cards to scan as the kid levels: 3 at L1-2, 4 at L3-5, 5 at L6+.
    private var itemCount: Int {
        switch progression.level {
        case 1...2: return 3
        case 3...5: return 4
        default: return 5
        }
    }

    /// Cards shrink a little when five are on screen so they still fit.
    private var cardSize: CGFloat { shuffledItems.count >= 5 ? 140 : 185 }
    private var cardSpacing: CGFloat { shuffledItems.count >= 5 ? 20 : 26 }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .oddOneOut)

            VStack(spacing: 0) {
                // Score + progression
                HStack(spacing: 14) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)
                    AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)

                    Spacer()

                    Text("Category: \(currentRound.category)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.8)))
                        .modifier(CategoryChipGlow())

                    Spacer()

                    Text("Round \(totalAttempts + 1)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
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

                VStack(spacing: 26) {
                    MascotBubble(theme: theme, text: "Find the odd one out!\nWhich one doesn't belong?")

                    // Items grid
                    HStack(spacing: cardSpacing) {
                        ForEach(Array(shuffledItems.enumerated()), id: \.offset) { displayIndex, entry in
                            Button(action: {
                                checkAnswer(originalIndex: entry.originalIndex, displayIndex: displayIndex)
                            }) {
                                Text(entry.item)
                                    .font(.system(size: cardSize * 0.52))
                                    .frame(width: cardSize, height: cardSize)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(cardColor(displayIndex: displayIndex, originalIndex: entry.originalIndex))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(
                                                        theme.accent.opacity(tappedIndex == displayIndex ? 0.9 : 0.4),
                                                        lineWidth: 2.5
                                                    )
                                            )
                                            .shadow(
                                                color: theme.accent.opacity(0.3),
                                                radius: tappedIndex == displayIndex ? 12 : 8,
                                                y: 4
                                            )
                                    )
                                    .scaleEffect(tappedIndex == displayIndex ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3), value: tappedIndex)
                            }
                            .buttonStyle(SquishyButtonStyle())
                            .disabled(showResult != nil)
                            .popIn(delay: Double(displayIndex) * 0.04)
                        }
                    }
                    .id(roundNumber)

                    // Feedback
                    Group {
                        if let result = showResult {
                            VStack(spacing: 12) {
                                Text(result ? "Correct!" : (showExplanation ? "Here it is!" : "Look again!"))
                                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                                    .foregroundColor(result ? .green : .orange)

                                if showExplanation {
                                    Text(currentRound.explanation)
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary.opacity(0.75))
                                        .multilineTextAlignment(.center)

                                    Button("Next Round") {
                                        Haptics.tap()
                                        SoundEngine.shared.play(.tap)
                                        nextRound()
                                    }
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                    .background(
                                        Capsule()
                                            .fill(theme.accent)
                                            .shadow(color: theme.accent.opacity(0.5), radius: 6, y: 3)
                                    )
                                    .buttonStyle(SquishyButtonStyle())
                                }
                            }
                            .padding(28)
                            .frame(minWidth: 380)
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
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            Color.clear
                        }
                    }
                    .frame(minHeight: 210)
                }

                Spacer(minLength: 16)
            }

            if showResult == true {
                ConfettiView()
                    .zIndex(5)
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
                        setupRound()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Odd One Out", theme: theme)
        .onAppear { setupRound() }
        .onDisappear { SpeechHelper.stop() }
    }

    func cardColor(displayIndex: Int, originalIndex: Int) -> Color {
        guard let result = showResult, tappedIndex != nil else {
            return .white.opacity(0.92)
        }
        if originalIndex == currentRound.oddIndex {
            // Highlight the odd card on a win or on the final reveal —
            // not on a first miss, so the retry stays a real challenge.
            return (result || showExplanation) ? Color.green.opacity(0.3) : .white.opacity(0.5)
        }
        return .white.opacity(0.5)
    }

    /// Generates a fresh round: N-1 items from one category plus one
    /// intruder from another. Categories rotate so no two consecutive
    /// rounds share a base.
    func makeRound() -> OddOneOutRound {
        let bases = OddCategory.all.filter { $0.name != lastCategoryName && $0.items.count >= itemCount - 1 }
        let base = bases.randomElement() ?? OddCategory.all[0]
        let odd = OddCategory.all.filter { $0.name != base.name }.randomElement() ?? OddCategory.all[1]
        lastCategoryName = base.name

        let baseItems = base.items.shuffled().prefix(itemCount - 1)
        let intruder = odd.items.randomElement()!
        let items = baseItems.map(\.emoji) + [intruder.emoji]
        let article = "aeiou".contains(base.singular.first ?? " ") ? "an" : "a"
        return OddOneOutRound(
            items: items,
            oddIndex: items.count - 1,
            category: base.name,
            explanation: "The \(intruder.name) is not \(article) \(base.singular)!"
        )
    }

    func setupRound() {
        currentRound = makeRound()
        showResult = nil
        showExplanation = false
        missedOnce = false
        tappedIndex = nil
        roundNumber += 1
        shuffledItems = currentRound.items.enumerated().map { (item: $1, originalIndex: $0) }.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SpeechHelper.speak("Find the odd one out!")
        }
    }

    func checkAnswer(originalIndex: Int, displayIndex: Int) {
        tappedIndex = displayIndex

        if originalIndex == currentRound.oddIndex {
            StarBank.shared.award(1, to: GameTheme.oddOneOut.key)
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.win)
            withAnimation {
                showResult = true
                score += 1
                streak += 1
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.oddOneOut.key)
                SoundEngine.shared.play(.streak)
            }
            if !progression.showLevelUp {
                SpeechHelper.speakPreferringClip(currentRound.explanation, fallback: "You did it!")
            }
            withAnimation(.easeIn.delay(0.5)) {
                showExplanation = true
            }
            totalAttempts += 1
        } else if !missedOnce {
            // First miss: a warm nudge and a real second chance.
            missedOnce = true
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            withAnimation { showResult = false }
            streak = 0
            SpeechHelper.speak("Oops! Try again!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    showResult = nil
                    tappedIndex = nil
                }
            }
        } else {
            // Second miss: reveal the answer kindly and move on.
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation {
                showResult = false
                showExplanation = true
            }
            SpeechHelper.speakPreferringClip(currentRound.explanation, fallback: "Oops! Try again!")
            totalAttempts += 1
        }
    }

    func nextRound() {
        // Five correct spots complete an adventure: the chest pops with a
        // bonus instead of silently rolling into the next round.
        if adventure.isComplete {
            StarBank.shared.award(adventure.chestStars, to: GameTheme.oddOneOut.key)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                showAdventureComplete = true
            }
            return
        }
        withAnimation { setupRound() }
    }
}

/// Soft, repeating breathing pulse for the category chip.
private struct CategoryChipGlow: ViewModifier {
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

#Preview {
    NavigationStack {
        OddOneOutGameView()
    }
}
