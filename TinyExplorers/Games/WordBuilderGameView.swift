import SwiftUI

struct SpellWord: Identifiable {
    let id = UUID()
    let word: String   // uppercase, e.g. "CAT"
    let emoji: String

    var display: String { word.prefix(1) + word.dropFirst().lowercased() }
    var spelled: String {
        word.map(String.init).joined(separator: "-") + " spells \(display)!"
    }
}

/// Spell It! — tap letters in order to build a word for the picture.
/// Bridges knowing letters (ABC game) to reading whole words.
struct WordBuilderGameView: View {
    enum Level: String, CaseIterable {
        case easy = "3 Letters"
        case medium = "4 Letters"
        case hard = "5 Letters"
    }

    static let easyWords = [
        SpellWord(word: "CAT", emoji: "🐱"), SpellWord(word: "DOG", emoji: "🐶"),
        SpellWord(word: "SUN", emoji: "☀️"), SpellWord(word: "HAT", emoji: "🎩"),
        SpellWord(word: "BUS", emoji: "🚌"), SpellWord(word: "CUP", emoji: "🥤"),
        SpellWord(word: "BEE", emoji: "🐝"), SpellWord(word: "PIG", emoji: "🐷"),
        SpellWord(word: "FOX", emoji: "🦊"), SpellWord(word: "EGG", emoji: "🥚"),
    ]
    static let mediumWords = [
        SpellWord(word: "FISH", emoji: "🐟"), SpellWord(word: "FROG", emoji: "🐸"),
        SpellWord(word: "CAKE", emoji: "🎂"), SpellWord(word: "STAR", emoji: "⭐"),
        SpellWord(word: "MOON", emoji: "🌙"), SpellWord(word: "BIRD", emoji: "🐦"),
        SpellWord(word: "DUCK", emoji: "🦆"), SpellWord(word: "BALL", emoji: "⚽"),
        SpellWord(word: "TREE", emoji: "🌳"), SpellWord(word: "BOAT", emoji: "⛵"),
    ]
    static let hardWords = [
        SpellWord(word: "APPLE", emoji: "🍎"), SpellWord(word: "HOUSE", emoji: "🏠"),
        SpellWord(word: "TRAIN", emoji: "🚂"), SpellWord(word: "HEART", emoji: "❤️"),
        SpellWord(word: "SNAKE", emoji: "🐍"), SpellWord(word: "TIGER", emoji: "🐯"),
    ]

    @State private var level: Level = .easy
    @State private var current: SpellWord = WordBuilderGameView.easyWords[0]
    @State private var filledCount = 0
    /// Letter bank: the word's letters plus decoys; consumed tiles fade out.
    @State private var bank: [(letter: Character, used: Bool)] = []
    @State private var wobbleIndex: Int? = nil
    @State private var celebrating = false
    @State private var score = 0
    @State private var queue: [SpellWord] = []
    @State private var progression = GameProgression()

    private let hints = [
        "Tap the letters in order!",
        "Say each letter sound out loud!",
        "Look at the picture for a clue!",
        "You're spelling like a pro now!",
    ]

    private let theme = GameTheme.spelling

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    StarCounterChipEnhanced(count: score)
                    Spacer()
                }

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                MascotBubble(theme: theme, text: "Spell \(current.display)!", mascotSize: 50)

                Spacer(minLength: 0)

                Text(current.emoji)
                    .font(.system(size: 130))
                    .scaleEffect(celebrating ? 1.25 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: celebrating)

                // Letter slots fill up as the kid taps the right letters.
                HStack(spacing: 12) {
                    ForEach(Array(current.word.enumerated()), id: \.offset) { i, ch in
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(i < filledCount ? theme.accent : Color.white.opacity(0.85))
                                .frame(width: 74, height: 74)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            theme.accent.opacity(i < filledCount ? 0 : 0.45),
                                            style: StrokeStyle(lineWidth: 3, dash: i < filledCount ? [] : [8, 6])
                                        )
                                )
                                .shadow(color: theme.accent.opacity(i < filledCount ? 0.4 : 0.1), radius: 6, y: 4)
                            if i < filledCount {
                                Text(String(ch))
                                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                // Letter bank
                HStack(spacing: 14) {
                    ForEach(Array(bank.enumerated()), id: \.offset) { i, tile in
                        Button {
                            tapLetter(at: i)
                        } label: {
                            Text(String(tile.letter))
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundColor(tile.used ? .gray.opacity(0.35) : theme.accent)
                                .frame(width: 78, height: 78)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white.opacity(tile.used ? 0.4 : 0.95))
                                        .shadow(color: theme.accent.opacity(tile.used ? 0 : 0.3), radius: 6, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(theme.accent.opacity(tile.used ? 0.1 : 0.4), lineWidth: 2.5)
                                )
                                .rotationEffect(.degrees(wobbleIndex == i ? 5 : 0))
                                .animation(
                                    wobbleIndex == i
                                        ? .easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)
                                        : .default,
                                    value: wobbleIndex
                                )
                        }
                        .buttonStyle(SquishyButtonStyle())
                        .disabled(tile.used || celebrating)
                        .popIn(delay: Double(i) * 0.05)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 10)
            .padding(.horizontal, 30)

            if celebrating {
                CelebrationOverlayEnhanced(message: current.spelled, emoji: current.emoji)
                    .transition(.scale.combined(with: .opacity))
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Spell It!", theme: theme)
        .onAppear { startRound(newLevel: true) }
        .onDisappear { SpeechHelper.stop() }
    }

    /// Auto-scales word difficulty based on progression level.
    private var currentWords: [SpellWord] {
        switch progression.level {
        case 1...2: return Self.easyWords
        case 3...5: return Self.mediumWords
        default: return Self.hardWords
        }
    }

    private var words: [SpellWord] { currentWords }

    private func startRound(newLevel: Bool = false) {
        if newLevel || queue.isEmpty { queue = words.shuffled() }
        current = queue.removeFirst()
        filledCount = 0
        celebrating = false

        let decoyPool = "ABCDEFGHIJKLMNOPRSTUW".filter { !current.word.contains($0) }
        let decoys = Array(decoyPool.shuffled().prefix(3))
        bank = (Array(current.word) + decoys).shuffled().map { ($0, false) }

        SpeechHelper.speak("Spell \(current.display)!")
    }

    private func tapLetter(at index: Int) {
        let needed = Array(current.word)[filledCount]
        if bank[index].letter == needed {
            Haptics.tap()
            SoundEngine.shared.playTileNote(filledCount)
            SpeechHelper.speak(String(needed))
            bank[index].used = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                filledCount += 1
            }
            if filledCount == current.word.count {
                score += 1
                StarBank.shared.award(1, to: theme.key)
                progression.registerCorrect()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Haptics.success()
                    SoundEngine.shared.play(.win)
                    if !progression.showLevelUp {
                        SpeechHelper.cheer(current.spelled)
                    }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        celebrating = true
                    }
                    let delay = progression.showLevelUp ? 2.5 : 2.4
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        progression.clearLevelUp()
                        // If leveled up, switch to harder words
                        let currentWord = current.word
                        if progression.level <= 2 && !Self.easyWords.contains(where: { $0.word == currentWord }) {
                            queue = Self.easyWords.shuffled()
                        } else if progression.level > 2 && progression.level <= 5 && !Self.mediumWords.contains(where: { $0.word == currentWord }) {
                            queue = Self.mediumWords.shuffled()
                        } else if progression.level > 5 && !Self.hardWords.contains(where: { $0.word == currentWord }) {
                            queue = Self.hardWords.shuffled()
                        }
                        withAnimation { startRound() }
                    }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation { wobbleIndex = index }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wobbleIndex = nil
            }
        }
    }
}

#Preview {
    NavigationStack { WordBuilderGameView() }
}
