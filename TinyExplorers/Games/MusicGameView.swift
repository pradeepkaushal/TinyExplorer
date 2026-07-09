import SwiftUI

struct Instrument: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
}

struct MusicGameView: View {
    let instruments: [Instrument] = [
        Instrument(name: "Piano", emoji: "🎹", color: .blue),
        Instrument(name: "Drum", emoji: "🥁", color: .red),
        Instrument(name: "Guitar", emoji: "🎸", color: .orange),
        Instrument(name: "Trumpet", emoji: "🎺", color: .yellow),
        Instrument(name: "Violin", emoji: "🎻", color: .purple),
        Instrument(name: "Bell", emoji: "🔔", color: .green),
        Instrument(name: "Flute", emoji: "🪈", color: .cyan),
        Instrument(name: "Tambourine", emoji: "🪘", color: .pink),
    ]

    // Piano keys: real C4 major scale, played with a plucked-string timbre.
    let pianoNotes: [(note: String, color: Color, midi: Int)] = [
        ("Do", .red, 60), ("Re", .orange, 62), ("Mi", .yellow, 64),
        ("Fa", .green, 65), ("Sol", .blue, 67), ("La", .purple, 69),
        ("Ti", .pink, 71), ("Do", .red, 72),
    ]

    // Free Play xylophone: 8 chime bars, C5 up to C6.
    let xylophoneBars: [(color: Color, midi: Int)] = [
        (.red, 72), (.orange, 74), (.yellow, 76), (.green, 77),
        (.mint, 79), (.blue, 81), (.purple, 83), (.pink, 84),
    ]

    /// One tap captured while recording: enough info to replay the exact
    /// musical gesture (instrument + which step of its pattern it was on).
    private struct RecordedTap: Identifiable {
        let id = UUID()
        let emoji: String
        let instrumentIndex: Int
        let step: Int
    }

    @State private var tappedInstrument: UUID? = nil
    @State private var gameMode: MusicMode = .freeplay
    @State private var recording: [RecordedTap] = []
    @State private var isRecording = false
    @State private var hasAwardedForRecording = false
    /// Drives the red "recording" pulse so the state is unmistakable.
    @State private var recordPulse = false
    @State private var tappedNote: Int? = nil
    @State private var tappedBar: Int? = nil
    /// Global tap counter so each instrument tap walks through its pattern
    /// instead of repeating one identical sound.
    @State private var tapStep = 0
    /// Drives the gentle idle sway of the header music note.
    @State private var noteSway = false
    /// Bumped on every key/bar tap so the glow flourish retriggers.
    @State private var flourishTick = 0
    @State private var progression = GameProgression(key: GameTheme.music.key)

    private let hints = [
        "Tap instruments to hear their sound!",
        "Record and play back your song!",
        "Try the piano keys to play a tune!",
        "Make a song with 4+ notes for a star!",
    ]

    @ObservedObject private var starBank = StarBank.shared

    private let theme = GameTheme.music

    /// C major pentatonic offsets — everything built on this sounds good together.
    private let pentatonic = [0, 2, 4, 7, 9]

    enum MusicMode: String, CaseIterable {
        case freeplay = "Free Play"
        case piano = "Piano"
    }

    var body: some View {
        ZStack {
            PlayfulBackground(theme: .music)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    // Gentle idle sway on a little music note beside the mode picker.
                    Text("🎵")
                        .font(.system(size: 30))
                        .rotationEffect(.degrees(noteSway ? 12 : -12), anchor: .bottom)
                        .offset(y: noteSway ? -2 : 2)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: noteSway)
                        .onAppear { noteSway = true }

                    ThemedSegmentedPicker(
                        items: MusicMode.allCases.map { (title: $0.rawValue, value: $0) },
                        selection: $gameMode,
                        accent: theme.accent
                    )

                    StarCounterChipEnhanced(count: starBank.count(for: GameTheme.music.key), compact: true)
                }
                .onChange(of: gameMode) { _ in
                    SoundEngine.shared.play(.pop)
                }

                GameProgressHeader(
                    level: progression.level,
                    correctInLevel: progression.correctInLevel,
                    neededForNextLevel: progression.neededForNextLevel,
                    theme: theme,
                    hint: progression.currentHint(from: hints)
                )
                .padding(.horizontal, 24)

                if gameMode == .freeplay {
                    freePlayView
                } else {
                    pianoView
                }
            }
            .padding(.top, 8)
        }
        .kidNavigation(title: "Music Maker", theme: theme)

            if progression.showLevelUp {
                LevelUpOverlay(level: progression.level, theme: theme)
                    .transition(.scale.combined(with: .opacity))
            }
    }

    // MARK: - Free Play

    var freePlayView: some View {
        VStack(spacing: 18) {
            MascotBubble(theme: theme, text: "Tap instruments to make music!")

            // Recording controls — one obvious Record button, one obvious Play button.
            HStack(spacing: 18) {
                Button(action: toggleRecording) {
                    HStack(spacing: 10) {
                        Image(systemName: isRecording ? "stop.fill" : "record.circle.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.red)
                        Text(isRecording ? "Stop" : "Record")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(minWidth: 150, minHeight: 64)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(isRecording ? Color.red.opacity(0.16) : .white.opacity(0.9))
                            .overlay(
                                Capsule().stroke(Color.red.opacity(isRecording ? 0.9 : 0.4),
                                                 lineWidth: isRecording ? 4 : 3)
                            )
                    )
                    .scaleEffect(recordPulse ? 1.05 : 1.0)
                    .animation(isRecording
                               ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                               : .default,
                               value: recordPulse)
                }
                .buttonStyle(SquishyButtonStyle())

                if !recording.isEmpty && !isRecording {
                    Button(action: playRecording) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                            Text("Play")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 130, minHeight: 64)
                        .padding(.horizontal, 24)
                        .background(Capsule().fill(GameTheme.music.accent))
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35), value: isRecording)

            Spacer(minLength: 4)

            // Instrument grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                ForEach(Array(instruments.enumerated()), id: \.element.id) { index, instrument in
                    Button(action: {
                        playInstrument(instrument, at: index)
                    }) {
                        VStack(spacing: 12) {
                            Text(instrument.emoji)
                                .font(.system(size: 76))

                            Text(instrument.name)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 170)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(tappedInstrument == instrument.id ?
                                      instrument.color.opacity(0.35) : .white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(instrument.color.opacity(0.5), lineWidth: 3)
                                )
                                .shadow(
                                    color: instrument.color.opacity(tappedInstrument == instrument.id ? 0.5 : 0.25),
                                    radius: tappedInstrument == instrument.id ? 10 : 5,
                                    y: 4
                                )
                        )
                        .overlay {
                            if tappedInstrument == instrument.id {
                                TapGlowBurst(color: instrument.color, cornerRadius: 22)
                                    .id(tapStep)
                            }
                        }
                        .scaleEffect(tappedInstrument == instrument.id ? 1.08 : 1.0)
                        .animation(.spring(response: 0.3), value: tappedInstrument)
                    }
                    .buttonStyle(SquishyButtonStyle())
                    .popIn(delay: Double(index) * 0.04)
                }
            }
            .padding(.horizontal, 40)

            // Song display
            if !recording.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recording) { tap in
                            Text(tap.emoji)
                                .font(.system(size: 36))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(GameTheme.music.accent.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 40)
            }

            Spacer(minLength: 4)

            // Xylophone row: real chime notes, C5 up to C6
            VStack(spacing: 10) {
                Text("Xylophone")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(xylophoneBars.enumerated()), id: \.offset) { index, bar in
                        Button(action: { playXylophoneBar(index) }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(bar.color)
                                .frame(maxWidth: .infinity)
                                .frame(height: CGFloat(130 - index * 6))
                                .overlay(
                                    Circle()
                                        .fill(.white.opacity(0.8))
                                        .frame(width: 12, height: 12)
                                        .offset(y: -8),
                                    alignment: .top
                                )
                                .shadow(color: bar.color.opacity(0.4), radius: tappedBar == index ? 8 : 3, y: 3)
                                .overlay {
                                    if tappedBar == index {
                                        TapGlowBurst(color: bar.color, cornerRadius: 10)
                                            .id(flourishTick)
                                    }
                                }
                                .scaleEffect(tappedBar == index ? 1.08 : 1.0)
                                .animation(.spring(response: 0.2), value: tappedBar)
                        }
                        .buttonStyle(SquishyButtonStyle(scale: 0.93))
                        .popIn(delay: 0.1 + Double(index) * 0.04)
                    }
                }
                .padding(.horizontal, 60)
            }

            Spacer(minLength: 8)
        }
    }

    // MARK: - Piano

    var pianoView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 8)

            MascotBubble(theme: theme, text: "Play the piano keys!")

            // Piano keys
            HStack(spacing: 10) {
                ForEach(Array(pianoNotes.enumerated()), id: \.offset) { index, note in
                    Button(action: {
                        playNote(index: index)
                    }) {
                        VStack(spacing: 12) {
                            Text(note.note)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(tappedNote == index ? .white : note.color)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(tappedNote == index ? note.color : .white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(note.color, lineWidth: 3)
                                )
                                .shadow(color: note.color.opacity(0.35), radius: tappedNote == index ? 8 : 4, y: 3)
                        )
                        .overlay {
                            if tappedNote == index {
                                TapGlowBurst(color: note.color, cornerRadius: 20)
                                    .id(flourishTick)
                            }
                        }
                        .scaleEffect(tappedNote == index ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2), value: tappedNote)
                    }
                    .buttonStyle(SquishyButtonStyle(scale: 0.95))
                    .popIn(delay: Double(index) * 0.04)
                }
            }
            .padding(.horizontal, 32)

            Text("…or tap the xylophone — same notes, one octave up!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)

            // Xylophone: chime timbre, one octave above the keys
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(pianoNotes.enumerated()), id: \.offset) { index, note in
                    Button(action: { playXylophoneNote(index: index) }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(note.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: CGFloat(120 + index * 14))
                            .shadow(color: note.color.opacity(0.4), radius: tappedNote == index ? 8 : 3, y: 3)
                            .overlay {
                                if tappedNote == index {
                                    TapGlowBurst(color: note.color, cornerRadius: 10)
                                        .id(flourishTick)
                                }
                            }
                            .scaleEffect(tappedNote == index ? 1.05 : 1.0)
                            .animation(.spring(response: 0.2), value: tappedNote)
                    }
                    .buttonStyle(SquishyButtonStyle(scale: 0.93))
                    .popIn(delay: 0.15 + Double(index) * 0.04)
                }
            }
            .padding(.horizontal, 40)

            Spacer(minLength: 8)
        }
    }

    // MARK: - Sound

    func playInstrument(_ instrument: Instrument, at index: Int) {
        Haptics.tap()
        tappedInstrument = instrument.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedInstrument = nil
        }

        if isRecording {
            recording.append(RecordedTap(emoji: instrument.emoji, instrumentIndex: index, step: tapStep))
        }

        performGesture(instrumentIndex: index, step: tapStep)
        tapStep += 1
    }

    /// Every instrument plays a small real musical gesture, and the gesture
    /// changes with `step`, so free play sounds like music — not one beep.
    private func performGesture(instrumentIndex: Int, step: Int) {
        switch instrumentIndex {
        case 0: // Piano — plucked notes walking up the C4 pentatonic scale
            let octave = 12 * ((step / 5) % 2)
            let first = 60 + octave + pentatonic[step % 5]
            let second = 60 + 12 * (((step + 1) / 5) % 2) + pentatonic[(step + 1) % 5]
            playNotes([
                (0.00, first, .pluck, 0.55, 0.85),
                (0.12, second, .pluck, 0.55, 0.6),
            ])
        case 1: // Drum — very low retro thumps: boom-boom, boom-BAP
            playNotes([
                (0.00, 36, .retro, 0.12, 0.9),
                (0.18, step % 2 == 0 ? 36 : 43, .retro, 0.12, 0.8),
            ])
        case 2: // Guitar — low plucked strum, cycling C / F / G chords
            let root = [48, 53, 55][step % 3]
            playNotes([
                (0.00, root, .pluck, 0.8, 0.8),
                (0.07, root + 7, .pluck, 0.8, 0.7),
                (0.14, root + 12, .pluck, 0.9, 0.7),
            ])
        case 3: // Trumpet — mid retro fanfare, alternating up and down
            let run = step % 2 == 0 ? [60, 64, 67] : [67, 64, 60]
            playNotes([
                (0.00, run[0], .retro, 0.2, 0.5),
                (0.10, run[1], .retro, 0.2, 0.5),
                (0.20, run[2], .retro, 0.3, 0.55),
            ])
        case 4: // Violin — long singing sine, two slurred notes
            let pair = [(69, 76), (72, 79), (74, 81)][step % 3]
            playNotes([
                (0.00, pair.0, .sine, 1.1, 0.7),
                (0.40, pair.1, .sine, 0.9, 0.55),
            ])
        case 5: // Bell — high chime with a soft fifth above
            let n = [84, 88, 91][step % 3]
            playNotes([
                (0.00, n, .chime, 1.2, 0.75),
                (0.16, n + 7, .chime, 0.9, 0.4),
            ])
        case 6: // Flute — quick airy high trill on the pentatonic
            let n = 84 + pentatonic[step % 5]
            playNotes([
                (0.00, n, .sine, 0.18, 0.55),
                (0.12, n + 2, .sine, 0.18, 0.5),
                (0.24, n, .sine, 0.32, 0.55),
            ])
        case 7: // Tambourine — shimmering shake
            SoundEngine.shared.play(.sparkle)
        default:
            break
        }
    }

    /// Schedule a tiny sequence of synthesized notes.
    private func playNotes(_ notes: [(delay: Double, midi: Int, timbre: SoundEngine.Timbre, duration: Double, volume: Float)]) {
        for note in notes {
            if note.delay <= 0 {
                SoundEngine.shared.playNote(midi: note.midi, timbre: note.timbre, duration: note.duration, volume: note.volume)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + note.delay) {
                    SoundEngine.shared.playNote(midi: note.midi, timbre: note.timbre, duration: note.duration, volume: note.volume)
                }
            }
        }
    }

    func playNote(index: Int) {
        Haptics.tap()
        flourishTick += 1
        tappedNote = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedNote = nil
        }
        SoundEngine.shared.playNote(midi: pianoNotes[index].midi, timbre: .pluck, duration: 0.9, volume: 0.85)
    }

    func playXylophoneNote(index: Int) {
        Haptics.tap()
        flourishTick += 1
        tappedNote = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedNote = nil
        }
        SoundEngine.shared.playNote(midi: pianoNotes[index].midi + 12, timbre: .chime, duration: 1.0, volume: 0.8)
    }

    func playXylophoneBar(_ index: Int) {
        Haptics.tap()
        flourishTick += 1
        tappedBar = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            tappedBar = nil
        }
        SoundEngine.shared.playNote(midi: xylophoneBars[index].midi, timbre: .chime, duration: 1.0, volume: 0.8)
    }

    /// Single, obvious toggle: start a fresh recording, or stop and let them
    /// play it back right away. Never dead-ends.
    private func toggleRecording() {
        Haptics.tap()
        if isRecording {
            SoundEngine.shared.play(.pop)
            isRecording = false
            recordPulse = false
        } else {
            SoundEngine.shared.play(.tap)
            recording.removeAll()
            hasAwardedForRecording = false
            isRecording = true
            recordPulse = true
        }
    }

    func playRecording() {
        Haptics.tap()
        SoundEngine.shared.play(.pop)
        for (i, tap) in recording.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.45) {
                tappedInstrument = instruments[tap.instrumentIndex].id
                performGesture(instrumentIndex: tap.instrumentIndex, step: tap.step)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tappedInstrument = nil
                }
            }
        }
        // Every playback celebrates: a real little song (4+ notes) earns a star,
        // and a shorter one still gets a happy cheer — there's no way to "fail".
        let finish = Double(recording.count) * 0.45 + 0.3
        if recording.count >= 4 && !hasAwardedForRecording {
            hasAwardedForRecording = true
            DispatchQueue.main.asyncAfter(deadline: .now() + finish) {
                StarBank.shared.award(1, to: GameTheme.music.key)
                progression.registerCorrect()
                SoundEngine.shared.play(.win)
                Haptics.success()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + finish) {
                SoundEngine.shared.play(.sparkle)
                Haptics.success()
            }
        }
    }
}

// MARK: - Tap flourish

/// Quick one-shot glow ring that expands and fades over the tapped
/// instrument/key/bar, visually connecting the tap to its sound.
/// Re-key with `.id(counter)` so rapid taps restart the burst.
private struct TapGlowBurst: View {
    let color: Color
    var cornerRadius: CGFloat = 20

    @State private var burst = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(color.opacity(burst ? 0 : 0.85), lineWidth: burst ? 1 : 5)
            .scaleEffect(burst ? 1.25 : 0.95)
            .animation(.easeOut(duration: 0.45), value: burst)
            .onAppear { burst = true }
            .allowsHitTesting(false)
    }
}

#Preview {
    NavigationStack {
        MusicGameView()
    }
}
