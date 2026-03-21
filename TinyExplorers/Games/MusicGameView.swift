import SwiftUI
import AVFoundation

struct Instrument: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
    let soundDescription: String
    let frequency: Double
}

struct MusicGameView: View {
    let instruments: [Instrument] = [
        Instrument(name: "Piano", emoji: "🎹", color: .blue, soundDescription: "ding", frequency: 523.25),
        Instrument(name: "Drum", emoji: "🥁", color: .red, soundDescription: "boom boom", frequency: 150),
        Instrument(name: "Guitar", emoji: "🎸", color: .orange, soundDescription: "twang", frequency: 329.63),
        Instrument(name: "Trumpet", emoji: "🎺", color: .yellow, soundDescription: "toot toot", frequency: 466.16),
        Instrument(name: "Violin", emoji: "🎻", color: .purple, soundDescription: "sweet melody", frequency: 440),
        Instrument(name: "Bell", emoji: "🔔", color: .green, soundDescription: "ding ding", frequency: 880),
        Instrument(name: "Flute", emoji: "🪈", color: .cyan, soundDescription: "tweet tweet", frequency: 659.25),
        Instrument(name: "Tambourine", emoji: "🪘", color: .pink, soundDescription: "shake shake", frequency: 200),
    ]

    // Piano notes
    let pianoNotes: [(note: String, color: Color, frequency: Double)] = [
        ("Do", .red, 261.63), ("Re", .orange, 293.66), ("Mi", .yellow, 329.63),
        ("Fa", .green, 349.23), ("Sol", .blue, 392.00), ("La", .purple, 440.00),
        ("Ti", .pink, 493.88), ("Do", .red, 523.25),
    ]

    @State private var tappedInstrument: UUID? = nil
    @State private var gameMode: MusicMode = .freeplay
    @State private var recording: [String] = []
    @State private var isRecording = false
    @State private var tappedNote: Int? = nil

    let synthesizer = AVSpeechSynthesizer()

    enum MusicMode: String, CaseIterable {
        case freeplay = "Free Play"
        case piano = "Piano"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.9, green: 0.85, blue: 1.0), Color(red: 1.0, green: 0.9, blue: 0.85)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Picker("Mode", selection: $gameMode) {
                    ForEach(MusicMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 200)

                if gameMode == .freeplay {
                    freePlayView
                } else {
                    pianoView
                }
            }
        }
        .navigationTitle("Music Maker")
        .navigationBarTitleDisplayMode(.inline)
    }

    var freePlayView: some View {
        VStack(spacing: 24) {
            Text("Tap instruments to play!")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)

            // Recording indicator
            HStack(spacing: 16) {
                Button(action: {
                    if isRecording {
                        isRecording = false
                    } else {
                        recording.removeAll()
                        isRecording = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.gray)
                            .frame(width: 16, height: 16)
                        Text(isRecording ? "Stop Recording" : "Record")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.white.opacity(0.8)))
                }

                if !recording.isEmpty && !isRecording {
                    Button(action: playRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Play Back")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.green))
                    }
                }
            }

            // Instrument grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                ForEach(instruments) { instrument in
                    Button(action: {
                        playInstrument(instrument)
                    }) {
                        VStack(spacing: 12) {
                            Text(instrument.emoji)
                                .font(.system(size: 70))

                            Text(instrument.name)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(tappedInstrument == instrument.id ?
                                      instrument.color.opacity(0.4) : .white.opacity(0.8))
                                .shadow(radius: tappedInstrument == instrument.id ? 8 : 4)
                        )
                        .scaleEffect(tappedInstrument == instrument.id ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: tappedInstrument)
                    }
                }
            }
            .padding(.horizontal, 40)

            // Song display
            if !recording.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(recording.enumerated()), id: \.offset) { _, emoji in
                            Text(emoji)
                                .font(.system(size: 36))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.5)))
                .padding(.horizontal, 40)
            }

            Spacer()
        }
    }

    var pianoView: some View {
        VStack(spacing: 24) {
            Text("Play the piano keys!")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)

            // Piano keys
            HStack(spacing: 8) {
                ForEach(Array(pianoNotes.enumerated()), id: \.offset) { index, note in
                    Button(action: {
                        playNote(index: index)
                    }) {
                        VStack(spacing: 12) {
                            Text(note.note)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(tappedNote == index ? .white : note.color)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tappedNote == index ? note.color : .white)
                                .shadow(radius: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(note.color, lineWidth: 3)
                                )
                        )
                        .scaleEffect(tappedNote == index ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2), value: tappedNote)
                    }
                }
            }
            .padding(.horizontal, 32)

            // Xylophone visual
            HStack(spacing: 6) {
                ForEach(Array(pianoNotes.enumerated()), id: \.offset) { index, note in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(note.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: CGFloat(120 + index * 15))
                        .onTapGesture {
                            playNote(index: index)
                        }
                        .scaleEffect(tappedNote == index ? 1.05 : 1.0)
                        .animation(.spring(response: 0.2), value: tappedNote)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    func playInstrument(_ instrument: Instrument) {
        tappedInstrument = instrument.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedInstrument = nil
        }

        if isRecording {
            recording.append(instrument.emoji)
        }

        AudioServicesPlaySystemSound(SystemSoundID(1104 + UInt32(instruments.firstIndex(where: { $0.id == instrument.id }) ?? 0)))

        let utterance = AVSpeechUtterance(string: instrument.soundDescription)
        utterance.rate = 0.4
        utterance.pitchMultiplier = Float.random(in: 0.8...1.4)
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func playNote(index: Int) {
        tappedNote = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tappedNote = nil
        }

        AudioServicesPlaySystemSound(SystemSoundID(1104 + UInt32(index)))

        let note = pianoNotes[index]
        let utterance = AVSpeechUtterance(string: note.note)
        utterance.rate = 0.3
        utterance.pitchMultiplier = Float(0.8 + Double(index) * 0.1)
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func playRecording() {
        for (i, emoji) in recording.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                if let instrument = instruments.first(where: { $0.emoji == emoji }) {
                    playInstrument(instrument)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MusicGameView()
    }
}
