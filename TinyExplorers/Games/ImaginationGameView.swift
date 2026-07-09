import SwiftUI

// MARK: - Story Land: the imagination game

/// A magical backdrop the kid can build a scene on. Later worlds unlock as
/// their global star level grows — the first progress-gated content in the
/// app, so leveling up visibly opens new places to imagine in.
struct StoryBackdrop: Identifiable {
    let id: String
    let name: String
    let badge: String
    let unlockLevel: Int
    let skyTop: Color
    let skyBottom: Color
    let groundTop: Color
    let groundBottom: Color
    let decorations: [String]

    static let all: [StoryBackdrop] = [
        StoryBackdrop(
            id: "meadow", name: "Sunny Meadow", badge: "🌻", unlockLevel: 1,
            skyTop: Color(red: 0.55, green: 0.82, blue: 1.0),
            skyBottom: Color(red: 0.85, green: 0.95, blue: 1.0),
            groundTop: Color(red: 0.6, green: 0.88, blue: 0.5),
            groundBottom: Color(red: 0.45, green: 0.78, blue: 0.4),
            decorations: ["☀️", "☁️", "🌼"]
        ),
        StoryBackdrop(
            id: "ocean", name: "Deep Blue Sea", badge: "🌊", unlockLevel: 2,
            skyTop: Color(red: 0.45, green: 0.78, blue: 0.95),
            skyBottom: Color(red: 0.6, green: 0.88, blue: 1.0),
            groundTop: Color(red: 0.1, green: 0.55, blue: 0.85),
            groundBottom: Color(red: 0.05, green: 0.4, blue: 0.7),
            decorations: ["⛵", "🐚", "🫧"]
        ),
        StoryBackdrop(
            id: "space", name: "Starry Space", badge: "🚀", unlockLevel: 4,
            skyTop: Color(red: 0.12, green: 0.12, blue: 0.35),
            skyBottom: Color(red: 0.25, green: 0.2, blue: 0.5),
            groundTop: Color(red: 0.55, green: 0.55, blue: 0.65),
            groundBottom: Color(red: 0.4, green: 0.4, blue: 0.5),
            decorations: ["🌟", "🪐", "🌙"]
        ),
        StoryBackdrop(
            id: "castle", name: "Magic Castle", badge: "🏰", unlockLevel: 6,
            skyTop: Color(red: 0.7, green: 0.55, blue: 0.95),
            skyBottom: Color(red: 0.95, green: 0.8, blue: 0.95),
            groundTop: Color(red: 0.55, green: 0.75, blue: 0.55),
            groundBottom: Color(red: 0.4, green: 0.6, blue: 0.45),
            decorations: ["🏰", "🌈", "🦋"]
        ),
    ]
}

/// One sticker the kid has placed in the scene. `position` is in unit
/// space (0...1 fractions of the canvas) so the layout survives rotation
/// and canvas resizes; views convert to points at render time.
struct PlacedSticker: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    var position: CGPoint
}

private struct StickerChoice {
    let emoji: String
    let name: String
}

private struct StickerGroup {
    let title: String
    let badge: String
    let items: [StickerChoice]

    static let all: [StickerGroup] = [
        StickerGroup(title: "Friends", badge: "🐶", items: [
            StickerChoice(emoji: "🐶", name: "puppy"), StickerChoice(emoji: "🐱", name: "kitten"),
            StickerChoice(emoji: "🐰", name: "bunny"), StickerChoice(emoji: "🦄", name: "unicorn"),
            StickerChoice(emoji: "🦖", name: "dinosaur"), StickerChoice(emoji: "🤖", name: "robot"),
        ]),
        StickerGroup(title: "Nature", badge: "🌳", items: [
            StickerChoice(emoji: "🌳", name: "tree"), StickerChoice(emoji: "🌸", name: "flower"),
            StickerChoice(emoji: "🍄", name: "mushroom"), StickerChoice(emoji: "🌈", name: "rainbow"),
            StickerChoice(emoji: "🦋", name: "butterfly"), StickerChoice(emoji: "⭐", name: "star"),
        ]),
        StickerGroup(title: "Fun", badge: "🎈", items: [
            StickerChoice(emoji: "🎈", name: "balloon"), StickerChoice(emoji: "⚽", name: "ball"),
            StickerChoice(emoji: "🪁", name: "kite"), StickerChoice(emoji: "👑", name: "crown"),
            StickerChoice(emoji: "🎁", name: "present"), StickerChoice(emoji: "🥁", name: "drum"),
        ]),
        StickerGroup(title: "Yummy", badge: "🎂", items: [
            StickerChoice(emoji: "🍎", name: "apple"), StickerChoice(emoji: "🎂", name: "cake"),
            StickerChoice(emoji: "🍦", name: "ice cream"), StickerChoice(emoji: "🍪", name: "cookie"),
            StickerChoice(emoji: "🍭", name: "lollipop"), StickerChoice(emoji: "🧁", name: "cupcake"),
        ]),
    ]
}

struct ImaginationGameView: View {
    @ObservedObject private var starBank = StarBank.shared

    @State private var backdropIndex = 0
    @State private var placed: [PlacedSticker] = []
    @State private var groupIndex = 0
    @State private var wigglingID: UUID? = nil
    @State private var storyText: String? = nil
    @State private var storiesTold = 0
    @State private var celebrate = false
    @State private var wandPulse = false
    @State private var lockedWobble: String? = nil

    private let theme = GameTheme.imagine
    private let canvasCoordSpace = "storyCanvas"

    private var backdrop: StoryBackdrop { StoryBackdrop.all[backdropIndex] }
    private var globalLevel: Int { LevelSystem.level(for: starBank.total) }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            VStack(spacing: 12) {
                backdropPicker

                sceneCanvas
                    .padding(.horizontal, 24)

                if let storyText {
                    MascotBubble(theme: theme, text: storyText, mascotSize: 50)
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                }

                palette

                controls
            }
            .padding(.top, 6)
            .padding(.bottom, 14)

            if celebrate {
                ConfettiView().allowsHitTesting(false).zIndex(5)
            }
        }
        .kidNavigation(title: "Story Land", theme: theme)
        .onAppear {
            SpeechHelper.speak("Tap a sticker to build your story!")
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                wandPulse = true
            }
        }
        .onDisappear { SpeechHelper.stop() }
    }

    // MARK: Backdrop picker — worlds unlock with the global star level

    private var backdropPicker: some View {
        HStack(spacing: 14) {
            ForEach(Array(StoryBackdrop.all.enumerated()), id: \.element.id) { index, world in
                let unlocked = globalLevel >= world.unlockLevel
                Button {
                    if unlocked {
                        Haptics.tap()
                        SoundEngine.shared.play(.pop)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            backdropIndex = index
                            storyText = nil
                        }
                        SpeechHelper.speak(world.name)
                    } else {
                        Haptics.error()
                        SoundEngine.shared.play(.tap)
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.35)) {
                            lockedWobble = world.id
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            lockedWobble = nil
                        }
                    }
                } label: {
                    VStack(spacing: 3) {
                        ZStack {
                            Circle()
                                .fill(
                                    unlocked
                                        ? LinearGradient(colors: [world.skyTop, world.groundTop], startPoint: .top, endPoint: .bottom)
                                        : LinearGradient(colors: [Color(white: 0.85), Color(white: 0.75)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 58, height: 58)
                                .overlay(
                                    Circle().stroke(
                                        backdropIndex == index && unlocked ? theme.accent : .white.opacity(0.8),
                                        lineWidth: backdropIndex == index && unlocked ? 4 : 2.5
                                    )
                                )
                                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                            Text(unlocked ? world.badge : "🔒")
                                .font(.system(size: 28))
                        }
                        .rotationEffect(.degrees(lockedWobble == world.id ? 6 : 0))

                        // A visible goal: which level opens this world.
                        Text(unlocked ? world.name : "Level \(world.unlockLevel)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(unlocked ? theme.accent : .secondary)
                            .lineLimit(1)
                    }
                }
                .buttonStyle(SquishyButtonStyle(scale: 0.9))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(.white.opacity(0.8)))
    }

    // MARK: Scene canvas

    private var sceneCanvas: some View {
        GeometryReader { geo in
            ZStack {
                // Sky and ground
                LinearGradient(colors: [backdrop.skyTop, backdrop.skyBottom], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 0) {
                    Spacer()
                    Ellipse()
                        .fill(LinearGradient(colors: [backdrop.groundTop, backdrop.groundBottom], startPoint: .top, endPoint: .bottom))
                        .frame(width: geo.size.width * 1.5, height: geo.size.height * 0.5)
                        .offset(y: geo.size.height * 0.18)
                }

                // Ambient decorations
                ForEach(Array(backdrop.decorations.enumerated()), id: \.offset) { i, deco in
                    Text(deco)
                        .font(.system(size: 34))
                        .opacity(0.8)
                        .position(
                            x: geo.size.width * [0.12, 0.88, 0.72][i % 3],
                            y: geo.size.height * [0.15, 0.12, 0.3][i % 3]
                        )
                        .allowsHitTesting(false)
                }

                if placed.isEmpty {
                    Text("Tap stickers below\nto fill your world!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                        .allowsHitTesting(false)
                }

                // The kid's stickers: drag to move, tap to wiggle.
                ForEach(placed) { sticker in
                    Text(sticker.emoji)
                        .font(.system(size: 58))
                        .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                        .scaleEffect(wigglingID == sticker.id ? 1.25 : 1.0)
                        .rotationEffect(.degrees(wigglingID == sticker.id ? 10 : 0))
                        .position(
                            x: sticker.position.x * geo.size.width,
                            y: sticker.position.y * geo.size.height
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(canvasCoordSpace))
                                .onChanged { value in
                                    move(sticker, to: value.location, in: geo.size)
                                }
                                .onEnded { value in
                                    if value.translation.width.magnitude < 4,
                                       value.translation.height.magnitude < 4 {
                                        wiggle(sticker)
                                    }
                                }
                        )
                }
            }
            // Pin the ZStack to the visible canvas: the oversized ground
            // ellipse would otherwise inflate it and shove centered
            // children (like the empty-state hint) off to the right.
            .frame(width: geo.size.width, height: geo.size.height)
            .coordinateSpace(name: canvasCoordSpace)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 260, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(theme.accent.opacity(0.5), lineWidth: 3)
        )
        .shadow(color: theme.accent.opacity(0.3), radius: 10, y: 5)
    }

    // MARK: Sticker palette

    private var palette: some View {
        VStack(spacing: 8) {
            ThemedSegmentedPicker(
                items: StickerGroup.all.enumerated().map { (title: "\($0.element.badge) \($0.element.title)", value: $0.offset) },
                selection: $groupIndex,
                accent: theme.accent
            )
            .onChange(of: groupIndex) { _ in SoundEngine.shared.play(.tap) }

            HStack(spacing: 12) {
                ForEach(Array(StickerGroup.all[groupIndex].items.enumerated()), id: \.offset) { index, choice in
                    Button {
                        add(choice)
                    } label: {
                        Text(choice.emoji)
                            .font(.system(size: 40))
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white.opacity(0.92))
                                    .shadow(color: theme.accent.opacity(0.25), radius: 4, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(theme.accent.opacity(0.35), lineWidth: 2)
                            )
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .popIn(delay: Double(index) * 0.04)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 16) {
            Button {
                guard let last = placed.last else { return }
                Haptics.tap()
                SoundEngine.shared.play(.pop)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    placed.removeLast()
                }
                SpeechHelper.speak("Bye bye, \(last.name)!")
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 22))
                    Text("Undo")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(theme.accent)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white.opacity(0.9)))
            }
            .buttonStyle(SquishyButtonStyle())
            .opacity(placed.isEmpty ? 0.4 : 1.0)
            .disabled(placed.isEmpty)

            Button(action: tellStory) {
                HStack(spacing: 8) {
                    Text("🪄")
                        .font(.system(size: 26))
                    Text("Tell my story!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [theme.accent, theme.accent.opacity(0.7)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: theme.accent.opacity(wandPulse ? 0.6 : 0.35), radius: wandPulse ? 12 : 7, y: 4)
                )
            }
            .buttonStyle(SquishyButtonStyle())
            .scaleEffect(wandPulse ? 1.04 : 1.0)
            .opacity(placed.isEmpty ? 0.4 : 1.0)
            .disabled(placed.isEmpty)
        }
    }

    // MARK: Actions

    private func add(_ choice: StickerChoice) {
        Haptics.tap()
        SoundEngine.shared.play(.pop)
        SpeechHelper.speak(choice.name.capitalized)
        // Land somewhere pleasant mid-scene; the kid drags it from there.
        let position = CGPoint(
            x: CGFloat.random(in: 0.2...0.8),
            y: CGFloat.random(in: 0.35...0.75)
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            placed.append(PlacedSticker(emoji: choice.emoji, name: choice.name, position: position))
            storyText = nil
        }
    }

    private func move(_ sticker: PlacedSticker, to location: CGPoint, in size: CGSize) {
        guard let index = placed.firstIndex(where: { $0.id == sticker.id }),
              size.width > 0, size.height > 0 else { return }
        // Convert the drag's point location back to unit space, keeping the
        // sticker fully inside the canvas.
        placed[index].position = CGPoint(
            x: min(max(location.x / size.width, 0.04), 0.96),
            y: min(max(location.y / size.height, 0.06), 0.94)
        )
    }

    private func wiggle(_ sticker: PlacedSticker) {
        Haptics.tap()
        SoundEngine.shared.playTileNote(placed.firstIndex(where: { $0.id == sticker.id }) ?? 0)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            wigglingID = sticker.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation { wigglingID = nil }
        }
    }

    private func tellStory() {
        guard !placed.isEmpty else { return }
        Haptics.success()
        SoundEngine.shared.play(.sparkle)

        let names = placed.map(\.name).shuffled()
        // "an apple" / "an ice cream", but "a unicorn" — article follows the
        // sound, so a lookup beats a first-letter check here.
        func an(_ name: String) -> String {
            ["apple", "ice cream"].contains(name) ? "an \(name)" : "a \(name)"
        }
        let story: String
        switch names.count {
        case 1:
            story = "Once upon a time, a happy \(names[0]) went on a big adventure in the \(backdrop.name.lowercased())!"
        case 2:
            story = "Once upon a time, \(an(names[0])) met \(an(names[1])) in the \(backdrop.name.lowercased()), and they became best friends!"
        default:
            story = "Once upon a time, \(an(names[0])) and \(an(names[1])) explored the \(backdrop.name.lowercased()). Then \(an(names[2])) threw a party for everyone!"
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            storyText = story
        }
        SpeechHelper.speak(story)

        // Stars for the first three stories each visit: creativity is
        // rewarded, but there's no grind treadmill.
        storiesTold += 1
        if storiesTold <= 3 {
            StarBank.shared.award(1, to: theme.key)
            withAnimation { celebrate = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { celebrate = false }
            }
        }
    }
}

#Preview {
    NavigationStack { ImaginationGameView() }
}
