import SwiftUI

struct Animal: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let sound: String
    let fact: String
    let color: Color
}

struct AnimalGameView: View {
    let animals: [Animal] = [
        // Farm animals
        Animal(name: "Dog", emoji: "🐶", sound: "Woof woof!", fact: "Dogs are loyal friends!", color: .brown),
        Animal(name: "Cat", emoji: "🐱", sound: "Meow meow!", fact: "Cats love to nap!", color: .orange),
        Animal(name: "Cow", emoji: "🐮", sound: "Mooo!", fact: "Cows give us milk!", color: .gray),
        Animal(name: "Duck", emoji: "🦆", sound: "Quack quack!", fact: "Ducks can swim and fly!", color: .yellow),
        Animal(name: "Pig", emoji: "🐷", sound: "Oink oink!", fact: "Pigs are very smart!", color: .pink),
        Animal(name: "Sheep", emoji: "🐑", sound: "Baa baa!", fact: "Sheep give us wool!", color: .white),
        Animal(name: "Horse", emoji: "🐴", sound: "Neigh!", fact: "Horses can run very fast!", color: .brown),
        Animal(name: "Rooster", emoji: "🐓", sound: "Cock-a-doodle-doo!", fact: "Roosters wake up early!", color: .red),
        Animal(name: "Goat", emoji: "🐐", sound: "Maa maa!", fact: "Goats can climb steep mountains!", color: .gray),
        Animal(name: "Donkey", emoji: "🫏", sound: "Hee-haw!", fact: "Donkeys are very strong!", color: .brown),
        // Wild animals
        Animal(name: "Lion", emoji: "🦁", sound: "Roar!", fact: "Lions are the king of the jungle!", color: .orange),
        Animal(name: "Elephant", emoji: "🐘", sound: "Trumpet!", fact: "Elephants never forget!", color: .gray),
        Animal(name: "Monkey", emoji: "🐵", sound: "Ooh ooh aah aah!", fact: "Monkeys love bananas!", color: .brown),
        Animal(name: "Tiger", emoji: "🐯", sound: "Grrr!", fact: "Tigers have beautiful stripes!", color: .orange),
        Animal(name: "Bear", emoji: "🐻", sound: "Growl!", fact: "Bears love honey and fish!", color: .brown),
        Animal(name: "Wolf", emoji: "🐺", sound: "Awoo!", fact: "Wolves howl at the moon!", color: .gray),
        Animal(name: "Snake", emoji: "🐍", sound: "Hisss!", fact: "Snakes have no legs!", color: .green),
        Animal(name: "Owl", emoji: "🦉", sound: "Hoo hoo!", fact: "Owls can turn their heads almost all the way around!", color: .brown),
        // Water & flying animals
        Animal(name: "Frog", emoji: "🐸", sound: "Ribbit ribbit!", fact: "Frogs can jump really far!", color: .green),
        Animal(name: "Bee", emoji: "🐝", sound: "Buzz buzz!", fact: "Bees make yummy honey!", color: .yellow),
        Animal(name: "Parrot", emoji: "🦜", sound: "Squawk!", fact: "Parrots can learn to talk!", color: .green),
        Animal(name: "Dolphin", emoji: "🐬", sound: "Click click eee!", fact: "Dolphins are super smart swimmers!", color: .blue),
        Animal(name: "Whale", emoji: "🐳", sound: "Wooo!", fact: "Whales are the biggest animals on Earth!", color: .blue),
        Animal(name: "Seal", emoji: "🦭", sound: "Arf arf!", fact: "Seals love to swim and play!", color: .gray),
    ]

    @State private var selectedAnimal: Animal? = nil
    @State private var showSound = false
    @State private var bounceAnimal = false
    @State private var gameMode: AnimalGameMode = .explore

    enum AnimalGameMode {
        case explore
        case guess
    }

    @State private var quizAnimal: Animal? = nil
    @State private var quizOptions: [Animal] = []
    @State private var quizScore = 0
    @State private var quizStreak = 0
    @State private var showResult: Bool? = nil
    @State private var celebrationMessage = Encouragement.random()
    /// Drives the gentle idle pulse of the paw placeholder.
    @State private var pawPulse = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 6)

    private let theme = GameTheme.animals

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .animals)

            VStack(spacing: 16) {
                ThemedSegmentedPicker(
                    items: [
                        (title: "Explore", value: AnimalGameMode.explore),
                        (title: "Sound Quiz", value: AnimalGameMode.guess),
                    ],
                    selection: $gameMode,
                    accent: theme.accent
                )
                .onChange(of: gameMode) { _ in
                    SoundEngine.shared.play(.pop)
                    SpeechHelper.stop()
                    if gameMode == .guess { newQuizRound() }
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    guessView
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Animal Friends")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { SpeechHelper.stop() }
    }

    var exploreView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)

            // Display area
            if let animal = selectedAnimal {
                VStack(spacing: 12) {
                    Text(animal.emoji)
                        .font(.system(size: 130))
                        .scaleEffect(bounceAnimal ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceAnimal)

                    Text(animal.name)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(animal.color == .white ? .gray : animal.color)

                    if showSound {
                        Text("\" \(animal.sound) \"")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                            .transition(.scale)
                    }

                    Text(animal.fact)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(height: 290)
                .animation(.spring(), value: selectedAnimal?.id)
            } else {
                VStack(spacing: 14) {
                    // Gentle idle pulse on the paw placeholder.
                    Text("🐾")
                        .font(.system(size: 90))
                    MascotBubble(theme: theme, text: "Tap an animal to learn about it!")
                }
                .frame(height: 290)
            }

            // Animal grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(animals.enumerated()), id: \.element.id) { index, animal in
                    Button(action: { selectAnimal(animal) }) {
                        VStack(spacing: 8) {
                            Text(animal.emoji)
                                .font(.system(size: 64))
                            Text(animal.name)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 122)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedAnimal?.id == animal.id ?
                                      theme.accent.opacity(0.18) : theme.accent.opacity(0.06))
                                .background(
                                    RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.92))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            theme.accent.opacity(selectedAnimal?.id == animal.id ? 0.7 : 0.3),
                                            lineWidth: 2.5
                                        )
                                )
                                .shadow(
                                    color: theme.accent.opacity(selectedAnimal?.id == animal.id ? 0.4 : 0.18),
                                    radius: selectedAnimal?.id == animal.id ? 8 : 3,
                                    y: 3
                                )
                        )
                        .scaleEffect(selectedAnimal?.id == animal.id ? 1.08 : 1.0)
                        .animation(.spring(), value: selectedAnimal?.id)
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .popIn(delay: Double(index) * 0.02)
                }
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 0)
        }
    }

    var guessView: some View {
        ZStack {
            quizContent
            if showResult == true {
                CelebrationOverlay(message: celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    var quizContent: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                StarCounterChip(count: quizScore)
                StreakBadge(streak: quizStreak)
            }

            Spacer(minLength: 0)

            if let quiz = quizAnimal {
                VStack(spacing: 16) {
                    Text("Which animal says...")
                        .font(.system(size: 26, weight: .medium, design: .rounded))

                    Text("\" \(quiz.sound) \"")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Button("🔊 Hear it again") {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        SpeechHelper.speak(quiz.sound)
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .buttonStyle(SquishyButtonStyle())
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(quizOptions) { option in
                        Button(action: { checkGuess(option) }) {
                            VStack(spacing: 12) {
                                Text(option.emoji)
                                    .font(.system(size: 84))
                                Text(option.name)
                                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 190)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.white.opacity(0.92))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(theme.accent.opacity(0.35), lineWidth: 3)
                                    )
                                    .shadow(color: theme.accent.opacity(0.22), radius: 5, y: 4)
                            )
                        }
                        .buttonStyle(SquishyButtonStyle())
                    }
                }
                .padding(.horizontal, 60)

                if showResult == false {
                    Text("❌ Oops! Try again!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                        .transition(.scale)
                }
            }

            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
    }

    func selectAnimal(_ animal: Animal) {
        Haptics.tap()
        SoundEngine.shared.playTileNote(animals.firstIndex(where: { $0.id == animal.id }) ?? 0)
        selectedAnimal = animal
        bounceAnimal = true
        showSound = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceAnimal = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showSound = true }
        }

        SpeechHelper.speak("The \(animal.name) says \(animal.sound)")
    }

    func newQuizRound() {
        showResult = nil
        quizAnimal = animals.randomElement()
        var options = [quizAnimal!]
        while options.count < 4 {
            if let random = animals.randomElement(), !options.contains(where: { $0.name == random.name }) {
                options.append(random)
            }
        }
        quizOptions = options.shuffled()

        if let quiz = quizAnimal {
            SpeechHelper.speak("Which animal says \(quiz.sound)")
        }
    }

    func checkGuess(_ option: Animal) {
        guard showResult != true else { return }
        if option.name == quizAnimal?.name {
            celebrationMessage = Encouragement.random()
            withAnimation {
                showResult = true
                quizScore += 1
                quizStreak += 1
            }
            StarBank.shared.award(1, to: GameTheme.animals.key)
            Haptics.success()
            SoundEngine.shared.play(.correct)
            SpeechHelper.speak(celebrationMessage)
            if quizStreak > 0 && quizStreak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.animals.key)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    SoundEngine.shared.play(.streak)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { newQuizRound() }
            }
        } else {
            withAnimation {
                showResult = false
                quizStreak = 0
            }
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Oops, that's the \(option.name)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showResult = nil }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnimalGameView()
    }
}
