import SwiftUI
import AVFoundation

struct ShapeInfo: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let shape: AnyShape
    let emoji: String
}

struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        _path = { rect in shape.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.closeSubpath()
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        var path = Path()
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                              y: center.y + CGFloat(sin(angle)) * radius)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            let w = rect.width
            let h = rect.height
            p.move(to: CGPoint(x: w * 0.5, y: h * 0.25))
            p.addCurve(to: CGPoint(x: 0, y: h * 0.25),
                       control1: CGPoint(x: w * 0.5, y: 0),
                       control2: CGPoint(x: 0, y: 0))
            p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                       control1: CGPoint(x: 0, y: h * 0.55),
                       control2: CGPoint(x: w * 0.5, y: h * 0.75))
            p.addCurve(to: CGPoint(x: w, y: h * 0.25),
                       control1: CGPoint(x: w * 0.5, y: h * 0.75),
                       control2: CGPoint(x: w, y: h * 0.55))
            p.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.25),
                       control1: CGPoint(x: w, y: 0),
                       control2: CGPoint(x: w * 0.5, y: 0))
        }
    }
}

struct ShapesGameView: View {
    let shapes: [ShapeInfo] = [
        ShapeInfo(name: "Circle", color: .red, shape: AnyShape(Circle()), emoji: "🔴"),
        ShapeInfo(name: "Square", color: .blue, shape: AnyShape(Rectangle()), emoji: "🟦"),
        ShapeInfo(name: "Triangle", color: .green, shape: AnyShape(TriangleShape()), emoji: "📐"),
        ShapeInfo(name: "Star", color: .yellow, shape: AnyShape(StarShape()), emoji: "⭐"),
        ShapeInfo(name: "Diamond", color: .purple, shape: AnyShape(DiamondShape()), emoji: "💎"),
        ShapeInfo(name: "Heart", color: .pink, shape: AnyShape(HeartShape()), emoji: "❤️"),
    ]

    @State private var selectedShape: ShapeInfo? = nil
    @State private var targetShape: ShapeInfo? = nil
    @State private var score = 0
    @State private var showCorrect = false
    @State private var showWrong = false
    @State private var gameMode: GameMode = .explore

    let synthesizer = AVSpeechSynthesizer()

    enum GameMode {
        case explore
        case quiz
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.85, blue: 1.0), Color(red: 0.85, green: 0.95, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Mode picker
                Picker("Mode", selection: $gameMode) {
                    Text("Explore").tag(GameMode.explore)
                    Text("Quiz").tag(GameMode.quiz)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 200)
                .onChange(of: gameMode) { _ in
                    if gameMode == .quiz { startQuiz() }
                    selectedShape = nil
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    quizView
                }
            }
        }
        .navigationTitle("Colors & Shapes")
        .navigationBarTitleDisplayMode(.inline)
    }

    var exploreView: some View {
        VStack(spacing: 24) {
            // Display area
            if let shape = selectedShape {
                VStack(spacing: 16) {
                    shape.shape
                        .fill(shape.color)
                        .frame(width: 180, height: 180)
                        .shadow(color: shape.color.opacity(0.5), radius: 10)
                        .transition(.scale)

                    Text(shape.name)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(shape.color)

                    Text("This is a \(shape.color.description) \(shape.name.lowercased())!")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(height: 300)
                .animation(.spring(), value: selectedShape?.id)
            } else {
                VStack {
                    Text("🟣")
                        .font(.system(size: 80))
                    Text("Tap a shape to explore!")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(height: 300)
            }

            // Shapes grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(shapes) { shape in
                    Button(action: {
                        withAnimation { selectedShape = shape }
                        speak("This is a \(shape.color.description) \(shape.name)")
                    }) {
                        VStack(spacing: 10) {
                            shape.shape
                                .fill(shape.color)
                                .frame(width: 110, height: 110)
                                .shadow(radius: 4)

                            Text(shape.name)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.8))
                                .shadow(radius: selectedShape?.id == shape.id ? 6 : 2)
                        )
                        .scaleEffect(selectedShape?.id == shape.id ? 1.1 : 1.0)
                        .animation(.spring(), value: selectedShape?.id)
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    var quizView: some View {
        VStack(spacing: 24) {
            Text("Score: \(score)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            if let target = targetShape {
                VStack(spacing: 16) {
                    Text("Find the \(target.name)!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    target.shape
                        .stroke(Color.gray, lineWidth: 3)
                        .frame(width: 120, height: 120)
                }
                .frame(height: 200)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                    ForEach(shapes.shuffled()) { shape in
                        Button(action: {
                            checkAnswer(shape)
                        }) {
                            shape.shape
                                .fill(shape.color)
                                .frame(width: 130, height: 130)
                                .shadow(radius: 4)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white.opacity(0.8))
                                )
                        }
                    }
                }
                .padding(.horizontal, 60)
            }

            if showCorrect {
                Text("✅ Correct! Great job!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .transition(.scale)
            }
            if showWrong {
                Text("❌ Try again!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .transition(.scale)
            }

            Spacer()
        }
    }

    func startQuiz() {
        score = 0
        targetShape = shapes.randomElement()
        if let target = targetShape {
            speak("Find the \(target.name)")
        }
    }

    func checkAnswer(_ shape: ShapeInfo) {
        if shape.name == targetShape?.name {
            withAnimation {
                showCorrect = true
                score += 1
            }
            speak("Correct! That's a \(shape.name)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showCorrect = false
                    targetShape = shapes.randomElement()
                }
                if let target = targetShape {
                    speak("Find the \(target.name)")
                }
            }
        } else {
            withAnimation { showWrong = true }
            speak("Try again! That's a \(shape.name)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showWrong = false }
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
        ShapesGameView()
    }
}
