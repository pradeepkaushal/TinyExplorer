import SwiftUI

struct GameItem: Identifiable {
    let id = UUID()
    let title: String
    let lesson: String
    let emoji: String
    let theme: GameTheme
    let destination: AnyView
}

struct GameSection: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let items: [GameItem]
}

struct HomeView: View {
    let sections: [GameSection] = [
        GameSection(title: "Learn & Discover", emoji: "📚", items: [
            GameItem(title: "ABC Letters", lesson: "Letters & sounds", emoji: "🔤", theme: .abc, destination: AnyView(ABCGameView())),
            GameItem(title: "Spell It!", lesson: "Build your first words", emoji: "🐝", theme: .spelling, destination: AnyView(WordBuilderGameView())),
            GameItem(title: "123 Numbers", lesson: "Count to 20", emoji: "🔢", theme: .numbers, destination: AnyView(NumberGameView())),
            GameItem(title: "Math Fun", lesson: "Add & subtract", emoji: "➕", theme: .math, destination: AnyView(MathGameView())),
            GameItem(title: "Counting", lesson: "Count & compare", emoji: "🧮", theme: .counting, destination: AnyView(CountingGameView())),
            GameItem(title: "Colors & Shapes", lesson: "Shapes all around", emoji: "🟣", theme: .shapes, destination: AnyView(ShapesGameView())),
            GameItem(title: "Clock Time", lesson: "Tell the time", emoji: "⏰", theme: .clock, destination: AnyView(ClockGameView())),
        ]),
        GameSection(title: "Brain Boosters", emoji: "🧠", items: [
            GameItem(title: "Memory Match", lesson: "Remember pairs", emoji: "🧠", theme: .memory, destination: AnyView(MemoryGameView())),
            GameItem(title: "I Spy", lesson: "Listen & find", emoji: "🔎", theme: .listen, destination: AnyView(ListenFindGameView())),
            GameItem(title: "Puzzle Time", lesson: "Solve puzzles", emoji: "🧩", theme: .puzzle, destination: AnyView(PuzzleGameView())),
            GameItem(title: "Pattern Fun", lesson: "What comes next?", emoji: "🔮", theme: .pattern, destination: AnyView(PatternGameView())),
            GameItem(title: "Odd One Out", lesson: "Spot the different one", emoji: "🔍", theme: .oddOneOut, destination: AnyView(OddOneOutGameView())),
        ]),
        GameSection(title: "Create & Play", emoji: "🎨", items: [
            GameItem(title: "Drawing Fun", lesson: "Draw & color", emoji: "🎨", theme: .drawing, destination: AnyView(DrawingGameView())),
            GameItem(title: "Music Maker", lesson: "Make melodies", emoji: "🎵", theme: .music, destination: AnyView(MusicGameView())),
        ]),
        GameSection(title: "Me & My World", emoji: "💛", items: [
            GameItem(title: "Animal Friends", lesson: "Animals & sounds", emoji: "🐾", theme: .animals, destination: AnyView(AnimalGameView())),
            GameItem(title: "Social Skills", lesson: "Being a good friend", emoji: "🤝", theme: .social, destination: AnyView(SocialGameView())),
            GameItem(title: "Emotions", lesson: "Name your feelings", emoji: "🎭", theme: .emotions, destination: AnyView(EmotionsGameView())),
        ]),
    ]

    @ObservedObject private var starBank = StarBank.shared
    @ObservedObject private var profile = Profile.shared
    @ObservedObject private var album = StickerAlbum.shared
    @State private var appeared = false
    @State private var showBuddyPicker = false

    let columns = [GridItem(.adaptive(minimum: 220, maximum: 320), spacing: 18)]

    var body: some View {
        NavigationStack {
            ZStack {
                SkyScene()

                ScrollView {
                    VStack(spacing: 28) {
                        header

                        todayRow

                        ForEach(Array(sections.enumerated()), id: \.element.id) { sectionIndex, section in
                            VStack(alignment: .leading, spacing: 14) {
                                SectionHeader(title: section.title, emoji: section.emoji)

                                LazyVGrid(columns: columns, spacing: 18) {
                                    ForEach(Array(section.items.enumerated()), id: \.element.id) { itemIndex, game in
                                        NavigationLink(destination: game.destination) {
                                            GameCard(game: game, stars: starBank.count(for: game.theme.key))
                                        }
                                        .buttonStyle(SquishyButtonStyle(scale: 0.93))
                                        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
                                        .opacity(appeared ? 1 : 0)
                                        .scaleEffect(appeared ? 1 : 0.7)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.7)
                                                .delay(Double(sectionIndex) * 0.12 + Double(itemIndex) * 0.05),
                                            value: appeared
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 28)
                        }
                    }
                    .padding(.bottom, 40)
                }

                InteractiveSkyLayer()
            }
            .onAppear { appeared = true }
            .sheet(isPresented: $showBuddyPicker) {
                BuddyPickerView()
            }
        }
    }

    var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                Button {
                    Haptics.tap()
                    SoundEngine.shared.play(.pop)
                    showBuddyPicker = true
                } label: {
                    VStack(spacing: 2) {
                        WavingMascot(emoji: profile.buddy.emoji)
                        Text(profile.buddy.name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color(red: 0.85, green: 0.6, blue: 0.05)))
                    }
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.88))

                WavyTitle(text: "Tiny Explorers")
            }

            Text("\(Profile.greeting()) Pick a game and earn stars!")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.4, blue: 0.55))

            StarCounterChip(count: starBank.available)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }

    /// Daily gift + sticker book: the first things a kid sees under the title.
    var todayRow: some View {
        HStack(spacing: 18) {
            DailyGiftCard()
            NavigationLink(destination: StickerBookView()) {
                StickerBookCard(unlockedCount: album.unlockedCount)
            }
            .buttonStyle(SquishyButtonStyle(scale: 0.93))
            .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
        }
        .padding(.horizontal, 28)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05), value: appeared)
    }
}

// MARK: - Daily gift card

/// Once-a-day present: tap to shake it open and rain bonus stars.
struct DailyGiftCard: View {
    @ObservedObject private var gift = DailyGift.shared
    @State private var shaking = false
    @State private var reward: Int? = nil
    @State private var celebrate = false

    var body: some View {
        Button(action: open) {
            HStack(spacing: 14) {
                Text(gift.isReady ? "🎁" : "🎀")
                    .font(.system(size: 54))
                    .rotationEffect(.degrees(shaking ? 8 : 0))
                    .animation(
                        shaking
                            ? .easeInOut(duration: 0.07).repeatCount(7, autoreverses: true)
                            : .default,
                        value: shaking
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(gift.isReady ? "Daily Surprise!" : "Gift opened!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.4))
                    if let reward {
                        Text("You found \(reward) stars! ⭐")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.85, green: 0.6, blue: 0.05))
                    } else {
                        Text(gift.isReady ? "Tap to open your gift" : "Come back tomorrow!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.45, green: 0.5, blue: 0.65))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: gift.isReady
                                ? [Color(red: 1.0, green: 0.95, blue: 0.75), .white]
                                : [Color(red: 0.95, green: 0.95, blue: 0.97), .white],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.9, green: 0.6, blue: 0.1).opacity(gift.isReady ? 0.4 : 0.15), radius: 9, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color(red: 0.9, green: 0.65, blue: 0.15).opacity(gift.isReady ? 0.5 : 0.2), lineWidth: 2.5)
            )
            .overlay {
                if celebrate { ConfettiView() }
            }
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.93))
        .disabled(!gift.isReady && reward == nil)
    }

    private func open() {
        guard gift.isReady else { return }
        Haptics.tap()
        SoundEngine.shared.play(.pop)
        shaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            shaking = false
            let stars = gift.open()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                reward = stars
                celebrate = true
            }
            Haptics.success()
            SoundEngine.shared.play(.win)
            SpeechHelper.cheer("Surprise! You found \(stars) bonus stars!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { celebrate = false }
            }
        }
    }
}

// MARK: - Sticker book card

struct StickerBookCard: View {
    let unlockedCount: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("📖")
                .font(.system(size: 54))

            VStack(alignment: .leading, spacing: 4) {
                Text("Sticker Book")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.4))
                Text(unlockedCount > 0
                     ? "\(unlockedCount) of \(StickerPack.totalStickerCount) collected"
                     : "Spend stars on stickers!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.1))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.92, blue: 0.85), .white],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 0.93, green: 0.5, blue: 0.3).opacity(0.35), radius: 9, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color(red: 0.93, green: 0.55, blue: 0.3).opacity(0.45), lineWidth: 2.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 26))
    }
}

// MARK: - Header pieces

struct WavyTitle: View {
    let text: String

    private let rainbow: [Color] = [
        Color(red: 0.94, green: 0.35, blue: 0.33),
        Color(red: 0.96, green: 0.55, blue: 0.14),
        Color(red: 0.85, green: 0.65, blue: 0.0),
        Color(red: 0.22, green: 0.66, blue: 0.34),
        Color(red: 0.25, green: 0.48, blue: 0.95),
        Color(red: 0.58, green: 0.34, blue: 0.86),
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 0) {
                ForEach(Array(text.enumerated()), id: \.offset) { i, char in
                    Text(String(char))
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundColor(rainbow[i % rainbow.count])
                        .offset(y: sin(t * 2.2 + Double(i) * 0.45) * 5)
                }
            }
            .shadow(color: .white.opacity(0.8), radius: 2, y: 2)
        }
    }
}

struct WavingMascot: View {
    var emoji: String = "🦊"
    var delay: Double = 0
    @State private var wave = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 56))
            .rotationEffect(.degrees(wave ? 12 : -8), anchor: .bottom)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(delay),
                value: wave
            )
            .onAppear { wave = true }
    }
}

struct SectionHeader: View {
    let title: String
    let emoji: String

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 30))
            Text(title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
            Spacer()
        }
    }
}

// MARK: - Game card

struct GameCard: View {
    let game: GameItem
    let stars: Int

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [game.theme.accent.opacity(0.25), game.theme.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                Text(game.emoji)
                    .font(.system(size: 58))

                if let medal = StarBadge.medal(for: stars) {
                    Text(medal)
                        .font(.system(size: 30))
                        .offset(x: 38, y: -34)
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                }
            }

            VStack(spacing: 4) {
                Text(game.title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.4))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(game.lesson)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(game.theme.accent)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            if stars > 0 {
                StarCounterChip(count: stars, compact: true)
            } else {
                Text("Let's play!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(game.theme.accent))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)
                .shadow(color: game.theme.accent.opacity(0.3), radius: 10, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(game.theme.accent.opacity(0.35), lineWidth: 2.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 28))
    }
}

// MARK: - Sky scene background

struct SkyScene: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.62, green: 0.85, blue: 1.0),
                    Color(red: 0.85, green: 0.94, blue: 1.0),
                    Color(red: 0.99, green: 0.97, blue: 0.90),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            DriftingClouds()

            RollingHills()

            FloatingEmojiLayer(emoji: ["🦋", "⭐", "🌸"])
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Touchable sky (above the scroll view)

/// Sago-Mini-style toy layer: a giggling sun and poppable balloons floating
/// over the home screen. Empty space passes touches through to the grid.
struct InteractiveSkyLayer: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                TappableSun()
                    .position(x: geo.size.width - 110, y: 100)

                PoppableBalloon(index: 0, canvas: geo.size)
                PoppableBalloon(index: 1, canvas: geo.size)
                PoppableBalloon(index: 2, canvas: geo.size)
            }
        }
        .ignoresSafeArea()
    }
}

/// The smiling sun reacts to pokes with a wiggle, a sparkle and a giggle.
struct TappableSun: View {
    @State private var spin = false
    @State private var excited = false

    private let giggles = [
        "Hee hee, that tickles!", "Hello, sunshine!", "What a lovely day to play!",
    ]

    var body: some View {
        Button {
            guard !excited else { return }
            Haptics.tap()
            SoundEngine.shared.play(.sparkle)
            SpeechHelper.cheer(giggles.randomElement() ?? "Hee hee!")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { excited = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { excited = false }
            }
        } label: {
            ZStack {
                ForEach(0..<10, id: \.self) { i in
                    Capsule()
                        .fill(Color(red: 1.0, green: 0.85, blue: 0.35).opacity(0.55))
                        .frame(width: 9, height: 36)
                        .offset(y: -56)
                        .rotationEffect(.degrees(Double(i) * 36))
                }
                .rotationEffect(.degrees(spin ? 360 : 0))
                .animation(.linear(duration: 36).repeatForever(autoreverses: false), value: spin)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.92, blue: 0.5), Color(red: 1.0, green: 0.78, blue: 0.25)],
                            center: .center, startRadius: 4, endRadius: 44
                        )
                    )
                    .frame(width: 76, height: 76)
                Text(excited ? "😄" : "😊")
                    .font(.system(size: 34))
            }
            .scaleEffect(excited ? 1.25 : 1.0)
            .rotationEffect(.degrees(excited ? 14 : 0))
        }
        .buttonStyle(.plain)
        .onAppear { spin = true }
    }
}

/// A balloon that drifts up the screen edge; tapping pops it with a burst,
/// and a fresh one floats up on the next pass.
struct PoppableBalloon: View {
    let index: Int
    let canvas: CGSize

    @State private var poppedCycle: Int? = nil
    @State private var burstPosition: CGPoint? = nil

    private var period: Double { [26.0, 34.0, 30.0][index % 3] }
    private var phase: Double { Double(index) * 11.3 }
    private var xFraction: CGFloat { [0.06, 0.94, 0.09][index % 3] }
    private var hue: Color {
        [
            Color(red: 0.95, green: 0.35, blue: 0.35),
            Color(red: 0.3, green: 0.55, blue: 0.95),
            Color(red: 0.6, green: 0.4, blue: 0.9),
        ][index % 3]
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let raw = (t + phase) / period
            let cycle = Int(raw)
            let progress = raw - Double(cycle)
            let x = canvas.width * xFraction + sin(t * 0.7 + phase) * 14
            let y = (canvas.height + 90) - progress * (canvas.height + 220)

            ZStack {
                if poppedCycle != cycle {
                    Button {
                        poppedCycle = cycle
                        burstPosition = CGPoint(x: x, y: y)
                        Haptics.tap()
                        SoundEngine.shared.play(.pop)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            burstPosition = nil
                        }
                    } label: {
                        BalloonShape(color: hue)
                            .rotationEffect(.degrees(sin(t * 0.9 + phase) * 7))
                    }
                    .buttonStyle(.plain)
                    .position(x: x, y: y)
                }

                if let burst = burstPosition {
                    Text("💥")
                        .font(.system(size: 44))
                        .position(burst)
                        .transition(.scale)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

/// Simple drawn balloon: shiny ellipse, knot, and a curvy string.
struct BalloonShape: View {
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.75), color],
                            center: .init(x: 0.35, y: 0.3),
                            startRadius: 2, endRadius: 40
                        )
                    )
                    .frame(width: 46, height: 56)
                Ellipse()
                    .fill(.white.opacity(0.45))
                    .frame(width: 12, height: 18)
                    .offset(x: -9, y: -13)
            }
            Triangle()
                .fill(color)
                .frame(width: 10, height: 7)
            BalloonString()
                .stroke(color.opacity(0.7), lineWidth: 1.6)
                .frame(width: 12, height: 26)
        }
        .shadow(color: color.opacity(0.35), radius: 5, y: 3)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct BalloonString: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.minX, y: rect.height * 0.35),
            control2: CGPoint(x: rect.maxX, y: rect.height * 0.7)
        )
        return p
    }
}

struct DriftingClouds: View {
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    cloud(scale: 1.0)
                        .position(x: drift(t, speed: 14, span: geo.size.width, phase: 0), y: 90)
                    cloud(scale: 0.7)
                        .position(x: drift(t, speed: 22, span: geo.size.width, phase: 0.45), y: 170)
                    cloud(scale: 0.85)
                        .position(x: drift(t, speed: 17, span: geo.size.width, phase: 0.8), y: 60)
                }
            }
        }
    }

    private func drift(_ t: Double, speed: Double, span: CGFloat, phase: Double) -> CGFloat {
        let width = Double(span) + 260
        let progress = (t * speed + phase * width).truncatingRemainder(dividingBy: width)
        return CGFloat(progress) - 130
    }

    private func cloud(scale: CGFloat) -> some View {
        ZStack {
            Ellipse().fill(.white.opacity(0.85)).frame(width: 110 * scale, height: 44 * scale)
            Circle().fill(.white.opacity(0.85)).frame(width: 52 * scale).offset(x: -22 * scale, y: -14 * scale)
            Circle().fill(.white.opacity(0.85)).frame(width: 40 * scale).offset(x: 20 * scale, y: -10 * scale)
        }
    }
}

struct RollingHills: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Ellipse()
                    .fill(Color(red: 0.65, green: 0.87, blue: 0.55).opacity(0.5))
                    .frame(width: geo.size.width * 1.6, height: 280)
                    .position(x: geo.size.width * 0.15, y: geo.size.height + 70)
                Ellipse()
                    .fill(Color(red: 0.55, green: 0.82, blue: 0.45).opacity(0.45))
                    .frame(width: geo.size.width * 1.6, height: 240)
                    .position(x: geo.size.width * 0.9, y: geo.size.height + 60)
            }
        }
    }
}

#Preview {
    HomeView()
}
