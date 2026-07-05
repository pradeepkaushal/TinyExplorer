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
    static let spelling = GameTheme(
        key: "spelling",
        accent: Color(red: 0.35, green: 0.40, blue: 0.90),
        gradientTop: Color(red: 0.89, green: 0.90, blue: 1.0),
        gradientBottom: Color(red: 0.95, green: 0.92, blue: 1.0),
        floaters: ["✏️", "🔤", "🌟"],
        mascot: "🐝"
    )
    static let listen = GameTheme(
        key: "listen",
        accent: Color(red: 0.93, green: 0.45, blue: 0.30),
        gradientTop: Color(red: 1.0, green: 0.91, blue: 0.86),
        gradientBottom: Color(red: 1.0, green: 0.95, blue: 0.88),
        floaters: ["🔍", "👀", "✨"],
        mascot: "🦜"
    )
    static let clock = GameTheme(
        key: "clock",
        accent: Color(red: 0.30, green: 0.52, blue: 0.75),
        gradientTop: Color(red: 0.87, green: 0.93, blue: 1.0),
        gradientBottom: Color(red: 0.92, green: 0.96, blue: 1.0),
        floaters: ["⏰", "🕐", "✨"],
        mascot: "🐓"
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
                    .font(.system(size: 21, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.22, green: 0.27, blue: 0.42))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.white)
                            .shadow(color: theme.accent.opacity(0.2), radius: 8, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                LinearGradient(
                                    colors: [theme.accent.opacity(0.4), theme.accent.opacity(0.15)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
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
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(selection == item.value ? .white : accent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(
                                selection == item.value
                                    ? LinearGradient(colors: [accent, accent.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
                            )
                        )
                        .shadow(color: selection == item.value ? accent.opacity(0.4) : .clear, radius: 4, y: 2)
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.95))
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.white.opacity(0.88))
                .shadow(color: accent.opacity(0.15), radius: 6, y: 3)
        )
        .overlay(
            Capsule()
                .stroke(accent.opacity(0.15), lineWidth: 1.5)
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
    @Published private(set) var spent: Int

    private let defaultsKey = "TinyExplorers.starBank"
    private let spentKey = "TinyExplorers.starsSpent"

    private init() {
        stars = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: Int] ?? [:]
        spent = UserDefaults.standard.integer(forKey: spentKey)
    }

    /// Lifetime stars earned; per-game counts on cards always keep growing.
    var total: Int { stars.values.reduce(0, +) }

    /// Stars left to spend in the sticker book.
    var available: Int { max(0, total - spent) }

    func count(for key: String) -> Int { stars[key] ?? 0 }

    func award(_ amount: Int = 1, to key: String) {
        stars[key, default: 0] += amount
        UserDefaults.standard.set(stars, forKey: defaultsKey)
    }

    /// Deducts from the spendable balance; returns false if there aren't enough.
    func spend(_ amount: Int) -> Bool {
        guard available >= amount else { return false }
        spent += amount
        UserDefaults.standard.set(spent, forKey: spentKey)
        return true
    }
}

/// Mastery medals: game cards earn bronze/silver/gold as stars accumulate,
/// giving kids a reason to come back to games they already "finished".
enum StarBadge {
    static func medal(for stars: Int) -> String? {
        switch stars {
        case 50...: return "🥇"
        case 25..<50: return "🥈"
        case 10..<25: return "🥉"
        default: return nil
        }
    }

    /// Stars still needed for the next medal, for "almost there!" hints.
    static func nextGoal(after stars: Int) -> Int? {
        for goal in [10, 25, 50] where stars < goal { return goal }
        return nil
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

// MARK: - Level system

enum LevelSystem {
    static let xpPerLevel: [Int] = [
        0, 10, 25, 45, 70, 100, 140, 185, 240, 300,
        370, 450, 540, 640, 750, 880, 1020, 1180, 1360, 1560
    ]

    static func level(for totalStars: Int) -> Int {
        for (i, threshold) in xpPerLevel.enumerated().reversed() {
            if totalStars >= threshold { return i + 1 }
        }
        return 1
    }

    static func xpForCurrentLevel(_ totalStars: Int) -> Int {
        let lvl = level(for: totalStars)
        let base = lvl > 0 && lvl <= xpPerLevel.count ? xpPerLevel[lvl - 1] : 0
        return totalStars - base
    }

    static func xpNeededForCurrentLevel(_ totalStars: Int) -> Int {
        let lvl = level(for: totalStars)
        if lvl >= xpPerLevel.count { return 100 }
        return xpPerLevel[lvl] - xpPerLevel[lvl - 1]
    }

    static func progress(for totalStars: Int) -> Double {
        let needed = xpNeededForCurrentLevel(totalStars)
        guard needed > 0 else { return 1.0 }
        return min(1.0, Double(xpForCurrentLevel(totalStars)) / Double(needed))
    }

    static func title(for level: Int) -> String {
        switch level {
        case 1: return "Tiny Explorer"
        case 2: return "Curious Cub"
        case 3: return "Star Seeker"
        case 4: return "Puzzle Pro"
        case 5: return "Brain Builder"
        case 6: return "Math Wizard"
        case 7: return "Word Master"
        case 8: return "Super Scholar"
        case 9: return "Genius Junior"
        case 10...: return "Legend!"
        default: return "Tiny Explorer"
        }
    }
}

// MARK: - XP Progress bar

struct XPProgressBar: View {
    let progress: Double
    var height: CGFloat = 14
    var showLabel: Bool = true
    var accent: Color = Color(red: 0.35, green: 0.75, blue: 0.35)

    @State private var animatedProgress: Double = 0
    @State private var shimmer = false

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.08))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accent, accent.opacity(0.8), Color(red: 1.0, green: 0.85, blue: 0.3)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress)
                        .overlay(
                            GeometryReader { g in
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.5), .clear],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .frame(width: g.size.width)
                            }
                        )
                        .overlay(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.6), .clear],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: 40)
                                .offset(x: shimmer ? geo.size.width * animatedProgress - 40 : -40)
                                .mask(Capsule().frame(width: geo.size.width * animatedProgress))
                        )
                }
            }
            .frame(height: height)
            .shadow(color: accent.opacity(0.4), radius: 4, y: 2)

            if showLabel {
                Text("\(Int(progress * 100))% to next level")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Level badge

struct LevelBadge: View {
    let level: Int
    var size: CGFloat = 64

    @State private var pulse = false

    private var ringColor: Color {
        switch level {
        case 1...3: return Color(red: 0.55, green: 0.75, blue: 0.35)
        case 4...6: return Color(red: 0.3, green: 0.6, blue: 0.95)
        case 7...9: return Color(red: 0.85, green: 0.55, blue: 0.1)
        default: return Color(red: 0.9, green: 0.3, blue: 0.5)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [ringColor.opacity(0.3), ringColor.opacity(0.1)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [ringColor, ringColor.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 4
                )
                .frame(width: size - 4, height: size - 4)
                .scaleEffect(pulse ? 1.08 : 1.0)
                .opacity(pulse ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

            VStack(spacing: 0) {
                Text("LVL")
                    .font(.system(size: size * 0.16, weight: .bold, design: .rounded))
                    .foregroundColor(ringColor.opacity(0.8))
                Text("\(level)")
                    .font(.system(size: size * 0.38, weight: .heavy, design: .rounded))
                    .foregroundColor(ringColor)
            }
        }
        .shadow(color: ringColor.opacity(0.4), radius: 8, y: 3)
        .onAppear { pulse = true }
    }
}

// MARK: - Glow modifier

struct GlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 12
    var intensity: Double = 0.5
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity * (pulse ? 0.7 : 1.0)), radius: radius * (pulse ? 1.2 : 1.0), y: radius * 0.4)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

extension View {
    func glow(_ color: Color, radius: CGFloat = 12, intensity: Double = 0.5) -> some View {
        modifier(GlowModifier(color: color, radius: radius, intensity: intensity))
    }
}

// MARK: - Shimmer modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.4)
                    .offset(x: phase * geo.size.width * 1.4 - geo.size.width * 0.2)
                    .mask(content)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false).delay(1.0)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Enhanced star counter

struct StarCounterChipEnhanced: View {
    let count: Int
    var compact = false

    @State private var bounce = false

    var body: some View {
        HStack(spacing: 5) {
            Text("⭐")
                .font(.system(size: compact ? 16 : 22))
                .scaleEffect(bounce ? 1.2 : 1.0)
            Text("\(count)")
                .font(.system(size: compact ? 17 : 24, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.6, blue: 0.0), Color(red: 0.95, green: 0.75, blue: 0.1)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
        .padding(.horizontal, compact ? 12 : 18)
        .padding(.vertical, compact ? 6 : 10)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.97, blue: 0.85), .white],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: Color(red: 0.9, green: 0.7, blue: 0.1).opacity(0.35), radius: 6, y: 3)
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.9, green: 0.7, blue: 0.2).opacity(0.4), lineWidth: 2)
        )
        .onChange(of: count) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { bounce = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { bounce = false }
            }
        }
    }
}

// MARK: - Enhanced streak badge

struct StreakBadgeEnhanced: View {
    let streak: Int

    @State private var flamePulse = false

    var body: some View {
        if streak >= 2 {
            HStack(spacing: 5) {
                Text("🔥")
                    .font(.system(size: 22))
                    .scaleEffect(flamePulse ? 1.25 : 1.0)
                    .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: flamePulse)
                Text("x\(streak)")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.95, green: 0.25, blue: 0.15)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: .orange.opacity(0.6), radius: flamePulse ? 10 : 6, y: 3)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
            .transition(.scale.combined(with: .opacity))
            .onAppear { flamePulse = true }
        }
    }
}

// MARK: - Enhanced celebration

struct CelebrationOverlayEnhanced: View {
    let message: String
    var emoji: String = "🎉"

    @State private var scale = false

    var body: some View {
        ZStack {
            ConfettiView()

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 80))
                    .scaleEffect(scale ? 1.15 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true), value: scale)

                Text(message)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.5, blue: 0.2), Color(red: 0.95, green: 0.3, blue: 0.5), Color(red: 0.6, green: 0.3, blue: 0.9)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .shadow(color: .white.opacity(0.8), radius: 2)

                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { i in
                        Text("⭐")
                            .font(.system(size: 36))
                            .scaleEffect(scale ? 1.1 : 0.95)
                            .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(Double(i) * 0.1).repeatForever(autoreverses: true), value: scale)
                    }
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
            )
            .scaleEffect(scale ? 1.0 : 0.8)
            .opacity(scale ? 1.0 : 0.0)
        }
        .zIndex(10)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { scale = true }
        }
    }
}

// MARK: - Kid-friendly navigation bar

/// Replaces the plain system navigation bar with a colorful gradient bar
/// and a big, chunky back button that small fingers can easily hit.
/// Apply via `.kidNavigation(title:theme:)` on any pushed screen.
struct KidNavigationModifier: ViewModifier {
    let title: String
    let theme: GameTheme
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Haptics.tap()
                        SoundEngine.shared.play(.tap)
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Back")
                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.7), lineWidth: 2.5)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    colors: [theme.accent, theme.accent.opacity(0.75)],
                    startPoint: .top, endPoint: .bottom
                ),
                for: .navigationBar
            )
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    /// Styled navigation bar with a themed gradient background and a chunky
    /// white back button. Replaces `.navigationTitle` + `.navigationBarTitleDisplayMode`.
    func kidNavigation(title: String, theme: GameTheme) -> some View {
        modifier(KidNavigationModifier(title: title, theme: theme))
    }
}

// MARK: - In-game progression system

/// Lightweight per-session level tracker. Each game owns one via `@State`.
/// Call `registerCorrect()` on every right answer; the level auto-advances
/// and `showLevelUp` flips to true so the view can present a celebration.
struct GameProgression {
    var level: Int = 1
    var correctInLevel: Int = 0
    var totalCorrect: Int = 0
    var showLevelUp: Bool = false

    /// Correct answers needed to advance from the current level.
    var neededForNextLevel: Int { 3 + level } // L1→4, L2→5, L3→6 …

    /// 0.0–1.0 progress toward the next level.
    var progress: Double {
        guard neededForNextLevel > 0 else { return 1.0 }
        return min(1.0, Double(correctInLevel) / Double(neededForNextLevel))
    }

    /// A rotating tip for the current level. Games pass their own `hints`.
    func currentHint(from hints: [String]) -> String {
        guard !hints.isEmpty else { return "" }
        let idx = (level - 1) % hints.count
        return hints[idx]
    }

    /// Register a correct answer; levels up when the threshold is reached.
    mutating func registerCorrect() {
        correctInLevel += 1
        totalCorrect += 1
        if correctInLevel >= neededForNextLevel {
            level += 1
            correctInLevel = 0
            showLevelUp = true
        }
    }

    /// Clear the level-up flag after the celebration has been shown.
    mutating func clearLevelUp() { showLevelUp = false }
}

/// Compact level + progress + hint header shown at the top of every game.
/// It tells the kid exactly where they are and what to do next.
struct GameProgressHeader: View {
    let level: Int
    let correctInLevel: Int
    let neededForNextLevel: Int
    let theme: GameTheme
    let hint: String

    @State private var bob = false

    var body: some View {
        HStack(spacing: 12) {
            // Level badge — pulsing circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, theme.accent.opacity(0.7)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 46, height: 46)
                    .shadow(color: theme.accent.opacity(0.4), radius: 5, y: 3)

                Circle()
                    .stroke(.white.opacity(0.8), lineWidth: 2.5)
                    .frame(width: 42, height: 42)

                VStack(spacing: 0) {
                    Text("LVL")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(level)")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(bob ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bob)

            // Progress bar + "X to level up"
            VStack(alignment: .leading, spacing: 3) {
                XPProgressBar(
                    progress: neededForNextLevel > 0
                        ? min(1.0, Double(correctInLevel) / Double(neededForNextLevel))
                        : 1.0,
                    height: 12,
                    showLabel: false,
                    accent: theme.accent
                )

                Text("\(correctInLevel)/\(neededForNextLevel) to level up!")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(theme.accent.opacity(0.85))
            }

            // Hint bubble — guides the kid
            if !hint.isEmpty {
                HStack(spacing: 5) {
                    Text("💡")
                        .font(.system(size: 16))
                    Text(hint)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.97, blue: 0.82), .white.opacity(0.9)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.95, green: 0.8, blue: 0.25).opacity(0.5), lineWidth: 2)
                )
                .frame(maxWidth: 280, alignment: .leading)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.88))
                .shadow(color: theme.accent.opacity(0.15), radius: 5, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(theme.accent.opacity(0.2), lineWidth: 2)
        )
        .onAppear { bob = true }
    }
}

/// Full-screen celebration shown when the kid levels up.
struct LevelUpOverlay: View {
    let level: Int
    let theme: GameTheme

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🆙")
                    .font(.system(size: 72))
                    .scaleEffect(appear ? 1.2 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true), value: appear)

                Text("Level \(level)!")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.accent, Color(red: 0.95, green: 0.5, blue: 0.2)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                Text(levelPraise)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in Text("⭐").font(.system(size: 32)) }
                }
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 36)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [theme.accent, Color(red: 0.95, green: 0.7, blue: 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
            )
            .scaleEffect(appear ? 1.0 : 0.7)
        }
        .zIndex(20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appear = true }
            Haptics.success()
            SoundEngine.shared.play(.win)
            SpeechHelper.cheer("Level \(level)! \(levelPraise)")
        }
    }

    private var levelPraise: String {
        let praises = [
            "You're getting smarter!",
            "Amazing progress!",
            "You're a quick learner!",
            "Keep it up, superstar!",
            "Wow, you're so good at this!",
        ]
        return praises[(level - 2) % praises.count]
    }
}

// MARK: - Game card progress indicator

struct GameProgressRing: View {
    let stars: Int
    var size: CGFloat = 32

    private var progress: Double {
        min(1.0, Double(stars) / 50.0)
    }

    private var ringColor: Color {
        if stars >= 50 { return .yellow }
        if stars >= 25 { return .gray }
        if stars >= 10 { return Color(red: 0.8, green: 0.5, blue: 0.2) }
        return Color.gray.opacity(0.3)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 3)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            if let medal = StarBadge.medal(for: stars) {
                Text(medal)
                    .font(.system(size: size * 0.55))
            } else {
                Text("\(stars)")
                    .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                    .foregroundColor(ringColor)
            }
        }
    }
}
