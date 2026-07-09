import SwiftUI

struct ShapeInfo: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let colorName: String
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

// MARK: - Extra file-private shapes (widen the pool so option-count scaling
// and look-alike distractors have real room to make higher levels harder).

/// Builds a regular polygon inscribed in `rect`. `rotation` (radians) sets
/// the angle of the first vertex; -pi/2 puts a point straight up.
private func regularPolygonPath(sides: Int, in rect: CGRect, rotation: Double = -.pi / 2) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2
    var path = Path()
    for i in 0..<sides {
        let angle = rotation + Double(i) * 2 * .pi / Double(sides)
        let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                            y: center.y + CGFloat(sin(angle)) * radius)
        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    path.closeSubpath()
    return path
}

/// A horizontal oval — a stretched circle — so it reads differently from Circle.
private struct OvalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let h = rect.height * 0.62
        let y = rect.midY - h / 2
        return Path(ellipseIn: CGRect(x: rect.minX, y: y, width: rect.width, height: h))
    }
}

/// A wide rectangle, distinct from the (square) Rectangle used for "Square".
private struct WideRectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let h = rect.height * 0.6
        let y = rect.midY - h / 2
        return Path(CGRect(x: rect.minX, y: y, width: rect.width, height: h))
    }
}

private struct PentagonShape: Shape {
    func path(in rect: CGRect) -> Path { regularPolygonPath(sides: 5, in: rect) }
}

private struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path { regularPolygonPath(sides: 6, in: rect, rotation: 0) }
}

/// A crescent moon: the right bulge of one circle minus a circle nudged right.
private struct CrescentShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: radius,
                    startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
        path.addArc(center: CGPoint(x: center.x + radius * 0.5, y: center.y), radius: radius,
                    startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)
        path.closeSubpath()
        return path
    }
}

/// A simple right-pointing arrow.
private struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        return Path { p in
            p.move(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.35))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.35))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.12))
            p.addLine(to: CGPoint(x: rect.minX + w, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.88))
            p.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.65))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.65))
            p.closeSubpath()
        }
    }
}

struct ShapesGameView: View {
    let shapes: [ShapeInfo] = [
        ShapeInfo(name: "Circle", color: .red, colorName: "red", shape: AnyShape(Circle()), emoji: "🔴",
                  funFact: "A circle is perfectly round, just like the sun!"),
        ShapeInfo(name: "Square", color: .blue, colorName: "blue", shape: AnyShape(Rectangle()), emoji: "🟦",
                  funFact: "A square has 4 sides that are all the same!"),
        ShapeInfo(name: "Triangle", color: .green, colorName: "green", shape: AnyShape(TriangleShape()), emoji: "📐",
                  funFact: "A triangle has 3 sides and 3 pointy corners!"),
        ShapeInfo(name: "Star", color: .yellow, colorName: "yellow", shape: AnyShape(StarShape()), emoji: "⭐",
                  funFact: "This star has 5 shiny points, like stars at night!"),
        ShapeInfo(name: "Diamond", color: .purple, colorName: "purple", shape: AnyShape(DiamondShape()), emoji: "💎",
                  funFact: "A diamond is a square balancing on its tippy-toe!"),
        ShapeInfo(name: "Heart", color: .pink, colorName: "pink", shape: AnyShape(HeartShape()), emoji: "❤️",
                  funFact: "Hearts mean love, hugs, and kindness!"),
        ShapeInfo(name: "Oval", color: .orange, colorName: "orange", shape: AnyShape(OvalShape()), emoji: "🥚",
                  funFact: "An oval is a circle after a gentle stretch!"),
        ShapeInfo(name: "Rectangle", color: .teal, colorName: "teal", shape: AnyShape(WideRectangleShape()), emoji: "🚪",
                  funFact: "A rectangle is like a stretched-out square!"),
        ShapeInfo(name: "Pentagon", color: .indigo, colorName: "indigo", shape: AnyShape(PentagonShape()), emoji: "⬠",
                  funFact: "A pentagon has 5 straight sides!"),
        ShapeInfo(name: "Hexagon", color: .mint, colorName: "mint", shape: AnyShape(HexagonShape()), emoji: "⬡",
                  funFact: "A hexagon has 6 sides, just like a honeycomb!"),
        ShapeInfo(name: "Crescent", color: .cyan, colorName: "blue", shape: AnyShape(CrescentShape()), emoji: "🌙",
                  funFact: "A crescent is the moon's curvy sliver!"),
        ShapeInfo(name: "Arrow", color: .brown, colorName: "brown", shape: AnyShape(ArrowShape()), emoji: "➡️",
                  funFact: "An arrow points the way to go!"),
    ]

    /// Look-alike groups: at higher levels we bias the distractors toward these
    /// so the child must tell apart shapes that are genuinely similar.
    private static let lookAlikes: [String: [String]] = [
        "Circle": ["Oval", "Crescent"],
        "Oval": ["Circle", "Crescent"],
        "Square": ["Rectangle", "Diamond"],
        "Rectangle": ["Square", "Diamond"],
        "Diamond": ["Square", "Rectangle", "Star"],
        "Triangle": ["Star", "Arrow"],
        "Star": ["Diamond", "Triangle"],
        "Pentagon": ["Hexagon", "Diamond"],
        "Hexagon": ["Pentagon", "Circle"],
        "Crescent": ["Circle", "Oval"],
        "Arrow": ["Triangle", "Diamond"],
        "Heart": ["Star", "Diamond"],
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
    @State private var progression = GameProgression(key: GameTheme.shapes.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    @State private var isResolving = false

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
                    selectedShape = nil
                    // Voice the mode a non-reader just landed on. For Quiz,
                    // startQuiz()'s target prompt ("Find the ...") follows and
                    // is the more useful confirmation of the finding game.
                    if gameMode == .quiz {
                        SpeechHelper.speak("Quiz")
                        startQuiz()
                    } else {
                        SpeechHelper.speak("Explore")
                    }
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

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    withAnimation {
                        showAdventureComplete = false
                        pickNewTarget()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Colors & Shapes", theme: theme)
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Explore

    var exploreView: some View {
        VStack(spacing: 16) {
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

            // Shapes grid — adaptive columns reflow so tiles wrap instead of
            // overflowing, and a ScrollView keeps every tile (up to 12)
            // reachable and never clipped off-screen at the maximum count.
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 92, maximum: 120), spacing: 14)],
                    spacing: 12
                ) {
                    ForEach(Array(shapes.enumerated()), id: \.element.id) { index, shape in
                        Button(action: {
                            Haptics.tap()
                            SoundEngine.shared.playTileNote(shapes.firstIndex(where: { $0.id == shape.id }) ?? 0)
                            withAnimation { selectedShape = shape }
                            let article = "aeiou".contains(shape.colorName.first ?? " ") ? "An" : "A"
                            SpeechHelper.speak("\(article) \(shape.colorName) \(shape.name.lowercased())!")
                        }) {
                            VStack(spacing: 6) {
                                shape.shape
                                    .fill(shape.color)
                                    .frame(width: 58, height: 58)
                                    .shadow(color: shape.color.opacity(0.4), radius: 5, y: 3)

                                Text(shape.name)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
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
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Quiz

    var quizView: some View {
        VStack(spacing: 16) {
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
                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
            }
            .padding(.top, 8)

            if let target = targetShape {
                VStack(spacing: 18) {
                    HStack(spacing: 12) {
                        Text("Find the \(target.name)!")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        // Pre-readers can replay the prompt any time.
                        SpeakOptionButton(text: "Find the \(target.name)", accent: theme.accent)
                    }

                    // Always show the target's dashed outline. A pre-reader on a
                    // muted iPad can't hear the prompt or read the name, so this
                    // outline is their only visual cue to which shape to find —
                    // never hide it behind a "?", or the goal becomes unknowable.
                    // Higher levels stay hard via more options, look-alike
                    // distractors, and (L5+) uniform-colored tiles that force a
                    // match by FORM rather than color.
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

                // Options — adaptive columns reflow and a ScrollView keep every
                // tile (up to 7 at higher levels) reachable and never clipped,
                // so the target tile can always be tapped to finish the round.
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 92, maximum: 120), spacing: 14)],
                        spacing: 12
                    ) {
                        ForEach(Array(quizOptions.enumerated()), id: \.element.id) { index, shape in
                            Button(action: {
                                checkAnswer(shape)
                            }) {
                                shape.shape
                                    // Level 5+: one uniform color removes the color
                                    // shortcut, so the child must match by FORM.
                                    .fill(progression.level >= 5 ? theme.accent : shape.color)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: shape.color.opacity(0.4), radius: 5, y: 3)
                                    .padding(.vertical, 18)
                                    .frame(maxWidth: .infinity)
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .disabled(isResolving)
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
        }
        .padding(.bottom, 8)
    }

    func startQuiz() {
        score = 0
        streak = 0
        // Fresh 5-find round with a clean trail every time Quiz is entered.
        adventure.reset()
        showAdventureComplete = false
        showWrong = false
        isResolving = false
        pickNewTarget()
    }

    func pickNewTarget() {
        // Fewer choices for beginners, growing toward the full set as they level
        // up: 3 options at L1-2, +1 every 2 levels. Never repeats the same
        // target twice in a row.
        let optionCount = min(shapes.count, 3 + (progression.level - 1) / 2)
        let candidates = shapes.filter { $0.name != targetShape?.name }
        guard let target = candidates.randomElement() else { return }
        targetShape = target

        let distractorsNeeded = max(0, optionCount - 1)
        let pool = shapes.filter { $0.name != target.name }
        let distractors: [ShapeInfo]
        if progression.level >= 3 {
            // Bias toward look-alikes so options are harder to tell apart,
            // then top up with the rest if we still need more.
            let similarNames = Self.lookAlikes[target.name] ?? []
            let similar = pool.filter { similarNames.contains($0.name) }.shuffled()
            let others = pool.filter { !similarNames.contains($0.name) }.shuffled()
            distractors = Array((similar + others).prefix(distractorsNeeded))
        } else {
            distractors = Array(pool.shuffled().prefix(distractorsNeeded))
        }

        var options = distractors + [target]
        options.shuffle()
        quizOptions = options
        SpeechHelper.speak("Find the \(target.name)!")
    }

    func checkAnswer(_ shape: ShapeInfo) {
        // Input lock: ignore a burst of taps during the reveal window so one
        // prompt can't double-award or over-advance the level/adventure.
        guard !isResolving else { return }
        if shape.name == targetShape?.name {
            isResolving = true
            celebrationMessage = Encouragement.random()
            StarBank.shared.award(1, to: GameTheme.shapes.key)
            progression.registerCorrect()
            adventure.recordCorrect()
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
                isResolving = false
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: GameTheme.shapes.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { pickNewTarget() }
                }
            }
        } else {
            isResolving = true
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation {
                showWrong = true
                streak = 0
            }
            SpeechHelper.speak("Try again!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isResolving = false
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
