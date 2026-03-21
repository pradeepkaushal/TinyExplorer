import SwiftUI
import AVFoundation

struct CountingGameView: View {
    @State private var mode: CountingMode = .numberLine

    enum CountingMode: String, CaseIterable {
        case numberLine = "Number Line"
        case skipCount = "Skip Count"
        case compare = "Compare"
        case beforeAfter = "Before & After"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.92, blue: 1.0), Color(red: 0.95, green: 0.88, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Picker("Mode", selection: $mode) {
                    ForEach(CountingMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)

                switch mode {
                case .numberLine:
                    NumberLineView()
                case .skipCount:
                    SkipCountView()
                case .compare:
                    CompareView()
                case .beforeAfter:
                    BeforeAfterView()
                }
            }
        }
        .navigationTitle("Number Counting")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Number Line (tap numbers in order 1-20)
struct NumberLineView: View {
    @State private var nextExpected = 1
    @State private var tappedNumbers: Set<Int> = []
    @State private var maxNumber = 10
    @State private var showComplete = false
    @State private var wrongTap = false
    let synthesizer = AVSpeechSynthesizer()

    let numberColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .teal, .indigo, .mint]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Tap numbers in order: 1 to \(maxNumber)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Spacer()

                Picker("Range", selection: $maxNumber) {
                    Text("1-10").tag(10)
                    Text("1-20").tag(20)
                    Text("1-30").tag(30)
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
                .onChange(of: maxNumber) { _ in resetGame() }
            }
            .padding(.horizontal, 24)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(nextExpected - 1) / CGFloat(maxNumber), height: 16)
                        .animation(.spring(), value: nextExpected)
                }
            }
            .frame(height: 16)
            .padding(.horizontal, 24)

            Text(wrongTap ? "Oops! Find number \(nextExpected)!" : "Tap number \(nextExpected)")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(wrongTap ? .red : .secondary)
                .animation(.easeInOut, value: wrongTap)

            // Shuffled number grid
            let cols = maxNumber <= 10 ? 5 : 6
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: cols)
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(shuffledNumbers(), id: \.self) { num in
                    Button(action: { tapNumber(num) }) {
                        Text("\(num)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(tappedNumbers.contains(num) ?
                                          Color.green.opacity(0.4) :
                                          numberColors[(num - 1) % numberColors.count])
                                    .shadow(radius: 3)
                            )
                            .scaleEffect(tappedNumbers.contains(num) ? 0.9 : 1.0)
                    }
                    .disabled(tappedNumbers.contains(num))
                }
            }
            .padding(.horizontal, 20)

            if showComplete {
                Text("🎉 Amazing! You counted to \(maxNumber)! 🎉")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .transition(.scale)

                Button("Count Again") {
                    resetGame()
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.blue))
            }

            Spacer()
        }
        .onAppear { resetGame() }
    }

    @State private var shuffled: [Int] = []

    func shuffledNumbers() -> [Int] {
        shuffled
    }

    func resetGame() {
        nextExpected = 1
        tappedNumbers = []
        showComplete = false
        wrongTap = false
        shuffled = Array(1...maxNumber).shuffled()
        speak("Tap the numbers in order! Start with 1.")
    }

    func tapNumber(_ num: Int) {
        if num == nextExpected {
            tappedNumbers.insert(num)
            wrongTap = false
            speak("\(num)")
            nextExpected += 1

            if nextExpected > maxNumber {
                withAnimation { showComplete = true }
                speak("Amazing! You counted all the way to \(maxNumber)!")
            }
        } else {
            wrongTap = true
            speak("That's \(num). Find number \(nextExpected)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                wrongTap = false
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

// MARK: - Skip Counting (2s, 5s, 10s)
struct SkipCountView: View {
    @State private var skipBy = 2
    @State private var sequence: [Int] = []
    @State private var revealed: Set<Int> = []
    @State private var nextToReveal = 0
    @State private var options: [Int] = []
    @State private var showResult: Bool? = nil
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Count by:")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))

                Picker("Skip", selection: $skipBy) {
                    Text("2s").tag(2)
                    Text("5s").tag(5)
                    Text("10s").tag(10)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .onChange(of: skipBy) { _ in setupSkipCount() }
            }

            // Sequence display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(sequence.enumerated()), id: \.offset) { idx, num in
                        VStack(spacing: 4) {
                            if revealed.contains(idx) {
                                Text("\(num)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                    .transition(.scale)
                            } else if idx == nextToReveal {
                                Text("?")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            } else {
                                Text("_")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.4))
                            }

                            if idx < sequence.count - 1 {
                                Text("+\(skipBy)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 70, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(revealed.contains(idx) ? Color.blue.opacity(0.1) :
                                        idx == nextToReveal ? Color.orange.opacity(0.15) : Color.white.opacity(0.5))
                                .shadow(radius: 2)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            Text("What comes next? Count by \(skipBy)s!")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // Answer options
            HStack(spacing: 20) {
                ForEach(options, id: \.self) { option in
                    Button(action: { checkSkipAnswer(option) }) {
                        Text("\(option)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                                    .shadow(radius: 4)
                            )
                    }
                    .disabled(showResult != nil)
                }
            }

            if let result = showResult {
                Text(result ? "Correct!" : "Not quite. \(sequence[nextToReveal]) comes next!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(result ? .green : .orange)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear { setupSkipCount() }
    }

    func setupSkipCount() {
        sequence = stride(from: skipBy, through: skipBy * 10, by: skipBy).map { $0 }
        revealed = [0] // reveal the first number
        nextToReveal = 1
        showResult = nil
        generateOptions()
        speak("Let's count by \(skipBy)s! \(sequence[0]),... what comes next?")
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
        let correct = sequence[nextToReveal]
        if answer == correct {
            withAnimation {
                revealed.insert(nextToReveal)
                showResult = true
            }
            speak("\(correct)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showResult = nil
                    nextToReveal += 1
                    if nextToReveal < sequence.count {
                        generateOptions()
                    } else {
                        speak("You finished counting by \(skipBy)s! Great job!")
                    }
                }
            }
        } else {
            withAnimation { showResult = false }
            speak("\(correct) comes after \(sequence[nextToReveal - 1])")
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

// MARK: - Compare Numbers (Greater / Smaller)
struct CompareView: View {
    @State private var num1 = 0
    @State private var num2 = 0
    @State private var score = 0
    @State private var total = 0
    @State private var showResult: String? = nil
    @State private var maxRange = 20
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Score: \(score)/\(total)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                Spacer()
                Picker("Range", selection: $maxRange) {
                    Text("1-10").tag(10)
                    Text("1-20").tag(20)
                    Text("1-50").tag(50)
                    Text("1-100").tag(100)
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                .onChange(of: maxRange) { _ in newComparison() }
            }
            .padding(.horizontal, 24)

            Text("Which number is bigger?")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            // Two number cards
            HStack(spacing: 40) {
                Button(action: { pickNumber(num1) }) {
                    VStack(spacing: 8) {
                        Text("\(num1)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        // Visual dots
                        let dotCount = min(num1, 20)
                        let dotCols = min(dotCount, 5)
                        if dotCount > 0 {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(12), spacing: 4), count: dotCols), spacing: 4) {
                                ForEach(0..<dotCount, id: \.self) { _ in
                                    Circle().fill(.white.opacity(0.6)).frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                    .frame(width: 180, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                            .shadow(radius: 6)
                    )
                }

                Text("or")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                Button(action: { pickNumber(num2) }) {
                    VStack(spacing: 8) {
                        Text("\(num2)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        let dotCount = min(num2, 20)
                        let dotCols = min(dotCount, 5)
                        if dotCount > 0 {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(12), spacing: 4), count: dotCols), spacing: 4) {
                                ForEach(0..<dotCount, id: \.self) { _ in
                                    Circle().fill(.white.opacity(0.6)).frame(width: 10, height: 10)
                                }
                            }
                        }
                    }
                    .frame(width: 180, height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [.purple, .purple.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                            .shadow(radius: 6)
                    )
                }
            }

            if let result = showResult {
                Text(result)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(result.contains("Correct") ? .green : .orange)
                    .multilineTextAlignment(.center)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear { newComparison() }
    }

    func newComparison() {
        showResult = nil
        num1 = Int.random(in: 1...maxRange)
        repeat { num2 = Int.random(in: 1...maxRange) } while num2 == num1
        speak("Which is bigger? \(num1) or \(num2)?")
    }

    func pickNumber(_ picked: Int) {
        total += 1
        let bigger = max(num1, num2)
        if picked == bigger {
            score += 1
            withAnimation { showResult = "Correct! \(bigger) is bigger!" }
            speak("Correct! \(bigger) is bigger than \(min(num1, num2))!")
        } else {
            withAnimation { showResult = "\(bigger) is bigger than \(min(num1, num2))!" }
            speak("\(bigger) is bigger. \(min(num1, num2)) is smaller.")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            newComparison()
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

// MARK: - Before & After
struct BeforeAfterView: View {
    @State private var targetNumber = 5
    @State private var questionType: QuestionType = .before
    @State private var options: [Int] = []
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var total = 0
    @State private var showResult: Bool? = nil
    let synthesizer = AVSpeechSynthesizer()

    enum QuestionType {
        case before, after, between
    }

    @State private var betweenLow = 0
    @State private var betweenHigh = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Score: \(score)/\(total)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.orange)

            // Question
            VStack(spacing: 12) {
                switch questionType {
                case .before:
                    Text("What comes BEFORE")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    HStack(spacing: 16) {
                        Text("?")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                            .frame(width: 90, height: 90)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(style: StrokeStyle(lineWidth: 3, dash: [8])).foregroundColor(.orange))
                        Text("→")
                            .font(.system(size: 40))
                        Text("\(targetNumber)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 90, height: 90)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
                    }

                case .after:
                    Text("What comes AFTER")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    HStack(spacing: 16) {
                        Text("\(targetNumber)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 90, height: 90)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
                        Text("→")
                            .font(.system(size: 40))
                        Text("?")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                            .frame(width: 90, height: 90)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(style: StrokeStyle(lineWidth: 3, dash: [8])).foregroundColor(.orange))
                    }

                case .between:
                    Text("What goes BETWEEN")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    HStack(spacing: 16) {
                        Text("\(betweenLow)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
                        Text("→")
                            .font(.system(size: 36))
                        Text("?")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                            .frame(width: 80, height: 80)
                            .background(RoundedRectangle(cornerRadius: 16).stroke(style: StrokeStyle(lineWidth: 3, dash: [8])).foregroundColor(.orange))
                        Text("→")
                            .font(.system(size: 36))
                        Text("\(betweenHigh)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue.opacity(0.1)))
                    }
                }
            }

            // Options
            HStack(spacing: 20) {
                ForEach(options, id: \.self) { option in
                    Button(action: { checkAnswer(option) }) {
                        Text("\(option)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.green)
                                    .shadow(radius: 4)
                            )
                    }
                    .disabled(showResult != nil)
                }
            }

            if let result = showResult {
                Text(result ? "Correct!" : "The answer is \(correctAnswer)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(result ? .green : .orange)
                    .transition(.scale)
            }

            Spacer()
        }
        .onAppear { newQuestion() }
    }

    func newQuestion() {
        showResult = nil
        let types: [QuestionType] = [.before, .after, .between]
        questionType = types.randomElement()!

        switch questionType {
        case .before:
            targetNumber = Int.random(in: 2...20)
            correctAnswer = targetNumber - 1
            speak("What number comes before \(targetNumber)?")
        case .after:
            targetNumber = Int.random(in: 1...19)
            correctAnswer = targetNumber + 1
            speak("What number comes after \(targetNumber)?")
        case .between:
            betweenLow = Int.random(in: 1...18)
            betweenHigh = betweenLow + 2
            correctAnswer = betweenLow + 1
            speak("What number goes between \(betweenLow) and \(betweenHigh)?")
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
            withAnimation { showResult = true }
            speak("Correct! \(correctAnswer)!")
        } else {
            withAnimation { showResult = false }
            speak("The answer is \(correctAnswer)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            newQuestion()
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
        CountingGameView()
    }
}
