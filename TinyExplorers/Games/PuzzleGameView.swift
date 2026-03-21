import SwiftUI

struct PuzzlePiece: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let correctSlot: Int
    var currentSlot: Int?

    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        lhs.id == rhs.id
    }
}

struct PuzzleGameView: View {
    let puzzleThemes: [(name: String, emojis: [String])] = [
        ("Farm Animals", ["🐄", "🐔", "🐷", "🐑", "🐴", "🐰"]),
        ("Sea Creatures", ["🐟", "🐙", "🦀", "🐳", "🦈", "🐠"]),
        ("Fruits", ["🍎", "🍊", "🍋", "🍇", "🍓", "🍌"]),
        ("Vehicles", ["🚗", "🚌", "🚂", "✈️", "🚁", "🚀"]),
        ("Weather", ["☀️", "🌧️", "⛈️", "🌈", "❄️", "🌤️"]),
        ("Food", ["🍕", "🍔", "🌮", "🍩", "🍪", "🧁"]),
    ]

    @State private var currentThemeIndex = 0
    @State private var pieces: [PuzzlePiece] = []
    @State private var slots: [PuzzlePiece?] = Array(repeating: nil, count: 6)
    @State private var selectedPieceId: UUID? = nil
    @State private var completed = false
    @State private var score = 0
    @State private var showWrongFeedback = false

    var currentTheme: (name: String, emojis: [String]) {
        puzzleThemes[currentThemeIndex]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.9, green: 0.95, blue: 1.0), Color(red: 0.95, green: 0.9, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Theme: \(currentTheme.name)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Spacer()

                    Text("Score: \(score)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.purple)

                    Spacer()

                    Button(action: nextTheme) {
                        HStack {
                            Text("Next Theme")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.purple))
                    }
                }
                .padding(.horizontal, 40)

                Text(selectedPieceId != nil ? "Now tap the matching spot above!" : "Tap a piece below, then tap its matching spot!")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(selectedPieceId != nil ? .blue : .secondary)
                    .animation(.easeInOut, value: selectedPieceId)

                // Target slots
                HStack(spacing: 16) {
                    ForEach(0..<6, id: \.self) { slotIndex in
                        Button(action: {
                            tapSlot(slotIndex)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(slots[slotIndex] != nil ? Color.green.opacity(0.2) : Color.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                style: StrokeStyle(lineWidth: 2, dash: slots[slotIndex] != nil ? [] : [8])
                                            )
                                            .foregroundColor(slots[slotIndex] != nil ? .green : (selectedPieceId != nil ? .blue : .gray))
                                    )

                                if let piece = slots[slotIndex] {
                                    Text(piece.emoji)
                                        .font(.system(size: 64))
                                        .transition(.scale)
                                } else {
                                    Text(currentTheme.emojis[slotIndex])
                                        .font(.system(size: 64))
                                        .opacity(0.2)
                                }
                            }
                        }
                        .disabled(slots[slotIndex] != nil)
                    }
                }
                .padding(.horizontal, 40)

                Divider()
                    .padding(.horizontal, 60)

                // Available pieces
                HStack(spacing: 20) {
                    ForEach(pieces.filter({ $0.currentSlot == nil })) { piece in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                if selectedPieceId == piece.id {
                                    selectedPieceId = nil
                                } else {
                                    selectedPieceId = piece.id
                                }
                            }
                        }) {
                            Text(piece.emoji)
                                .font(.system(size: 64))
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedPieceId == piece.id ? Color.blue.opacity(0.2) : Color.white)
                                        .shadow(
                                            color: selectedPieceId == piece.id ? .blue.opacity(0.5) : .purple.opacity(0.3),
                                            radius: selectedPieceId == piece.id ? 10 : 6
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: selectedPieceId == piece.id ? 3 : 0)
                                )
                                .scaleEffect(selectedPieceId == piece.id ? 1.1 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 40)

                if showWrongFeedback {
                    Text("Hmm, try a different spot!")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                        .transition(.scale.combined(with: .opacity))
                }

                // Reset button
                Button(action: resetPuzzle) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Puzzle")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.blue))
                }

                Spacer()
            }
            .padding(.top, 16)

            if completed {
                VStack(spacing: 16) {
                    Text("🧩 Puzzle Complete! 🧩")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)

                    Text("All pieces matched correctly!")
                        .font(.system(size: 22, weight: .medium, design: .rounded))

                    Button("Next Puzzle") {
                        withAnimation { completed = false }
                        nextTheme()
                    }
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Color.green))
                }
                .padding(40)
                .background(RoundedRectangle(cornerRadius: 24).fill(.white).shadow(radius: 20))
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationTitle("Puzzle Time")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { resetPuzzle() }
    }

    func resetPuzzle() {
        pieces = currentTheme.emojis.enumerated().map { index, emoji in
            PuzzlePiece(emoji: emoji, correctSlot: index)
        }.shuffled()
        slots = Array(repeating: nil, count: 6)
        selectedPieceId = nil
        completed = false
    }

    func nextTheme() {
        currentThemeIndex = (currentThemeIndex + 1) % puzzleThemes.count
        resetPuzzle()
    }

    func tapSlot(_ slotIndex: Int) {
        guard let pieceId = selectedPieceId,
              let pieceIndex = pieces.firstIndex(where: { $0.id == pieceId }),
              slots[slotIndex] == nil else { return }

        let piece = pieces[pieceIndex]

        if piece.correctSlot == slotIndex {
            withAnimation(.spring()) {
                pieces[pieceIndex].currentSlot = slotIndex
                slots[slotIndex] = pieces[pieceIndex]
                selectedPieceId = nil
            }
            score += 10

            if slots.allSatisfy({ $0 != nil }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) { completed = true }
                }
            }
        } else {
            withAnimation { showWrongFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showWrongFeedback = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleGameView()
    }
}
