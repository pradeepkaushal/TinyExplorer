import SwiftUI

struct SpyItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let emoji: String

    static func == (a: SpyItem, b: SpyItem) -> Bool { a.name == b.name }
}

struct SpyCategory {
    let title: String
    let items: [SpyItem]

    static let all: [SpyCategory] = [
        SpyCategory(title: "Animals", items: [
            SpyItem(name: "Dog", emoji: "🐶"), SpyItem(name: "Cat", emoji: "🐱"),
            SpyItem(name: "Lion", emoji: "🦁"), SpyItem(name: "Elephant", emoji: "🐘"),
            SpyItem(name: "Frog", emoji: "🐸"), SpyItem(name: "Duck", emoji: "🦆"),
            SpyItem(name: "Owl", emoji: "🦉"), SpyItem(name: "Bee", emoji: "🐝"),
            SpyItem(name: "Fish", emoji: "🐟"), SpyItem(name: "Monkey", emoji: "🐵"),
        ]),
        SpyCategory(title: "Food", items: [
            SpyItem(name: "Apple", emoji: "🍎"), SpyItem(name: "Banana", emoji: "🍌"),
            SpyItem(name: "Pizza", emoji: "🍕"), SpyItem(name: "Cake", emoji: "🎂"),
            SpyItem(name: "Carrot", emoji: "🥕"), SpyItem(name: "Grapes", emoji: "🍇"),
            SpyItem(name: "Cookie", emoji: "🍪"), SpyItem(name: "Milk", emoji: "🥛"),
            SpyItem(name: "Egg", emoji: "🍳"), SpyItem(name: "Corn", emoji: "🌽"),
        ]),
        SpyCategory(title: "Vehicles", items: [
            SpyItem(name: "Car", emoji: "🚗"), SpyItem(name: "Bus", emoji: "🚌"),
            SpyItem(name: "Train", emoji: "🚂"), SpyItem(name: "Rocket", emoji: "🚀"),
            SpyItem(name: "Boat", emoji: "⛵"), SpyItem(name: "Bicycle", emoji: "🚲"),
            SpyItem(name: "Airplane", emoji: "✈️"), SpyItem(name: "Truck", emoji: "🚚"),
            SpyItem(name: "Helicopter", emoji: "🚁"), SpyItem(name: "Tractor", emoji: "🚜"),
        ]),
        SpyCategory(title: "Toys & Things", items: [
            SpyItem(name: "Ball", emoji: "⚽"), SpyItem(name: "Book", emoji: "📖"),
            SpyItem(name: "Umbrella", emoji: "☂️"), SpyItem(name: "Clock", emoji: "⏰"),
            SpyItem(name: "Balloon", emoji: "🎈"), SpyItem(name: "Drum", emoji: "🥁"),
            SpyItem(name: "Kite", emoji: "🪁"), SpyItem(name: "Robot", emoji: "🤖"),
            SpyItem(name: "Crown", emoji: "👑"), SpyItem(name: "Gift", emoji: "🎁"),
        ]),
    ]
}

/// I Spy — the narrator names something; the kid finds it in the grid.
/// Trains careful listening and word-object mapping. Every prompt is voice
/// first, so pre-readers can play alone.
struct ListenFindGameView: View {
    @State private var categoryIndex = 0
    @State private var choices: [SpyItem] = []
    @State private var target: SpyItem? = nil
    @State private var score = 0
    @State private var streak = 0
    @State private var celebrating = false
    @State private var wrongItem: SpyItem? = nil
    @State private var celebrationMessage = Encouragement.random()
    @State private var progression = GameProgression(key: GameTheme.listen.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @State private var lastTargetName: String? = nil
    @State private var missRecordedThisRound = false

    private let hints = [
        "Listen carefully to the name!",
        "Tap the speaker to hear it again!",
        "Say the word out loud, then find it!",
        "You're a great listener — go fast!",
    ]

    private let theme = GameTheme.listen
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ThemedSegmentedPicker(
                        items: SpyCategory.all.enumerated().map {
                            (title: Self.categoryEmoji(for: $0.element.title) + " " + $0.element.title, value: $0.offset)
                        },
                        selection: $categoryIndex,
                        accent: theme.accent
                    )
                    .onChange(of: categoryIndex) { _ in
                        SoundEngine.shared.play(.pop)
                        SpeechHelper.speak(SpyCategory.all[categoryIndex].title)
                        lastTargetName = nil
                        newRound()
                    }
                    .disabled(celebrating || showAdventureComplete)
                }

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)
                    Spacer()
                    AdventureTrail(
                        progress: adventure.completedInRound,
                        goal: adventure.goal,
                        theme: theme
                    )
                }
                .padding(.horizontal, 8)

                if let target {
                    HStack(spacing: 10) {
                        MascotBubble(
                            theme: theme,
                            text: progression.level >= 4 ? "Find it — listen!" : "Find the \(target.name)!",
                            mascotSize: 52
                        )
                        Button {
                            Haptics.tap()
                            SoundEngine.shared.play(.tap)
                            SpeechHelper.speak("Find the \(target.name)!")
                        } label: {
                            Image(systemName: "speaker.wave.2.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(theme.accent)
                                .background(Circle().fill(.white).padding(4))
                        }
                        .buttonStyle(SquishyButtonStyle())
                    }
                }

                Spacer(minLength: 0)

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Array(choices.enumerated()), id: \.element.id) { index, item in
                        Button {
                            pick(item)
                        } label: {
                            VStack(spacing: 6) {
                                Text(item.emoji)
                                    .font(.system(size: 76))
                                // No text label: this is a LISTENING game.
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.white.opacity(wrongItem == item ? 0.6 : 0.94))
                                    .shadow(color: theme.accent.opacity(0.22), radius: 6, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        wrongItem == item ? Color.red.opacity(0.5) : theme.accent.opacity(0.35),
                                        lineWidth: 3
                                    )
                            )
                            .rotationEffect(.degrees(wrongItem == item ? 4 : 0))
                            .animation(
                                wrongItem == item
                                    ? .easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)
                                    : .default,
                                value: wrongItem
                            )
                        }
                        .buttonStyle(SquishyButtonStyle())
                        .disabled(celebrating)
                        .popIn(delay: Double(index) * 0.06)
                    }
                }
                .padding(.horizontal, 40)

                Spacer(minLength: 0)
            }
            .padding(.top, 10)
            .padding(.horizontal, 30)

            if celebrating, let target {
                CelebrationOverlayEnhanced(message: celebrationMessage, emoji: target.emoji)
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
                        newRound()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "I Spy", theme: theme)
        .onAppear { newRound() }
        .onDisappear { SpeechHelper.stop() }
    }

    /// Representative emoji per category so a pre-reader can both see and
    /// (via the spoken title) hear which segment is which.
    private static func categoryEmoji(for title: String) -> String {
        switch title {
        case "Animals": return "🐾"
        case "Food": return "🍎"
        case "Vehicles": return "🚗"
        default: return "🧸"
        }
    }

    private func newRound() {
        celebrating = false
        wrongItem = nil
        missRecordedThisRound = false

        let pool = SpyCategory.all[categoryIndex].items.shuffled()
        // Progressive: deeper ramp fills the full 10-item pool (L1=6 … L5=10).
        let itemCount = min(pool.count, 5 + progression.level)
        var built = Array(pool.prefix(itemCount))

        // Anti-repeat: never make the previous round's item the target again.
        let candidates = built.count > 1 ? built.filter { $0.name != lastTargetName } : built
        let chosen = candidates.randomElement() ?? built.randomElement()

        // Higher levels: sprinkle in subtler cross-category distractors so the
        // find is genuinely harder and less predictable as the child grows.
        if progression.level >= 4, let chosen {
            let crossCount = max(1, (itemCount - 1) / 3)
            var kept = built.filter { $0.name == chosen.name }
            let currentDistractors = built.filter { $0.name != chosen.name }
            let keepCurrentCount = max(0, currentDistractors.count - crossCount)
            kept.append(contentsOf: currentDistractors.prefix(keepCurrentCount))
            var seenNames = Set(kept.map { $0.name })
            let others = SpyCategory.all.enumerated()
                .filter { $0.offset != categoryIndex }
                .flatMap { $0.element.items }
                .shuffled()
            for candidate in others where kept.count < itemCount {
                if seenNames.insert(candidate.name).inserted {
                    kept.append(candidate)
                }
            }
            built = kept
        }

        built.shuffle()
        choices = built
        target = chosen
        lastTargetName = target?.name
        if let target {
            SpeechHelper.speak("Find the \(target.name)!")
        }
    }

    private func pick(_ item: SpyItem) {
        guard let target, !celebrating else { return }
        if item == target {
            celebrationMessage = Encouragement.random()
            score += 1
            streak += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            if !progression.showLevelUp {
                SpeechHelper.cheer(celebrationMessage)
            }
            if !progression.showLevelUp, streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    SoundEngine.shared.play(.streak)
                }
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                celebrating = true
                adventure.recordCorrect()
            }
            let delay = progression.showLevelUp ? 2.5 : 1.9
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    // Pop the chest: bonus stars scale with how clean the run was.
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    celebrating = false
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { newRound() }
                }
            }
        } else {
            streak = 0
            // Every wrong tap feeds difficulty relief, so a child who is over
            // their head genuinely gets gentler rounds (the level quietly steps
            // down once the recent window fills with misses). The adventure
            // chest still treats a whole round as at most one miss, so fumbling
            // within a single round doesn't wipe out the clean-run bonus.
            progression.registerWrong()
            if !missRecordedThisRound {
                adventure.recordMiss()
                missRecordedThisRound = true
            }
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Oops, that's the \(item.name). Find the \(target.name)!")
            withAnimation { wrongItem = item }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongItem = nil
            }
        }
    }
}

#Preview {
    NavigationStack { ListenFindGameView() }
}
