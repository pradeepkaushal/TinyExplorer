import SwiftUI

struct ShapeInfo: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let shape: AnyShape
    let emoji: String
    let funFact: String
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
        ShapeInfo(name: "Circle", color: .red, shape: AnyShape(Circle()), emoji: "🔴",
                  funFact: "A circle is perfectly round, just like the sun!"),
        ShapeInfo(name: "Square", color: .blue, shape: AnyShape(Rectangle()), emoji: "🟦",
                  funFact: "A square has 4 sides that are all the same!"),
        ShapeInfo(name: "Triangle", color: .green, shape: AnyShape(TriangleShape()), emoji: "📐",
                  funFact: "A triangle has 3 sides and 3 pointy corners!"),
        ShapeInfo(name: "Star", color: .yellow, shape: AnyShape(StarShape()), emoji: "⭐",
                  funFact: "This star has 5 shiny points, like stars at night!"),
        ShapeInfo(name: "Diamond", color: .purple, shape: AnyShape(DiamondShape()), emoji: "💎",
                  funFact: "A diamond is a square balancing on its tippy-toe!"),
        ShapeInfo(name: "Heart", color: .pink, shape: AnyShape(HeartShape()), emoji: "❤️",
                  funFact: "Hearts mean love, hugs, and kindness!"),
    ]

    @State private var selectedShape: ShapeInfo? = nil
    @State private var targetShape: ShapeInfo? = nil
    @State private var quizOptions: [ShapeInfo] = []
    @State private var score = 0
    @State private var streak = 0
    @State private var showCorrect = false
    @State private var showWrong = false
    @State private var gameMode: GameMode = .explore
    @State private var celebrationMessage = ""
    @State private var progression = GameProgression()

    private let hints = [
        "Look at the shape's sides and corners!",
        "Match the outline to the right shape!",
        "Colors can help you remember shapes!",
        "You're a shape master — go fast!",
    ]

    private let theme = GameTheme.shapes

    enum GameMode {
        case explore
        case quiz
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .shapes)

            VStack(spacing: 16) {
                // Mode picker
                ThemedSegmentedPicker(
                    items: [(title: "Explore", value: GameMode.explore), (title: "Quiz", value: GameMode.quiz)],
                    selection: $gameMode,
                    accent: theme.accent
                )
                .padding(.top, 8)
                .onChange(of: gameMode) { _ in
                    Haptics.tap()
                    SoundEngine.shared.play(.tap)
                    if gameMode == .quiz { startQuiz() }
                    selectedShape = nil
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    quizView
                }
            }

            if showCorrect {
                CelebrationOverlayEnhanced(message: celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Colors & Shapes", theme: theme)
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Explore

    var exploreView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            // Display area
            Group {
                if let shape = selectedShape {
                    VStack(spacing: 14) {
                        shape.shape
                            .fill(
                                LinearGradient(
                                    colors: [shape.color.opacity(0.85), shape.color],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 190, height: 190)
                            .shadow(color: shape.color.opacity(0.5), radius: 12, y: 6)
                            .modifier(GentleShapePulse())
                            .transition(.scale)

                        Text(shape.name)
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundColor(shape.color)

                        Text(shape.funFact)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.75))
                            )
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 44)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [.white, theme.accent.opacity(0.12)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(theme.accent.opacity(0.45), lineWidth: 2.5)
                            )
                            .shadow(color: theme.accent.opacity(0.3), radius: 12, y: 6)
                    )
                    .animation(.spring(), value: selectedShape?.id)
                } else {
                    VStack(spacing: 14) {
                        Text("🟣")
                            .font(.system(size: 90))
                            .modifier(GentleShapePulse())
                        MascotBubble(theme: theme, text: "Tap a shape to explore!")
                    }
                    .popIn()
                }
            }
            .frame(height: 330)

            Spacer(minLength: 24)

            // Shapes grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                ForEach(Array(shapes.enumerated()), id: \.element.id) { index, shape in
                    Button(action: {
                        Haptics.tap()
                        SoundEngine.shared.playTileNote(shapes.firstIndex(where: { $0.id == shape.id }) ?? 0)
                        withAnimation { selectedShape = shape }
                        SpeechHelper.speak("A \(shape.color.description) \(shape.name.lowercased())!")
                    }) {
                        VStack(spacing: 12) {
                            shape.shape
                                .fill(shape.color)
                                .frame(width: 120, height: 120)
                                .shadow(color: shape.color.opacity(0.4), radius: 5, y: 3)

                            Text(shape.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 22)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [.white, theme.accent.opacity(selectedShape?.id == shape.id ? 0.22 : 0.1)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(
                                            theme.accent.opacity(selectedShape?.id == shape.id ? 0.9 : 0.4),
                                            lineWidth: 2.5
                                        )
                                )
                                .shadow(color: theme.accent.opacity(0.25), radius: 8, y: 4)
                        )
                        .scaleEffect(selectedShape?.id == shape.id ? 1.06 : 1.0)
                        .animation(.spring(), value: selectedShape?.id)
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .popIn(delay: Double(index) * 0.04)
                }
            }
            .padding(.horizontal, 60)

            Spacer(minLength: 24)
        }
    }

    // MARK: - Quiz

    var quizView: some View {
        VStack(spacing: 0) {
            GameProgressHeader(
                level: progression.level,
                correctInLevel: progression.correctInLevel,
                neededForNextLevel: progression.neededForNextLevel,
                theme: theme,
                hint: progression.currentHint(from: hints)
            )
            .padding(.horizontal, 24)
            .padding(.top, 4)

            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: score)
                StreakBadgeEnhanced(streak: streak)
            }
            .padding(.top, 8)

            Spacer(minLength: 16)

            if let target = targetShape {
                VStack(spacing: 18) {
                    Text("Find the \(target.name)!")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)

                    target.shape
                        .stroke(
                            theme.accent.opacity(0.7),
                            style: StrokeStyle(lineWidth: 4, dash: [12, 8])
                        )
                        .frame(width: 140, height: 140)
                        .padding(26)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(theme.accent.opacity(0.35), lineWidth: 2.5)
                                )
                                .shadow(color: theme.accent.opacity(0.2), radius: 8, y: 4)
                        )
                }

                Spacer(minLength: 28)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                    ForEach(Array(quizOptions.enumerated()), id: \.element.id) { index, shape in
                        Button(action: {
                            checkAnswer(shape)
                        }) {
                            shape.shape
                                .fill(shape.color)
                                .frame(width: 140, height: 140)
                                .shadow(color: shape.color.opacity(0.4), radius: 5, y: 3)
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(
                                            LinearGradient(
                                                colors: [.white, theme.accent.opacity(0.1)],
                                                startPoint: .top, endPoint: .bottom
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22)
                                                .stroke(theme.accent.opacity(0.4), lineWidth: 2.5)
                                        )
                                        .shadow(color: theme.accent.opacity(0.25), radius: 8, y: 4)
                                )
                        }
                        .buttonStyle(SquishyButtonStyle())
                        .popIn(delay: Double(index) * 0.04)
                    }
                }
                .padding(.horizontal, 70)
            }

            Group {
                if showWrong {
                    Text("❌ Try again!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                        .transition(.scale)
                } else {
                    Color.clear
                }
            }
            .frame(height: 60)

            Spacer(minLength: 16)
        }
    }

    func startQuiz() {
        score = 0
        streak = 0
        pickNewTarget()
    }

    func pickNewTarget() {
        targetShape = shapes.randomElement()
        quizOptions = shapes.shuffled()
        if let target = targetShape {
            SpeechHelper.speak("Find the \(target.name)!")
        }
    }

    func checkAnswer(_ shape: ShapeInfo) {
        if shape.name == targetShape?.name {
            celebrationMessage = Encouragement.random()
            StarBank.shared.award(1, to: GameTheme.shapes.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation {
                showCorrect = true
                score += 1
                streak += 1
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.shapes.key)
                SoundEngine.shared.play(.streak)
            }
            SpeechHelper.speak("That's a \(shape.name)!")
            let delay = progression.showLevelUp ? 2.5 : 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                withAnimation { showCorrect = false }
                pickNewTarget()
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation {
                showWrong = true
                streak = 0
            }
            SpeechHelper.speak("Try again!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showWrong = false }
            }
        }
    }
}

/// Slow, subtle breathing pulse for the featured shape.
private struct GentleShapePulse: ViewModifier {
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.04 : 1.0)
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

#Preview {
    NavigationStack {
        ShapesGameView()
    }
}
