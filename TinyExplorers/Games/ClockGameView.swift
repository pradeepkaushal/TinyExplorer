import SwiftUI

/// Clock Time — read the analog clock and pick the right time.
/// Easy mode is whole hours; Half Past mode adds half hours.
struct ClockGameView: View {
    enum Level: String, CaseIterable {
        case hours = "O'Clock"
        case halves = "Half Past"
    }

    @State private var level: Level = .hours
    @State private var hour = 3
    @State private var halfPast = false
    @State private var options: [String] = []
    @State private var score = 0
    @State private var streak = 0
    @State private var celebrating = false
    @State private var wrongAnswer: String? = nil
    @State private var celebrationMessage = Encouragement.random()

    private let theme = GameTheme.clock

    private var answer: String { Self.label(hour: hour, halfPast: halfPast) }

    static func label(hour: Int, halfPast: Bool) -> String {
        halfPast ? "Half past \(hour)" : "\(hour) o'clock"
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    ThemedSegmentedPicker(
                        items: Level.allCases.map { (title: $0.rawValue, value: $0) },
                        selection: $level,
                        accent: theme.accent
                    )
                    .onChange(of: level) { _ in
                        SoundEngine.shared.play(.pop)
                        newRound()
                    }
                    StarCounterChip(count: score)
                    StreakBadge(streak: streak)
                }

                MascotBubble(theme: theme, text: "What time is it?", mascotSize: 50)

                Spacer(minLength: 0)

                ClockFace(hour: hour, halfPast: halfPast, accent: theme.accent)
                    .frame(width: 300, height: 300)
                    .scaleEffect(celebrating ? 1.08 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: celebrating)

                Spacer(minLength: 0)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 2), spacing: 18) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            pick(option)
                        } label: {
                            Text(option)
                                .font(.system(size: 27, weight: .heavy, design: .rounded))
                                .foregroundColor(theme.accent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 82)
                                .background(
                                    RoundedRectangle(cornerRadius: 22)
                                        .fill(.white.opacity(wrongAnswer == option ? 0.6 : 0.94))
                                        .shadow(color: theme.accent.opacity(0.25), radius: 6, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(
                                            wrongAnswer == option ? Color.red.opacity(0.5) : theme.accent.opacity(0.4),
                                            lineWidth: 3
                                        )
                                )
                                .rotationEffect(.degrees(wrongAnswer == option ? 3 : 0))
                                .animation(
                                    wrongAnswer == option
                                        ? .easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)
                                        : .default,
                                    value: wrongAnswer
                                )
                        }
                        .buttonStyle(SquishyButtonStyle())
                        .disabled(celebrating)
                    }
                }
                .padding(.horizontal, 120)

                Spacer(minLength: 0)
            }
            .padding(.top, 10)
            .padding(.horizontal, 30)

            if celebrating {
                CelebrationOverlay(message: celebrationMessage, emoji: "⏰")
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Clock Time")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { newRound() }
        .onDisappear { SpeechHelper.stop() }
    }

    private func newRound() {
        celebrating = false
        wrongAnswer = nil
        hour = Int.random(in: 1...12)
        halfPast = level == .halves && Bool.random()

        var opts = Set([answer])
        while opts.count < 4 {
            let h = Int.random(in: 1...12)
            let half = level == .halves && Bool.random()
            opts.insert(Self.label(hour: h, halfPast: half))
        }
        options = Array(opts).shuffled()
        SpeechHelper.speak("What time is it?")
    }

    private func pick(_ option: String) {
        guard !celebrating else { return }
        if option == answer {
            celebrationMessage = Encouragement.random()
            score += 1
            streak += 1
            StarBank.shared.award(1, to: theme.key)
            Haptics.success()
            SoundEngine.shared.play(.correct)
            SpeechHelper.cheer(halfPast ? "Yes! It's half past \(hour)!" : "Yes! It's \(hour) o'clock!")
            if streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    SoundEngine.shared.play(.streak)
                }
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                celebrating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation { newRound() }
            }
        } else {
            streak = 0
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Look at the little hand! Try again!")
            withAnimation { wrongAnswer = option }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongAnswer = nil
            }
        }
    }
}

/// A friendly analog clock drawn in SwiftUI: numbered face, thick hour hand,
/// thin minute hand, smiling center.
struct ClockFace: View {
    let hour: Int
    let halfPast: Bool
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let r = s / 2
            ZStack {
                Circle()
                    .fill(.white)
                    .shadow(color: accent.opacity(0.35), radius: 12, y: 6)
                Circle()
                    .stroke(accent, lineWidth: s * 0.045)

                // Numbers 1-12
                ForEach(1...12, id: \.self) { n in
                    let angle = Double(n) / 12.0 * 2 * .pi - .pi / 2
                    Text("\(n)")
                        .font(.system(size: s * 0.105, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                        .position(
                            x: r + cos(angle) * r * 0.78,
                            y: r + sin(angle) * r * 0.78
                        )
                }

                // Minute ticks
                ForEach(0..<12, id: \.self) { n in
                    Capsule()
                        .fill(accent.opacity(0.45))
                        .frame(width: s * 0.012, height: s * 0.05)
                        .offset(y: -r * 0.93)
                        .rotationEffect(.degrees(Double(n) * 30))
                }

                // Hour hand (shorter, thicker); points midway when half past.
                Capsule()
                    .fill(Color(red: 0.25, green: 0.3, blue: 0.45))
                    .frame(width: s * 0.045, height: r * 0.45)
                    .offset(y: -r * 0.225)
                    .rotationEffect(.degrees(Double(hour % 12) * 30 + (halfPast ? 15 : 0)))

                // Minute hand (longer, thinner)
                Capsule()
                    .fill(accent)
                    .frame(width: s * 0.03, height: r * 0.68)
                    .offset(y: -r * 0.34)
                    .rotationEffect(.degrees(halfPast ? 180 : 0))

                Circle()
                    .fill(accent)
                    .frame(width: s * 0.09)
                Text("😊")
                    .font(.system(size: s * 0.055))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hour)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: halfPast)
        }
    }
}

#Preview {
    NavigationStack { ClockGameView() }
}
