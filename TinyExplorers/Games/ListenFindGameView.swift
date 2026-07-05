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
    @State private var round = 1
    @State private var celebrationMessage = Encouragement.random()
    @State private var progression = GameProgression()

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
                        items: SpyCategory.all.enumerated().map { (title: $0.element.title, value: $0.offset) },
                        selection: $categoryIndex,
                        accent: theme.accent
                    )
                    .onChange(of: categoryIndex) { _ in
                        SoundEngine.shared.play(.pop)
                        newRound()
                    }
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
                    Text("Round \(round)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white.opacity(0.85)))
                }
                .padding(.horizontal, 8)

                if let target {
                    HStack(spacing: 10) {
                        MascotBubble(theme: theme, text: "Find the \(target.name)!", mascotSize: 52)
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
        }
        .kidNavigation(title: "I Spy", theme: theme)
        .onAppear { newRound() }
        .onDisappear { SpeechHelper.stop() }
    }

    private func newRound() {
        celebrating = false
        wrongItem = nil
        let pool = SpyCategory.all[categoryIndex].items.shuffled()
        // Progressive: more items at higher levels (6 → 8 → 9)
        let itemCount = min(9, 6 + progression.level / 3)
        choices = Array(pool.prefix(itemCount))
        target = choices.randomElement()
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
            }
            let delay = progression.showLevelUp ? 2.5 : 1.9
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                round += 1
                withAnimation { newRound() }
            }
        } else {
            streak = 0
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
