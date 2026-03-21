import SwiftUI
import AVFoundation

struct LetterInfo {
    let word: String
    let emoji: String
    let phonics: String       // how the letter sounds
    let moreWords: [String]   // extra example words
    let funFact: String       // educational fun fact
}

struct ABCGameView: View {
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let letterData: [Character: LetterInfo] = [
        "A": LetterInfo(word: "Apple", emoji: "🍎", phonics: "ah", moreWords: ["Ant 🐜", "Airplane ✈️", "Alligator 🐊"], funFact: "A is a vowel! Vowels help us say every word."),
        "B": LetterInfo(word: "Bear", emoji: "🐻", phonics: "buh", moreWords: ["Ball ⚽", "Banana 🍌", "Bird 🐦"], funFact: "B is the second letter. Bears sleep all winter!"),
        "C": LetterInfo(word: "Cat", emoji: "🐱", phonics: "kuh", moreWords: ["Car 🚗", "Cake 🎂", "Cloud ☁️"], funFact: "C can sound like K or S! Cat has a K sound."),
        "D": LetterInfo(word: "Dog", emoji: "🐶", phonics: "duh", moreWords: ["Duck 🦆", "Door 🚪", "Dragon 🐉"], funFact: "D looks like a half circle! Dogs are our best friends."),
        "E": LetterInfo(word: "Elephant", emoji: "🐘", phonics: "eh", moreWords: ["Egg 🥚", "Earth 🌍", "Eagle 🦅"], funFact: "E is the most used letter in English!"),
        "F": LetterInfo(word: "Fish", emoji: "🐟", phonics: "fuh", moreWords: ["Flower 🌸", "Frog 🐸", "Fire 🔥"], funFact: "F makes a blowing sound. Fish breathe underwater!"),
        "G": LetterInfo(word: "Grape", emoji: "🍇", phonics: "guh", moreWords: ["Giraffe 🦒", "Guitar 🎸", "Garden 🌻"], funFact: "G can be hard like Grape or soft like Giraffe!"),
        "H": LetterInfo(word: "House", emoji: "🏠", phonics: "huh", moreWords: ["Heart ❤️", "Horse 🐴", "Hat 🎩"], funFact: "H sounds like a breath of air. It's a quiet letter!"),
        "I": LetterInfo(word: "Ice Cream", emoji: "🍦", phonics: "ih", moreWords: ["Igloo 🏔️", "Island 🏝️", "Insect 🐛"], funFact: "I is a vowel and the smallest letter to write!"),
        "J": LetterInfo(word: "Jellyfish", emoji: "🪼", phonics: "juh", moreWords: ["Juice 🧃", "Jungle 🌴", "Jump 🦘"], funFact: "J was the last letter added to the alphabet!"),
        "K": LetterInfo(word: "Kite", emoji: "🪁", phonics: "kuh", moreWords: ["Koala 🐨", "King 🤴", "Key 🔑"], funFact: "K and C can make the same sound! Kangaroos jump high."),
        "L": LetterInfo(word: "Lion", emoji: "🦁", phonics: "luh", moreWords: ["Leaf 🍃", "Lemon 🍋", "Ladybug 🐞"], funFact: "L is a tall letter. Lions are called the king of the jungle!"),
        "M": LetterInfo(word: "Moon", emoji: "🌙", phonics: "muh", moreWords: ["Monkey 🐵", "Music 🎵", "Mountain ⛰️"], funFact: "M has two bumps. Mom starts with M!"),
        "N": LetterInfo(word: "Nest", emoji: "🪺", phonics: "nuh", moreWords: ["Night 🌃", "Nurse 👩‍⚕️", "Nut 🥜"], funFact: "N has one bump. Birds build nests for their babies!"),
        "O": LetterInfo(word: "Octopus", emoji: "🐙", phonics: "oh", moreWords: ["Orange 🍊", "Owl 🦉", "Ocean 🌊"], funFact: "O is a vowel shaped like a circle! Octopuses have 8 arms."),
        "P": LetterInfo(word: "Penguin", emoji: "🐧", phonics: "puh", moreWords: ["Pizza 🍕", "Panda 🐼", "Planet 🪐"], funFact: "P makes a popping sound. Penguins can't fly but swim fast!"),
        "Q": LetterInfo(word: "Queen", emoji: "👸", phonics: "kwuh", moreWords: ["Quilt 🛏️", "Question ❓", "Quiet 🤫"], funFact: "Q almost always has U after it! They are best friends."),
        "R": LetterInfo(word: "Rainbow", emoji: "🌈", phonics: "ruh", moreWords: ["Rocket 🚀", "Robot 🤖", "Rabbit 🐰"], funFact: "R makes a rumbling sound. Rainbows have 7 colors!"),
        "S": LetterInfo(word: "Star", emoji: "⭐", phonics: "sss", moreWords: ["Sun ☀️", "Snake 🐍", "Smile 😊"], funFact: "S sounds like a snake hissing! Stars twinkle at night."),
        "T": LetterInfo(word: "Turtle", emoji: "🐢", phonics: "tuh", moreWords: ["Tree 🌳", "Train 🚂", "Tiger 🐯"], funFact: "T looks like a cross. Turtles carry their home on their back!"),
        "U": LetterInfo(word: "Umbrella", emoji: "☂️", phonics: "uh", moreWords: ["Unicorn 🦄", "Up ⬆️", "Uniform 👔"], funFact: "U is a vowel that looks like a cup! Umbrellas keep us dry."),
        "V": LetterInfo(word: "Violin", emoji: "🎻", phonics: "vuh", moreWords: ["Volcano 🌋", "Van 🚐", "Vegetable 🥕"], funFact: "V is like an upside-down mountain! Violins make beautiful music."),
        "W": LetterInfo(word: "Whale", emoji: "🐳", phonics: "wuh", moreWords: ["Water 💧", "Wind 💨", "Worm 🪱"], funFact: "W is the widest letter! Blue whales are the biggest animals ever."),
        "X": LetterInfo(word: "Xylophone", emoji: "🎵", phonics: "ks", moreWords: ["X-ray 🩻", "Fox 🦊", "Box 📦"], funFact: "X often appears at the end of words. X marks the spot on treasure maps!"),
        "Y": LetterInfo(word: "Yarn", emoji: "🧶", phonics: "yuh", moreWords: ["Yak 🐃", "Yellow 💛", "Yogurt 🥛"], funFact: "Y can be a vowel or consonant! It's a special letter."),
        "Z": LetterInfo(word: "Zebra", emoji: "🦓", phonics: "zz", moreWords: ["Zoo 🦁", "Zipper 🤐", "Zero 0️⃣"], funFact: "Z is the last letter! No two zebras have the same stripes."),
    ]

    @State private var selectedLetter: Character? = nil
    @State private var bounceEffect = false
    @State private var showConfetti = false
    @State private var gameMode: ABCMode = .explore

    enum ABCMode {
        case explore
        case quiz
    }

    @State private var quizLetter: Character? = nil
    @State private var quizOptions: [Character] = []
    @State private var quizScore = 0
    @State private var quizShowResult: Bool? = nil

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.85, blue: 0.85), Color(red: 1.0, green: 0.95, blue: 0.85)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                // Mode picker
                Picker("Mode", selection: $gameMode) {
                    Text("Explore").tag(ABCMode.explore)
                    Text("Letter Quiz").tag(ABCMode.quiz)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 200)
                .onChange(of: gameMode) { _ in
                    if gameMode == .quiz { newQuizRound() }
                }

                if gameMode == .explore {
                    exploreView
                } else {
                    quizView
                }
            }
            .padding(.top, 8)

            if showConfetti {
                ConfettiView()
            }
        }
        .navigationTitle("ABC Letters")
        .navigationBarTitleDisplayMode(.inline)
    }

    var exploreView: some View {
        VStack(spacing: 12) {
            // Selected letter display
            if let letter = selectedLetter, let info = letterData[letter] {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        // Left: Letter + visual
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Text(String(letter))
                                    .font(.system(size: 80, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom)
                                    )
                                Text(String(letter).lowercased())
                                    .font(.system(size: 60, weight: .medium, design: .rounded))
                                    .foregroundColor(.orange.opacity(0.7))
                            }
                            .scaleEffect(bounceEffect ? 1.15 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: bounceEffect)

                            Text("Sounds like: \"\(info.phonics)\"")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.blue.opacity(0.1)))

                            HStack(spacing: 8) {
                                Text(info.emoji).font(.system(size: 40))
                                Text(info.word)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }

                            HStack(spacing: 8) {
                                Text(isVowel(letter) ? "Vowel" : "Consonant")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(isVowel(letter) ? Color.green : Color.blue))
                                Text("Letter #\(letterPosition(letter))")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Right: More words + fun fact
                        VStack(alignment: .leading, spacing: 6) {
                            Text("More \(String(letter)) words:")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.purple)
                            ForEach(info.moreWords, id: \.self) { word in
                                Text("• \(word)")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            Divider()
                            HStack(spacing: 6) {
                                Text("💡").font(.system(size: 18))
                                Text(info.funFact)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(width: 260)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.white.opacity(0.7))
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 230)
                .animation(.spring(), value: selectedLetter)
            } else {
                VStack(spacing: 8) {
                    Text("🔤")
                        .font(.system(size: 70))
                    Text("Tap a letter to learn!")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(height: 230)
            }

            // Letter grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(letters, id: \.self) { letter in
                    Button(action: { selectLetter(letter) }) {
                        Text(String(letter))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(letterColor(letter))
                                    .shadow(radius: selectedLetter == letter ? 6 : 3)
                            )
                            .scaleEffect(selectedLetter == letter ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedLetter)
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    var quizView: some View {
        VStack(spacing: 20) {
            Text("Score: \(quizScore)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.orange)

            if let quiz = quizLetter, let info = letterData[quiz] {
                VStack(spacing: 16) {
                    Text("Which letter does \(info.word) start with?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(info.emoji)
                        .font(.system(size: 100))

                    Text(info.word)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                }

                HStack(spacing: 24) {
                    ForEach(quizOptions, id: \.self) { option in
                        Button(action: { checkQuizAnswer(option) }) {
                            Text(String(option))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 0.95, green: 0.4, blue: 0.4))
                                        .shadow(radius: 6)
                                )
                        }
                        .disabled(quizShowResult != nil)
                    }
                }

                if let result = quizShowResult {
                    Text(result ? "Correct! \(String(quiz)) is for \(info.word)!" : "Try again! \(info.word) starts with \(String(quiz))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(result ? .green : .orange)
                        .transition(.scale)
                }
            }

            Spacer()
        }
    }

    func letterColor(_ letter: Character) -> Color {
        if selectedLetter == letter { return .orange }
        return isVowel(letter) ?
            Color(red: 0.2, green: 0.7, blue: 0.4) :
            Color(red: 0.95, green: 0.4, blue: 0.4)
    }

    func isVowel(_ letter: Character) -> Bool {
        "AEIOU".contains(letter)
    }

    func letterPosition(_ letter: Character) -> Int {
        Int(letter.asciiValue! - Character("A").asciiValue!) + 1
    }

    func selectLetter(_ letter: Character) {
        selectedLetter = letter
        bounceEffect = true
        showConfetti = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { bounceEffect = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }

        speakLetter(letter)
    }

    func speakLetter(_ letter: Character) {
        guard let info = letterData[letter] else { return }
        let moreWordsText = info.moreWords.map { word in
            // Strip emojis for speech
            word.components(separatedBy: " ").first ?? word
        }.joined(separator: ", ")
        let text = "Capital \(letter), lowercase \(String(letter).lowercased()). \(letter) makes the sound \(info.phonics). \(letter) is for \(info.word). More \(letter) words: \(moreWordsText). \(info.funFact)"
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func newQuizRound() {
        quizShowResult = nil
        quizLetter = letters.randomElement()
        guard let quiz = quizLetter else { return }

        var opts: [Character] = [quiz]
        while opts.count < 4 {
            if let random = letters.randomElement(), !opts.contains(random) {
                opts.append(random)
            }
        }
        quizOptions = opts.shuffled()

        if let info = letterData[quiz] {
            speak("Which letter does \(info.word) start with?")
        }
    }

    func checkQuizAnswer(_ answer: Character) {
        if answer == quizLetter {
            quizScore += 1
            withAnimation { quizShowResult = true }
            if let info = letterData[quizLetter!] {
                speak("Correct! \(String(quizLetter!)) is for \(info.word)!")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { newQuizRound() }
            }
        } else {
            withAnimation { quizShowResult = false }
            if let info = letterData[quizLetter!] {
                speak("\(info.word) starts with \(String(quizLetter!)). Try again!")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { quizShowResult = nil }
            }
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

struct ConfettiView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                Text(["🎉", "⭐", "🌟", "✨", "🎊"][i % 5])
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: animate ? CGFloat.random(in: 200...500) : -100
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeIn(duration: Double.random(in: 1.0...2.0))
                        .delay(Double(i) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    NavigationStack {
        ABCGameView()
    }
}
