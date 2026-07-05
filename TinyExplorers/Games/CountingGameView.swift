import SwiftUI

struct CountingGameView: View {
    @State private var mode: CountingMode = .numberLine
    @State private var progression = GameProgression()

    private let hints = [
        "Tap numbers in the right order!",
        "Count by 2s, 5s, or 10s to go faster!",
        "Which number is bigger or smaller?",
        "You're a number expert now!",
    ]

    private let theme = GameTheme.counting

    enum CountingMode: String, CaseIterable {
        case numberLine = "Number Line"
        case skipCount = "Skip Count"
        case compare = "Compare"
        case beforeAfter = "Before & After"
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .counting)

            VStack(spacing: 12) {
                ThemedSegmentedPicker(
                    items: CountingMode.allCases.map { (title: $0.rawValue, value: $0) },
                    selection: $mode,
                    accent: theme.accent
                )
                .padding(.horizontal, 40)

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                switch mode {
                case .numberLine:
                    NumberLineView(progression: $progression)
                case .skipCount:
                    SkipCountView(progression: $progression)
                case .compare:
                    CompareView(progression: $progression)
                case .beforeAfter:
                    BeforeAfterView(progression: $progression)
                }
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Number Counting", theme: theme)
        .onDisappear { SpeechHelper.stop() }
    }
}

// MARK: - Number Line (tap numbers in order)
struct NumberLineView: View {
    @State private var nextExpected = 1
    @State private var tappedNumbers: Set<Int> = []
    @State private var maxNumber = 10
    @State private var showComplete = false
    @State private var wrongTap = false
    @State private var shuffled: [Int] = []
    @State private var promptBreathe = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting
    let numberColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal, .indigo, .mint]

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                HStack {
                    MascotBubble(theme: theme, text: "Tap numbers in order: 1 to \(maxNumber)", mascotSize: 54)

                    Spacer()

                    ThemedSegmentedPicker(
                        items: [
                            (title: "1-10", value: 10),
                            (title: "1-20", value: 20),
                            (title: "1-30", value: 30),
                            (title: "1-50", value: 50),
                        ],
                        selection: $maxNumber,
                        accent: theme.accent
                    )
                    .onChange(of: maxNumber) { _ in resetGame() }
                }
                .padding(.horizontal, 24)

                progressBar
                    .padding(.horizontal, 24)

                Spacer()

                Text(wrongTap ? "Oops! Find number \(nextExpected)!" : "Tap number \(nextExpected)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(wrongTap ? .red : theme.accent)
                    .animation(.easeInOut, value: wrongTap)
                    .padding(.bottom, 4)

                numberGrid

                if showComplete {
                    Button("Count Again") {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        resetGame()
                    }
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(theme.accent)
                            .shadow(color: theme.accent.opacity(0.4), radius: 6, y: 4)
                    )
                    .buttonStyle(SquishyButtonStyle())
                    .transition(.scale)
                }

                Spacer()
            }

            if showComplete {
                CelebrationOverlayEnhanced(message: "You counted to \(maxNumber)!", emoji: "🔢")
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            resetGame()
            promptBreathe = true
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(theme.accent.opacity(0.35), lineWidth: 2)
                    )
                    .frame(height: 28)
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, .mint],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geo.size.width * CGFloat(nextExpected - 1) / CGFloat(maxNumber)), height: 28)
                    .shadow(color: theme.accent.opacity(0.4), radius: 4, y: 2)
                    .animation(.spring(), value: nextExpected)
            }
        }
        .frame(height: 28)
    }

    private var numberGrid: some View {
        let cols = maxNumber <= 10 ? 5 : (maxNumber <= 30 ? 6 : 10)
        let tileHeight: CGFloat = maxNumber <= 30 ? 78 : 62
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: cols)
        return LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(Array(shuffled.enumerated()), id: \.element) { index, num in
                Button(action: { tapNumber(num) }) {
                    Text("\(num)")
                        .font(.system(size: maxNumber <= 30 ? 34 : 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: tileHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tappedNumbers.contains(num) ?
                                      Color.green.opacity(0.4) :
                                      numberColors[(num - 1) % numberColors.count])
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
                        )
                        .scaleEffect(tappedNumbers.contains(num) ? 0.9 : 1.0)
                }
                .buttonStyle(SquishyButtonStyle())
                .disabled(tappedNumbers.contains(num) || showComplete)
                .popIn(delay: min(Double(index) * 0.04, 1.0))
            }
        }
        .padding(.horizontal, 20)
    }

    func resetGame() {
        nextExpected = 1
        tappedNumbers = []
        showComplete = false
        wrongTap = false
        shuffled = Array(1...maxNumber).shuffled()
        SpeechHelper.speak("Tap number 1 first!")
    }

    func tapNumber(_ num: Int) {
        if num == nextExpected {
            tappedNumbers.insert(num)
            wrongTap = false
            Haptics.tap()
            SoundEngine.shared.play(.pop)
            SpeechHelper.speak("\(num)")
            nextExpected += 1

            if nextExpected > maxNumber {
                StarBank.shared.award(1, to: theme.key)
                progression.registerCorrect()
                Haptics.success()
                SoundEngine.shared.play(.win)
                withAnimation { showComplete = true }
                if !progression.showLevelUp {
                    SpeechHelper.speak("You counted to \(maxNumber)!")
                }
            }
        } else {
            wrongTap = true
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Find number \(nextExpected)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                wrongTap = false
            }
        }
    }
}

// MARK: - Skip Counting (2s, 5s, 10s)
struct SkipCountView: View {
    @State private var skipBy = 2
    @State private var sequence: [Int] = []
    @State private var revealed: Set<Int> = []
    @State private var nextToReveal = 0
    @State private var options: [Int] = []
    @State private var showResult: Bool? = nil
    @State private var score = 0
    @State private var streak = 0
    @State private var hintPulse = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)

                Spacer()

                Text("Count by:")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))

                ThemedSegmentedPicker(
                    items: [
                        (title: "2s", value: 2),
                        (title: "5s", value: 5),
                        (title: "10s", value: 10),
                    ],
                    selection: $skipBy,
                    accent: theme.accent
                )
                .onChange(of: skipBy) { _ in setupSkipCount() }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Sequence display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(sequence.enumerated()), id: \.offset) { idx, num in
                        VStack(spacing: 4) {
                            if revealed.contains(idx) {
                                Text("\(num)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.accent)
                                    .transition(.scale)
                            } else if idx == nextToReveal {
                                Text("?")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            } else {
                                Text("_")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.4))
                            }

                            if idx < sequence.count - 1 {
                                Text("+\(skipBy)")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 80, height: 92)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(revealed.contains(idx) ? theme.accent.opacity(0.15) :
                                        idx == nextToReveal ? Color.orange.opacity(0.18) : Color.white.opacity(0.75))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            idx == nextToReveal ? Color.orange : theme.accent.opacity(revealed.contains(idx) ? 0.8 : 0.3),
                                            lineWidth: 2.5
                                        )
                                )
                                .shadow(color: theme.accent.opacity(0.2), radius: 4, y: 3)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
            }

            MascotBubble(theme: theme, text: "What comes next? Count by \(skipBy)s!", mascotSize: 54)

            // Answer options
            HStack(spacing: 24) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button(action: { checkSkipAnswer(option) }) {
                        Text("\(option)")
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 110)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.accent, theme.accent.opacity(0.7)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.white.opacity(0.55), lineWidth: 2.5)
                                    )
                                    .shadow(color: theme.accent.opacity(0.45), radius: 7, y: 4)
                            )
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .disabled(showResult != nil || nextToReveal >= sequence.count)
                    .popIn(delay: Double(index) * 0.04)
                }
            }

            if let result = showResult {
                Text(result ? Encouragement.random() : "Not quite. \(sequence[min(nextToReveal, sequence.count - 1)]) comes next!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(result ? .green : .orange)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear {
            setupSkipCount()
            hintPulse = true
        }
    }

    func setupSkipCount() {
        sequence = stride(from: skipBy, through: skipBy * 10, by: skipBy).map { $0 }
        revealed = [0] // reveal the first number
        nextToReveal = 1
        showResult = nil
        generateOptions()
        SpeechHelper.speak("Count by \(skipBy)s! What comes after \(sequence[0])?")
    }

    func generateOptions() {
        guard nextToReveal < sequence.count else { return }
        let correct = sequence[nextToReveal]
        var opts = Set([correct])
        while opts.count < 4 {
            let offset = [-skipBy, skipBy, -1, 1, skipBy * 2, -skipBy * 2].randomElement()!
            let candidate = correct + offset
            if candidate > 0 && candidate != correct { opts.insert(candidate) }
        }
        options = Array(opts).shuffled()
    }

    func checkSkipAnswer(_ answer: Int) {
        guard nextToReveal < sequence.count else { return }
        let correct = sequence[nextToReveal]
        if answer == correct {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                streak += 1
                revealed.insert(nextToReveal)
                showResult = true
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                SoundEngine.shared.play(.streak)
            }
            if !progression.showLevelUp {
                SpeechHelper.speak("\(correct)!")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showResult = nil
                    nextToReveal += 1
                    if nextToReveal < sequence.count {
                        generateOptions()
                    } else {
                        SoundEngine.shared.play(.win)
                        if !progression.showLevelUp {
                            SpeechHelper.speak("You counted by \(skipBy)s!")
                        }
                    }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                streak = 0
                showResult = false
            }
            SpeechHelper.speak("\(correct) comes next!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showResult = nil }
            }
        }
    }
}

// MARK: - Compare Numbers (Greater / Smaller)
struct CompareView: View {
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var score = 0
    @State private var total = 0
    @State private var streak = 0
    @State private var showResult: String? = nil
    @State private var maxRange = 20
    @State private var orBreathe = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    var body: some View {
        VStack(spacing: 26) {
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)
                Spacer()
                ThemedSegmentedPicker(
                    items: [
                        (title: "1-10", value: 10),
                        (title: "1-20", value: 20),
                        (title: "1-50", value: 50),
                        (title: "1-100", value: 100),
                    ],
                    selection: $maxRange,
                    accent: theme.accent
                )
                .onChange(of: maxRange) { _ in newComparison() }
            }
            .padding(.horizontal, 24)

            Spacer()

            MascotBubble(theme: theme, text: "Which number is bigger?")

            // Two number cards
            HStack(spacing: 44) {
                compareCard(number: num1, colors: [.blue, .blue.opacity(0.7)])
                    .popIn()

                Text("or")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                compareCard(number: num2, colors: [.purple, .purple.opacity(0.7)])
                    .popIn(delay: 0.08)
            }

            if let result = showResult {
                Text(result)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(result.contains("Correct") ? .green : .orange)
                    .multilineTextAlignment(.center)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear {
            newComparison()
            orBreathe = true
        }
    }

    private func compareCard(number: Int, colors: [Color]) -> some View {
        Button(action: { pickNumber(number) }) {
            VStack(spacing: 10) {
                Text("\(number)")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)

                // Visual dots
                let dotCount = min(number, 20)
                let dotCols = min(dotCount, 5)
                if dotCount > 0 {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(14), spacing: 5), count: dotCols), spacing: 5) {
                        ForEach(0..<dotCount, id: \.self) { _ in
                            Circle().fill(.white.opacity(0.6)).frame(width: 12, height: 12)
                        }
                    }
                }
            }
            .frame(width: 210, height: 240)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.55), lineWidth: 2.5)
                    )
                    .shadow(color: colors[0].opacity(0.45), radius: 8, y: 5)
            )
        }
        .buttonStyle(SquishyButtonStyle())
        .disabled(showResult != nil)
    }

    func newComparison() {
        showResult = nil
        num1 = Int.random(in: 1...maxRange)
        repeat { num2 = Int.random(in: 1...maxRange) } while num2 == num1
        SpeechHelper.speak("Which is bigger?")
    }

    func pickNumber(_ picked: Int) {
        total += 1
        let bigger = max(num1, num2)
        if picked == bigger {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                streak += 1
                showResult = "Correct! \(bigger) is bigger!"
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                SoundEngine.shared.play(.streak)
            }
            if !progression.showLevelUp {
                SpeechHelper.speak("Yes! \(bigger) is bigger!")
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                streak = 0
                showResult = "\(bigger) is bigger than \(min(num1, num2))!"
            }
            SpeechHelper.speak("\(bigger) is bigger!")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            newComparison()
        }
    }
}

// MARK: - Before & After
struct BeforeAfterView: View {
    @State private var targetNumber = 5
    @State private var questionType: QuestionType = .before
    @State private var options: [Int] = []
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var total = 0
    @State private var streak = 0
    @State private var showResult: Bool? = nil
    @State private var mysteryPulse = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    enum QuestionType {
        case before, after, between
    }

    private var questionPrompt: String {
        switch questionType {
        case .before: return "What comes BEFORE?"
        case .after: return "What comes AFTER?"
        case .between: return "What goes BETWEEN?"
        }
    }

    @State private var betweenLow = 0
    @State private var betweenHigh = 0

    var body: some View {
        VStack(spacing: 28) {
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)
            }

            Spacer()

            // Question
            MascotBubble(theme: theme, text: questionPrompt)

            VStack(spacing: 16) {
                switch questionType {
                case .before:
                    HStack(spacing: 18) {
                        mysteryBox(size: 104)
                        arrow
                        numberBox(targetNumber, size: 104)
                    }

                case .after:
                    HStack(spacing: 18) {
                        numberBox(targetNumber, size: 104)
                        arrow
                        mysteryBox(size: 104)
                    }

                case .between:
                    HStack(spacing: 16) {
                        numberBox(betweenLow, size: 94)
                        arrow
                        mysteryBox(size: 94)
                        arrow
                        numberBox(betweenHigh, size: 94)
                    }
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(theme.accent.opacity(0.5), lineWidth: 2.5)
                    )
                    .shadow(color: theme.accent.opacity(0.3), radius: 8, y: 5)
            )
            .popIn()

            // Options
            HStack(spacing: 24) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button(action: { checkAnswer(option) }) {
                        Text("\(option)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 130, height: 116)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.accent, theme.accent.opacity(0.7)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.white.opacity(0.55), lineWidth: 2.5)
                                    )
                                    .shadow(color: theme.accent.opacity(0.45), radius: 7, y: 4)
                            )
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .disabled(showResult != nil)
                    .popIn(delay: Double(index) * 0.04)
                }
            }

            if let result = showResult {
                Text(result ? Encouragement.random() : "The answer is \(correctAnswer)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(result ? .green : .orange)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear {
            newQuestion()
            mysteryPulse = true
        }
    }

    private var arrow: some View {
        Text("→")
            .font(.system(size: 40))
            .foregroundColor(theme.accent)
    }

    private func numberBox(_ n: Int, size: CGFloat) -> some View {
        Text("\(n)")
            .font(.system(size: size * 0.62, weight: .bold, design: .rounded))
            .foregroundColor(.blue)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.blue.opacity(0.1)))
    }

    private func mysteryBox(size: CGFloat) -> some View {
        Text("?")
            .font(.system(size: size * 0.62, weight: .bold, design: .rounded))
            .foregroundColor(.orange)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .foregroundColor(.orange)
            )
    }

    func newQuestion() {
        showResult = nil
        let types: [QuestionType] = [.before, .after, .between]
        questionType = types.randomElement()!

        switch questionType {
        case .before:
            targetNumber = Int.random(in: 2...20)
            correctAnswer = targetNumber - 1
            SpeechHelper.speak("What comes before \(targetNumber)?")
        case .after:
            targetNumber = Int.random(in: 1...19)
            correctAnswer = targetNumber + 1
            SpeechHelper.speak("What comes after \(targetNumber)?")
        case .between:
            betweenLow = Int.random(in: 1...18)
            betweenHigh = betweenLow + 2
            correctAnswer = betweenLow + 1
            SpeechHelper.speak("What goes between \(betweenLow) and \(betweenHigh)?")
        }

        var opts = Set([correctAnswer])
        while opts.count < 4 {
            let candidate = correctAnswer + [-2, -1, 1, 2, 3].randomElement()!
            if candidate > 0 && candidate != correctAnswer { opts.insert(candidate) }
        }
        options = Array(opts).shuffled()
    }

    func checkAnswer(_ answer: Int) {
        total += 1
        if answer == correctAnswer {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                streak += 1
                showResult = true
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                SoundEngine.shared.play(.streak)
            }
            if !progression.showLevelUp {
                SpeechHelper.speak("Yes, \(correctAnswer)!")
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                streak = 0
                showResult = false
            }
            SpeechHelper.speak("The answer is \(correctAnswer)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            newQuestion()
        }
    }
}

#Preview {
    NavigationStack {
        CountingGameView()
    }
}
