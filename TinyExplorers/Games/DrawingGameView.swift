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
    @State private var selectedWidth: CGFloat = 8
    @State private var showStickers = false

    let colors: [(Color, String)] = [
        (.red, "Red"), (.orange, "Orange"), (.yellow, "Yellow"),
        (.green, "Green"), (.blue, "Blue"), (.purple, "Purple"),
        (.pink, "Pink"), (.brown, "Brown"), (.black, "Black"), (.white, "Eraser"),
    ]

    let brushSizes: [(CGFloat, String)] = [
        (4, "Thin"), (8, "Medium"), (16, "Thick"), (28, "Super"),
    ]

    let stickers = ["⭐", "❤️", "🌈", "🦋", "🌸", "🐶", "🐱", "🎈",
                     "🌻", "🍎", "🐸", "🦄", "🎵", "☀️", "🌙", "🐝"]

    @State private var placedStickers: [(emoji: String, position: CGPoint)] = []

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.98)
                .ignoresSafeArea()

            HStack(spacing: 0) {
                // Tool sidebar
                VStack(spacing: 16) {
                    Text("🎨")
                        .font(.system(size: 40))

                    // Colors
                    VStack(spacing: 8) {
                        Text("Colors")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(colors, id: \.1) { color, name in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(color == .white ? Color.gray.opacity(0.2) : color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 3)
                                        )
                                        .overlay(
                                            color == .white ? Image(systemName: "eraser.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray) : nil
                                        )
                                }
                            }
                        }
                    }

                    Divider()

                    // Brush sizes
                    VStack(spacing: 8) {
                        Text("Size")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)

                        ForEach(brushSizes, id: \.1) { size, name in
                            Button(action: { selectedWidth = size }) {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: size + 8, height: size + 8)
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedWidth == size ? Color.blue.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }

                    Divider()

                    // Sticker button
                    Button(action: { showStickers.toggle() }) {
                        VStack(spacing: 4) {
                            Text("😀")
                                .font(.system(size: 28))
                            Text("Stickers")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(showStickers ? Color.yellow.opacity(0.3) : Color.clear)
                        )
                    }

                    Spacer()

                    // Clear button
                    Button(action: {
                        lines.removeAll()
                        placedStickers.removeAll()
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 24))
                            Text("Clear")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom, 16)
                }
                .frame(width: 100)
                .padding(.vertical, 12)
                .background(Color.white.shadow(radius: 4))

                // Canvas
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
                            HStack(spacing: 12) {
                                ForEach(stickers, id: \.self) { emoji in
                                    Button(action: {
                                        // Place sticker in center, user can tap canvas to place more
                                        placedStickers.append((emoji: emoji, position: CGPoint(x: 400, y: 400)))
                                        showStickers = false
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 40))
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.white)
                                                    .shadow(radius: 3)
                                            )
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.yellow.opacity(0.9))
                                    .shadow(radius: 8)
                            )
                            .padding(.bottom, 20)
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if showStickers { return }
                            let point = value.location
                            if currentLine == nil {
                                currentLine = DrawingLine(points: [point], color: selectedColor, lineWidth: selectedWidth)
                            } else {
                                currentLine?.points.append(point)
                            }
                        }
                        .onEnded { _ in
                            if let line = currentLine {
                                lines.append(line)
                            }
                            currentLine = nil
                        }
                )
                .clipShape(Rectangle())
            }
        }
        .navigationTitle("Drawing Fun")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DrawingGameView()
    }
}
