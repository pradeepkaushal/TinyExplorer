import SwiftUI
import AVFoundation

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

    // Quiz state
    @State private var quizEmotion: Emotion? = nil
    @State private var quizOptions: [Emotion] = []
    @State private var quizScore = 0
    @State private var quizTotal = 0
    @State private var quizResult: Bool? = nil
    @State private var quizType: QuizType = .nameToFace

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

    let synthesizer = AVSpeechSynthesizer()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.92, blue: 0.85), Color(red: 0.88, green: 0.85, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                Picker("Mode", selection: $gameMode) {
                    ForEach(EmotionMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 60)
                .onChange(of: gameMode) { _ in
                    if gameMode == .quiz { newQuizRound() }
                    if gameMode == .mirror { startMirror() }
                }

                switch gameMode {
                case .explore: exploreView
                case .quiz: quizView
                case .mirror: mirrorView
                }
            }
        }
        .navigationTitle("Emotions")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Explore Mode
    var exploreView: some View {
        VStack(spacing: 10) {
            if let emotion = selectedEmotion {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        // Left: Face & name
                        VStack(spacing: 8) {
                            Text(emotion.face)
                                .font(.system(size: 90))
                                .scaleEffect(bounceEmoji ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceEmoji)

                            Text(emotion.name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(emotion.color)

                            // Related expressions
                            HStack(spacing: 8) {
                                ForEach(emotion.relatedFaces, id: \.self) { face in
                                    Text(face).font(.system(size: 28))
                                }
                            }
                        }
                        .frame(width: 180)

                        // Right: Info cards
                        VStack(alignment: .leading, spacing: 8) {
                            InfoBubble(icon: "💬", title: "What is it?", text: emotion.description, color: emotion.color)
                            InfoBubble(icon: "🤔", title: "When you feel it:", text: emotion.whenYouFeel, color: .blue)
                            InfoBubble(icon: "🫀", title: "Body clue:", text: emotion.bodyClue, color: .purple)
                            InfoBubble(icon: "💡", title: "What to do:", text: emotion.whatToDo, color: .green)
                        }
                        .frame(width: 380)
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 260)
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("😊").font(.system(size: 50))
                        Text("😢").font(.system(size: 50))
                        Text("😠").font(.system(size: 50))
                        Text("😨").font(.system(size: 50))
                    }
                    Text("Tap an emotion to learn about it!")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(height: 260)
            }

            // Emotions grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(emotions) { emotion in
                    Button(action: { selectEmotion(emotion) }) {
                        VStack(spacing: 4) {
                            Text(emotion.face)
                                .font(.system(size: 44))
                            Text(emotion.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 85)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedEmotion?.id == emotion.id ? emotion.color.opacity(0.25) : .white.opacity(0.8))
                                .shadow(radius: selectedEmotion?.id == emotion.id ? 5 : 2)
                        )
                        .scaleEffect(selectedEmotion?.id == emotion.id ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedEmotion?.id)
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - Quiz Mode
    var quizView: some View {
        VStack(spacing: 20) {
            Text("Score: \(quizScore)/\(quizTotal)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.orange)

            if let quiz = quizEmotion {
                switch quizType {
                case .nameToFace:
                    Text("Which face shows \"\(quiz.name)\"?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 20) {
                        ForEach(quizOptions) { option in
                            Button(action: { checkQuiz(option) }) {
                                Text(option.face)
                                    .font(.system(size: 70))
                                    .frame(width: 120, height: 120)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.white.opacity(0.9))
                                            .shadow(radius: 4)
                                    )
                            }
                            .disabled(quizResult != nil)
                        }
                    }

                case .faceToName:
                    Text(quiz.face)
                        .font(.system(size: 100))
                    Text("How is this face feeling?")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))

                    HStack(spacing: 16) {
                        ForEach(quizOptions) { option in
                            Button(action: { checkQuiz(option) }) {
                                Text(option.name)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 140, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(option.color)
                                            .shadow(radius: 4)
                                    )
                            }
                            .disabled(quizResult != nil)
                        }
                    }

                case .situationToEmotion:
                    VStack(spacing: 12) {
                        Text("🎭")
                            .font(.system(size: 60))
                        Text(quiz.whenYouFeel)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Text("How would you feel?")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 16) {
                        ForEach(quizOptions) { option in
                            Button(action: { checkQuiz(option) }) {
                                VStack(spacing: 6) {
                                    Text(option.face)
                                        .font(.system(size: 50))
                                    Text(option.name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 110, height: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white.opacity(0.9))
                                        .shadow(radius: 3)
                                )
                            }
                            .disabled(quizResult != nil)
                        }
                    }
                }

                if let result = quizResult {
                    Text(result ? "Correct! That's \(quiz.name)!" : "That's the \(quiz.name) \(quiz.face) face!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(result ? .green : .orange)
                        .transition(.scale)
                }
            }

            Spacer()
        }
    }

    // MARK: - Mirror Game (act out the emotion)
    @State private var mirrorEmotion: Emotion? = nil
    @State private var mirrorTimer = 5
    @State private var mirrorActive = false

    var mirrorView: some View {
        VStack(spacing: 24) {
            Text("Make the face! Act it out!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            if let emotion = mirrorEmotion {
                VStack(spacing: 16) {
                    Text("Show me your \(emotion.name) face!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(emotion.color)

                    Text(emotion.face)
                        .font(.system(size: 120))
                        .scaleEffect(mirrorActive ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: mirrorActive)

                    Text(emotion.bodyClue)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)

                    // Expression variants to try
                    HStack(spacing: 12) {
                        Text("Try these too:")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        ForEach(emotion.relatedFaces, id: \.self) { face in
                            Text(face).font(.system(size: 36))
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.white.opacity(0.8))
                        .shadow(radius: 8)
                )

                Button(action: { nextMirrorEmotion() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Next Emotion")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.blue))
                }
            }

            Spacer()
        }
    }

    // MARK: - Functions

    func selectEmotion(_ emotion: Emotion) {
        selectedEmotion = emotion
        bounceEmoji = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { bounceEmoji = false }
        speak("\(emotion.name). \(emotion.description) \(emotion.whatToDo)")
    }

    func newQuizRound() {
        quizResult = nil
        quizEmotion = emotions.randomElement()
        quizType = [QuizType.nameToFace, .faceToName, .situationToEmotion].randomElement()!

        guard let quiz = quizEmotion else { return }
        var opts = [quiz]
        while opts.count < 4 {
            if let random = emotions.randomElement(), !opts.contains(where: { $0.name == random.name }) {
                opts.append(random)
            }
        }
        quizOptions = opts.shuffled()

        switch quizType {
        case .nameToFace:
            speak("Which face shows \(quiz.name)?")
        case .faceToName:
            speak("How is this face feeling?")
        case .situationToEmotion:
            speak("\(quiz.whenYouFeel). How would you feel?")
        }
    }

    func checkQuiz(_ option: Emotion) {
        quizTotal += 1
        if option.name == quizEmotion?.name {
            quizScore += 1
            withAnimation { quizResult = true }
            speak("Correct! That's the \(option.name) face!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { newQuizRound() }
            }
        } else {
            withAnimation { quizResult = false }
            speak("That's \(option.name). The answer is \(quizEmotion?.name ?? "")")
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
        mirrorEmotion = emotions.randomElement()
        if let emotion = mirrorEmotion {
            speak("Show me your \(emotion.name) face! \(emotion.bodyClue)")
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}

// MARK: - Info Bubble Component
struct InfoBubble: View {
    let icon: String
    let title: String
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon).font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                Text(text)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.7))
        )
    }
}

#Preview {
    NavigationStack {
        EmotionsGameView()
    }
}
