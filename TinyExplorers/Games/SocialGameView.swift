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
                SocialOption(text: "Put it away without a word", emoji: "😐", isCorrect: false, explanation: "A quick 'thank you' lets the giver know you care."),
                SocialOption(text: "Ask how much it cost", emoji: "💰", isCorrect: false, explanation: "The kind thing is to say thank you, not ask the price."),
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
                SocialOption(text: "Say it was their fault", emoji: "😠", isCorrect: false, explanation: "Owning our little mistakes with a 'sorry' is the kind thing to do."),
                SocialOption(text: "Pretend it didn't happen", emoji: "😶", isCorrect: false, explanation: "Even a small bump deserves a gentle 'sorry'."),
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
                SocialOption(text: "Walk to another room", emoji: "🚪", isCorrect: false, explanation: "Staying close shows your friend they are not alone."),
                SocialOption(text: "Say it's no big deal", emoji: "🤷", isCorrect: false, explanation: "Feelings matter. Ask how you can help instead."),
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
                SocialOption(text: "Keep it all inside", emoji: "😑", isCorrect: false, explanation: "It helps to let big feelings out gently, like with deep breaths."),
                SocialOption(text: "Stomp away upset", emoji: "😾", isCorrect: false, explanation: "A few deep breaths help more than stomping away."),
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
                SocialOption(text: "Eat them quickly", emoji: "😬", isCorrect: false, explanation: "Slowing down to share makes the treat even sweeter."),
                SocialOption(text: "Say maybe later", emoji: "🤔", isCorrect: false, explanation: "Sharing right now shows your friend you care."),
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
                SocialOption(text: "Wait for them to talk first", emoji: "🤐", isCorrect: false, explanation: "A friendly 'hello' first helps them feel welcome."),
                SocialOption(text: "Watch them from far away", emoji: "👀", isCorrect: false, explanation: "Going over to say hi is warmer than watching."),
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
                SocialOption(text: "Ask where they want to go", emoji: "🤔", isCorrect: false, explanation: "Don't chat with strangers. Say no and find a grown-up."),
                SocialOption(text: "Follow just a little way", emoji: "👣", isCorrect: false, explanation: "Never follow a stranger. Say no and tell an adult you trust."),
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
                SocialOption(text: "Ignore them and keep going", emoji: "🙄", isCorrect: false, explanation: "Inviting them in works better than leaving them out."),
                SocialOption(text: "Get upset with them", emoji: "😤", isCorrect: false, explanation: "A kind question helps more than getting upset."),
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
    @State private var displayedOptions: [SocialOption] = []
    @State private var scenarioSway = false
    @State private var progression = GameProgression(key: GameTheme.social.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    // The +1.5s "why it was kind" explanation is held here so advancing or
    // leaving can cancel it before it interrupts the next prompt / Home screen.
    @State private var pendingExplanation: DispatchWorkItem? = nil

    private let hints = [
        "Think: what would a kind friend do?",
        "Put yourself in their shoes!",
        "There's always a caring choice!",
        "You're a kindness champion now!",
    ]

    private let theme = GameTheme.social

    var currentScenario: SocialScenario {
        shuffledScenarios.isEmpty ? scenarios[0] : shuffledScenarios[currentIndex % shuffledScenarios.count]
    }

    // More choices to weigh as the child levels up: L1 shows 3, L2 shows 4,
    // L3+ shows 5 (capped by how many options a scenario actually carries).
    var optionCount: Int { min(currentScenario.options.count, 2 + progression.level) }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .social)

            VStack(spacing: 0) {
                // Score bar
                HStack(spacing: 16) {
                    StarCounterChipEnhanced(count: score)
                    StreakBadgeEnhanced(streak: streak)
    AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)

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

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)

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
                        ForEach(Array(displayedOptions.enumerated()), id: \.element.id) { index, option in
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

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    withAnimation {
                        showAdventureComplete = false
                        nextQuestion()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Social Skills", theme: theme)
        .onAppear {
            shuffledScenarios = levelScenarios().shuffled()
            buildOptions()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SpeechHelper.speak(currentScenario.situation)
            }
        }
        .onDisappear {
            cancelPendingExplanation()
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
        // Speaker beside the card: the option sentences are the one part of
        // this game a pre-reader couldn't access before.
        HStack(spacing: 12) {
            SpeakOptionButton(text: option.text, accent: theme.accent)
            optionCardButton(option)
        }
    }

    private func optionCardButton(_ option: SocialOption) -> some View {
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
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation(.spring()) { streak += 1 }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if streak > 0, streak % 5 == 0 {
                StarBank.shared.award(1, to: theme.key)
                score += 1
                SoundEngine.shared.play(.streak)
                SpeechHelper.speak("\(streak) in a row!")
            } else {
                SpeechHelper.cheer(Encouragement.random())
            }
            let delay = progression.showLevelUp ? 2.5 : 0.0
            if progression.showLevelUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation { progression.clearLevelUp() }
                }
            }
            // Read WHY the choice was kind so a pre-reader hears the lesson,
            // just as wrong answers already speak their explanation. Delayed so
            // the celebration line plays first (speak interrupts prior speech).
            // Held in a cancellable work item so a fast tap on Next Question, an
            // adventure chest, or a Back tap doesn't let this fire late and
            // clobber the next prompt.
            let work = DispatchWorkItem {
                SpeechHelper.speak(option.explanation)
                pendingExplanation = nil
            }
            pendingExplanation = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            progression.registerWrong()
            adventure.recordMiss()
            withAnimation(.spring()) { streak = 0 }
            SpeechHelper.speak(option.explanation)
        }
    }

    /// Restricts the deck to gentle Manners / Sharing / Emotions scenarios at
    /// Level 1, unlocking the judgment-heavy Safety / Teamwork / Friendship
    /// scenarios once the child reaches Level 2.
    func levelScenarios() -> [SocialScenario] {
        guard progression.level < 2 else { return scenarios }
        let gated: Set<String> = ["Safety", "Teamwork", "Friendship"]
        let allowed = scenarios.filter { !gated.contains($0.category) }
        return allowed.isEmpty ? scenarios : allowed
    }

    /// Picks the options shown for the current question once, so the buttons
    /// don't reshuffle on every re-render. Always keeps the correct answer and
    /// fills the rest with randomly chosen distractors, sized by level.
    func buildOptions() {
        let scenario = currentScenario
        let correct = scenario.options.filter { $0.isCorrect }
        let wrong = scenario.options.filter { !$0.isCorrect }.shuffled()
        let wrongNeeded = max(0, optionCount - correct.count)
        var chosen = correct + Array(wrong.prefix(wrongNeeded))
        chosen.shuffle()
        displayedOptions = chosen
    }

    /// Cancels any pending delayed explanation so it can't speak over the next
    /// question's prompt, the adventure chest cheer, or the Home screen.
    private func cancelPendingExplanation() {
        pendingExplanation?.cancel()
        pendingExplanation = nil
    }

    func nextQuestion() {
        // A queued explanation from the answer we're leaving must not fire late
        // and interrupt the next prompt or the chest celebration.
        cancelPendingExplanation()
        // Five CORRECT scenarios complete an adventure; the chest pops
        // instead of silently rolling into the next question.
        if adventure.isComplete {
            StarBank.shared.award(adventure.chestStars, to: theme.key)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                showAdventureComplete = true
            }
            return
        }
        let lastShownID = currentScenario.id
        withAnimation {
            selectedOption = nil
            showExplanation = false
            answeredCount += 1
            currentIndex += 1

            if currentIndex >= shuffledScenarios.count {
                shuffledScenarios = levelScenarios().shuffled()
                currentIndex = 0
                // Avoid a back-to-back repeat at the cycle boundary: if the
                // fresh deck leads with the scenario we just showed, swap it
                // deeper into the deck.
                if shuffledScenarios.count > 1, shuffledScenarios[0].id == lastShownID {
                    let swapIndex = Int.random(in: 1..<shuffledScenarios.count)
                    shuffledScenarios.swapAt(0, swapIndex)
                }
            }
        }

        buildOptions()

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
