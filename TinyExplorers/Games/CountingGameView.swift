import SwiftUI

struct CountingGameView: View {
    @State private var mode: CountingMode = .numberLine
    @State private var progression = GameProgression(key: GameTheme.counting.key)

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
    @State private var missedThisLine = false
    @State private var shuffled: [Int] = []
    @State private var promptBreathe = false
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting
    let numberColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal, .indigo, .mint]

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                HStack {
                    MascotBubble(theme: theme, text: "Tap numbers in order: 1 to \(maxNumber)", mascotSize: 54)

                    Spacer()

                    AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    showAdventureComplete = false
                    resetGame()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
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
        // The level (not a picker) sets how far we count: L1→10, L2→15 … cap 50.
        maxNumber = min(50, 10 + (progression.level - 1) * 5)
        nextExpected = 1
        tappedNumbers = []
        showComplete = false
        wrongTap = false
        missedThisLine = false
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
                adventure.recordCorrect()
                Haptics.success()
                SoundEngine.shared.play(.win)
                withAnimation { showComplete = true }
                if !progression.showLevelUp {
                    SpeechHelper.speak("You counted to \(maxNumber)!")
                }
                let delay = progression.showLevelUp ? 2.5 : 1.8
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    progression.clearLevelUp()
                    if adventure.isComplete {
                        StarBank.shared.award(adventure.chestStars, to: theme.key)
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                            showAdventureComplete = true
                        }
                    }
                }
            }
        } else {
            wrongTap = true
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            // Count at most one miss per number-line so the chest reward
            // reflects a stumble without a mistap-mashing child zeroing it out.
            if !missedThisLine {
                adventure.recordMiss()
                missedThisLine = true
            }
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
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    var body: some View {
        ZStack {
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

                            if idx < sequence.count - 1 && progression.level < 3 {
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

            AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)

            // Answer options — each with a speaker so a pre-reader can hear it.
            HStack(spacing: 24) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    VStack(spacing: 8) {
                        SpeakOptionButton(text: "\(option)", accent: theme.accent)
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
                    }
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    showAdventureComplete = false
                    setupSkipCount()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
    }

    func setupSkipCount() {
        // Longer sequences and fewer freebie terms as the child levels up.
        let terms = min(12, 6 + progression.level)
        sequence = stride(from: skipBy, through: skipBy * terms, by: skipBy).map { $0 }
        let revealCount = max(1, 4 - progression.level)
        revealed = Set(0..<min(revealCount, sequence.count))
        nextToReveal = revealed.count
        showResult = nil
        generateOptions()
        SpeechHelper.speak("Count by \(skipBy)s! What comes after \(sequence[nextToReveal - 1])?")
    }

    func generateOptions() {
        guard nextToReveal < sequence.count else { return }
        let correct = sequence[nextToReveal]
        // Wider pool of near-miss distractors as the level climbs.
        var pool: [Int] = [-skipBy, skipBy, -1, 1]
        if progression.level >= 3 { pool += [skipBy * 2, -skipBy * 2, 2, -2] }
        if progression.level >= 5 { pool += [skipBy * 3, -skipBy * 3, 3, -3] }
        var opts = Set([correct])
        while opts.count < 4 {
            let candidate = correct + pool.randomElement()!
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
            adventure.recordCorrect()
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
            let delay = progression.showLevelUp ? 2.5 : 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    SoundEngine.shared.play(.win)
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                    return
                }
                withAnimation {
                    showResult = nil
                    nextToReveal += 1
                    if nextToReveal < sequence.count {
                        generateOptions()
                    } else {
                        // Sequence finished but the adventure isn't done yet —
                        // roll a fresh sequence instead of dead-ending on
                        // disabled tiles with no way forward.
                        SoundEngine.shared.play(.win)
                        SpeechHelper.speak("You counted by \(skipBy)s!")
                        setupSkipCount()
                    }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation {
                streak = 0
                showResult = false
            }
            SpeechHelper.speak("\(correct) comes next!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                progression.clearLevelUp()
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
    @State private var streak = 0
    @State private var showResult: String? = nil
    @State private var orBreathe = false
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @State private var previousPair: Set<Int> = []
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    /// Range widens with the child's level — tiny and dot-friendly at first,
    /// up to 1–100 once they're confident. No picker: the level decides.
    private var maxRange: Int {
        switch progression.level {
        case 1: return 10
        case 2: return 20
        case 3: return 30
        case 4: return 50
        default: return 100
        }
    }

    /// Biggest allowed distance between the two numbers: obvious gaps early,
    /// near-neighbours (subtler) as they grow.
    private var maxGap: Int {
        max(1, 8 - (progression.level - 1) * 2)
    }

    var body: some View {
        ZStack {
        VStack(spacing: 26) {
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)
                Spacer()
                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
            }
            .padding(.horizontal, 24)

            Spacer()

            MascotBubble(theme: theme, text: "Which number is bigger?")

            // Two number cards, each with a speaker so a pre-reader can hear it.
            HStack(spacing: 44) {
                VStack(spacing: 10) {
                    compareCard(number: num1, colors: [.blue, .blue.opacity(0.7)])
                    SpeakOptionButton(text: "\(num1)", accent: theme.accent)
                }
                .popIn()

                Text("or")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                VStack(spacing: 10) {
                    compareCard(number: num2, colors: [.purple, .purple.opacity(0.7)])
                    SpeakOptionButton(text: "\(num2)", accent: theme.accent)
                }
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    showAdventureComplete = false
                    newComparison()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
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

                // Base-ten blocks: each tall rod is a ten, each dot a one, so
                // any two different numbers always look visibly different —
                // even past 20, where the old flat 20-dot cap used to mislead.
                quantityBlocks(for: number)
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

    /// Place-value quantity: a rod per ten, a dot per one. Legible past 20 and
    /// guaranteed to differ whenever the two numbers differ.
    private func quantityBlocks(for number: Int) -> some View {
        let tens = number / 10
        let ones = number % 10
        return HStack(alignment: .bottom, spacing: 5) {
            ForEach(0..<tens, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 3)
                    .fill(.white.opacity(0.75))
                    .frame(width: 9, height: 46)
            }
            ForEach(0..<ones, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 11, height: 11)
            }
        }
        .frame(height: 48)
    }

    func newComparison() {
        showResult = nil
        let range = maxRange
        var a = 0
        var b = 0
        var attempts = 0
        // Keep the two numbers within maxGap (shrinks with level) and never
        // repeat the previous unordered pair back-to-back.
        repeat {
            a = Int.random(in: 1...range)
            let delta = Int.random(in: 1...min(maxGap, range - 1))
            b = Bool.random() ? a + delta : a - delta
            if b < 1 { b = a + delta }
            if b > range { b = a - delta }
            attempts += 1
        } while (b == a || b < 1 || b > range || Set([a, b]) == previousPair) && attempts < 12
        if b == a { b = a < range ? a + 1 : a - 1 }
        num1 = a
        num2 = b
        previousPair = Set([a, b])
        SpeechHelper.speak("Which is bigger?")
    }

    func pickNumber(_ picked: Int) {
        let bigger = max(num1, num2)
        if picked == bigger {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            adventure.recordCorrect()
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
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation {
                streak = 0
                showResult = "\(bigger) is bigger than \(min(num1, num2))!"
            }
            SpeechHelper.speak("\(bigger) is bigger!")
        }
        let delay = progression.showLevelUp ? 2.5 : 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            progression.clearLevelUp()
            if adventure.isComplete {
                StarBank.shared.award(adventure.chestStars, to: theme.key)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                    showAdventureComplete = true
                }
            } else {
                newComparison()
            }
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
    @State private var streak = 0
    @State private var showResult: Bool? = nil
    @State private var mysteryPulse = false
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @State private var previousPrompt = ""
    @Binding var progression: GameProgression

    private let theme = GameTheme.counting

    /// Number range grows with the level: gentle low numbers at first, up to
    /// about 50 once they're strong.
    private var maxN: Int { min(50, 10 + progression.level * 5) }

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
        ZStack {
        VStack(spacing: 28) {
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)
                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
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

            // Options — each with a speaker so a pre-reader can hear the choice.
            HStack(spacing: 24) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    VStack(spacing: 8) {
                        SpeakOptionButton(text: "\(option)", accent: theme.accent)
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
                    }
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    showAdventureComplete = false
                    newQuestion()
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
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
        let range = maxN
        // Bias toward the harder "between" prompt as the level rises.
        var types: [QuestionType] = [.before, .after]
        if progression.level >= 2 { types.append(.between) }
        if progression.level >= 4 { types.append(.between) }

        // Re-roll while the prompt matches the previous one, so the same
        // question can't appear twice in a row.
        var chosenType: QuestionType = .before
        var target = 0
        var low = 0
        var signature = ""
        var attempts = 0
        repeat {
            chosenType = types.randomElement()!
            switch chosenType {
            case .before:
                target = Int.random(in: 2...range)
                signature = "before-\(target)"
            case .after:
                target = Int.random(in: 1...(range - 1))
                signature = "after-\(target)"
            case .between:
                low = Int.random(in: 1...(range - 2))
                signature = "between-\(low)"
            }
            attempts += 1
        } while signature == previousPrompt && attempts < 8
        previousPrompt = signature

        questionType = chosenType
        switch chosenType {
        case .before:
            targetNumber = target
            correctAnswer = targetNumber - 1
            SpeechHelper.speak("What comes before \(targetNumber)?")
        case .after:
            targetNumber = target
            correctAnswer = targetNumber + 1
            SpeechHelper.speak("What comes after \(targetNumber)?")
        case .between:
            betweenLow = low
            betweenHigh = low + 2
            correctAnswer = betweenLow + 1
            SpeechHelper.speak("What goes between \(betweenLow) and \(betweenHigh)?")
        }

        // Wider spread of distractors as the level climbs.
        var offsets: [Int] = [-2, -1, 1, 2]
        if progression.level >= 3 { offsets += [3, -3] }
        if progression.level >= 5 { offsets += [4, -4, 5, -5] }
        var opts = Set([correctAnswer])
        var tries = 0
        while opts.count < 4 && tries < 100 {
            let candidate = correctAnswer + offsets.randomElement()!
            if candidate > 0 && candidate != correctAnswer { opts.insert(candidate) }
            tries += 1
        }
        // Guaranteed termination: when the offset spread can't yield four
        // distinct positive options (e.g. "before 2" → correctAnswer 1 at low
        // levels, where offsets reach only {2,3}), fill upward from 1 so the
        // round always has four tappable choices instead of spinning forever.
        var filler = 1
        while opts.count < 4 {
            if filler != correctAnswer { opts.insert(filler) }
            filler += 1
        }
        options = Array(opts).shuffled()
    }

    func checkAnswer(_ answer: Int) {
        if answer == correctAnswer {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            adventure.recordCorrect()
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
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation {
                streak = 0
                showResult = false
            }
            SpeechHelper.speak("The answer is \(correctAnswer)")
        }
        let delay = progression.showLevelUp ? 2.5 : 1.8
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            progression.clearLevelUp()
            if adventure.isComplete {
                StarBank.shared.award(adventure.chestStars, to: theme.key)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                    showAdventureComplete = true
                }
            } else {
                newQuestion()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CountingGameView()
    }
}
