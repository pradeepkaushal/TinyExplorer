import AVFoundation
import CryptoKit

/// Shared speech for all games, tuned to sound like a cheerful kid.
/// Fixed phrases were pre-rendered with a neural voice and bundled in
/// BundledVoice/ (file name = sha256 of the exact text); they play through a
/// pitch-shifter so the narrator sounds young. Live text-to-speech (also
/// pitched up) is the fallback for dynamic text.
enum SpeechHelper {
    /// Bundled clips are recorded with a real child voice (en-US-AnaNeural),
    /// so they play at natural speed. Varispeed stays in the chain only for
    /// the playful rate jitter on celebration lines.
    private static let kidClipSpeed: Float = 1.0
    /// Live TTS pitch multiplier for the kid voice. Values near the API
    /// max of 2 start to warble, so stay well below.
    private static let kidTTSPitch: Float = 1.32

    /// Returns the best available enhanced English voice
    static let preferredVoice: AVSpeechSynthesisVoice? = {
        // Prefer premium/enhanced voices for clarity
        let preferredIdentifiers = [
            "com.apple.voice.premium.en-US.Ava",
            "com.apple.voice.enhanced.en-US.Ava",
            "com.apple.voice.premium.en-US.Zoe",
            "com.apple.voice.enhanced.en-US.Zoe",
            "com.apple.voice.premium.en-US.Samantha",
            "com.apple.voice.enhanced.en-US.Samantha",
            "com.apple.voice.compact.en-US.Samantha",
        ]
        for id in preferredIdentifiers {
            if let voice = AVSpeechSynthesisVoice(identifier: id) {
                return voice
            }
        }
        // Fallback: pick the highest quality en-US voice available
        let enVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        return enVoices.first ?? AVSpeechSynthesisVoice(language: "en-US")
    }()

    /// Playful character voices that ship with iOS. "Junior" leads because
    /// it is the closest to an actual child; the rest add variety.
    private static let funVoiceNames = [
        "Junior", "Superstar", "Bubbles", "Good News", "Jester",
    ]
    static let funVoices: [AVSpeechSynthesisVoice] = {
        let english = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        return funVoiceNames.compactMap { name in
            english.first { $0.name.localizedCaseInsensitiveContains(name) }
        }
    }()

    private static let synthesizer = AVSpeechSynthesizer()

    /// Speak with natural pacing. Bundled neural recordings (pitched up to a
    /// kid voice) play first; live TTS covers anything dynamic.
    static func speak(_ text: String, rate: Float = 0.48, pitch: Float = kidTTSPitch) {
        if playBundledClip(for: text) { return }
        let jitter = Float.random(in: -0.06...0.05)
        utter(text, voice: preferredVoice, rate: rate, pitch: min(2.0, pitch + jitter))
    }

    /// Celebration lines: bundled recording with playful speed variation,
    /// else the child-like "Junior" voice when installed, else the pitched-up
    /// main voice.
    static func cheer(_ text: String) {
        if playBundledClip(for: text, rateJitter: true) { return }
        if let junior = funVoices.first {
            utter(text, voice: junior, rate: 0.5, pitch: 1.15)
        } else {
            utter(text, voice: preferredVoice, rate: 0.5, pitch: kidTTSPitch)
        }
    }

    static func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        ClipEngine.shared.stop()
    }

    private static func playBundledClip(for text: String, rateJitter: Bool = false) -> Bool {
        let hash = SHA256.hash(data: Data(text.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
            .prefix(20)
        guard let url = Bundle.main.url(
            forResource: String(hash), withExtension: "m4a", subdirectory: "BundledVoice"
        ) else { return false }

        synthesizer.stopSpeaking(at: .immediate)
        let speed = rateJitter ? kidClipSpeed * Float.random(in: 0.97...1.05) : kidClipSpeed
        return ClipEngine.shared.play(url: url, speed: speed)
    }

    private static func utter(_ text: String, voice: AVSpeechSynthesisVoice?, rate: Float, pitch: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.voice = voice
        synthesizer.stopSpeaking(at: .immediate)
        ClipEngine.shared.stop()
        synthesizer.speak(utterance)
    }
}

/// Plays bundled voice clips through AVAudioUnitVarispeed so the recorded
/// narrator sounds like a kid. Varispeed raises pitch by resampling — no
/// spectral smearing, so speech stays crisp. All engine work happens on a
/// serial background queue: audio-session activation takes long enough to
/// visibly stall a screen's first frame if done on the main thread (games
/// speak from onAppear).
private final class ClipEngine {
    static let shared = ClipEngine()

    private let queue = DispatchQueue(label: "TinyExplorers.ClipEngine")
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let varispeed = AVAudioUnitVarispeed()
    private var connectedFormat: AVAudioFormat?
    private var started = false

    private init() {
        engine.attach(player)
        engine.attach(varispeed)
    }

    /// Schedules the clip asynchronously. Returns false only when the file
    /// can't be read; a rare engine-start failure just means silence rather
    /// than falling back to TTS.
    func play(url: URL, speed: Float) -> Bool {
        guard let file = try? AVAudioFile(forReading: url) else { return false }

        queue.async { [self] in
            player.stop()

            // (Re)wire the chain in the file's format the first time and
            // whenever the clip format changes; the mixer handles conversion
            // to the hardware format.
            if connectedFormat?.isEqual(file.processingFormat) != true {
                engine.disconnectNodeOutput(player)
                engine.disconnectNodeOutput(varispeed)
                engine.connect(player, to: varispeed, format: file.processingFormat)
                engine.connect(varispeed, to: engine.mainMixerNode, format: file.processingFormat)
                connectedFormat = file.processingFormat
            }

            if !started {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
                try? AVAudioSession.sharedInstance().setActive(true)
                do {
                    try engine.start()
                } catch {
                    return // No audio available (e.g. some simulators).
                }
                started = true
            }

            varispeed.rate = speed
            player.scheduleFile(file, at: nil)
            player.play()
        }
        return true
    }

    func stop() {
        queue.async { [self] in
            if started { player.stop() }
        }
    }
}
