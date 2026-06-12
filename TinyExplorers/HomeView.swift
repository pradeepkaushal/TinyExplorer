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
            GameItem(title: "123 Numbers", lesson: "Count to 20", emoji: "🔢", theme: .numbers, destination: AnyView(NumberGameView())),
            GameItem(title: "Math Fun", lesson: "Add & subtract", emoji: "➕", theme: .math, destination: AnyView(MathGameView())),
            GameItem(title: "Counting", lesson: "Count & compare", emoji: "🧮", theme: .counting, destination: AnyView(CountingGameView())),
            GameItem(title: "Colors & Shapes", lesson: "Shapes all around", emoji: "🟣", theme: .shapes, destination: AnyView(ShapesGameView())),
        ]),
        GameSection(title: "Brain Boosters", emoji: "🧠", items: [
            GameItem(title: "Memory Match", lesson: "Remember pairs", emoji: "🧠", theme: .memory, destination: AnyView(MemoryGameView())),
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
    @State private var appeared = false

    let columns = [GridItem(.adaptive(minimum: 220, maximum: 320), spacing: 18)]

    var body: some View {
        NavigationStack {
            ZStack {
                SkyScene()

                ScrollView {
                    VStack(spacing: 28) {
                        header

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
            }
            .onAppear { appeared = true }
        }
    }

    var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                WavingMascot()
                WavyTitle(text: "Tiny Explorers")
            }

            Text("Pick a game, learn something new, earn stars!")
                .font(.system(size: 21, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.4, blue: 0.55))

            StarCounterChip(count: starBank.total)
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
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

            SunView()

            DriftingClouds()

            RollingHills()

            FloatingEmojiLayer(emoji: ["🎈", "🦋", "⭐"])
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct SunView: View {
    @State private var spin = false

    var body: some View {
        GeometryReader { geo in
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
                Text("😊")
                    .font(.system(size: 34))
            }
            .position(x: geo.size.width - 110, y: 100)
        }
        .onAppear { spin = true }
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
