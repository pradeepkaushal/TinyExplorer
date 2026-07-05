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
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                // Buddy avatar — big, golden, and inviting
                Button {
                    Haptics.tap()
                    SoundEngine.shared.play(.pop)
                    showBuddyPicker = true
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.92, blue: 0.55), Color(red: 1.0, green: 0.78, blue: 0.35)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 84, height: 84)
                                .shadow(color: Color(red: 0.9, green: 0.65, blue: 0.15).opacity(0.55), radius: 10, y: 5)
                            Circle()
                                .stroke(Color.white.opacity(0.85), lineWidth: 4)
                                .frame(width: 78, height: 78)
                            WavingMascot(emoji: profile.buddy.emoji)
                        }
                        Text(profile.buddy.name)
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.9, green: 0.65, blue: 0.1), Color(red: 0.85, green: 0.55, blue: 0.05)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                            )
                            .shadow(color: Color(red: 0.8, green: 0.5, blue: 0.0).opacity(0.4), radius: 3, y: 2)
                    }
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.88))

                VStack(spacing: 8) {
                    WavyTitle(text: "Tiny Explorers")

                    HStack(spacing: 10) {
                        LevelBadge(level: LevelSystem.level(for: starBank.total), size: 52)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(LevelSystem.title(for: LevelSystem.level(for: starBank.total)))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.5))
                            XPProgressBar(
                                progress: LevelSystem.progress(for: starBank.total),
                                height: 12,
                                showLabel: false
                            )
                            .frame(width: 150)
                        }
                    }
                }

                Spacer(minLength: 0)
            }

            StarCounterChipEnhanced(count: starBank.available)
        }
        .padding(.top, 20)
        .padding(.horizontal, 28)
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
    @State private var glowPulse = false

    var body: some View {
        Button(action: open) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.5), .clear],
                                center: .center, startRadius: 5, endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                    Text(gift.isReady ? "🎁" : "🎀")
                        .font(.system(size: 54))
                        .rotationEffect(.degrees(shaking ? 8 : 0))
                        .animation(
                            shaking
                                ? .easeInOut(duration: 0.07).repeatCount(7, autoreverses: true)
                                : .default,
                            value: shaking
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(gift.isReady ? "Daily Surprise!" : "Gift opened!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.25, blue: 0.4), Color(red: 0.5, green: 0.35, blue: 0.7)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    if let reward {
                        HStack(spacing: 4) {
                            Text("⭐").font(.system(size: 16))
                            Text("+\(reward) stars!")
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.85, green: 0.6, blue: 0.05))
                        }
                    } else {
                        Text(gift.isReady ? "Tap to open!" : "Come back tomorrow!")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
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
                                ? [Color(red: 1.0, green: 0.95, blue: 0.75), Color(red: 1.0, green: 0.98, blue: 0.9), .white]
                                : [Color(red: 0.95, green: 0.95, blue: 0.97), .white],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0.9, green: 0.6, blue: 0.1).opacity(gift.isReady ? (glowPulse ? 0.55 : 0.35) : 0.15), radius: glowPulse ? 14 : 9, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.75, blue: 0.2).opacity(gift.isReady ? 0.7 : 0.2), Color(red: 0.9, green: 0.6, blue: 0.1).opacity(gift.isReady ? 0.4 : 0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
            )
            .overlay {
                if celebrate { ConfettiView() }
            }
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.93))
        .disabled(!gift.isReady && reward == nil)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
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

    @State private var glowPulse = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 1.0, green: 0.8, blue: 0.6).opacity(0.4), .clear],
                            center: .center, startRadius: 5, endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                Text("📖")
                    .font(.system(size: 54))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Sticker Book")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.25, blue: 0.4), Color(red: 0.6, green: 0.35, blue: 0.2)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                if unlockedCount > 0 {
                    HStack(spacing: 6) {
                        Text("\(unlockedCount)/\(StickerPack.totalStickerCount)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.1))
                        XPProgressBar(
                            progress: Double(unlockedCount) / Double(StickerPack.totalStickerCount),
                            height: 8,
                            showLabel: false,
                            accent: Color(red: 0.85, green: 0.55, blue: 0.1)
                        )
                        .frame(width: 80)
                    }
                } else {
                    Text("Spend stars on stickers!")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.1))
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
                        colors: [Color(red: 1.0, green: 0.92, blue: 0.82), Color(red: 1.0, green: 0.97, blue: 0.92), .white],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.93, green: 0.5, blue: 0.3).opacity(glowPulse ? 0.5 : 0.3), radius: glowPulse ? 14 : 9, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.6, blue: 0.3).opacity(0.6), Color(red: 0.9, green: 0.5, blue: 0.25).opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 26))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
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
                        .offset(y: sin(t * 2.2 + Double(i) * 0.45) * 6)
                        .shadow(color: rainbow[i % rainbow.count].opacity(0.5), radius: 3, y: 2)
                }
            }
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

    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 40))
                .scaleEffect(shimmer ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: shimmer)

            Text(title)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.25, blue: 0.45), Color(red: 0.4, green: 0.35, blue: 0.65)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Spacer()

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.75, blue: 0.95).opacity(0.6), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(height: 4)
                .frame(maxWidth: 120)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.75), .white.opacity(0.35)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        )
        .onAppear { shimmer = true }
    }
}

// MARK: - Game card

struct GameCard: View {
    let game: GameItem
    let stars: Int

    @State private var hoverGlow = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Soft radial glow behind the emoji
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [game.theme.accent.opacity(0.35), game.theme.accent.opacity(0.08)],
                            center: .center, startRadius: 5, endRadius: 60
                        )
                    )
                    .frame(width: 110, height: 110)
                    .blur(radius: 2)

                Text(game.emoji)
                    .font(.system(size: 72))
                    .shadow(color: game.theme.accent.opacity(0.3), radius: 4, y: 2)

                // Star badge — small, top-right corner
                if stars > 0 {
                    HStack(spacing: 2) {
                        Text("⭐")
                            .font(.system(size: 13))
                        Text("\(stars)")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.0))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    )
                    .offset(x: 38, y: -38)
                }
            }

            // Title — big and bold
            Text(game.title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.2, blue: 0.35))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            // Lesson subtitle
            Text(game.lesson)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(game.theme.accent)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Big chunky Play button
            Text(stars > 0 ? "Play Again!" : "Play!")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [game.theme.accent, game.theme.accent.opacity(0.75)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                )
                .overlay(
                    Capsule().stroke(.white.opacity(0.6), lineWidth: 2)
                )
                .shadow(color: game.theme.accent.opacity(0.45), radius: 5, y: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: [.white, game.theme.accent.opacity(0.06)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: game.theme.accent.opacity(hoverGlow ? 0.5 : 0.28), radius: hoverGlow ? 18 : 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    LinearGradient(
                        colors: [game.theme.accent.opacity(0.55), game.theme.accent.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 30))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                hoverGlow = true
            }
        }
    }
}

// MARK: - Sky scene background

struct SkyScene: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.82, blue: 1.0),
                    Color(red: 0.75, green: 0.9, blue: 1.0),
                    Color(red: 0.92, green: 0.96, blue: 1.0),
                    Color(red: 0.99, green: 0.97, blue: 0.88),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RainbowArc()

            DriftingClouds()

            RollingHills()

            FloatingEmojiLayer(emoji: ["🦋", "⭐", "🌸", "🌈"])
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct RainbowArc: View {
    private let colors: [Color] = [
        Color(red: 0.95, green: 0.3, blue: 0.3).opacity(0.2),
        Color(red: 0.96, green: 0.55, blue: 0.1).opacity(0.2),
        Color(red: 0.95, green: 0.85, blue: 0.1).opacity(0.2),
        Color(red: 0.3, green: 0.75, blue: 0.3).opacity(0.2),
        Color(red: 0.3, green: 0.55, blue: 0.95).opacity(0.2),
        Color(red: 0.55, green: 0.3, blue: 0.85).opacity(0.18),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(colors.enumerated()), id: \.offset) { i, color in
                    Circle()
                        .stroke(color, lineWidth: 12)
                        .frame(width: geo.size.width * 0.9 + CGFloat(i) * 24, height: geo.size.width * 0.9 + CGFloat(i) * 24)
                        .offset(y: -geo.size.width * 0.25)
                }
            }
            .frame(maxWidth: .infinity)
        }
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
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.6, green: 0.88, blue: 0.5), Color(red: 0.5, green: 0.82, blue: 0.4)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: geo.size.width * 1.6, height: 300)
                    .position(x: geo.size.width * 0.15, y: geo.size.height + 80)

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.5, green: 0.85, blue: 0.4), Color(red: 0.4, green: 0.75, blue: 0.35)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: geo.size.width * 1.6, height: 260)
                    .position(x: geo.size.width * 0.9, y: geo.size.height + 70)

                HStack(spacing: 80) {
                    Text("🌳").font(.system(size: 40)).opacity(0.5)
                    Text("🌻").font(.system(size: 28)).opacity(0.5)
                    Text("🌳").font(.system(size: 36)).opacity(0.4)
                    Text("🌷").font(.system(size: 26)).opacity(0.5)
                    Text("🌲").font(.system(size: 42)).opacity(0.45)
                }
                .position(x: geo.size.width * 0.5, y: geo.size.height - 30)
            }
        }
    }
}

#Preview {
    HomeView()
}
