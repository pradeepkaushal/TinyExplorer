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
                CelebrationOverlay(message: "\(sticker.name) unlocked!", emoji: sticker.emoji)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("Sticker Book")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { SpeechHelper.stop() }
    }

    private var header: some View {
        VStack(spacing: 12) {
            MascotBubble(
                theme: theme,
                text: bubbleText,
                mascotSize: 60
            )
            HStack(spacing: 12) {
                StarCounterChip(count: starBank.available)
                Text("\(album.unlockedCount) of \(StickerPack.totalStickerCount) collected")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(pack.emoji).font(.system(size: 26))
                Text(pack.title)
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                Spacer()
            }

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
        }
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
            SpeechHelper.speak("Earn \(missing) more stars to get this one!")
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [accent.opacity(0.3), accent.opacity(0.12)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(Color.gray.opacity(0.12))
                        )
                        .frame(width: 78, height: 78)
                    Text(unlocked ? sticker.emoji : "❓")
                        .font(.system(size: unlocked ? 48 : 36))
                        .opacity(unlocked ? 1 : 0.5)
                }

                if unlocked {
                    Text(sticker.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    HStack(spacing: 3) {
                        Text("⭐").font(.system(size: 13))
                        Text("\(sticker.cost)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(affordable ? accent : Color.gray.opacity(0.55))
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white.opacity(unlocked ? 1.0 : 0.75))
                    .shadow(color: accent.opacity(unlocked ? 0.35 : 0.12), radius: 7, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        unlocked ? accent.opacity(0.5) : Color.gray.opacity(0.25),
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
    }
}

// MARK: - Buddy picker

/// Full-screen friendly sheet where the kid picks their explorer buddy.
struct BuddyPickerView: View {
    @ObservedObject private var profile = Profile.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .stickers)

            VStack(spacing: 20) {
                Text("Pick your buddy!")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                    .padding(.top, 30)

                Text("Your buddy explores with you")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.35, green: 0.4, blue: 0.55))

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(Array(Buddy.all.enumerated()), id: \.element.id) { index, buddy in
                        BuddyTile(buddy: buddy, selected: profile.buddyID == buddy.id) {
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(buddy.emoji)
                    .font(.system(size: 64))
                Text(buddy.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.25, green: 0.3, blue: 0.45))
                if selected {
                    Text("My buddy!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(red: 0.85, green: 0.6, blue: 0.05)))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(selected ? 1.0 : 0.88))
                    .shadow(
                        color: Color(red: 0.85, green: 0.6, blue: 0.05).opacity(selected ? 0.45 : 0.15),
                        radius: selected ? 10 : 5, y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        Color(red: 0.85, green: 0.6, blue: 0.05).opacity(selected ? 0.8 : 0.2),
                        lineWidth: selected ? 3.5 : 2
                    )
            )
            .scaleEffect(selected ? 1.05 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selected)
        }
        .buttonStyle(SquishyButtonStyle(scale: 0.92))
    }
}

#Preview("Sticker Book") {
    NavigationStack { StickerBookView() }
}

#Preview("Buddy Picker") {
    BuddyPickerView()
}
