import SwiftUI

struct DrawingLine: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
}

struct DrawingGameView: View {
    @State private var lines: [DrawingLine] = []
    @State private var currentLine: DrawingLine?
    @State private var selectedColor: Color = .red
    @State private var selectedColorName: String = "Red"
    @State private var selectedWidth: CGFloat = 8
    @State private var showStickers = false
    @State private var placedStickers: [(emoji: String, position: CGPoint)] = []
    @State private var selectedSticker: String? = nil
    @State private var history: [DrawAction] = []
    @State private var paletteBob = false
    @State private var progression = GameProgression(key: GameTheme.drawing.key)

    // Tracks the order of actions so Undo removes the most recent stroke OR sticker.
    private enum DrawAction { case stroke, sticker }

    private let hints = [
        "Pick a color and start drawing!",
        "Try different brush sizes!",
        "Add stickers to your art!",
        "Use the eraser to fix mistakes!",
    ]

    // Eraser paints canvas-white; "White" is a real paint color.
    let colors: [(Color, String)] = [
        (.red, "Red"), (.orange, "Orange"),
        (.yellow, "Yellow"), (Color(red: 0.62, green: 0.85, blue: 0.1), "Lime"),
        (.green, "Green"), (.teal, "Teal"),
        (.cyan, "Cyan"), (.blue, "Blue"),
        (.indigo, "Indigo"), (.purple, "Purple"),
        (Color(red: 0.93, green: 0.2, blue: 0.74), "Magenta"), (.pink, "Pink"),
        (.brown, "Brown"), (.black, "Black"),
        (.white, "White"), (.white, "Eraser"),
    ]

    let brushSizes: [(CGFloat, String)] = [
        (4, "Thin"), (8, "Medium"), (16, "Thick"), (28, "Super"),
    ]

    let stickers = ["⭐", "❤️", "🌈", "🦋", "🌸", "🐶", "🐱", "🎈",
                    "🌻", "🍎", "🐸", "🦄", "🎵", "☀️", "🌙", "🐝"]

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .drawing)

            HStack(spacing: 14) {
                toolSidebar
                VStack(spacing: 10) {
                    GameProgressHeader(
                        level: progression.level,
                        correctInLevel: progression.correctInLevel,
                        neededForNextLevel: progression.neededForNextLevel,
                        theme: .drawing,
                        hint: progression.currentHint(from: hints)
                    )
                    .padding(.horizontal, 10)

                    MascotBubble(theme: .drawing, text: "Let's draw something amazing!", mascotSize: 44)
                        .popIn(delay: 0.1)
                    canvasCard
                }
            }
            .padding(14)

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: .drawing)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Drawing Fun", theme: .drawing)
        .onAppear { paletteBob = true }
    }

    // MARK: - Tool sidebar (themed card)

    private var toolSidebar: some View {
        VStack(spacing: 10) {
            Text("🎨")
                .font(.system(size: 36))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // Colors
                    VStack(spacing: 8) {
                        Text("Colors")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Array(colors.enumerated()), id: \.element.1) { swatchIndex, item in
                                let (color, name) = item
                                Button(action: {
                                    Haptics.tap()
                                    SoundEngine.shared.play(.tap)
                                    selectedColor = color
                                    selectedColorName = name
                                    selectedSticker = nil
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(name == "Eraser" ? Color.gray.opacity(0.15) : color)
                                            .frame(width: 36, height: 36)
                                        if name == "Eraser" {
                                            Image(systemName: "eraser.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedColorName == name
                                                    ? GameTheme.drawing.accent
                                                    : (name == "White" ? Color.gray.opacity(0.35) : Color.clear),
                                                lineWidth: selectedColorName == name ? 3 : 1.5
                                            )
                                    )
                                }
                                .buttonStyle(SquishyButtonStyle())
                                .popIn(delay: Double(swatchIndex) * 0.04)
                            }
                        }
                    }

                    Divider()
                        .padding(.horizontal, 10)

                    // Brush sizes
                    VStack(spacing: 8) {
                        Text("Size")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        ForEach(brushSizes, id: \.1) { size, name in
                            Button(action: {
                                Haptics.tap()
                                SoundEngine.shared.play(.tap)
                                selectedWidth = size
                                selectedSticker = nil
                            }) {
                                Circle()
                                    .fill(selectedWidth == size ? GameTheme.drawing.accent : Color.gray.opacity(0.5))
                                    .frame(width: size + 8, height: size + 8)
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedWidth == size ? GameTheme.drawing.accent.opacity(0.18) : Color.clear)
                                    )
                            }
                            .buttonStyle(SquishyButtonStyle())
                        }
                    }

                    Divider()
                        .padding(.horizontal, 10)

                    // Sticker button
                    Button(action: {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        showStickers.toggle()
                    }) {
                        VStack(spacing: 4) {
                            Text(selectedSticker ?? "😀")
                                .font(.system(size: 28))
                            Text("Stickers")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill((showStickers || selectedSticker != nil) ? GameTheme.drawing.accent.opacity(0.2) : Color.clear)
                        )
                    }
                    .buttonStyle(SquishyButtonStyle())
                }
                .padding(.bottom, 8)
            }

            // Undo button — pinned at the bottom (disabled when nothing to undo)
            Button(action: {
                guard !history.isEmpty else { return }
                Haptics.tap()
                SoundEngine.shared.play(.tap)
                withAnimation(.easeInOut(duration: 0.15)) {
                    undoLast()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 22))
                    Text("Undo")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(history.isEmpty ? .gray : GameTheme.drawing.accent)
            }
            .buttonStyle(SquishyButtonStyle())
            .disabled(history.isEmpty)
            .opacity(history.isEmpty ? 0.4 : 1)
            .padding(.bottom, 2)

            // Clear button — pinned at the bottom
            Button(action: {
                Haptics.tap()
                SoundEngine.shared.play(.wrong)
                withAnimation(.easeInOut(duration: 0.2)) {
                    lines.removeAll()
                    placedStickers.removeAll()
                    history.removeAll()
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 24))
                    Text("Clear")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.red)
            }
            .buttonStyle(SquishyButtonStyle())
            .padding(.bottom, 6)
        }
        .frame(width: 108)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.95))
                .shadow(color: GameTheme.drawing.accent.opacity(0.25), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(GameTheme.drawing.accent.opacity(0.45), lineWidth: 2.5)
        )
    }

    // MARK: - Canvas (inset rounded card so the playful background shows)

    private var canvasCard: some View {
        GeometryReader { _ in
            ZStack {
                Color.white

                // Draw lines
                Canvas { context, _ in
                    for line in lines {
                        var path = Path()
                        guard let first = line.points.first else { continue }
                        path.move(to: first)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                        context.stroke(path, with: .color(line.color),
                                       style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                    }
                    if let current = currentLine {
                        var path = Path()
                        guard let first = current.points.first else { return }
                        path.move(to: first)
                        for point in current.points.dropFirst() {
                            path.addLine(to: point)
                        }
                        context.stroke(path, with: .color(current.color),
                                       style: StrokeStyle(lineWidth: current.lineWidth, lineCap: .round, lineJoin: .round))
                    }
                }

                // Placed stickers
                ForEach(Array(placedStickers.enumerated()), id: \.offset) { _, sticker in
                    Text(sticker.emoji)
                        .font(.system(size: 50))
                        .position(sticker.position)
                }

                // Sticker picker overlay
                if showStickers {
                    VStack {
                        Spacer()
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                            ForEach(stickers, id: \.self) { emoji in
                                Button(action: {
                                    Haptics.tap()
                                    SoundEngine.shared.play(.tap)
                                    // Arm this sticker — the next tap on the canvas places it.
                                    selectedSticker = emoji
                                    showStickers = false
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 38))
                                        .frame(width: 60, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedSticker == emoji ? GameTheme.drawing.accent.opacity(0.3) : .white)
                                                .shadow(radius: 3)
                                        )
                                }
                                .buttonStyle(SquishyButtonStyle())
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(GameTheme.drawing.gradientTop.opacity(0.97))
                                .shadow(radius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(GameTheme.drawing.accent.opacity(0.4), lineWidth: 2)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if showStickers { return }
                        // When a sticker is armed, the canvas places it on release — don't draw.
                        if selectedSticker != nil { return }
                        let point = value.location
                        if currentLine == nil {
                            currentLine = DrawingLine(points: [point], color: selectedColor, lineWidth: selectedWidth)
                        } else {
                            currentLine?.points.append(point)
                        }
                    }
                    .onEnded { value in
                        if showStickers { return }
                        // Tap-to-place: drop the armed sticker exactly where the child tapped.
                        if let emoji = selectedSticker {
                            Haptics.tap()
                            SoundEngine.shared.play(.pop)
                            withAnimation(.spring(response: 0.3)) {
                                placedStickers.append((emoji: emoji, position: value.location))
                            }
                            history.append(.sticker)
                            currentLine = nil
                            return
                        }
                        if let line = currentLine {
                            lines.append(line)
                            history.append(.stroke)
                        }
                        currentLine = nil
                    }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(GameTheme.drawing.accent.opacity(0.5), lineWidth: 2.5)
            )
            .shadow(color: GameTheme.drawing.accent.opacity(0.25), radius: 10, y: 4)
        }
    }

    // MARK: - Undo

    // Removes the most recent action (a stroke or a placed sticker), preserving order.
    private func undoLast() {
        guard let last = history.popLast() else { return }
        switch last {
        case .stroke:
            if !lines.isEmpty { lines.removeLast() }
        case .sticker:
            if !placedStickers.isEmpty { placedStickers.removeLast() }
        }
    }
}

#Preview {
    NavigationStack {
        DrawingGameView()
    }
}
