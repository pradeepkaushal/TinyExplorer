import SwiftUI

struct Emotion: Identifiable {
    let id = UUID()
    let name: String
    let face: String          // main cartoon face
    let color: Color
    let description: String   // kid-friendly explanation
    let whenYouFeel: String   // when do you feel this way
    let whatToDo: String      // what to do when feeling this
    let bodyClue: String      // how your body feels
    let relatedFaces: [String] // related expression variants
}

struct EmotionsGameView: View {
    let emotions: [Emotion] = [
        Emotion(name: "Happy", face: "😊", color: .yellow,
                description: "Happy is when you feel good inside, like sunshine in your tummy!",
                whenYouFeel: "When you play with friends, eat your favorite food, or get a hug",
                whatToDo: "Share your happiness! Smile, laugh, and tell someone what made you happy",
                bodyClue: "You smile, your eyes sparkle, and you might want to jump or dance!",
                relatedFaces: ["😄", "😁", "🥰", "😃"]),

        Emotion(name: "Sad", face: "😢", color: .blue,
                description: "Sad is when something makes your heart feel heavy, and that's okay!",
                whenYouFeel: "When you miss someone, lose a toy, or something doesn't go your way",
                whatToDo: "It's okay to cry. Talk to someone you trust, get a hug, or draw how you feel",
                bodyClue: "You might cry, feel tired, want to be alone, or your tummy might hurt",
                relatedFaces: ["😞", "😔", "🥺", "😿"]),

        Emotion(name: "Angry", face: "😠", color: .red,
                description: "Angry is when something feels really unfair or frustrating!",
                whenYouFeel: "When someone takes your toy, breaks your things, or won't listen",
                whatToDo: "Take 5 deep breaths! Count to 10. Squeeze a pillow. Then use your words",
                bodyClue: "Your face gets hot, your fists clench, your heart beats fast",
                relatedFaces: ["😤", "😡", "🤬", "💢"]),

        Emotion(name: "Scared", face: "😨", color: .purple,
                description: "Scared is when something makes you feel unsafe or worried!",
                whenYouFeel: "In the dark, hearing loud noises, seeing something new and big",
                whatToDo: "Tell a grown-up! Hold someone's hand. Remember: being brave means being scared but trying anyway",
                bodyClue: "Your heart beats really fast, you might shake, or want to hide",
                relatedFaces: ["😰", "😱", "🫣", "😧"]),

        Emotion(name: "Surprised", face: "😲", color: .orange,
                description: "Surprised is when something you didn't expect happens!",
                whenYouFeel: "A surprise party, an unexpected gift, or something sudden",
                whatToDo: "Take a moment to understand what happened. Surprises can be fun!",
                bodyClue: "Your eyes go wide, your mouth opens, and you might gasp or jump",
                relatedFaces: ["😮", "🤯", "😳", "🫢"]),

        Emotion(name: "Excited", face: "🤩", color: .pink,
                description: "Excited is when you can't wait for something amazing to happen!",
                whenYouFeel: "Before your birthday, going to the park, or seeing your best friend",
                whatToDo: "Enjoy the feeling! Share your excitement, but remember to be patient too",
                bodyClue: "You feel like jumping, your voice gets louder, you can't sit still!",
                relatedFaces: ["🥳", "😆", "🎉", "✨"]),

        Emotion(name: "Shy", face: "🫣", color: .mint,
                description: "Shy is when you feel nervous around new people or places!",
                whenYouFeel: "Meeting new kids, speaking in front of class, or going somewhere new",
                whatToDo: "It's okay to be shy! Start with a small wave or smile. You can be brave step by step",
                bodyClue: "You might look down, feel butterflies in your tummy, or hide behind someone",
                relatedFaces: ["😶", "🙈", "😊", "🫠"]),

        Emotion(name: "Proud", face: "😎", color: .green,
                description: "Proud is when you did something great and feel really good about it!",
                whenYouFeel: "When you learn something new, help someone, or try really hard",
                whatToDo: "Celebrate! Tell someone what you accomplished. Be proud of yourself!",
                bodyClue: "You stand tall, smile big, and feel warm inside",
                relatedFaces: ["🏆", "💪", "⭐", "👏"]),

        Emotion(name: "Lonely", face: "🥺", color: .gray,
                description: "Lonely is when you wish you had someone to play with or talk to!",
                whenYouFeel: "When friends are busy, you're new somewhere, or no one is around",
                whatToDo: "Ask someone to play! Draw a picture, call a friend, or hug a stuffed animal",
                bodyClue: "You feel quiet inside, might sigh a lot, and want company",
                relatedFaces: ["😔", "🧸", "💭", "🫂"]),

        Emotion(name: "Silly", face: "🤪", color: .teal,
                description: "Silly is when you feel playful and want to laugh and be goofy!",
                whenYouFeel: "Playing with friends, making funny faces, or telling jokes",
                whatToDo: "Being silly is great! Just make sure it's the right time and place",
                bodyClue: "You giggle, make funny sounds, and can't stop smiling",
                relatedFaces: ["😜", "😝", "🤡", "😂"]),

        Emotion(name: "Loved", face: "🥰", color: Color(red: 1.0, green: 0.4, blue: 0.5),
                description: "Loved is the warm feeling when you know someone cares about you!",
                whenYouFeel: "Getting a hug, hearing 'I love you', or when someone helps you",
                whatToDo: "Say 'I love you' back! Give hugs, draw pictures for people you love",
                bodyClue: "You feel warm, safe, and happy. Your heart feels full!",
                relatedFaces: ["❤️", "🤗", "💕", "😘"]),

        Emotion(name: "Frustrated", face: "😤", color: Color(red: 0.9, green: 0.4, blue: 0.2),
                description: "Frustrated is when something is hard and won't work the way you want!",
                whenYouFeel: "Can't solve a puzzle, tie your shoes, or something keeps going wrong",
                whatToDo: "Take a break! Ask for help. Remember: practice makes things easier",
                bodyClue: "You might stomp your feet, huff, or feel like giving up",
                relatedFaces: ["😩", "😫", "🤦", "😮‍💨"]),
    ]

    @State private var selectedEmotion: Emotion? = nil
    @State private var gameMode: EmotionMode = .explore
    @State private var bounceEmoji = false
    @State private var headerFacesPulse = false

    // Quiz state
    @State private var quizEmotion: Emotion? = nil
    @State private var quizOptions: [Emotion] = []
    @State private var quizScore = 0
    @State private var quizTotal = 0
    @State private var quizStreak = 0
    @State private var quizResult: Bool? = nil
    @State private var quizType: QuizType = .nameToFace
    @State private var progression = GameProgression(key: GameTheme.emotions.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    // Guards against one troublesome emotion draining the adventure chest: a
    // wrong round lets the child retry, but the miss is recorded only once.
    @State private var missRecordedThisRound = false

    private let quizHints = [
        "Look at the face's eyes and mouth!",
        "How would YOU feel in that situation?",
        "Think about what makes each feeling special!",
        "You understand feelings so well now!",
    ]

    private let theme = GameTheme.emotions

    enum EmotionMode: String, CaseIterable {
        case explore = "Explore"
        case quiz = "Emotion Quiz"
        case mirror = "Mirror Game"
    }

    enum QuizType {
        case nameToFace    // "Which face shows happy?"
        case faceToName    // Show face, pick the name
        case situationToEmotion // "Your friend took your toy. How do you feel?"
    }

    let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)

    // Balances the (now level-dependent) option count into tidy rows: 3 or 6
    // options fill rows of three; 4 becomes a neat 2x2; 5 becomes 3+2.
    private var optionsPerRow: Int { quizOptions.count == 4 ? 2 : 3 }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .emotions)

            VStack(spacing: 10) {
                ThemedSegmentedPicker(
                    items: EmotionMode.allCases.map { (title: $0.rawValue, value: $0) },
                    selection: $gameMode,
                    accent: theme.accent
                )
                .padding(.top, 8)
                .onChange(of: gameMode) { _ in
                    Haptics.tap()
                    SoundEngine.shared.play(.tap)
                    if gameMode == .quiz { newQuizRound() }
                    if gameMode == .mirror { startMirror() }
                }

                switch gameMode {
                case .explore: exploreView
                case .quiz: quizView
                case .mirror: mirrorView
                }
            }

            if gameMode == .quiz, quizResult == true, let quiz = quizEmotion {
                CelebrationOverlayEnhanced(message: "Correct! That's \(quiz.name)!", emoji: quiz.face)
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
                        newQuizRound()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
        .kidNavigation(title: "Emotions", theme: theme)
        .onDisappear {
            SpeechHelper.stop()
        }
    }

    // MARK: - Explore Mode
    var exploreView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            if let emotion = selectedEmotion {
                emotionDetailCard(emotion)
            } else {
                VStack(spacing: 18) {
                    HStack(spacing: 14) {
                        ForEach(["😊", "😢", "😠", "😨"], id: \.self) { face in
                            Text(face)
                                .font(.system(size: 64))
                        }
                    }
                    MascotBubble(theme: theme, text: "Tap an emotion to learn about it!")
                }
                .padding(.vertical, 28)
            }

            Spacer(minLength: 20)

            // Emotions grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(emotions.enumerated()), id: \.element.id) { index, emotion in
                    emotionGridCard(emotion)
                        .popIn(delay: Double(index) * 0.04)
                }
            }
            .frame(maxWidth: 820)
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
    }

    private func emotionGridCard(_ emotion: Emotion) -> some View {
        let isSelected = selectedEmotion?.id == emotion.id
        return Button(action: { selectEmotion(emotion) }) {
            VStack(spacing: 6) {
                Text(emotion.face)
                    .font(.system(size: 52))
                Text(emotion.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.white, emotion.color.opacity(isSelected ? 0.35 : 0.18)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(emotion.color.opacity(isSelected ? 0.9 : 0.45), lineWidth: 2.5)
                    )
                    .shadow(color: emotion.color.opacity(isSelected ? 0.45 : 0.25), radius: isSelected ? 8 : 5, y: 3)
            )
            .scaleEffect(isSelected ? 1.07 : 1.0)
            .animation(.spring(response: 0.3), value: selectedEmotion?.id)
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.92))
    }

    /// Single centered themed card: face on the left, info bubbles on the right.
    private func emotionDetailCard(_ emotion: Emotion) -> some View {
        HStack(alignment: .center, spacing: 28) {
            // Left: Face & name
            VStack(spacing: 10) {
                Text(emotion.face)
                    .font(.system(size: 104))
                    .scaleEffect(bounceEmoji ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceEmoji)

                Text(emotion.name)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(emotion.color)

                // Related expressions
                HStack(spacing: 8) {
                    ForEach(emotion.relatedFaces, id: \.self) { face in
                        Text(face).font(.system(size: 30))
                    }
                }
            }
            .frame(width: 200)

            // Right: Info bubbles
            VStack(alignment: .leading, spacing: 10) {
                InfoBubble(icon: "💬", title: "What is it?", text: emotion.description, color: emotion.color)
                InfoBubble(icon: "🤔", title: "When you feel it:", text: emotion.whenYouFeel, color: .blue)
                InfoBubble(icon: "🫀", title: "Body clue:", text: emotion.bodyClue, color: .purple)
                InfoBubble(icon: "💡", title: "What to do:", text: emotion.whatToDo, color: .green)
            }
            .frame(maxWidth: 440)
        }
        .padding(26)
        .frame(maxWidth: 780)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.white, emotion.color.opacity(0.15)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(emotion.color.opacity(0.5), lineWidth: 2.5)
                )
                .shadow(color: emotion.color.opacity(0.35), radius: 12, y: 6)
        )
        .padding(.horizontal, 24)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Quiz Mode
    var quizView: some View {
        VStack(spacing: 0) {
            GameProgressHeader(
                level: progression.level,
                correctInLevel: progression.correctInLevel,
                neededForNextLevel: progression.neededForNextLevel,
                theme: theme,
                hint: progression.currentHint(from: quizHints)
            )
            .padding(.horizontal, 24)
            .padding(.top, 4)

            HStack(spacing: 16) {
                StarCounterChipEnhanced(count: quizScore)
                StreakBadgeEnhanced(streak: quizStreak)
                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
            }
            .padding(.top, 8)

            Spacer(minLength: 16)

            VStack(spacing: 28) {
                if let quiz = quizEmotion {
                    switch quizType {
                    case .nameToFace:
                        Text("Which face shows \"\(quiz.name)\"?")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: optionsPerRow),
                            spacing: 20
                        ) {
                            ForEach(Array(quizOptions.enumerated()), id: \.element.id) { index, option in
                                Button(action: { checkQuiz(option) }) {
                                    Text(option.face)
                                        .font(.system(size: 84))
                                        .frame(width: 144, height: 144)
                                        .background(quizCardBackground())
                                }
                                .buttonStyle(SquishyButtonStyle())
                                .disabled(quizResult != nil)
                                .popIn(delay: Double(index) * 0.04)
                            }
                        }
                        .frame(maxWidth: 640)
                        .padding(.horizontal, 24)

                    case .faceToName:
                        Text(quiz.face)
                            .font(.system(size: 120))
                        Text("How is this face feeling?")
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: optionsPerRow),
                            spacing: 18
                        ) {
                            ForEach(Array(quizOptions.enumerated()), id: \.element.id) { index, option in
                                // Speaker beside the word so a pre-reader can hear
                                // every choice instead of facing a wall of text.
                                HStack(spacing: 10) {
                                    SpeakOptionButton(text: option.name, accent: option.color)
                                    Button(action: { checkQuiz(option) }) {
                                        Text(option.name)
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(width: 150, height: 70)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(option.color)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .strokeBorder(.white.opacity(0.5), lineWidth: 2.5)
                                                    )
                                                    .shadow(color: option.color.opacity(0.5), radius: 6, y: 3)
                                            )
                                    }
                                    .buttonStyle(SquishyButtonStyle())
                                    .disabled(quizResult != nil)
                                }
                                .popIn(delay: Double(index) * 0.04)
                            }
                        }
                        .frame(maxWidth: 760)
                        .padding(.horizontal, 24)

                    case .situationToEmotion:
                        VStack(spacing: 14) {
                            Text("🎭")
                                .font(.system(size: 70))
                            Text(quiz.whenYouFeel)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 48)
                            Text("How would you feel?")
                                .font(.system(size: 23, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: optionsPerRow),
                            spacing: 18
                        ) {
                            ForEach(Array(quizOptions.enumerated()), id: \.element.id) { index, option in
                                // Speaker beside each feeling name for pre-readers.
                                HStack(spacing: 10) {
                                    SpeakOptionButton(text: option.name, accent: option.color)
                                    Button(action: { checkQuiz(option) }) {
                                        VStack(spacing: 8) {
                                            Text(option.face)
                                                .font(.system(size: 58))
                                            Text(option.name)
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                        }
                                        .frame(width: 132, height: 122)
                                        .background(quizCardBackground())
                                    }
                                    .buttonStyle(SquishyButtonStyle())
                                    .disabled(quizResult != nil)
                                }
                                .popIn(delay: Double(index) * 0.04)
                            }
                        }
                        .frame(maxWidth: 760)
                        .padding(.horizontal, 24)
                    }

                    if quizResult == false {
                        Text("That's the \(quiz.name) \(quiz.face) face!")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                            .transition(.scale)
                    }
                }
            }

            Spacer(minLength: 24)
        }
    }

    private func quizCardBackground() -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(
                LinearGradient(
                    colors: [.white, theme.accent.opacity(0.14)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(theme.accent.opacity(0.45), lineWidth: 2.5)
            )
            .shadow(color: theme.accent.opacity(0.3), radius: 7, y: 4)
    }

    // MARK: - Mirror Game (act out the emotion)
    @State private var mirrorEmotion: Emotion? = nil
    @State private var mirrorActive = false

    var mirrorView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 26) {
                Text("Make the face! Act it out!")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accent)

                if let emotion = mirrorEmotion {
                    VStack(spacing: 18) {
                        Text("Show me your \(emotion.name) face!")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(emotion.color)

                        Text(emotion.face)
                            .font(.system(size: 140))
                            .scaleEffect(mirrorActive ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: mirrorActive)

                        Text(emotion.bodyClue)
                            .font(.system(size: 21, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Expression variants to try
                        HStack(spacing: 12) {
                            Text("Try these too:")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            ForEach(emotion.relatedFaces, id: \.self) { face in
                                Text(face).font(.system(size: 40))
                            }
                        }
                    }
                    .padding(30)
                    .frame(maxWidth: 720)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [.white, emotion.color.opacity(0.15)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(emotion.color.opacity(0.5), lineWidth: 2.5)
                            )
                            .shadow(color: emotion.color.opacity(0.35), radius: 12, y: 6)
                    )
                    .padding(.horizontal, 24)

                    Button(action: {
                        Haptics.tap()
                        SoundEngine.shared.play(.pop)
                        nextMirrorEmotion()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Next Emotion")
                        }
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(theme.accent)
                                .shadow(color: theme.accent.opacity(0.45), radius: 6, y: 3)
                        )
                    }
                    .buttonStyle(SquishyButtonStyle())
                }
            }

            Spacer(minLength: 24)
        }
    }

    // MARK: - Functions

    func selectEmotion(_ emotion: Emotion) {
        Haptics.tap()
        SoundEngine.shared.playTileNote(emotions.firstIndex(where: { $0.id == emotion.id }) ?? 0)
        withAnimation(.spring()) { selectedEmotion = emotion }
        bounceEmoji = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { bounceEmoji = false }
        SpeechHelper.speak("\(emotion.name)! \(emotion.description)")
    }

    func newQuizRound() {
        quizResult = nil
        missRecordedThisRound = false
        // Never the same emotion twice in a row.
        guard let quiz = emotions.filter({ $0.name != quizEmotion?.name }).randomElement() else { return }
        quizEmotion = quiz
        // Staged unlock: beginners only get the fully-spoken pick-the-face round;
        // Level 3-4 add the situation round (still a face-based, non-reading path);
        // Level 5+ add the reading variant as the top challenge.
        let availableTypes: [QuizType]
        switch progression.level {
        case ..<3:
            availableTypes = [.nameToFace]
        case 3...4:
            availableTypes = [.nameToFace, .situationToEmotion]
        default:
            availableTypes = [.nameToFace, .situationToEmotion, .faceToName]
        }
        quizType = availableTypes.randomElement()!

        // More choices as the level rises: L1=3, L2=4, L3=5, L4+=6 (cap 6).
        let optionCount = min(emotions.count, min(6, 3 + max(0, progression.level - 1)))

        var opts = [quiz]
        // In situation rounds the prompt itself can fit more than one feeling
        // (e.g. Sad's "miss someone" also fits Lonely, Shy's "somewhere new"
        // fits Lonely, Frustrated overlaps Angry). Never offer those partners as
        // distractors for each other, or a reasonable answer is marked wrong.
        let banned: Set<String> = quizType == .situationToEmotion ? ambiguousPartners(of: quiz) : []
        // From Level 4, bias distractors toward the target's valence cluster so
        // the wrong faces are genuinely harder to rule out.
        if progression.level >= 4 {
            let cluster = valenceCluster(for: quiz)
            let confusable = emotions
                .filter { cluster.contains($0.name) && $0.name != quiz.name && !banned.contains($0.name) }
                .shuffled()
            for candidate in confusable where opts.count < optionCount {
                opts.append(candidate)
            }
        }
        while opts.count < optionCount {
            if let random = emotions.randomElement(),
               !banned.contains(random.name),
               !opts.contains(where: { $0.name == random.name }) {
                opts.append(random)
            }
        }
        quizOptions = opts.shuffled()

        switch quizType {
        case .nameToFace:
            SpeechHelper.speak("Which face shows \(quiz.name)?")
        case .faceToName:
            SpeechHelper.speak("How is this face feeling?")
        case .situationToEmotion:
            SpeechHelper.speak("\(quiz.whenYouFeel). How would you feel?")
        }
    }

    /// Splits the feelings into two rough valence clusters so higher levels can
    /// draw distractors that are genuinely close to (and confusable with) the
    /// target emotion instead of being obvious opposites.
    private func valenceCluster(for emotion: Emotion) -> Set<String> {
        let unpleasant: Set<String> = ["Sad", "Lonely", "Frustrated", "Scared", "Angry", "Shy"]
        return unpleasant.contains(emotion.name)
            ? unpleasant
            : ["Happy", "Excited", "Proud", "Loved", "Silly", "Surprised"]
    }

    /// Feelings whose situation prompts overlap enough that a child could
    /// reasonably pick either one. In situationToEmotion rounds these must never
    /// be distractors for each other, or a sensible answer gets marked wrong.
    private func ambiguousPartners(of emotion: Emotion) -> Set<String> {
        switch emotion.name {
        case "Sad": return ["Lonely"]
        case "Lonely": return ["Sad", "Shy"]
        case "Shy": return ["Lonely"]
        case "Frustrated": return ["Angry"]
        case "Angry": return ["Frustrated"]
        default: return []
        }
    }

    func checkQuiz(_ option: Emotion) {
        quizTotal += 1
        if option.name == quizEmotion?.name {
            quizScore += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            withAnimation(.spring()) {
                quizStreak += 1
                quizResult = true
            }
            // Award the every-5th-in-a-row bonus star independently of the
            // level-up branch, so a streak milestone that lands on the same
            // answer as a level-up is never silently dropped.
            let isStreakMilestone = quizStreak > 0 && quizStreak % 5 == 0
            if isStreakMilestone {
                StarBank.shared.award(1, to: theme.key)
                quizScore += 1
            }
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else if isStreakMilestone {
                SoundEngine.shared.play(.streak)
                SpeechHelper.speak("\(quizStreak) in a row!")
            } else {
                SpeechHelper.speak("That's \(option.name)!")
            }
            let delay = progression.showLevelUp ? 2.5 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        // Clear the "Correct!" celebration first so it does not
                        // linger stacked behind the treasure-chest overlay.
                        quizResult = nil
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { newQuizRound() }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            if !missRecordedThisRound {
                progression.registerWrong()
                adventure.recordMiss()
                missRecordedThisRound = true
            }
            withAnimation(.spring()) {
                quizStreak = 0
                quizResult = false
            }
            SpeechHelper.speak("Oops! That's the \(quizEmotion?.name ?? "") face.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { quizResult = nil }
            }
        }
    }

    func startMirror() {
        mirrorActive = true
        nextMirrorEmotion()
    }

    func nextMirrorEmotion() {
        // Never show the same face twice in a row, matching the quiz guard.
        mirrorEmotion = emotions.filter { $0.name != mirrorEmotion?.name }.randomElement()
        if let emotion = mirrorEmotion {
            SpeechHelper.speak("Show me your \(emotion.name) face!")
        }
    }
}

// MARK: - Info Bubble Component
struct InfoBubble: View {
    let icon: String
    let title: String
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.system(size: 22))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.8))
        )
    }
}

#Preview {
    NavigationStack {
        EmotionsGameView()
    }
}
