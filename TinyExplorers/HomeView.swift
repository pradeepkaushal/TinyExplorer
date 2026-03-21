import SwiftUI

struct GameItem: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let color: Color
    let destination: AnyView
}

struct HomeView: View {
    let games: [GameItem] = [
        GameItem(title: "ABC Letters", emoji: "🔤", color: .red, destination: AnyView(ABCGameView())),
        GameItem(title: "123 Numbers", emoji: "🔢", color: .blue, destination: AnyView(NumberGameView())),
        GameItem(title: "Math Fun", emoji: "➕", color: .teal, destination: AnyView(MathGameView())),
        GameItem(title: "Colors & Shapes", emoji: "🟣", color: .purple, destination: AnyView(ShapesGameView())),
        GameItem(title: "Animal Friends", emoji: "🐾", color: .green, destination: AnyView(AnimalGameView())),
        GameItem(title: "Social Skills", emoji: "🤝", color: .cyan, destination: AnyView(SocialGameView())),
        GameItem(title: "Memory Match", emoji: "🧠", color: .orange, destination: AnyView(MemoryGameView())),
        GameItem(title: "Puzzle Time", emoji: "🧩", color: .pink, destination: AnyView(PuzzleGameView())),
        GameItem(title: "Drawing Fun", emoji: "🎨", color: .mint, destination: AnyView(DrawingGameView())),
        GameItem(title: "Music Maker", emoji: "🎵", color: .indigo, destination: AnyView(MusicGameView())),
        GameItem(title: "Pattern Fun", emoji: "🔮", color: Color(red: 0.6, green: 0.4, blue: 0.8), destination: AnyView(PatternGameView())),
        GameItem(title: "Odd One Out", emoji: "🔍", color: Color(red: 0.9, green: 0.5, blue: 0.3), destination: AnyView(OddOneOutGameView())),
        GameItem(title: "Counting", emoji: "🔢", color: Color(red: 0.2, green: 0.7, blue: 0.5), destination: AnyView(CountingGameView())),
        GameItem(title: "Emotions", emoji: "🎭", color: Color(red: 0.95, green: 0.5, blue: 0.6), destination: AnyView(EmotionsGameView())),
    ]

    @State private var animateTitle = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.83, blue: 1.0), Color(red: 0.93, green: 0.95, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Floating background decorations
                FloatingBubblesView()
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text("🌟 Tiny Explorers 🌟")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .scaleEffect(animateTitle ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateTitle)

                            Text("Pick a game and start learning!")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)

                        // Game grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(games) { game in
                                NavigationLink(destination: game.destination) {
                                    GameCard(game: game)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .onAppear {
                animateTitle = true
            }
        }
    }
}

struct GameCard: View {
    let game: GameItem

    var body: some View {
        VStack(spacing: 20) {
            Text(game.emoji)
                .font(.system(size: 90))
                .shadow(radius: 4)

            Text(game.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [game.color, game.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: game.color.opacity(0.4), radius: 8, y: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct FloatingBubblesView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(bubbleColor(for: i).opacity(0.15))
                    .frame(width: CGFloat.random(in: 40...120))
                    .offset(
                        x: CGFloat.random(in: -300...300),
                        y: animate ? CGFloat.random(in: -400...400) : CGFloat.random(in: -200...200)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.5),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }

    func bubbleColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]
        return colors[index % colors.count]
    }
}

#Preview {
    HomeView()
}
