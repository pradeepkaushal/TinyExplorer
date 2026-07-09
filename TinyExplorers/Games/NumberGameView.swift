import SwiftUI

struct NumberGameView: View {
    @State private var currentNumber = 1
    @State private var tappedCount = 0
    @State private var items: [CountItem] = []
    @State private var showCelebration = false
    @State private var bounceNumber = false
    @State private var idlePulse = false
    @State private var progression = GameProgression(key: GameTheme.numbers.key)

    private let hints = [
        "Tap each item and count out loud!",
        "Count slowly — one at a time!",
        "The number tells you how many to tap!",
        "You're a counting champion now!",
    ]

    private let theme = GameTheme.numbers

    let numberEmojis: [Int: String] = [
        1: "🍎", 2: "🌟", 3: "🐱", 4: "🌺", 5: "🦋",
        6: "🐠", 7: "🎈", 8: "🍪", 9: "🐤", 10: "🌈",
        11: "🍩", 12: "🐸", 13: "🌻", 14: "🍬", 15: "🦄",
        16: "🎵", 17: "🍓", 18: "🐙", 19: "🌮", 20: "🎂"
    ]

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .numbers)

            VStack(spacing: 26) {
                Spacer(minLength: 8)

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                numberBadge

                missionHeader

                itemsGrid

                resetButton

                Spacer(minLength: 8)
            }
            .frame(maxHeight: .infinity)

            if showCelebration {
                CelebrationOverlayEnhanced(message: "You counted to \(currentNumber)!", emoji: numberEmojis[currentNumber] ?? "🎉")
                    .transition(.scale.combined(with: .opacity))
            }

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "123 Numbers", theme: theme)
        .onAppear {
            resetCounting()
            idlePulse = true
        }
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: - Pieces

    private var numberBadge: some View {
        HStack(spacing: 40) {
            arrowButton(systemName: "arrow.left.circle.fill", enabled: currentNumber > 1) {
                changeNumber(-1)
            }

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.accent, Color(red: 0.55, green: 0.35, blue: 0.95)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 190, height: 190)
                        .shadow(color: theme.accent.opacity(0.45), radius: 16, y: 8)

                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 5)
                        .frame(width: 168, height: 168)

                    Text("\(currentNumber)")
                        .font(.system(size: 92, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                }
                .scaleEffect(bounceNumber ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceNumber)

                Text(numberWord(currentNumber))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accent)
            }

            arrowButton(systemName: "arrow.right.circle.fill", enabled: currentNumber < 20) {
                changeNumber(1)
            }
        }
    }

    private func arrowButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 64))
                .foregroundColor(enabled ? theme.accent : .gray.opacity(0.4))
                .background(Circle().fill(.white).padding(6))
                .shadow(color: theme.accent.opacity(enabled ? 0.3 : 0), radius: 6, y: 3)
        }
        .buttonStyle(SquishyButtonStyle())
        .disabled(!enabled)
    }

    private var missionHeader: some View {
        VStack(spacing: 8) {
            MascotBubble(theme: theme, text: "Mission: count to \(currentNumber)!")

            Text("\(tappedCount) of \(currentNumber) found")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.accent)
                        .shadow(color: theme.accent.opacity(0.4), radius: 5, y: 3)
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tappedCount)
        }
    }

    private var itemsGrid: some View {
        let circleSize: CGFloat = currentNumber > 10 ? 108 : 126
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 14), count: min(currentNumber, 5))
        return LazyVGrid(columns: gridColumns, spacing: 14) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button(action: { tapItem(item) }) {
                    ZStack {
                        Circle()
                            .fill(
                                item.tapped
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [theme.accent.opacity(0.35), theme.accent.opacity(0.15)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                  )
                                : AnyShapeStyle(Color.white)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .overlay(
                                Circle().stroke(theme.accent.opacity(item.tapped ? 1.0 : 0.5), lineWidth: 2.5)
                            )
                            .shadow(color: theme.accent.opacity(0.3), radius: 6, y: 4)

                        if item.tapped {
                            Text(numberEmojis[currentNumber] ?? "⭐")
                                .font(.system(size: circleSize * 0.52))
                                .transition(.scale)
                        } else {
                            Text("?")
                                .font(.system(size: circleSize * 0.45, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.accent.opacity(0.6))
                        }
                    }
                }
                .buttonStyle(SquishyButtonStyle())
                .disabled(item.tapped)
                .animation(.spring(), value: item.tapped)
                .popIn(delay: Double(index) * 0.04)
            }
        }
        .padding(.horizontal, 50)
    }

    private var resetButton: some View {
        Button(action: {
            Haptics.tap()
            SoundEngine.shared.play(.tap)
            resetCounting()
        }) {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Reset")
            }
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 36)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(theme.accent)
                    .shadow(color: theme.accent.opacity(0.4), radius: 6, y: 4)
            )
        }
        .buttonStyle(SquishyButtonStyle())
    }

    // MARK: - Logic

    func changeNumber(_ delta: Int) {
        Haptics.tap()
        SoundEngine.shared.play(.tap)
        currentNumber = max(1, min(20, currentNumber + delta))
        bounceNumber = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceNumber = false }
        resetCounting()
        SpeechHelper.speak("\(numberWord(currentNumber))!")
    }

    func tapItem(_ item: CountItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }), !items[index].tapped else { return }
        items[index].tapped = true
        tappedCount += 1

        Haptics.tap()
        SoundEngine.shared.play(.pop)
        SoundEngine.shared.playNote(midi: 60 + tappedCount, timbre: .chime, duration: 0.4, volume: 0.5)
        SpeechHelper.speak("\(tappedCount)")

        if tappedCount == currentNumber {
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            Haptics.success()
            SoundEngine.shared.play(.win)
            withAnimation {
                showCelebration = true
            }
            if !progression.showLevelUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    SpeechHelper.speak("You counted to \(currentNumber)!")
                }
            }
            let delay = progression.showLevelUp ? 3.0 : 3.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                // Auto-advance to next number on level up
                if progression.showLevelUp && currentNumber < 20 {
                    currentNumber += 1
                    bounceNumber = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceNumber = false }
                }
                withAnimation { showCelebration = false }
            }
        }
    }

    func resetCounting() {
        tappedCount = 0
        showCelebration = false
        items = (0..<currentNumber).map { _ in CountItem() }
    }

    func numberWord(_ n: Int) -> String {
        let words = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
                     "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
                     "Eighteen", "Nineteen", "Twenty"]
        return n <= 20 ? words[n] : "\(n)"
    }
}

struct CountItem: Identifiable {
    let id = UUID()
    var tapped = false
}

#Preview {
    NavigationStack {
        NumberGameView()
    }
}
