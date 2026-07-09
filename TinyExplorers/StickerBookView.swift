import SwiftUI

// MARK: - Sticker book

/// The star shop: kids trade stars earned in games for collectible stickers.
struct StickerBookView: View {
    @ObservedObject private var starBank = StarBank.shared
    @ObservedObject private var album = StickerAlbum.shared
    @ObservedObject private var profile = Profile.shared

    @State private var justUnlocked: Sticker? = nil
    @State private var wobbling: String? = nil

    private let theme = GameTheme.stickers

    var body: some View {
        ZStack {
            PlayfulBackground(theme: theme)

            ScrollView {
                VStack(spacing: 24) {
                    header

                    ForEach(StickerPack.all) { pack in
                        packSection(pack)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }

            if let sticker = justUnlocked {
                CelebrationOverlayEnhanced(message: "\(sticker.name) unlocked!", emoji: sticker.emoji)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .kidNavigation(title: "Sticker Book", theme: theme)
        .onDisappear { SpeechHelper.stop() }
    }

    private var header: some View {
        VStack(spacing: 14) {
            MascotBubble(
                theme: theme,
                text: bubbleText,
                mascotSize: 60
            )
            HStack(spacing: 14) {
                StarCounterChipEnhanced(count: starBank.available)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(album.unlockedCount) of \(StickerPack.totalStickerCount) collected")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.15))
                    XPProgressBar(
                        progress: Double(album.unlockedCount) / Double(StickerPack.totalStickerCount),
                        height: 10,
                        showLabel: false,
                        accent: Color(red: 0.85, green: 0.6, blue: 0.05)
                    )
                    .frame(width: 160)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
                )
            }
        }
        .padding(.top, 10)
    }

    private var bubbleText: String {
        if album.unlockedCount == StickerPack.totalStickerCount {
            return "Wow! You collected every sticker!"
        }
        return "Trade your stars for stickers!"
    }

    private func packSection(_ pack: StickerPack) -> some View {
        let level = LevelSystem.level(for: starBank.total)
        let gateOpen = pack.isUnlocked(atLevel: level)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(gateOpen ? pack.emoji : "🔒").font(.system(size: 28))
                Text(pack.title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.25, blue: 0.45), pack.accent],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .opacity(gateOpen ? 1 : 0.6)
                Spacer()
                if gateOpen {
                    let packUnlocked = pack.stickers.filter { album.isUnlocked($0) }.count
                    Text("\(packUnlocked)/\(pack.stickers.count)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(pack.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(pack.accent.opacity(0.12)))
                } else {
                    Text("Level \(pack.unlockLevel)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(pack.accent.opacity(0.85)))
                }
            }

            if gateOpen {
                let packUnlocked = pack.stickers.filter { album.isUnlocked($0) }.count
                XPProgressBar(
                    progress: Double(packUnlocked) / Double(pack.stickers.count),
                    height: 8,
                    showLabel: false,
                    accent: pack.accent
                )

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 130, maximum: 180), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(Array(pack.stickers.enumerated()), id: \.element.id) { index, sticker in
                        StickerTile(
                            sticker: sticker,
                            accent: pack.accent,
                            unlocked: album.isUnlocked(sticker),
                            affordable: starBank.available >= sticker.cost,
                            wobbling: wobbling == sticker.id
                        ) {
                            tap(sticker)
                        }
                        .popIn(delay: Double(index) * 0.05)
                    }
                }
            } else {
                lockedPackTeaser(pack)
            }
        }
    }

    /// Silhouette preview shown for a pack the kid hasn't reached yet — the
    /// mystery of what's inside is the pull to keep earning stars.
    private func lockedPackTeaser(_ pack: StickerPack) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ForEach(pack.stickers.prefix(6)) { _ in
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.12)).frame(width: 58, height: 58)
                        Text("❓").font(.system(size: 26)).opacity(0.45)
                    }
                }
            }
            Text("Reach Level \(pack.unlockLevel) to open this pack!")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(pack.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(RoundedRectangle(cornerRadius: 20).fill(pack.accent.opacity(0.06)))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(pack.accent.opacity(0.25), style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
        )
    }

    private func tap(_ sticker: Sticker) {
        if album.isUnlocked(sticker) {
            // Already collected: a happy little replay, never a dead tap.
            Haptics.tap()
            SoundEngine.shared.play(.sparkle)
            SpeechHelper.speak(sticker.name)
            return
        }

        if album.unlock(sticker) {
            Haptics.success()
            SoundEngine.shared.play(.win)
            SpeechHelper.cheer("You got the \(sticker.name) sticker!")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                justUnlocked = sticker
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { justUnlocked = nil }
            }
        } else {
            let missing = sticker.cost - starBank.available
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Earn \(missing) more \(missing == 1 ? "star" : "stars") to get this one!")
            withAnimation(.default) { wobbling = sticker.id }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wobbling = nil
            }
        }
    }
}

/// One sticker slot: a big colorful sticker when unlocked, a mystery
/// silhouette with a star price tag when still locked.
private struct StickerTile: View {
    let sticker: Sticker
    let accent: Color
    let unlocked: Bool
    let affordable: Bool
    let wobbling: Bool
    let action: () -> Void

    @State private var glowPulse = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? AnyShapeStyle(
                                    RadialGradient(
                                        colors: [accent.opacity(0.35), accent.opacity(0.1)],
                                        center: .center, startRadius: 5, endRadius: 45
                                    )
                                  )
                                : AnyShapeStyle(Color.gray.opacity(0.1))
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: unlocked ? accent.opacity(glowPulse ? 0.5 : 0.3) : .clear, radius: 8)
                    Text(unlocked ? sticker.emoji : "❓")
                        .font(.system(size: unlocked ? 50 : 36))
                        .opacity(unlocked ? 1 : 0.5)
                        .scaleEffect(unlocked && glowPulse ? 1.05 : 1.0)
                }

                if unlocked {
                    Text(sticker.name)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.25, blue: 0.4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    HStack(spacing: 4) {
                        Text("⭐").font(.system(size: 14))
                        Text("\(sticker.cost)")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(
                            affordable
                                ? LinearGradient(colors: [accent, accent.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.gray.opacity(0.55), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                    )
                    .shadow(color: affordable ? accent.opacity(0.4) : .clear, radius: 3, y: 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: unlocked
                                ? [.white, accent.opacity(0.06)]
                                : [.white.opacity(0.8), .white.opacity(0.6)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: accent.opacity(unlocked ? 0.4 : 0.1), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        unlocked ? accent.opacity(0.6) : Color.gray.opacity(0.2),
                        style: unlocked
                            ? StrokeStyle(lineWidth: 2.5)
                            : StrokeStyle(lineWidth: 2.5, dash: [7, 5])
                    )
            )
            .rotationEffect(.degrees(wobbling ? 4 : 0))
            .animation(
                wobbling
                    ? .easeInOut(duration: 0.08).repeatCount(5, autoreverses: true)
                    : .default,
                value: wobbling
            )
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.92))
        .onAppear {
            if unlocked {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}

// MARK: - Buddy picker

/// Full-screen friendly sheet where the kid picks their explorer buddy.
struct BuddyPickerView: View {
    @ObservedObject private var profile = Profile.shared
    @ObservedObject private var starBank = StarBank.shared
    @Environment(\.dismiss) private var dismiss

    private var level: Int { LevelSystem.level(for: starBank.total) }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .stickers)

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Pick your buddy!")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.25, blue: 0.45), Color(red: 0.6, green: 0.4, blue: 0.2)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .padding(.top, 30)

                    Text("Your buddy explores with you")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.45, blue: 0.6))
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(Array(Buddy.all.enumerated()), id: \.element.id) { index, buddy in
                        BuddyTile(
                            buddy: buddy,
                            selected: profile.buddyID == buddy.id,
                            locked: !buddy.isUnlocked(atLevel: level)
                        ) {
                            choose(buddy)
                        }
                        .popIn(delay: Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .onDisappear { SpeechHelper.stop() }
    }

    private func choose(_ buddy: Buddy) {
        // Locked buddies aren't choosable yet — nudge toward the unlock goal
        // instead of a dead tap.
        guard buddy.isUnlocked(atLevel: level) else {
            Haptics.error()
            SoundEngine.shared.play(.wrong)
            SpeechHelper.speak("Reach level \(buddy.unlockLevel) to meet \(buddy.name)!")
            return
        }
        Haptics.success()
        SoundEngine.shared.play(.correct)
        SpeechHelper.cheer(buddy.hello)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            profile.buddyID = buddy.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            dismiss()
        }
    }
}

private struct BuddyTile: View {
    let buddy: Buddy
    let selected: Bool
    var locked: Bool = false
    let action: () -> Void

    @State private var glowPulse = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            selected
                                ? RadialGradient(
                                    colors: [Color(red: 1.0, green: 0.9, blue: 0.5).opacity(0.5), .clear],
                                    center: .center, startRadius: 5, endRadius: 45
                                  )
                                : RadialGradient(
                                    colors: [Color.white.opacity(0.3), .clear],
                                    center: .center, startRadius: 5, endRadius: 40
                                  )
                        )
                        .frame(width: 80, height: 80)
                    Text(buddy.emoji)
                        .font(.system(size: 64))
                        .grayscale(locked ? 1 : 0)
                        .opacity(locked ? 0.45 : 1)
                    if locked {
                        Text("🔒").font(.system(size: 30))
                            .offset(x: 22, y: 22)
                    }
                }

                Text(locked ? "Level \(buddy.unlockLevel)" : buddy.name)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(locked ? Color(red: 0.5, green: 0.5, blue: 0.6) : Color(red: 0.2, green: 0.25, blue: 0.4))

                if selected && !locked {
                    HStack(spacing: 4) {
                        Text("✨")
                            .font(.system(size: 12))
                        Text("My buddy!")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("✨")
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [Color(red: 0.9, green: 0.65, blue: 0.1), Color(red: 0.85, green: 0.55, blue: 0.05)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    )
                    .shadow(color: Color(red: 0.85, green: 0.6, blue: 0.05).opacity(0.5), radius: 4, y: 2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: selected
                                ? [.white, Color(red: 1.0, green: 0.96, blue: 0.85)]
                                : [.white.opacity(0.92), .white.opacity(0.78)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: Color(red: 0.85, green: 0.6, blue: 0.05).opacity(selected ? (glowPulse ? 0.55 : 0.35) : 0.12),
                        radius: selected ? 12 : 5, y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        Color(red: 0.85, green: 0.6, blue: 0.05).opacity(selected ? 0.8 : 0.15),
                        lineWidth: selected ? 3.5 : 2
                    )
            )
            .scaleEffect(selected ? 1.05 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selected)
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.92))
        .onAppear {
            if selected {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}

#Preview("Sticker Book") {
    NavigationStack { StickerBookView() }
}

#Preview("Buddy Picker") {
    BuddyPickerView()
}
