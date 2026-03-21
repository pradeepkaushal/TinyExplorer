import SwiftUI
import AVFoundation

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

    let synthesizer = AVSpeechSynthesizer()

    enum AnimalGameMode {
        case explore
        case guess
    }

    @State private var quizAnimal: Animal? = nil
    @State private var quizOptions: [Animal] = []
    @State private var quizScore = 0
    @State private var showResult: Bool? = nil

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 1.0, blue: 0.85), Color(red: 0.95, green: 1.0, blue: 0.85)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Picker("Mode", selection: $gameMode) {
                    Text("Explore").tag(AnimalGameMode.explore)
                    Text("Sound Quiz").tag(AnimalGameMode.guess)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 200)
                .onChange(of: gameMode) { _ in
                    if gameMode == .guess { newQuizRound() }
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    guessView
                }
            }
        }
        .navigationTitle("Animal Friends")
        .navigationBarTitleDisplayMode(.inline)
    }

    var exploreView: some View {
        VStack(spacing: 16) {
            // Display area
            if let animal = selectedAnimal {
                VStack(spacing: 12) {
                    Text(animal.emoji)
                        .font(.system(size: 120))
                        .scaleEffect(bounceAnimal ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceAnimal)

                    Text(animal.name)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(animal.color == .white ? .gray : animal.color)

                    if showSound {
                        Text("\" \(animal.sound) \"")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                            .transition(.scale)
                    }

                    Text(animal.fact)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(height: 300)
                .animation(.spring(), value: selectedAnimal?.id)
            } else {
                VStack(spacing: 8) {
                    Text("🐾")
                        .font(.system(size: 80))
                    Text("Tap an animal to learn about it!")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(height: 300)
            }

            // Animal grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(animals) { animal in
                    Button(action: { selectAnimal(animal) }) {
                        VStack(spacing: 6) {
                            Text(animal.emoji)
                                .font(.system(size: 60))
                            Text(animal.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.8))
                                .shadow(radius: selectedAnimal?.id == animal.id ? 6 : 2)
                        )
                        .scaleEffect(selectedAnimal?.id == animal.id ? 1.1 : 1.0)
                        .animation(.spring(), value: selectedAnimal?.id)
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    var guessView: some View {
        VStack(spacing: 24) {
            Text("Score: \(quizScore)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.green)

            if let quiz = quizAnimal {
                VStack(spacing: 16) {
                    Text("Which animal says...")
                        .font(.system(size: 24, weight: .medium, design: .rounded))

                    Text("\" \(quiz.sound) \"")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Button("🔊 Hear it again") {
                        speakAnimalSound(quiz)
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(quizOptions) { option in
                        Button(action: { checkGuess(option) }) {
                            VStack(spacing: 12) {
                                Text(option.emoji)
                                    .font(.system(size: 80))
                                Text(option.name)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white.opacity(0.9))
                                    .shadow(radius: 4)
                            )
                        }
                    }
                }
                .padding(.horizontal, 60)

                if let result = showResult {
                    Text(result ? "✅ Correct!" : "❌ That's the \(quizAnimal?.name ?? ""). Try again!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(result ? .green : .red)
                        .transition(.scale)
                }
            }

            Spacer()
        }
    }

    func selectAnimal(_ animal: Animal) {
        selectedAnimal = animal
        bounceAnimal = true
        showSound = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceAnimal = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showSound = true }
        }

        speakAnimalSound(animal)
    }

    func speakAnimalSound(_ animal: Animal) {
        let utterance = AVSpeechUtterance(string: "The \(animal.name) says \(animal.sound)")
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
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
            speak("Which animal says \(quiz.sound)")
        }
    }

    func checkGuess(_ option: Animal) {
        if option.name == quizAnimal?.name {
            withAnimation { showResult = true }
            quizScore += 1
            speak("Correct! The \(option.name) says \(option.sound)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { newQuizRound() }
            }
        } else {
            withAnimation { showResult = false }
            speak("That's the \(option.name). Try again!")
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
