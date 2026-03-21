import SwiftUI
import AVFoundation

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
    @State private var totalAttempts = 0
    @State private var showResult: Bool? = nil
    @State private var options: [(emoji: String, name: String)] = []
    @State private var correctAnswer: (emoji: String, name: String) = ("", "")
    @State private var shuffledPatterns: [[( emoji: String, name: String)]] = []

    let synthesizer = AVSpeechSynthesizer()

    var currentPattern: [(emoji: String, name: String)] {
        guard !shuffledPatterns.isEmpty else { return patternSets[0] }
        return shuffledPatterns[currentPatternIndex % shuffledPatterns.count]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 1.0, blue: 0.95), Color(red: 0.95, green: 0.9, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                // Score
                HStack(spacing: 32) {
                    Label("\(score) Correct", systemImage: "star.fill")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Spacer()

                    Text("Pattern \(totalAttempts + 1)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 60)

                Text("What comes next?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                // Pattern display
                HStack(spacing: 16) {
                    ForEach(0..<currentPattern.count, id: \.self) { i in
                        Text(currentPattern[i].emoji)
                            .font(.system(size: 70))
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.white.opacity(0.8))
                                    .shadow(radius: 3)
                            )
                    }

                    // Mystery slot
                    Text("❓")
                        .font(.system(size: 70))
                        .frame(width: 100, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.yellow.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
                                        .foregroundColor(.orange)
                                )
                        )
                }

                // Answer options
                Text("Choose the right answer:")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                HStack(spacing: 24) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        Button(action: {
                            checkAnswer(option)
                        }) {
                            Text(option.emoji)
                                .font(.system(size: 80))
                                .frame(width: 140, height: 140)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                        .shadow(radius: 6)
                                )
                        }
                        .disabled(showResult != nil)
                    }
                }

                // Feedback
                if let result = showResult {
                    Text(result ? "Correct! Great pattern spotting!" : "Not quite. Look at the pattern again!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(result ? .green : .orange)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationTitle("Pattern Fun")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledPatterns = patternSets.shuffled()
            setupRound()
        }
    }

    func setupRound() {
        showResult = nil
        let pattern = currentPattern

        // The answer is the next in the repeating pattern
        // Pattern repeats every N items, find the cycle
        let cycleLength = findCycleLength(pattern)
        let nextIndex = pattern.count % cycleLength
        correctAnswer = pattern[nextIndex]

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
            speak("What comes next in the pattern?")
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
            score += 1
            withAnimation { showResult = true }
            speak("Correct! The next one is \(correctAnswer.name)!")

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
            withAnimation { showResult = false }
            speak("Try again! Look carefully at the pattern.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showResult = nil }
            }
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
        PatternGameView()
    }
}
