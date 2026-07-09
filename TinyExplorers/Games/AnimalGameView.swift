import SwiftUI

struct Animal: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let sound: String
    let fact: String
    let color: Color
    let home: String
    let food: String
    let baby: String

    /// Spoken "encyclopedia entry" for the Tell Me More button.
    var story: String {
        let plural: String
        switch name {
        case "Sheep": plural = "Sheep"
        case "Wolf": plural = "Wolves"
        default: plural = "\(name)s"
        }
        let babyWord = baby.lowercased()
        let babyArticle = "aeiou".contains(babyWord.first ?? " ") ? "an" : "a"
        return "\(plural) live in \(home.lowercased()). They love to eat \(food.lowercased()). A baby \(name.lowercased()) is called \(babyArticle) \(babyWord). \(fact)"
    }

    /// Stable sound-family grouping. Used from Level 4 up to prefer subtler
    /// distractors (farm sounds among farm sounds) instead of the free-text
    /// `home` string, which is too unique to group by reliably.
    fileprivate var category: AnimalCategory {
        switch name {
        case "Dog", "Cat", "Cow", "Duck", "Pig", "Sheep", "Horse", "Rooster", "Goat", "Donkey":
            return .farm
        case "Lion", "Elephant", "Monkey", "Tiger", "Bear", "Wolf", "Snake", "Owl":
            return .wild
        default: // Frog, Bee, Parrot, Dolphin, Whale, Seal
            return .water
        }
    }
}

/// Sound families used to build subtler distractors as the level ramps.
private enum AnimalCategory {
    case farm, wild, water
}

struct AnimalGameView: View {
    let animals: [Animal] = [
        // Farm animals
        Animal(name: "Dog", emoji: "🐶", sound: "Woof woof!", fact: "Dogs are loyal friends!", color: .brown,
               home: "Our homes", food: "Kibble and bones", baby: "Puppy"),
        Animal(name: "Cat", emoji: "🐱", sound: "Meow meow!", fact: "Cats love to nap!", color: .orange,
               home: "Our homes", food: "Fish and kitty food", baby: "Kitten"),
        Animal(name: "Cow", emoji: "🐮", sound: "Mooo!", fact: "Cows give us milk!", color: .gray,
               home: "The farm", food: "Grass and hay", baby: "Calf"),
        Animal(name: "Duck", emoji: "🦆", sound: "Quack quack!", fact: "Ducks can swim and fly!", color: .yellow,
               home: "Ponds and lakes", food: "Water plants and bugs", baby: "Duckling"),
        Animal(name: "Pig", emoji: "🐷", sound: "Oink oink!", fact: "Pigs are very smart!", color: .pink,
               home: "The farm", food: "Veggies and fruit", baby: "Piglet"),
        Animal(name: "Sheep", emoji: "🐑", sound: "Baa baa!", fact: "Sheep give us wool!", color: .white,
               home: "Grassy hills", food: "Grass", baby: "Lamb"),
        Animal(name: "Horse", emoji: "🐴", sound: "Neigh!", fact: "Horses can run very fast!", color: .brown,
               home: "The stable", food: "Hay and apples", baby: "Foal"),
        Animal(name: "Rooster", emoji: "🐓", sound: "Cock-a-doodle-doo!", fact: "Roosters wake up early!", color: .red,
               home: "The farmyard", food: "Seeds and grains", baby: "Chick"),
        Animal(name: "Goat", emoji: "🐐", sound: "Maa maa!", fact: "Goats can climb steep mountains!", color: .gray,
               home: "Hills and farms", food: "Grass and leaves", baby: "Kid"),
        Animal(name: "Donkey", emoji: "🫏", sound: "Hee-haw!", fact: "Donkeys are very strong!", color: .brown,
               home: "The farm", food: "Grass and hay", baby: "Foal"),
        // Wild animals
        Animal(name: "Lion", emoji: "🦁", sound: "Roar!", fact: "Lions are the king of the jungle!", color: .orange,
               home: "The African savanna", food: "Meat", baby: "Cub"),
        Animal(name: "Elephant", emoji: "🐘", sound: "Trumpet!", fact: "Elephants never forget!", color: .gray,
               home: "Africa and Asia", food: "Leaves, grass and fruit", baby: "Calf"),
        Animal(name: "Monkey", emoji: "🐵", sound: "Ooh ooh aah aah!", fact: "Monkeys love bananas!", color: .brown,
               home: "The jungle", food: "Bananas and fruit", baby: "Infant"),
        Animal(name: "Tiger", emoji: "🐯", sound: "Grrr!", fact: "Tigers have beautiful stripes!", color: .orange,
               home: "Forests in Asia", food: "Meat", baby: "Cub"),
        Animal(name: "Bear", emoji: "🐻", sound: "Growl!", fact: "Bears love honey and fish!", color: .brown,
               home: "Forests and mountains", food: "Honey, fish and berries", baby: "Cub"),
        Animal(name: "Wolf", emoji: "🐺", sound: "Awoo!", fact: "Wolves howl at the moon!", color: .gray,
               home: "Forests", food: "Meat", baby: "Pup"),
        Animal(name: "Snake", emoji: "🐍", sound: "Hisss!", fact: "Snakes have no legs!", color: .green,
               home: "Forests and deserts", food: "Small animals", baby: "Snakelet"),
        Animal(name: "Owl", emoji: "🦉", sound: "Hoo hoo!", fact: "Owls can turn their heads almost all the way around!", color: .brown,
               home: "Tree hollows", food: "Mice and bugs", baby: "Owlet"),
        // Water & flying animals
        Animal(name: "Frog", emoji: "🐸", sound: "Ribbit ribbit!", fact: "Frogs can jump really far!", color: .green,
               home: "Ponds", food: "Flies and bugs", baby: "Tadpole"),
        Animal(name: "Bee", emoji: "🐝", sound: "Buzz buzz!", fact: "Bees make yummy honey!", color: .yellow,
               home: "The beehive", food: "Nectar from flowers", baby: "Baby bee"),
        Animal(name: "Parrot", emoji: "🦜", sound: "Squawk!", fact: "Parrots can learn to talk!", color: .green,
               home: "Rainforests", food: "Seeds and fruit", baby: "Chick"),
        Animal(name: "Dolphin", emoji: "🐬", sound: "Click click eee!", fact: "Dolphins are super smart swimmers!", color: .blue,
               home: "The ocean", food: "Fish and squid", baby: "Calf"),
        Animal(name: "Whale", emoji: "🐳", sound: "Wooo!", fact: "Whales are the biggest animals on Earth!", color: .blue,
               home: "The deep ocean", food: "Tiny krill", baby: "Calf"),
        Animal(name: "Seal", emoji: "🦭", sound: "Arf arf!", fact: "Seals love to swim and play!", color: .gray,
               home: "Icy seas and beaches", food: "Fish", baby: "Pup"),
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
    @State private var progression = GameProgression(key: GameTheme.animals.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    /// Target names already asked in the current Adventure round, so a
    /// five-find adventure always surfaces five distinct animals.
    @State private var usedInAdventure: Set<String> = []
    /// Once-per-round guard so multiple wrong taps in one round can't
    /// re-penalize (mirrors ListenFindGameView's missRecordedThisRound).
    @State private var missRecordedThisRound = false

    private let quizHints = [
        "Think about what sound the animal makes!",
        "Say the sound out loud, then find it!",
        "Some animals have funny sounds — listen carefully!",
        "You know so many animals now — amazing!",
    ]

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
                    if gameMode == .guess {
                        // If the completion chest was still up from a finished
                        // adventure, clear it and start fresh so the stale
                        // overlay can't layer over the new round.
                        if showAdventureComplete {
                            adventure.reset()
                            usedInAdventure.removeAll()
                            showAdventureComplete = false
                        }
                        newQuizRound()
                    }
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    guessView
                }
            }
            .padding(.top, 8)
        }
        .kidNavigation(title: "Animal Friends", theme: theme)
        .onAppear {
            #if DEBUG
            // `-demo` launch argument pre-selects an animal so automated
            // screenshots can capture the detail card without tapping.
            if ProcessInfo.processInfo.arguments.contains("-demo") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    selectAnimal(animals[0])
                }
            }
            #endif
        }
        .onDisappear { SpeechHelper.stop() }
    }

    var exploreView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)

            // Display area
            if let animal = selectedAnimal {
                VStack(spacing: 10) {
                    Text(animal.emoji)
                        .font(.system(size: 110))
                        .scaleEffect(bounceAnimal ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceAnimal)

                    HStack(spacing: 12) {
                        Text(animal.name)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(animal.color == .white ? .gray : animal.color)
                        if showSound {
                            Text("\" \(animal.sound) \"")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                                .transition(.scale)
                        }
                    }

                    // Little encyclopedia: home, food, and baby name.
                    HStack(spacing: 12) {
                        AnimalFactChip(icon: "🏠", label: "Lives in", value: animal.home, accent: theme.accent)
                        AnimalFactChip(icon: "🍽️", label: "Eats", value: animal.food, accent: theme.accent)
                        AnimalFactChip(icon: "👶", label: "Baby", value: animal.baby, accent: theme.accent)
                    }
                    .padding(.horizontal, 40)

                    Text(animal.fact)
                        .font(.system(size: 21, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    TellMeMoreButton(theme: theme) {
                        SpeechHelper.speak(animal.story)
                    }
                }
                .frame(height: 340)
                .animation(.spring(), value: selectedAnimal?.id)
            } else {
                VStack(spacing: 14) {
                    // Gentle idle pulse on the paw placeholder.
                    Text("🐾")
                        .font(.system(size: 90))
                        .scaleEffect(pawPulse ? 1.08 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                                pawPulse = true
                            }
                        }
                    MascotBubble(theme: theme, text: "Tap an animal to learn about it!")
                }
                .frame(height: 330)
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
                CelebrationOverlayEnhanced(message: celebrationMessage)
                    .transition(.scale.combined(with: .opacity))
            }
            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }

            if showAdventureComplete {
                AdventureCompleteOverlay(stars: adventure.chestStars, theme: theme) {
                    adventure.reset()
                    usedInAdventure.removeAll()
                    withAnimation {
                        showAdventureComplete = false
                        newQuizRound()
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
            }
        }
    }

    var quizContent: some View {
        VStack(spacing: 24) {
            GameProgressHeader(
                level: progression.level,
                correctInLevel: progression.correctInLevel,
                neededForNextLevel: progression.neededForNextLevel,
                theme: theme,
                hint: progression.currentHint(from: quizHints)
            )
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                StarCounterChipEnhanced(count: quizScore)
                StreakBadgeEnhanced(streak: quizStreak)
                AdventureTrail(progress: adventure.completedInRound, goal: adventure.goal, theme: theme)
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
                        // Speaker sits in the corner as a sibling of the tile so
                        // a pre-reader can hear the name; it speaks the NAME only
                        // (never the sound) so it can't give away the answer, and
                        // never triggers the tile's own selection.
                        .overlay(alignment: .topTrailing) {
                            SpeakOptionButton(text: option.name, accent: theme.accent)
                                .padding(10)
                        }
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
        missRecordedThisRound = false
        // 3 choices for beginners, up to 6 as they level, never the same
        // animal twice in a row.
        let optionCount = min(6, 2 + (progression.level + 1) / 2)
        // Exclude every animal already asked this adventure so five finds mean
        // five distinct animals; fall back to "anything but the last" only if
        // the whole roster were somehow exhausted.
        var candidates = animals.filter { !usedInAdventure.contains($0.name) }
        if candidates.isEmpty {
            candidates = animals.filter { $0.name != quizAnimal?.name }
        }
        guard let quiz = candidates.randomElement() else { return }
        quizAnimal = quiz
        usedInAdventure.insert(quiz.name)

        // From Level 4, distractors prefer animals from the same sound family —
        // farm sounds among farm sounds is a real listen, not a giveaway. Falls
        // back to random fill when the family has too few members.
        var pool = animals.filter { $0.name != quiz.name }.shuffled()
        if progression.level >= 4 {
            let confusable = pool.filter { $0.category == quiz.category }
            pool = confusable + pool.filter { $0.category != quiz.category }
        }
        quizOptions = ([quiz] + pool.prefix(optionCount - 1)).shuffled()

        SpeechHelper.speak("Which animal says \(quiz.sound)")
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
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            if progression.showLevelUp {
                SoundEngine.shared.play(.streak)
            } else {
                SpeechHelper.speak(celebrationMessage)
            }
            if !progression.showLevelUp, quizStreak > 0 && quizStreak % 5 == 0 {
                StarBank.shared.award(1, to: GameTheme.animals.key)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    SoundEngine.shared.play(.streak)
                }
            }
            let delay = progression.showLevelUp ? 2.5 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: GameTheme.animals.key)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { newQuizRound() }
                }
            }
        } else {
            withAnimation {
                showResult = false
                quizStreak = 0
            }
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            if !missRecordedThisRound {
                progression.registerWrong()
                adventure.recordMiss()
                missRecordedThisRound = true
            }
            SpeechHelper.speak("Oops, that's the \(option.name)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showResult = nil }
            }
        }
    }
}

/// Big storybook button that reads the animal's full story aloud. It never
/// sits still — a gentle heartbeat pulse plus a wiggling book keep pulling
/// little fingers toward it.
struct TellMeMoreButton: View {
    let theme: GameTheme
    let action: () -> Void

    @State private var pulse = false
    @State private var reading = false

    var body: some View {
        Button {
            Haptics.tap()
            SoundEngine.shared.play(.sparkle)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { reading = true }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation { reading = false }
            }
        } label: {
            HStack(spacing: 10) {
                Text(reading ? "🔊" : "📖")
                    .font(.system(size: 30))
                    .rotationEffect(.degrees(reading ? 0 : (pulse ? 8 : -8)))
                Text(reading ? "Listen..." : "Tell me more!")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("✨")
                    .font(.system(size: 22))
                    .opacity(pulse ? 1 : 0.4)
                    .scaleEffect(pulse ? 1.2 : 0.8)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [theme.accent, Color(red: 0.98, green: 0.65, blue: 0.15)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
            )
            .overlay(Capsule().stroke(.white.opacity(0.65), lineWidth: 3))
            .shadow(color: theme.accent.opacity(0.5), radius: pulse ? 12 : 6, y: 4)
            .scaleEffect(pulse ? 1.06 : 1.0)
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.9))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

/// One "Lives in / Eats / Baby" card on the animal detail panel.
struct AnimalFactChip: View {
    let icon: String
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(icon)
                .font(.system(size: 26))
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(accent)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 92)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.92))
                .shadow(color: accent.opacity(0.2), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(accent.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        AnimalGameView()
    }
}
