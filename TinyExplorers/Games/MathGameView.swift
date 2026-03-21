import SwiftUI
import AVFoundation

struct MathGameView: View {
    @State private var num1 = 1
    @State private var num2 = 1
    @State private var operation: MathOperation = .addition
    @State private var options: [Int] = []
    @State private var correctAnswer = 0
    @State private var score = 0
    @State private var totalQuestions = 0
    @State private var showResult: Bool? = nil
    @State private var difficulty: MathDifficulty = .easy
    @State private var bounceAnswer = false

    let synthesizer = AVSpeechSynthesizer()

    enum MathOperation: String, CaseIterable {
        case addition = "Addition +"
        case subtraction = "Subtraction −"
        case counting = "Counting"

        var symbol: String {
            switch self {
            case .addition: return "+"
            case .subtraction: return "−"
            case .counting: return ""
            }
        }
    }

    enum MathDifficulty: String, CaseIterable {
        case easy = "Easy (1-5)"
        case medium = "Medium (1-10)"
        case hard = "Hard (1-20)"

        var range: ClosedRange<Int> {
            switch self {
            case .easy: return 1...5
            case .medium: return 1...10
            case .hard: return 1...20
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.95, blue: 0.85), Color(red: 0.8, green: 0.9, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Controls
                HStack(spacing: 24) {
                    Picker("Operation", selection: $operation) {
                        ForEach(MathOperation.allCases, id: \.self) { op in
                            Text(op.rawValue).tag(op)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 400)
                    .onChange(of: operation) { _ in generateQuestion() }

                    Picker("Level", selection: $difficulty) {
                        ForEach(MathDifficulty.allCases, id: \.self) { d in
                            Text(d.rawValue).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 350)
                    .onChange(of: difficulty) { _ in generateQuestion() }
                }
                .padding(.horizontal, 20)

                // Score
                HStack(spacing: 32) {
                    Label("\(score)/\(totalQuestions) Correct", systemImage: "star.fill")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)

                    if totalQuestions > 0 {
                        Text("\(Int(Double(score) / Double(totalQuestions) * 100))%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                }

                // Question display
                if operation == .counting {
                    countingView
                } else {
                    arithmeticView
                }

                // Answer options
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { checkAnswer(option) }) {
                            Text("\(option)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .shadow(radius: 4)
                                )
                        }
                    }
                }
                .padding(.horizontal, 60)

                // Feedback
                if let result = showResult {
                    HStack(spacing: 12) {
                        Text(result ? "Correct!" : "The answer is \(correctAnswer)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(result ? .green : .orange)

                        if result {
                            Text("⭐")
                                .font(.system(size: 36))
                                .scaleEffect(bounceAnswer ? 1.4 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.3), value: bounceAnswer)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationTitle("Math Fun")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { generateQuestion() }
    }

    var arithmeticView: some View {
        HStack(spacing: 20) {
            // Visual representation
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<num1, id: \.self) { _ in
                        Text("🍎")
                            .font(.system(size: 36))
                    }
                }
                Text("\(num1)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Text(operation.symbol)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<num2, id: \.self) { _ in
                        Text(operation == .addition ? "🍎" : "🍎")
                            .font(.system(size: 36))
                            .opacity(operation == .subtraction ? 0.4 : 1.0)
                    }
                }
                Text("\(num2)")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Text("=")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.purple)

            Text("?")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.7))
                .shadow(radius: 6)
        )
    }

    var countingView: some View {
        VStack(spacing: 16) {
            Text("How many apples?")
                .font(.system(size: 28, weight: .semibold, design: .rounded))

            // Grid of items to count
            let cols = min(num1, 5)
            let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: cols)
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(0..<num1, id: \.self) { _ in
                    Text("🍎")
                        .font(.system(size: 52))
                }
            }
            .frame(maxWidth: 300)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white.opacity(0.7))
                .shadow(radius: 6)
        )
    }

    func generateQuestion() {
        showResult = nil
        let range = difficulty.range

        switch operation {
        case .addition:
            num1 = Int.random(in: range)
            num2 = Int.random(in: range)
            correctAnswer = num1 + num2

        case .subtraction:
            num1 = Int.random(in: range)
            num2 = Int.random(in: 1...num1)
            correctAnswer = num1 - num2

        case .counting:
            num1 = Int.random(in: range)
            correctAnswer = num1
        }

        // Generate 4 options including the correct answer
        var opts = Set<Int>()
        opts.insert(correctAnswer)
        while opts.count < 4 {
            let offset = Int.random(in: -3...3)
            let candidate = max(0, correctAnswer + offset)
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
            withAnimation { showResult = true; bounceAnswer = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceAnswer = false }

            let utterance = AVSpeechUtterance(string: "Correct! Great job!")
            utterance.rate = 0.34
            utterance.pitchMultiplier = 1.2
            utterance.voice = SpeechHelper.preferredVoice
            synthesizer.stopSpeaking(at: .immediate)
            synthesizer.speak(utterance)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { generateQuestion() }
            }
        } else {
            withAnimation { showResult = false }

            let utterance = AVSpeechUtterance(string: "The answer is \(correctAnswer). Let's try another one!")
            utterance.rate = 0.3
            utterance.pitchMultiplier = 1.1
            utterance.voice = SpeechHelper.preferredVoice
            synthesizer.stopSpeaking(at: .immediate)
            synthesizer.speak(utterance)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
