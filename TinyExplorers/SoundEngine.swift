import AVFoundation

/// Real-time synthesized game audio: cheerful sound effects and musical notes.
/// Everything is generated as PCM buffers in code — no bundled audio assets.
final class SoundEngine {
    static let shared = SoundEngine()

    enum SFX {
        case tap        // soft xylophone tick for neutral taps
        case pop        // bubble pop
        case correct    // bright rising arpeggio
        case wrong      // gentle, non-punishing low wobble
        case win        // short fanfare with sparkle
        case sparkle    // quick high shimmer
        case streak     // rising zip for combo streaks
    }

    enum Timbre {
        case sine       // soft and round
        case chime      // xylophone / marimba
        case pluck      // plucked string
        case retro      // 8-bit square
    }

    private let engine = AVAudioEngine()
    private var players: [AVAudioPlayerNode] = []
    private var nextPlayer = 0
    private let format: AVAudioFormat
    private let sampleRate: Double = 44_100
    private var sfxCache: [String: AVAudioPCMBuffer] = [:]
    private var started = false

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        for _ in 0..<8 {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: engine.mainMixerNode, format: format)
            players.append(node)
        }
        engine.mainMixerNode.outputVolume = 0.6
    }

    private func startIfNeeded() {
        guard !started else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        do {
            try engine.start()
            players.forEach { $0.play() }
            started = true
        } catch {
            // No audio available (e.g. some simulators) — stay silent rather than crash.
        }
    }

    // MARK: - Public API

    func play(_ sfx: SFX) {
        startIfNeeded()
        guard started else { return }
        let key = "sfx-\(sfx)"
        let buffer: AVAudioPCMBuffer
        if let cached = sfxCache[key] {
            buffer = cached
        } else {
            buffer = render(sfx)
            sfxCache[key] = buffer
        }
        schedule(buffer)
    }

    /// Play a musical note. `midi` 60 == middle C.
    func playNote(midi: Int, timbre: Timbre = .chime, duration: Double = 0.8, volume: Float = 0.8) {
        startIfNeeded()
        guard started else { return }
        let key = "note-\(midi)-\(timbre)-\(duration)"
        let buffer: AVAudioPCMBuffer
        if let cached = sfxCache[key] {
            buffer = cached
        } else {
            buffer = renderBuffer(duration: duration) { add in
                add(NoteEvent(freq: Self.frequency(midi: midi), start: 0, duration: duration, timbre: timbre, volume: volume))
            }
            sfxCache[key] = buffer
        }
        schedule(buffer)
    }

    static func frequency(midi: Int) -> Double {
        440.0 * pow(2.0, Double(midi - 69) / 12.0)
    }

    /// Happy tile-tap note: maps any grid index onto a two-octave major
    /// pentatonic scale, so tapping through letters/shapes plays a melody.
    func playTileNote(_ step: Int, timbre: Timbre = .chime) {
        let pentatonic = [0, 2, 4, 7, 9]
        let positive = abs(step)
        let octave = (positive / pentatonic.count) % 2
        let midi = 72 + octave * 12 + pentatonic[positive % pentatonic.count]
        playNote(midi: midi, timbre: timbre, duration: 0.5, volume: 0.7)
    }

    // MARK: - Scheduling

    private func schedule(_ buffer: AVAudioPCMBuffer) {
        let player = players[nextPlayer]
        nextPlayer = (nextPlayer + 1) % players.count
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    }

    // MARK: - Synthesis

    private struct NoteEvent {
        let freq: Double
        let start: Double
        let duration: Double
        let timbre: Timbre
        var volume: Float = 0.8
    }

    private func render(_ sfx: SFX) -> AVAudioPCMBuffer {
        switch sfx {
        case .tap:
            return renderBuffer(duration: 0.18) { add in
                add(NoteEvent(freq: 880, start: 0, duration: 0.15, timbre: .chime, volume: 0.5))
            }
        case .pop:
            return renderPop()
        case .correct:
            return renderBuffer(duration: 0.75) { add in
                add(NoteEvent(freq: 523.25, start: 0.00, duration: 0.35, timbre: .chime, volume: 0.7)) // C5
                add(NoteEvent(freq: 659.26, start: 0.09, duration: 0.35, timbre: .chime, volume: 0.7)) // E5
                add(NoteEvent(freq: 783.99, start: 0.18, duration: 0.45, timbre: .chime, volume: 0.8)) // G5
            }
        case .wrong:
            return renderBuffer(duration: 0.5) { add in
                add(NoteEvent(freq: 196.00, start: 0.00, duration: 0.20, timbre: .sine, volume: 0.5)) // G3
                add(NoteEvent(freq: 155.56, start: 0.18, duration: 0.28, timbre: .sine, volume: 0.5)) // Eb3
            }
        case .win:
            return renderBuffer(duration: 1.5) { add in
                add(NoteEvent(freq: 523.25, start: 0.00, duration: 0.30, timbre: .pluck, volume: 0.7))  // C5
                add(NoteEvent(freq: 659.26, start: 0.12, duration: 0.30, timbre: .pluck, volume: 0.7))  // E5
                add(NoteEvent(freq: 783.99, start: 0.24, duration: 0.30, timbre: .pluck, volume: 0.7))  // G5
                add(NoteEvent(freq: 1046.50, start: 0.36, duration: 0.55, timbre: .chime, volume: 0.85)) // C6
                add(NoteEvent(freq: 1318.51, start: 0.55, duration: 0.40, timbre: .chime, volume: 0.5))  // E6
                add(NoteEvent(freq: 1567.98, start: 0.68, duration: 0.50, timbre: .chime, volume: 0.45)) // G6
                add(NoteEvent(freq: 2093.00, start: 0.82, duration: 0.50, timbre: .chime, volume: 0.35)) // C7
            }
        case .sparkle:
            return renderBuffer(duration: 0.55) { add in
                add(NoteEvent(freq: 1567.98, start: 0.00, duration: 0.18, timbre: .chime, volume: 0.4))
                add(NoteEvent(freq: 2093.00, start: 0.07, duration: 0.18, timbre: .chime, volume: 0.4))
                add(NoteEvent(freq: 2637.02, start: 0.14, duration: 0.30, timbre: .chime, volume: 0.4))
            }
        case .streak:
            return renderBuffer(duration: 0.65) { add in
                add(NoteEvent(freq: 523.25, start: 0.00, duration: 0.10, timbre: .retro, volume: 0.45))
                add(NoteEvent(freq: 659.26, start: 0.08, duration: 0.10, timbre: .retro, volume: 0.45))
                add(NoteEvent(freq: 783.99, start: 0.16, duration: 0.10, timbre: .retro, volume: 0.45))
                add(NoteEvent(freq: 1046.50, start: 0.24, duration: 0.30, timbre: .chime, volume: 0.7))
            }
        }
    }

    private func renderBuffer(duration: Double, _ build: ((NoteEvent) -> Void) -> Void) -> AVAudioPCMBuffer {
        let frames = AVAudioFrameCount(duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let samples = buffer.floatChannelData![0]
        for i in 0..<Int(frames) { samples[i] = 0 }

        var events: [NoteEvent] = []
        build { events.append($0) }

        for event in events {
            mix(event, into: samples, totalFrames: Int(frames))
        }
        // Soft limiter so overlapping notes never clip
        for i in 0..<Int(frames) {
            samples[i] = tanhf(samples[i])
        }
        return buffer
    }

    private func mix(_ event: NoteEvent, into samples: UnsafeMutablePointer<Float>, totalFrames: Int) {
        let startFrame = Int(event.start * sampleRate)
        let noteFrames = min(Int(event.duration * sampleRate), totalFrames - startFrame)
        guard noteFrames > 0 else { return }

        let twoPi = 2.0 * Double.pi
        for i in 0..<noteFrames {
            let t = Double(i) / sampleRate
            let progress = Double(i) / Double(noteFrames)
            let phase = twoPi * event.freq * t

            var value: Double
            switch event.timbre {
            case .sine:
                value = sin(phase)
            case .chime:
                // Bright struck-bar partials that decay faster than the fundamental
                value = sin(phase)
                    + 0.5 * sin(phase * 3.01) * exp(-t * 9)
                    + 0.25 * sin(phase * 6.2) * exp(-t * 14)
            case .pluck:
                value = 0.0
                for h in 1...6 {
                    value += sin(phase * Double(h)) / Double(h) * exp(-t * Double(h) * 2.2)
                }
            case .retro:
                value = sin(phase) > 0 ? 0.6 : -0.6
            }

            // Envelope: 6ms attack, exponential decay, fade tail
            let attack = min(1.0, t / 0.006)
            let decay = exp(-t * 3.5)
            let release = progress > 0.85 ? (1.0 - progress) / 0.15 : 1.0
            let envelope = attack * decay * release

            let frame = startFrame + i
            samples[frame] += Float(value * envelope) * event.volume * 0.4
        }
    }

    private func renderPop() -> AVAudioPCMBuffer {
        let duration = 0.12
        let frames = AVAudioFrameCount(duration * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let samples = buffer.floatChannelData![0]
        let twoPi = 2.0 * Double.pi
        var phase = 0.0
        for i in 0..<Int(frames) {
            let t = Double(i) / sampleRate
            let progress = t / duration
            // Downward frequency sweep 700 -> 150 Hz = bubble pop
            let freq = 700.0 - 550.0 * progress
            phase += twoPi * freq / sampleRate
            let envelope = min(1.0, t / 0.003) * exp(-t * 28)
            samples[i] = Float(sin(phase) * envelope) * 0.5
        }
        return buffer
    }
}
