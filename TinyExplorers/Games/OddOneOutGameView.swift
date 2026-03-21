import SwiftUI
import AVFoundation

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
    @State private var totalAttempts = 0
    @State private var tappedIndex: Int? = nil
    @State private var showResult: Bool? = nil
    @State private var showExplanation = false
    @State private var shuffledItems: [(item: String, originalIndex: Int)] = []

    let synthesizer = AVSpeechSynthesizer()

    var currentRound: OddOneOutRound {
        guard !shuffledRounds.isEmpty else { return rounds[0] }
        return shuffledRounds[currentRoundIndex % shuffledRounds.count]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.92, blue: 0.85), Color(red: 0.85, green: 0.92, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Score
                HStack {
                    Label("\(score) Correct", systemImage: "star.fill")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Spacer()

                    Text("Category: \(currentRound.category)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.7)))

                    Spacer()

                    Text("Round \(totalAttempts + 1)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)

                Text("Find the odd one out!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Which one doesn't belong with the others?")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                // Items grid
                HStack(spacing: 24) {
                    ForEach(Array(shuffledItems.enumerated()), id: \.offset) { displayIndex, entry in
                        Button(action: {
                            checkAnswer(originalIndex: entry.originalIndex, displayIndex: displayIndex)
                        }) {
                            Text(entry.item)
                                .font(.system(size: 90))
                                .frame(width: 180, height: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(cardColor(displayIndex: displayIndex, originalIndex: entry.originalIndex))
                                        .shadow(radius: tappedIndex == displayIndex ? 10 : 5)
                                )
                                .scaleEffect(tappedIndex == displayIndex ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3), value: tappedIndex)
                        }
                        .disabled(showResult != nil)
                    }
                }

                // Feedback
                if let result = showResult {
                    VStack(spacing: 12) {
                        Text(result ? "Correct!" : "Not quite!")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(result ? .green : .orange)

                        if showExplanation {
                            Text(currentRound.explanation)
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Button("Next Round") {
                                nextRound()
                            }
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(Color.blue))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white.opacity(0.9))
                            .shadow(radius: 6)
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationTitle("Odd One Out")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledRounds = rounds.shuffled()
            setupRound()
        }
    }

    func cardColor(displayIndex: Int, originalIndex: Int) -> Color {
        guard let result = showResult, tappedIndex != nil else {
            return .white.opacity(0.9)
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
        shuffledItems = currentRound.items.enumerated().map { (item: $1, originalIndex: $0) }.shuffled()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            speak("Which one doesn't belong? Find the odd one out!")
        }
    }

    func checkAnswer(originalIndex: Int, displayIndex: Int) {
        tappedIndex = displayIndex

        if originalIndex == currentRound.oddIndex {
            score += 1
            withAnimation { showResult = true }
            speak("Correct! \(currentRound.explanation)")
        } else {
            withAnimation { showResult = false }
            speak("Not that one. Try to find which one is different!")
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

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}

#Preview {
    NavigationStack {
        OddOneOutGameView()
    }
}
