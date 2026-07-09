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
    @State private var minute = 0
    @State private var options: [String] = []
    @State private var score = 0
    @State private var streak = 0
    @State private var celebrating = false
    @State private var wrongAnswer: String? = nil
    @State private var lastAnswer: String? = nil
    @State private var celebrationMessage = Encouragement.random()
    @State private var progression = GameProgression(key: GameTheme.clock.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false

    private let hints = [
        "The SHORT hand shows the hour!",
        "The LONG hand points to 12 for o'clock!",
        "Half past means the long hand is at 6!",
        "You're a time-telling pro now!",
    ]

    private let theme = GameTheme.clock

    private var answer: String { Self.label(hour: hour, minute: minute) }

    static func label(hour: Int, minute: Int) -> String {
        switch minute {
        case 15: return "quarter past \(hour)"
        case 30: return "half past \(hour)"
        case 45: return "quarter to \(hour % 12 + 1)"
        default: return "\(hour) o'clock"
        }
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            VStack(spacing: 18) {
                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)
    AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
                }

                MascotBubble(theme: theme, text: "What time is it?", mascotSize: 50)

                Spacer(minLength: 0)

                ClockFace(hour: hour, minute: minute, accent: theme.accent)
                    .frame(width: 300, height: 300)
                    .scaleEffect(celebrating ? 1.08 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: celebrating)

                Spacer(minLength: 0)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 2), spacing: 18) {
                    ForEach(options, id: \.self) { option in
                        // Speaker sits beside the answer so a pre-reader can
                        // hear each time without selecting it.
                        HStack(spacing: 10) {
                            SpeakOptionButton(text: option, accent: theme.accent)
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
                }
                .padding(.horizontal, 90)

                Spacer(minLength: 0)
            }
            .padding(.top, 10)
            .padding(.horizontal, 30)

            if celebrating {
                CelebrationOverlayEnhanced(message: celebrationMessage, emoji: "⏰")
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
                        newRound()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Clock Time", theme: theme)
        .onAppear { newRound() }
        .onDisappear { SpeechHelper.stop() }
    }

    private func newRound() {
        celebrating = false
        wrongAnswer = nil

        // Difficulty tiers unlock more times as the level climbs.
        let allowedMinutes: [Int] = progression.level <= 1 ? [0]
            : progression.level <= 3 ? [0, 30]
            : [0, 15, 30, 45]

        // Re-roll until the new time differs from the previous prompt.
        repeat {
            hour = Int.random(in: 1...12)
            minute = allowedMinutes.randomElement()!
        } while Self.label(hour: hour, minute: minute) == lastAnswer

        let optionCount = progression.level >= 4 ? 6 : 4

        var opts = Set([answer])

        // Higher levels use time-adjacent distractors so the hands must be
        // read carefully instead of just glanced at.
        if progression.level >= 3 {
            var near: [String] = []
            // Same hour, but a different allowed minute.
            for m in allowedMinutes where m != minute {
                near.append(Self.label(hour: hour, minute: m))
            }
            // Neighbouring hours, keeping the answer's minute.
            for dh in [-1, 1] {
                let h = (hour - 1 + dh + 12) % 12 + 1
                near.append(Self.label(hour: h, minute: minute))
            }
            for candidate in near.shuffled() where opts.count < optionCount {
                opts.insert(candidate)
            }
        }

        // Fill any remaining slots with random times from the same tier.
        while opts.count < optionCount {
            let h = Int.random(in: 1...12)
            let m = allowedMinutes.randomElement()!
            opts.insert(Self.label(hour: h, minute: m))
        }
        options = Array(opts).shuffled()
        lastAnswer = answer
        SpeechHelper.speak("What time is it?")
    }

    private func pick(_ option: String) {
        guard !celebrating else { return }
        if option == answer {
            celebrationMessage = Encouragement.random()
            score += 1
            streak += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            if !progression.showLevelUp {
                SpeechHelper.cheer("Yes! It's \(answer)!")
            }
            if !progression.showLevelUp, streak > 0 && streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    SoundEngine.shared.play(.streak)
                }
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                celebrating = true
            }
            let delay = progression.showLevelUp ? 2.5 : 1.9
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                celebrating = false
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { newRound() }
                }
            }
        } else {
            streak = 0
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
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
    let minute: Int
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

                // Hour hand (shorter, thicker); creeps forward with the minutes.
                Capsule()
                    .fill(Color(red: 0.25, green: 0.3, blue: 0.45))
                    .frame(width: s * 0.045, height: r * 0.45)
                    .offset(y: -r * 0.225)
                    .rotationEffect(.degrees(Double(hour % 12) * 30 + Double(minute) / 60.0 * 30))

                // Minute hand (longer, thinner)
                Capsule()
                    .fill(accent)
                    .frame(width: s * 0.03, height: r * 0.68)
                    .offset(y: -r * 0.34)
                    .rotationEffect(.degrees(Double(minute) / 60.0 * 360))

                Circle()
                    .fill(accent)
                    .frame(width: s * 0.09)
                Text("😊")
                    .font(.system(size: s * 0.055))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hour)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: minute)
        }
    }
}

#Preview {
    NavigationStack { ClockGameView() }
}
