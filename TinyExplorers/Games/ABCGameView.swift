import SwiftUI

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
    @State private var quizStreak = 0
    @State private var quizShowResult: Bool? = nil
    @State private var quizEmojiBob = false
    @State private var progression = GameProgression(key: GameTheme.abc.key)
    @State private var adventure = Adventure()
    @State private var showAdventureComplete = false
    // One miss per question: extra wrong taps on the same round give feedback
    // but never re-count against the chest or the adaptive step-down.
    @State private var missRecordedThisRound = false

    private let quizHints = [
        "Look at the picture and find its first letter!",
        "Say the word out loud — what sound does it start with?",
        "The answer gets harder — take your time!",
        "You're a letter pro now — go fast!",
    ]

    private let theme = GameTheme.abc

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .abc)

            VStack(spacing: 12) {
                // Mode picker
                ThemedSegmentedPicker(
                    items: [
                        (title: "Explore", value: ABCMode.explore),
                        (title: "Letter Quiz", value: ABCMode.quiz),
                    ],
                    selection: $gameMode,
                    accent: theme.accent
                )
                .onChange(of: gameMode) { _ in
                    Haptics.tap()
                    SoundEngine.shared.play(.tap)
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
        .kidNavigation(title: "ABC Letters", theme: theme)
        .onDisappear {
            SpeechHelper.stop()
        }
    }

    // MARK: - Explore Mode

    var exploreView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            // Selected letter display: one centered themed card
            if let letter = selectedLetter, let info = letterData[letter] {
                letterDetailCard(letter: letter, info: info)
                    .animation(.spring(), value: selectedLetter)
            } else {
                // Frame keeps roughly the old empty-state height so the
                // letter grid doesn't jump when a letter gets selected.
                MascotBubble(theme: theme, text: "Tap a letter to learn!")
                    .frame(minHeight: 200)
            }

            Spacer(minLength: 20)

            // Letter grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(letters.enumerated()), id: \.element) { index, letter in
                    Button(action: { selectLetter(letter) }) {
                        Text(String(letter))
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(letterColor(letter))
                                    .shadow(
                                        color: .black.opacity(0.18),
                                        radius: selectedLetter == letter ? 6 : 3, y: 2
                                    )
                            )
                            .scaleEffect(selectedLetter == letter ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedLetter)
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .popIn(delay: Double(index) * 0.015)
                }
            }
            .frame(maxWidth: 820)
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
    }

    /// Single centered themed card: big letter + phonics + word on the left,
    /// more words and a tappable fun fact on the right.
    private func letterDetailCard(letter: Character, info: LetterInfo) -> some View {
        HStack(alignment: .center, spacing: 30) {
            // Left: Letter + word
            VStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(String(letter))
                        .font(.system(size: 92, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [theme.accent, .orange], startPoint: .top, endPoint: .bottom)
                        )
                    Text(String(letter).lowercased())
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundColor(theme.accent.opacity(0.65))
                }
                .scaleEffect(bounceEffect ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: bounceEffect)

                Text("Sounds like: \"\(info.phonics)\"")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.accent)
                            .shadow(color: theme.accent.opacity(0.4), radius: 4, y: 2)
                    )

                HStack(spacing: 10) {
                    Text(info.emoji).font(.system(size: 50))
                    Text(info.word)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                HStack(spacing: 10) {
                    Text(isVowel(letter) ? "Vowel" : "Consonant")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(isVowel(letter) ? Color.green : Color.blue))
                    Text("Letter #\(letterPosition(letter))")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            // Right: More words + tappable fun fact
            VStack(alignment: .leading, spacing: 10) {
                Text("More \(String(letter)) words:")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
                ForEach(info.moreWords, id: \.self) { word in
                    Text("• \(word)")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                }

                Divider()

                // Fun fact is spoken only when the kid taps it
                Button {
                    Haptics.tap()
                    SoundEngine.shared.play(.sparkle)
                    SpeechHelper.speak(info.funFact)
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Text("💡").font(.system(size: 22))
                        Text(info.funFact)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.accent)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.accent.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(theme.accent.opacity(0.3), lineWidth: 1.5)
                            )
                    )
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.96))
            }
            .frame(maxWidth: 340)
        }
        .padding(26)
        .frame(maxWidth: 780)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.white, theme.accent.opacity(0.12)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(theme.accent.opacity(0.45), lineWidth: 2.5)
                )
                .shadow(color: theme.accent.opacity(0.3), radius: 12, y: 6)
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

            VStack(spacing: 26) {
                if let quiz = quizLetter, let info = letterData[quiz] {
                    VStack(spacing: 16) {
                        Text(progression.level < 3
                             ? "Which letter does \(info.word) start with?"
                             : "Which letter does this word start with?")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        // Decouple the giveaway cue by level: the emoji is the
                        // last visual crutch and disappears at high levels so the
                        // child must lean on the spoken sound instead of reading.
                        if progression.level < 5 {
                            Text(info.emoji)
                                .font(.system(size: 120))
                                .shadow(color: theme.accent.opacity(0.3), radius: 8, y: 4)
                        }

                        // Only the earliest levels spell the word out; hiding it
                        // stops a reading child from simply copying the answer.
                        if progression.level < 3 {
                            Text(info.word)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white.opacity(0.85))
                            .shadow(color: theme.accent.opacity(0.2), radius: 10, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(theme.accent.opacity(0.3), lineWidth: 2.5)
                    )

                    // Replay control: at high levels the emoji and word are
                    // hidden, so a pre-reader who missed the spoken prompt can
                    // always hear the question (and target sound) again.
                    Button {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        speakQuizPrompt()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Hear again")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(minHeight: 60)
                        .background(
                            Capsule()
                                .fill(theme.accent)
                                .shadow(color: theme.accent.opacity(0.4), radius: 6, y: 3)
                        )
                    }
                    .buttonStyle(SquishyButtonStyle())

                    HStack(spacing: 26) {
                        ForEach(Array(quizOptions.enumerated()), id: \.element) { index, option in
                            VStack(spacing: 12) {
                                Button(action: { checkQuizAnswer(option) }) {
                                    Text(String(option))
                                        .font(.system(size: 62, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 132, height: 132)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [theme.accent, theme.accent.opacity(0.7)],
                                                        startPoint: .top, endPoint: .bottom
                                                    )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .strokeBorder(.white.opacity(0.6), lineWidth: 3)
                                                )
                                                .shadow(color: theme.accent.opacity(0.5), radius: 10, y: 5)
                                        )
                                }
                                .buttonStyle(SquishyButtonStyle())
                                .disabled(quizShowResult != nil)

                                // Speaker sits below the answer (outside its Button)
                                // so a pre-reader can hear each candidate letter's
                                // name before choosing — hearing never selects.
                                SpeakOptionButton(text: String(option), accent: theme.accent)
                            }
                            .popIn(delay: Double(index) * 0.04)
                        }
                    }

                    if let result = quizShowResult {
                        Text(result ? "Correct! \(String(quiz)) is for \(info.word)!" : "Oops! Listen and try again!")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundColor(result ? .green : .orange)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(.white.opacity(0.9))
                            )
                            .transition(.scale)
                    }
                }
            }

            Spacer(minLength: 24)
        }
    }

    // MARK: - Helpers

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

    /// Letters that are easy to mix up with `letter` — mirror/rotation shapes
    /// (b/d/p/q), similar strokes (M/N/W/V, E/F, I/J/L/T) and shared sounds
    /// (C/G/K/S). Used to make quiz distractors subtler at higher levels.
    private func confusableLetters(for letter: Character) -> [Character] {
        let groups: [[Character]] = [
            ["B", "D", "P", "Q"],
            ["M", "N", "W", "V"],
            ["E", "F"],
            ["C", "G", "K", "S"],
            ["I", "J", "L", "T"],
        ]
        for group in groups where group.contains(letter) {
            return group.filter { $0 != letter }
        }
        return []
    }

    // MARK: - Game logic

    func selectLetter(_ letter: Character) {
        withAnimation(.spring()) { selectedLetter = letter }
        bounceEffect = true
        showConfetti = true
        Haptics.tap()
        SoundEngine.shared.playTileNote(letterPosition(letter) - 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { bounceEffect = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }

        // Short and snappy — the fun fact only plays if the kid taps it.
        if let info = letterData[letter] {
            SpeechHelper.speak("\(letter)! \(info.phonics)! \(letter) is for \(info.word)!")
        }
    }

    /// Speaks the current quiz prompt (sound + word to find). Shared by the
    /// round start, the "Hear again" replay button, and the wrong-answer retry
    /// so a pre-reader can always recover the target by ear.
    func speakQuizPrompt() {
        guard let quiz = quizLetter, let info = letterData[quiz] else { return }
        // Carry the difficulty in audio: the sound is spoken so the round still
        // works once the printed word/emoji are hidden at high levels.
        SpeechHelper.speak("Which letter says '\(info.phonics)'? Find the start of \(info.word)")
    }

    func newQuizRound() {
        quizShowResult = nil
        missRecordedThisRound = false
        // Never the same letter twice in a row.
        guard let quiz = letters.filter({ $0 != quizLetter }).randomElement() else { return }
        quizLetter = quiz

        // Progressive: more options at higher levels, felt sooner (3 → 4 → 5 → 6)
        let optionCount = min(6, 3 + progression.level / 2)

        var opts: [Character] = [quiz]

        // From level 3, fill distractor slots preferentially from letters that
        // are easy to confuse with the target before falling back to random, so
        // extra options mean harder discrimination — not just more buttons a
        // child can rule out at a glance.
        if progression.level >= 3 {
            for candidate in confusableLetters(for: quiz).shuffled() where opts.count < optionCount {
                if !opts.contains(candidate) { opts.append(candidate) }
            }
        }

        while opts.count < optionCount {
            if let random = letters.randomElement(), !opts.contains(random) {
                opts.append(random)
            }
        }
        quizOptions = opts.shuffled()

        speakQuizPrompt()
    }

    func checkQuizAnswer(_ answer: Character) {
        if answer == quizLetter {
            quizScore += 1
            StarBank.shared.award(1, to: theme.key)
            progression.registerCorrect()
            adventure.recordCorrect()
            Haptics.success()
            SoundEngine.shared.play(.correct)
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showConfetti = false }
            withAnimation(.spring()) {
                quizStreak += 1
                quizShowResult = true
            }

            // The streak bonus is computed independently of the level-up so a
            // 5-in-a-row that lands on the same answer as a level-up still
            // awards its bonus star and cheer instead of being swallowed by the
            // else-if chain.
            let hitStreakMilestone = quizStreak > 0 && quizStreak % 5 == 0
            if hitStreakMilestone {
                StarBank.shared.award(1, to: theme.key)
                quizScore += 1
                SpeechHelper.cheer("\(quizStreak) in a row!")
            }

            if progression.showLevelUp || hitStreakMilestone {
                SoundEngine.shared.play(.streak)
            } else if let info = letterData[quizLetter!] {
                SpeechHelper.speak("\(String(quizLetter!)) is for \(info.word)!")
            }

            let delay = progression.showLevelUp ? 2.5 : 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                progression.clearLevelUp()
                if adventure.isComplete {
                    StarBank.shared.award(adventure.chestStars, to: theme.key)
                    // Keep the on-screen star chip in sync with the real star
                    // bank: chest stars are awarded to the bank, so mirror them
                    // into quizScore too instead of letting the chip drift.
                    quizScore += adventure.chestStars
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        showAdventureComplete = true
                    }
                } else {
                    withAnimation { newQuizRound() }
                }
            }
        } else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            // Count only the first miss of this question; further wrong taps
            // still get feedback but never inflate misses or misfire step-down.
            if !missRecordedThisRound {
                progression.registerWrong()
                adventure.recordMiss()
                missRecordedThisRound = true
            }
            withAnimation(.spring()) {
                quizStreak = 0
                quizShowResult = false
            }
            SpeechHelper.speak("Oops! Try again!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { quizShowResult = nil }
                // Replay the prompt so a pre-reader recovers the target by ear.
                speakQuizPrompt()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ABCGameView()
    }
}
