import SwiftUI

struct SocialScenario: Identifiable {
    let id = UUID()
    let situation: String
    let emoji: String
    let options: [SocialOption]
    let category: String
}

struct SocialOption: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
    let isCorrect: Bool
    let explanation: String
}

struct SocialGameView: View {
    let scenarios: [SocialScenario] = [
        // Manners & Politeness
        SocialScenario(
            situation: "Someone gives you a gift. What do you say?",
            emoji: "🎁",
            options: [
                SocialOption(text: "Thank you!", emoji: "😊", isCorrect: true, explanation: "Saying 'thank you' shows you appreciate the gift!"),
                SocialOption(text: "I don't like it", emoji: "😒", isCorrect: false, explanation: "Even if you don't love the gift, it's kind to say thank you."),
                SocialOption(text: "Give me more!", emoji: "😤", isCorrect: false, explanation: "Asking for more can hurt someone's feelings."),
            ],
            category: "Manners"
        ),
        SocialScenario(
            situation: "You accidentally bump into someone. What do you do?",
            emoji: "💥",
            options: [
                SocialOption(text: "Say 'Sorry!'", emoji: "🙏", isCorrect: true, explanation: "Apologizing shows you care about others!"),
                SocialOption(text: "Walk away", emoji: "🚶", isCorrect: false, explanation: "Walking away without saying sorry can make someone feel bad."),
                SocialOption(text: "Laugh at them", emoji: "😂", isCorrect: false, explanation: "Laughing can hurt their feelings. It's better to say sorry."),
            ],
            category: "Manners"
        ),
        // Emotions
        SocialScenario(
            situation: "Your friend is crying. What should you do?",
            emoji: "😢",
            options: [
                SocialOption(text: "Ask if they're OK", emoji: "🤗", isCorrect: true, explanation: "Asking shows you care and want to help your friend!"),
                SocialOption(text: "Ignore them", emoji: "🙈", isCorrect: false, explanation: "Friends need us when they're sad. Try to help!"),
                SocialOption(text: "Tell them to stop", emoji: "🛑", isCorrect: false, explanation: "Everyone needs to express their feelings. Be patient and kind."),
            ],
            category: "Emotions"
        ),
        SocialScenario(
            situation: "You feel really angry. What's the best thing to do?",
            emoji: "😡",
            options: [
                SocialOption(text: "Take deep breaths", emoji: "🌬️", isCorrect: true, explanation: "Breathing deeply helps calm you down so you can think clearly!"),
                SocialOption(text: "Yell at someone", emoji: "🗣️", isCorrect: false, explanation: "Yelling can hurt others. Try calming down first."),
                SocialOption(text: "Break something", emoji: "💔", isCorrect: false, explanation: "Breaking things doesn't help. Deep breaths are much better!"),
            ],
            category: "Emotions"
        ),
        // Sharing
        SocialScenario(
            situation: "You have cookies and your friend has none. What do you do?",
            emoji: "🍪",
            options: [
                SocialOption(text: "Share some!", emoji: "🤝", isCorrect: true, explanation: "Sharing makes everyone happy and is a great way to be kind!"),
                SocialOption(text: "Eat them all", emoji: "😋", isCorrect: false, explanation: "Eating them all when your friend has none isn't very kind."),
                SocialOption(text: "Hide them", emoji: "🙈", isCorrect: false, explanation: "Hiding food from a friend can make them sad. Sharing is caring!"),
            ],
            category: "Sharing"
        ),
        SocialScenario(
            situation: "A new kid joins your class. What should you do?",
            emoji: "👋",
            options: [
                SocialOption(text: "Say hello and be friendly", emoji: "😄", isCorrect: true, explanation: "Being friendly helps new kids feel welcome and happy!"),
                SocialOption(text: "Ignore them", emoji: "😐", isCorrect: false, explanation: "Being ignored feels lonely. Saying hi can make their whole day!"),
                SocialOption(text: "Whisper about them", emoji: "🤫", isCorrect: false, explanation: "Whispering about someone can hurt their feelings."),
            ],
            category: "Friendship"
        ),
        // Safety
        SocialScenario(
            situation: "A stranger asks you to go with them. What do you do?",
            emoji: "⚠️",
            options: [
                SocialOption(text: "Say NO and tell a grown-up", emoji: "🚫", isCorrect: true, explanation: "Always say no to strangers and tell a trusted adult right away!"),
                SocialOption(text: "Go with them", emoji: "🚶", isCorrect: false, explanation: "Never go with strangers! Always tell a trusted grown-up."),
                SocialOption(text: "Take their candy", emoji: "🍬", isCorrect: false, explanation: "Never accept things from strangers. Tell a grown-up instead!"),
            ],
            category: "Safety"
        ),
        // Teamwork
        SocialScenario(
            situation: "Your team is working on a project but one person isn't helping. What do you do?",
            emoji: "🏗️",
            options: [
                SocialOption(text: "Ask them nicely to help", emoji: "💬", isCorrect: true, explanation: "Asking nicely encourages everyone to participate!"),
                SocialOption(text: "Do all the work yourself", emoji: "😩", isCorrect: false, explanation: "It's better to include everyone. Ask them what they'd like to do!"),
                SocialOption(text: "Tell on them", emoji: "☝️", isCorrect: false, explanation: "Try asking them first. Maybe they don't know how to help!"),
            ],
            category: "Teamwork"
        ),
    ]

    @State private var currentIndex = 0
    @State private var selectedOption: SocialOption? = nil
    @State private var score = 0
    @State private var streak = 0
    @State private var answeredCount = 0
    @State private var showExplanation = false
    @State private var shuffledScenarios: [SocialScenario] = []
    @State private var scenarioSway = false

    private let theme = GameTheme.social

    var currentScenario: SocialScenario {
        shuffledScenarios.isEmpty ? scenarios[0] : shuffledScenarios[currentIndex % shuffledScenarios.count]
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .social)

            VStack(spacing: 0) {
                // Score bar
                HStack(spacing: 16) {
                    StarCounterChip(count: score)
                    StreakBadge(streak: streak)

                    Spacer()

                    Text("Category: \(currentScenario.category)")
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.85))
                                .overlay(Capsule().strokeBorder(theme.accent.opacity(0.35), lineWidth: 1.5))
                        )

                    Spacer()

                    Text("Question \(answeredCount + 1)")
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                .padding(.top, 16)

                Spacer(minLength: 16)

                // Main content, centered in the remaining space
                VStack(spacing: 22) {
                    // The bear hosts the question; it steps aside when the
                    // explanation panel needs the vertical space.
                    if !showExplanation {
                        MascotBubble(theme: theme, text: "What would YOU do?", mascotSize: 48)
                            .transition(.scale.combined(with: .opacity))
                    }

                    scenarioCard

                    VStack(spacing: 16) {
                        ForEach(Array(currentScenario.options.enumerated()), id: \.element.id) { index, option in
                            optionCard(option)
                                .popIn(delay: Double(index) * 0.04)
                        }
                    }

                    if showExplanation, let option = selectedOption {
                        explanationPanel(option)
                    }
                }
                .padding(.horizontal, 40)

                Spacer(minLength: 24)
            }
        }
        .navigationTitle("Social Skills")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledScenarios = scenarios.shuffled()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SpeechHelper.speak(currentScenario.situation)
            }
        }
        .onDisappear {
            SpeechHelper.stop()
        }
    }

    // MARK: - Subviews

    private var scenarioCard: some View {
        VStack(spacing: 14) {
            Text(currentScenario.emoji)
                .font(.system(size: 110))

            Text(currentScenario.situation)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                Haptics.tap()
                SoundEngine.shared.play(.tap)
                SpeechHelper.speak(currentScenario.situation)
            } label: {
                Label("Read aloud", systemImage: "speaker.wave.2.fill")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.accent.opacity(0.12)))
            }
            .buttonStyle(SquishyButtonStyle())
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: 720)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.white, theme.accent.opacity(0.10)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(theme.accent.opacity(0.4), lineWidth: 2.5)
                )
                .shadow(color: theme.accent.opacity(0.25), radius: 12, y: 6)
        )
    }

    private func optionCard(_ option: SocialOption) -> some View {
        Button {
            selectOption(option)
        } label: {
            HStack(spacing: 22) {
                Text(option.emoji)
                    .font(.system(size: 52))

                Text(option.text)
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if selectedOption?.id == option.id {
                    Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(option.isCorrect ? .green : .red)
                        .transition(.scale)
                }
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 20)
            .frame(maxWidth: 720)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(cardFill(for: option))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(cardBorder(for: option), lineWidth: 2.5)
                    )
                    .shadow(color: theme.accent.opacity(0.2), radius: 8, y: 4)
            )
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.95))
        .disabled(selectedOption != nil)
    }

    private func explanationPanel(_ option: SocialOption) -> some View {
        VStack(spacing: 10) {
            Text(option.isCorrect ? "Great choice!" : "Let's learn from this!")
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundColor(option.isCorrect ? .green : .orange)

            Text(option.explanation)
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Haptics.tap()
                SoundEngine.shared.play(.pop)
                nextQuestion()
            } label: {
                HStack(spacing: 8) {
                    Text("Next Question")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 34)
                .padding(.vertical, 13)
                .background(
                    Capsule()
                        .fill(theme.accent)
                        .shadow(color: theme.accent.opacity(0.45), radius: 6, y: 3)
                )
            }
            .buttonStyle(SquishyButtonStyle())
            .padding(.top, 6)
        }
        .padding(22)
        .frame(maxWidth: 640)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            (option.isCorrect ? Color.green : Color.orange).opacity(0.45),
                            lineWidth: 2.5
                        )
                )
                .shadow(color: theme.accent.opacity(0.2), radius: 10, y: 5)
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Styling

    private func cardFill(for option: SocialOption) -> LinearGradient {
        let base: Color
        if let selected = selectedOption {
            if option.id == selected.id {
                base = option.isCorrect ? Color.green.opacity(0.22) : Color.red.opacity(0.20)
            } else if option.isCorrect {
                base = Color.green.opacity(0.12)
            } else {
                base = Color.white.opacity(0.5)
            }
        } else {
            base = theme.accent.opacity(0.10)
        }
        return LinearGradient(colors: [.white, base], startPoint: .top, endPoint: .bottom)
    }

    private func cardBorder(for option: SocialOption) -> Color {
        if let selected = selectedOption {
            if option.id == selected.id {
                return option.isCorrect ? .green : .red
            }
            if option.isCorrect { return .green.opacity(0.6) }
            return theme.accent.opacity(0.2)
        }
        return theme.accent.opacity(0.45)
    }

    // MARK: - Game logic

    func selectOption(_ option: SocialOption) {
        withAnimation(.spring()) {
            selectedOption = option
            showExplanation = true
        }

        if option.isCorrect {
            score += 1
            StarBank.shared.award(1, to: theme.key)
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation(.spring()) { streak += 1 }
            if streak > 0, streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                score += 1
                SoundEngine.shared.play(.streak)
                SpeechHelper.speak("\(streak) in a row!")
            } else {
                SpeechHelper.cheer(Encouragement.random())
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            withAnimation(.spring()) { streak = 0 }
            SpeechHelper.speak(option.explanation)
        }
    }

    func nextQuestion() {
        withAnimation {
            selectedOption = nil
            showExplanation = false
            answeredCount += 1
            currentIndex += 1

            if currentIndex >= shuffledScenarios.count {
                shuffledScenarios = scenarios.shuffled()
                currentIndex = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SpeechHelper.speak(currentScenario.situation)
        }
    }
}

#Preview {
    NavigationStack {
        SocialGameView()
    }
}
