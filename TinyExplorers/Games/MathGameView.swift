import SwiftUI

struct MathGameView: View {
    @State private var num1 = 1
    @State private var num2 = 1
    @State private var operation: MathOperation = .addition
    @State private var options: [Int] = []
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var totalQuestions = 0
    @State private var streak = 0
    @State private var showResult: Bool? = nil
    @State private var difficulty: MathDifficulty = .easy
    @State private var bounceAnswer = false
    @State private var idlePulse = false
    @State private var progression = GameProgression()

    private let hints = [
        "Count on your fingers to help you!",
        "Take your time — no rush!",
        "Look at the pictures for a clue!",
        "You're doing great — keep going!",
        "Try doing it in your head now!",
    ]

    private let theme = GameTheme.math

    enum MathOperation: String, CaseIterable {
        case addition = "Add +"
        case subtraction = "Subtract −"
        case multiplication = "Multiply ×"
        case counting = "Counting"

        var symbol: String {
            switch self {
            case .addition: return "+"
            case .subtraction: return "−"
            case .multiplication: return "×"
            case .counting: return ""
            }
        }
    }

    enum MathDifficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    /// Auto-scales difficulty based on progression level.
    private func currentDifficulty() -> MathDifficulty {
        switch progression.level {
        case 1...2: return .easy
        case 3...5: return .medium
        default: return .hard
        }
    }

    /// Number range per operation: Hard goes up to 50 for +/−,
    /// multiplication uses times-table factors up to 12.
    private func range(for op: MathOperation) -> ClosedRange<Int> {
        let diff = currentDifficulty()
        switch op {
        case .addition, .subtraction:
            switch difficulty {
            case .easy: return 1...5
            case .medium: return 1...10
            case .hard: return 1...50
            }
        case .multiplication:
            switch difficulty {
            case .easy: return 1...5
            case .medium: return 1...10
            case .hard: return 1...12
            }
        case .counting:
            switch difficulty {
            case .easy: return 1...5
            case .medium: return 1...10
            case .hard: return 1...20
            }
        }
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .math)

            VStack(spacing: 18) {
                // Controls: operation picker only (difficulty auto-scales)
                VStack(spacing: 10) {
                    ThemedSegmentedPicker(
                        items: MathOperation.allCases.map { (title: $0.rawValue, value: $0) },
                        selection: $operation,
                        accent: theme.accent
                    )
                    .onChange(of: operation) { _ in generateQuestion() }

                    GameProgressHeader(
                        level: progression.level,
                        correctInLevel: progression.correctInLevel,
                        neededForNextLevel: progression.neededForNextLevel,
                        theme: theme,
                        hint: progression.currentHint(from: hints)
                    )
                }
                .padding(.horizontal, 20)

                // Score + streak
                HStack(spacing: 16) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)

                    if totalQuestions > 0 {
                        Text("\(Int(Double(score) / Double(totalQuestions) * 100))%")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(.white.opacity(0.85)))
                    }
                }

                Spacer()

                // Question display
                if operation == .counting {
                    countingView
                } else {
                    arithmeticView
                }

                // Answer options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 22), count: 2), spacing: 22) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                        Button(action: { checkAnswer(option) }) {
                            Text("\(option)")
                                .font(.system(size: 58, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                colors: [theme.accent, theme.accent.opacity(0.65)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.6), lineWidth: 3)
                                        )
                                        .shadow(color: theme.accent.opacity(0.5), radius: 10, y: 5)
                                )
                        }
                        .buttonStyle(SquishyButtonStyle())
                        .disabled(showResult != nil)
                        .popIn(delay: Double(index) * 0.04)
                    }
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 40)

                // Feedback
                if let result = showResult {
                    HStack(spacing: 12) {
                        Text(result ? Encouragement.random() : "The answer is \(correctAnswer)")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(result ? .green : .orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(.white.opacity(0.9))
                                    .shadow(color: (result ? Color.green : Color.orange).opacity(0.3), radius: 6, y: 3)
                            )

                        if result {
                            Text("⭐")
                                .font(.system(size: 38))
                                .scaleEffect(bounceAnswer ? 1.4 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.3), value: bounceAnswer)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 12)

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Math Fun", theme: theme)
        .onAppear {
            generateQuestion()
            idlePulse = true
        }
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Question cards

    /// Emoji groups only stay readable for small numbers.
    private var showsEmojiGroups: Bool {
        switch operation {
        case .multiplication: return num1 <= 4 && num2 <= 6
        default: return num1 <= 10 && num2 <= 10
        }
    }

    private var questionCardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white.opacity(0.88))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(theme.accent.opacity(0.5), lineWidth: 2.5)
            )
            .shadow(color: theme.accent.opacity(0.3), radius: 9, y: 5)
    }

    var arithmeticView: some View {
        Group {
            if operation == .multiplication {
                multiplicationContent
            } else if showsEmojiGroups {
                emojiArithmeticContent
            } else {
                numeralContent
            }
        }
        .padding(28)
        .background(questionCardBackground)
        .popIn()
    }

    private var emojiArithmeticContent: some View {
        HStack(spacing: 22) {
            emojiGroup(count: num1, label: num1, faded: false)

            Text(operation.symbol)
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            emojiGroup(count: num2, label: num2, faded: operation == .subtraction)

            Text("=")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.purple)

            Text("?")
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
    }

    private func emojiGroup(count: Int, label: Int, faded: Bool) -> some View {
        VStack(spacing: 8) {
            let cols = min(count, 5)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 4), count: max(cols, 1)), spacing: 4) {
                ForEach(0..<count, id: \.self) { _ in
                    Text("🍎")
                        .font(.system(size: 38))
                        .opacity(faded ? 0.4 : 1.0)
                }
            }
            Text("\(label)")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    private var numeralContent: some View {
        HStack(spacing: 22) {
            Text("\(num1)")
                .font(.system(size: 84, weight: .heavy, design: .rounded))
                .foregroundColor(theme.accent)
            Text(operation.symbol)
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            Text("\(num2)")
                .font(.system(size: 84, weight: .heavy, design: .rounded))
                .foregroundColor(theme.accent)
            Text("=")
                .font(.system(size: 62, weight: .bold, design: .rounded))
                .foregroundColor(.purple)
            Text("?")
                .font(.system(size: 84, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
    }

    private var multiplicationContent: some View {
        VStack(spacing: 16) {
            numeralContent

            // Show "num1 groups of num2" when small enough to read
            if showsEmojiGroups {
                VStack(spacing: 6) {
                    ForEach(0..<num1, id: \.self) { _ in
                        HStack(spacing: 5) {
                            ForEach(0..<num2, id: \.self) { _ in
                                Text("🍎")
                                    .font(.system(size: 30))
                            }
                        }
                    }
                }
                Text("\(num1) groups of \(num2)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }

    var countingView: some View {
        VStack(spacing: 18) {
            MascotBubble(theme: theme, text: "How many apples?", mascotSize: 54)

            // Grid of items to count
            let cols = min(num1, 5)
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: max(cols, 1))
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(0..<num1, id: \.self) { index in
                    Text("🍎")
                        .font(.system(size: 56))
                        .popIn(delay: Double(index) * 0.04)
                }
            }
            .frame(maxWidth: 340)
            .padding(28)
            .background(questionCardBackground)
            .popIn()
        }
    }

    // MARK: - Logic

    func generateQuestion() {
        showResult = nil
        let r = range(for: operation)

        switch operation {
        case .addition:
            num1 = Int.random(in: r)
            num2 = Int.random(in: r)
            correctAnswer = num1 + num2

        case .subtraction:
            num1 = Int.random(in: r)
            num2 = Int.random(in: 1...num1)
            correctAnswer = num1 - num2

        case .multiplication:
            num1 = Int.random(in: r)
            num2 = Int.random(in: r)
            correctAnswer = num1 * num2

        case .counting:
            num1 = Int.random(in: r)
            correctAnswer = num1
        }

        // Generate 4 options including the correct answer
        var opts = Set<Int>()
        opts.insert(correctAnswer)
        let offsets: [Int]
        if operation == .multiplication {
            // Near-miss table values make better distractors
            offsets = [num1, -num1, num2, -num2, num1 * 2, 1, -1, 2]
        } else {
            offsets = [-3, -2, -1, 1, 2, 3]
        }
        while opts.count < 4 {
            let candidate = max(0, correctAnswer + (offsets.randomElement() ?? 1))
            if candidate != correctAnswer {
                opts.insert(candidate)
            }
        }
        options = Array(opts).shuffled()
    }

    func checkAnswer(_ answer: Int) {
        totalQuestions += 1

        if answer == correctAnswer {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                streak += 1
                showResult = true
                bounceAnswer = true
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                SoundEngine.shared.play(.streak)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceAnswer = false }

            if !progression.showLevelUp {
                SpeechHelper.cheer(Encouragement.random())
            }

            let delay = progression.showLevelUp ? 2.5 : 1.3
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                withAnimation { generateQuestion() }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                streak = 0
                showResult = false
            }

            SpeechHelper.speak("The answer is \(correctAnswer).")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { generateQuestion() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MathGameView()
    }
}
