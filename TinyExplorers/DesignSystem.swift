import SwiftUI
import UIKit

// MARK: - Game themes

/// A consistent visual identity for each game: soft gradient + saturated accent,
/// an illustrated scenery strip (asset "scene-<key>") and floating emoji.
struct GameTheme {
    let key: String
    let accent: Color
    let gradientTop: Color
    let gradientBottom: Color
    var floaters: [String] = []
    var mascot: String = "🦊"

    static let abc = GameTheme(
        key: "abc",
        accent: Color(red: 0.94, green: 0.35, blue: 0.33),
        gradientTop: Color(red: 1.0, green: 0.88, blue: 0.86),
        gradientBottom: Color(red: 1.0, green: 0.96, blue: 0.88),
        floaters: ["✏️", "📚", "🌟"],
        mascot: "🦉"
    )
    static let numbers = GameTheme(
        key: "numbers",
        accent: Color(red: 0.25, green: 0.48, blue: 0.95),
        gradientTop: Color(red: 0.86, green: 0.91, blue: 1.0),
        gradientBottom: Color(red: 0.93, green: 0.89, blue: 1.0),
        floaters: ["🎈", "⭐", "🍎"],
        mascot: "🐰"
    )
    static let math = GameTheme(
        key: "math",
        accent: Color(red: 0.0, green: 0.62, blue: 0.62),
        gradientTop: Color(red: 0.84, green: 0.97, blue: 0.95),
        gradientBottom: Color(red: 0.90, green: 0.98, blue: 0.88),
        floaters: ["🧮", "➕", "⭐"],
        mascot: "🦊"
    )
    static let shapes = GameTheme(
        key: "shapes",
        accent: Color(red: 0.58, green: 0.34, blue: 0.86),
        gradientTop: Color(red: 0.93, green: 0.88, blue: 1.0),
        gradientBottom: Color(red: 0.98, green: 0.91, blue: 0.98),
        floaters: ["🔷", "🟡", "🔺"],
        mascot: "🐱"
    )
    static let animals = GameTheme(
        key: "animals",
        accent: Color(red: 0.22, green: 0.66, blue: 0.34),
        gradientTop: Color(red: 0.87, green: 0.97, blue: 0.86),
        gradientBottom: Color(red: 0.95, green: 0.99, blue: 0.87),
        floaters: ["🦋", "🍃", "🐾"],
        mascot: "🐵"
    )
    static let social = GameTheme(
        key: "social",
        accent: Color(red: 0.0, green: 0.6, blue: 0.78),
        gradientTop: Color(red: 0.85, green: 0.95, blue: 1.0),
        gradientBottom: Color(red: 0.88, green: 0.99, blue: 0.97),
        floaters: ["💬", "🤝", "💛"],
        mascot: "🐻"
    )
    static let memory = GameTheme(
        key: "memory",
        accent: Color(red: 0.96, green: 0.55, blue: 0.14),
        gradientTop: Color(red: 1.0, green: 0.93, blue: 0.83),
        gradientBottom: Color(red: 1.0, green: 0.97, blue: 0.88),
        floaters: ["✨", "🧠", "🌟"],
        mascot: "🐘"
    )
    static let puzzle = GameTheme(
        key: "puzzle",
        accent: Color(red: 0.93, green: 0.38, blue: 0.62),
        gradientTop: Color(red: 1.0, green: 0.89, blue: 0.94),
        gradientBottom: Color(red: 0.98, green: 0.92, blue: 1.0),
        floaters: ["🧩", "✨", "🌟"],
        mascot: "🐼"
    )
    static let drawing = GameTheme(
        key: "drawing",
        accent: Color(red: 0.0, green: 0.66, blue: 0.55),
        gradientTop: Color(red: 0.87, green: 0.98, blue: 0.94),
        gradientBottom: Color(red: 0.93, green: 0.97, blue: 1.0),
        floaters: ["🖍️", "🎨", "✨"],
        mascot: "🦄"
    )
    static let music = GameTheme(
        key: "music",
        accent: Color(red: 0.42, green: 0.40, blue: 0.91),
        gradientTop: Color(red: 0.89, green: 0.89, blue: 1.0),
        gradientBottom: Color(red: 0.96, green: 0.90, blue: 1.0),
        floaters: ["🎵", "🎶", "🎼"],
        mascot: "🐸"
    )
    static let pattern = GameTheme(
        key: "pattern",
        accent: Color(red: 0.60, green: 0.40, blue: 0.80),
        gradientTop: Color(red: 0.92, green: 0.88, blue: 0.99),
        gradientBottom: Color(red: 0.88, green: 0.93, blue: 1.0),
        floaters: ["🔮", "✨", "🌀"],
        mascot: "🦚"
    )
    static let oddOneOut = GameTheme(
        key: "oddOneOut",
        accent: Color(red: 0.90, green: 0.45, blue: 0.20),
        gradientTop: Color(red: 1.0, green: 0.92, blue: 0.85),
        gradientBottom: Color(red: 1.0, green: 0.96, blue: 0.90),
        floaters: ["🔍", "❓", "✨"],
        mascot: "🐹"
    )
    static let counting = GameTheme(
        key: "counting",
        accent: Color(red: 0.13, green: 0.62, blue: 0.45),
        gradientTop: Color(red: 0.86, green: 0.97, blue: 0.91),
        gradientBottom: Color(red: 0.93, green: 0.99, blue: 0.89),
        floaters: ["🎈", "🍎", "⭐"],
        mascot: "🐢"
    )
    static let emotions = GameTheme(
        key: "emotions",
        accent: Color(red: 0.93, green: 0.42, blue: 0.54),
        gradientTop: Color(red: 1.0, green: 0.90, blue: 0.92),
        gradientBottom: Color(red: 1.0, green: 0.95, blue: 0.88),
        floaters: ["💖", "😊", "✨"],
        mascot: "🐥"
    )
}

// MARK: - Playful animated background

/// Shared game background: soft themed gradient, an illustrated scenery
/// strip along the bottom, drifting bubbles, sparkles, and floating themed
/// emoji near the edges. Purely decorative, never intercepts touches.
struct PlayfulBackground: View {
    let theme: GameTheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.gradientTop, theme.gradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            SceneryStrip(key: theme.key)
            DriftingShapes(accent: theme.accent)
            FloatingEmojiLayer(emoji: theme.floaters)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// Illustrated flat-style landscape pinned to the bottom edge.
private struct SceneryStrip: View {
    let key: String

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Image("scene-\(key)")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.width * 520.0 / 1600.0)
                    .clipped()
            }
        }
    }
}

/// A few themed emoji bobbing gently near the screen edges, leaving the
/// center clear for game content.
struct FloatingEmojiLayer: View {
    let emoji: [String]

    private func frac(_ x: Double) -> Double { x - x.rounded(.down) }

    var body: some View {
        if !emoji.isEmpty {
            GeometryReader { geo in
                TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    ZStack {
                        ForEach(0..<6, id: \.self) { i in
                            let seed = Double(i) * 3.7 + 1
                            let onLeft = i % 2 == 0
                            let xFrac = onLeft ? 0.04 + 0.10 * frac(seed * 0.7) : 0.84 + 0.10 * frac(seed * 0.7)
                            let yFrac = 0.10 + 0.55 * frac(seed * 0.43)
                            Text(emoji[i % emoji.count])
                                .font(.system(size: 30 + CGFloat(frac(seed) * 22)))
                                .opacity(0.55)
                                .rotationEffect(.degrees(sin(t * 0.5 + seed) * 10))
                                .position(
                                    x: geo.size.width * xFrac + sin(t * (0.3 + frac(seed) * 0.2) + seed) * 12,
                                    y: geo.size.height * yFrac + cos(t * 0.4 + seed * 2) * 18
                                )
                        }
                    }
                }
            }
        }
    }
}

private struct DriftingShapes: View {
    let accent: Color

    // Deterministic pseudo-random in [0, 1) so layout is stable across redraws
    private func frac(_ x: Double) -> Double { x - x.rounded(.down) }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                // Soft drifting bubbles
                for i in 0..<12 {
                    let seed = Double(i) + 1
                    let baseX = size.width * frac(seed * 0.61803)
                    let baseY = size.height * frac(seed * 0.38196 + 0.17)
                    let radius = 16 + 38 * frac(seed * 0.7548)
                    let x = baseX + sin(t * (0.18 + frac(seed * 0.31) * 0.25) + seed) * 34
                    let y = baseY + cos(t * (0.14 + frac(seed * 0.17) * 0.22) + seed * 2) * 26
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Ellipse().path(in: rect), with: .color(accent.opacity(0.07)))
                }
                // Twinkling sparkles
                for i in 0..<8 {
                    let seed = Double(i) * 7.3 + 2
                    let x = size.width * frac(seed * 0.523)
                    let y = size.height * frac(seed * 0.311 + 0.05)
                    let twinkle = (sin(t * (0.8 + frac(seed) * 0.8) + seed) + 1) / 2
                    let r = 2.0 + twinkle * 2.5
                    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                    context.fill(
                        Ellipse().path(in: rect),
                        with: .color(.white.opacity(0.25 + twinkle * 0.45))
                    )
                }
            }
        }
    }
}

// MARK: - Mascot speech bubble

/// The game's host: a gently bobbing mascot beside a speech bubble.
/// Use it wherever a bare instruction Text used to float.
struct MascotBubble: View {
    let theme: GameTheme
    let text: String
    var mascotSize: CGFloat = 64

    @State private var bob = false

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Text(theme.mascot)
                .font(.system(size: mascotSize))
                .rotationEffect(.degrees(bob ? 6 : -6), anchor: .bottom)
                .offset(y: bob ? -3 : 3)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: bob)

            HStack(spacing: 0) {
                BubbleTail()
                    .fill(.white)
                    .frame(width: 14, height: 22)
                    .offset(x: 1)
                Text(text)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: theme.accent.opacity(0.25), radius: 6, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.accent.opacity(0.3), lineWidth: 2)
                    )
            }
        }
        .onAppear { bob = true }
    }
}

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Themed mode picker

/// Capsule-style replacement for the gray system segmented picker.
struct ThemedSegmentedPicker<V: Hashable>: View {
    let items: [(title: String, value: V)]
    @Binding var selection: V
    let accent: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.value) { item in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = item.value
                    }
                } label: {
                    Text(item.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(selection == item.value ? .white : accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(selection == item.value ? accent : .clear)
                        )
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.95))
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.white.opacity(0.85))
                .shadow(color: accent.opacity(0.2), radius: 4, y: 2)
        )
    }
}

// MARK: - Pop-in entrance

/// Springy scale+fade entrance. Stagger grids with `delay: Double(index) * 0.05`.
struct PopIn: ViewModifier {
    var delay: Double = 0
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown ? 1 : 0.6)
            .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(delay), value: shown)
            .onAppear { shown = true }
    }
}

extension View {
    func popIn(delay: Double = 0) -> some View {
        modifier(PopIn(delay: delay))
    }
}

// MARK: - Squishy button

/// Chunky, toy-like press feedback for every tappable thing in the app.
struct SquishyButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Haptics

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - Star rewards

/// Persistent star bank: kids earn stars in every game; totals show on the home screen.
final class StarBank: ObservableObject {
    static let shared = StarBank()

    @Published private(set) var stars: [String: Int]

    private let defaultsKey = "TinyExplorers.starBank"

    private init() {
        stars = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: Int] ?? [:]
    }

    var total: Int { stars.values.reduce(0, +) }

    func count(for key: String) -> Int { stars[key] ?? 0 }

    func award(_ amount: Int = 1, to key: String) {
        stars[key, default: 0] += amount
        UserDefaults.standard.set(stars, forKey: defaultsKey)
    }
}

/// Small capsule showing a star count, e.g. on game cards or in game headers.
struct StarCounterChip: View {
    let count: Int
    var compact = false

    var body: some View {
        HStack(spacing: 4) {
            Text("⭐")
                .font(.system(size: compact ? 14 : 18))
            Text("\(count)")
                .font(.system(size: compact ? 15 : 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.72, green: 0.5, blue: 0.0))
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 4 : 7)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
        )
    }
}

/// Combo streak badge for quiz games: shows from 2 consecutive correct answers.
struct StreakBadge: View {
    let streak: Int

    var body: some View {
        if streak >= 2 {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 18))
                Text("x\(streak)")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.2)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 5, y: 2)
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Celebration

enum Encouragement {
    static let phrases = [
        "Great job!", "Amazing!", "You did it!", "Super star!",
        "Wow, brilliant!", "Fantastic!", "Way to go!", "You're awesome!",
    ]
    static func random() -> String { phrases.randomElement() ?? "Great job!" }
}

/// Big friendly celebration card with falling confetti behind it.
/// Show it in a ZStack with a scale/opacity transition.
struct CelebrationOverlay: View {
    let message: String
    var emoji: String = "🎉"

    var body: some View {
        ZStack {
            ConfettiView()
            VStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 64))
                Text(message)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                    )
                    .multilineTextAlignment(.center)
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Text("⭐").font(.system(size: 30))
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
            )
        }
        .zIndex(10)
    }
}

/// Falling emoji + colored shape confetti. Plays once on appear.
struct ConfettiView: View {
    @State private var animate = false

    private let pieces = ["🎉", "⭐", "🌟", "✨", "🎊", "💛", "💙", "💜"]
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .mint]

    var body: some View {
        ZStack {
            ForEach(0..<28, id: \.self) { i in
                Group {
                    if i % 2 == 0 {
                        Text(pieces[i % pieces.count])
                            .font(.system(size: CGFloat(18 + (i * 7) % 24)))
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colors[i % colors.count])
                            .frame(width: 10, height: 16)
                    }
                }
                .rotationEffect(.degrees(animate ? Double((i * 73) % 360) + 240 : Double((i * 73) % 360)))
                .offset(
                    x: CGFloat((i * 53) % 480) - 240,
                    y: animate ? CGFloat(260 + (i * 37) % 320) : -120
                )
                .opacity(animate ? 0 : 1)
                .animation(
                    .easeIn(duration: 1.1 + Double((i * 13) % 10) / 10.0)
                        .delay(Double(i) * 0.04),
                    value: animate
                )
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
