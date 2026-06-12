import SwiftUI

struct OddOneOutRound: Identifiable {
    let id = UUID()
    let items: [String]
    let oddIndex: Int
    let category: String
    let explanation: String
}

struct OddOneOutGameView: View {
    let rounds: [OddOneOutRound] = [
        OddOneOutRound(items: ["🍎", "🍊", "🍋", "🐶"], oddIndex: 3, category: "Fruits",
                       explanation: "The dog is not a fruit!"),
        OddOneOutRound(items: ["🐱", "🐶", "🐸", "🚗"], oddIndex: 3, category: "Animals",
                       explanation: "The car is not an animal!"),
        OddOneOutRound(items: ["🔴", "🔵", "🟢", "⭐"], oddIndex: 3, category: "Circles",
                       explanation: "The star is not a circle!"),
        OddOneOutRound(items: ["✈️", "🚁", "🚀", "🐟"], oddIndex: 3, category: "Flying",
                       explanation: "The fish doesn't fly!"),
        OddOneOutRound(items: ["🌧️", "☀️", "❄️", "🍕"], oddIndex: 3, category: "Weather",
                       explanation: "Pizza is not weather!"),
        OddOneOutRound(items: ["👟", "🥾", "👢", "🎩"], oddIndex: 3, category: "Shoes",
                       explanation: "The hat is not a shoe!"),
        OddOneOutRound(items: ["🎹", "🎸", "🎺", "🍎"], oddIndex: 3, category: "Instruments",
                       explanation: "An apple is not a musical instrument!"),
        OddOneOutRound(items: ["🌸", "🌻", "🌺", "🐛"], oddIndex: 3, category: "Flowers",
                       explanation: "The bug is not a flower!"),
        OddOneOutRound(items: ["2", "4", "6", "3"], oddIndex: 3, category: "Even Numbers",
                       explanation: "3 is odd, the others are even!"),
        OddOneOutRound(items: ["🐘", "🐋", "🦒", "🐜"], oddIndex: 3, category: "Big Animals",
                       explanation: "The ant is tiny compared to the others!"),
        OddOneOutRound(items: ["🍦", "🧁", "🍰", "🥦"], oddIndex: 3, category: "Sweet Treats",
                       explanation: "Broccoli is a vegetable, not a sweet treat!"),
        OddOneOutRound(items: ["🌙", "⭐", "☀️", "🌊"], oddIndex: 3, category: "Sky Things",
                       explanation: "Waves are in the ocean, not the sky!"),
        OddOneOutRound(items: ["🚗", "🚌", "🚂", "🍌"], oddIndex: 3, category: "Vehicles",
                       explanation: "A banana is not a vehicle!"),
        OddOneOutRound(items: ["A", "B", "C", "3"], oddIndex: 3, category: "Letters",
                       explanation: "3 is a number, not a letter!"),
        OddOneOutRound(items: ["👀", "👃", "👂", "🦶"], oddIndex: 3, category: "Face Parts",
                       explanation: "A foot is not on your face!"),
        OddOneOutRound(items: ["❄️", "⛄", "🧊", "🔥"], oddIndex: 3, category: "Cold Things",
                       explanation: "Fire is hot, not cold!"),
    ]

    @State private var shuffledRounds: [OddOneOutRound] = []
    @State private var currentRoundIndex = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var totalAttempts = 0
    @State private var tappedIndex: Int? = nil
    @State private var showResult: Bool? = nil
    @State private var showExplanation = false
    @State private var shuffledItems: [(item: String, originalIndex: Int)] = []
    @State private var roundNumber = 0

    private let theme = GameTheme.oddOneOut

    var currentRound: OddOneOutRound {
        guard !shuffledRounds.isEmpty else { return rounds[0] }
        return shuffledRounds[currentRoundIndex % shuffledRounds.count]
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .oddOneOut)

            VStack(spacing: 0) {
                // Score
                HStack(spacing: 14) {
                    StarCounterChip(count: score)
                    StreakBadge(streak: streak)

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

                Spacer(minLength: 16)

                VStack(spacing: 26) {
                    MascotBubble(theme: theme, text: "Find the odd one out!\nWhich one doesn't belong?")

                    // Items grid
                    HStack(spacing: 26) {
                        ForEach(Array(shuffledItems.enumerated()), id: \.offset) { displayIndex, entry in
                            Button(action: {
                                checkAnswer(originalIndex: entry.originalIndex, displayIndex: displayIndex)
                            }) {
                                Text(entry.item)
                                    .font(.system(size: 96))
                                    .frame(width: 185, height: 185)
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
                                Text(result ? "Correct!" : "Not quite!")
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
        }
        .navigationTitle("Odd One Out")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledRounds = rounds.shuffled()
            setupRound()
        }
        .onDisappear { SpeechHelper.stop() }
    }

    func cardColor(displayIndex: Int, originalIndex: Int) -> Color {
        guard let result = showResult, tappedIndex != nil else {
            return .white.opacity(0.92)
        }
        if originalIndex == currentRound.oddIndex {
            return result ? Color.green.opacity(0.3) : Color.red.opacity(0.2)
        }
        return .white.opacity(0.5)
    }

    func setupRound() {
        showResult = nil
        showExplanation = false
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
            Haptics.success()
            SoundEngine.shared.play(.win)
            withAnimation {
                showResult = true
                score += 1
                streak += 1
            }
            if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.oddOneOut.key)
                SoundEngine.shared.play(.streak)
            }
            SpeechHelper.speak(currentRound.explanation)
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                showResult = false
                streak = 0
            }
            SpeechHelper.speak("Try again!")
        }

        withAnimation(.easeIn.delay(0.5)) {
            showExplanation = true
        }
        totalAttempts += 1
    }

    func nextRound() {
        withAnimation {
            currentRoundIndex += 1
            if currentRoundIndex >= shuffledRounds.count {
                shuffledRounds = rounds.shuffled()
                currentRoundIndex = 0
            }
            setupRound()
        }
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
