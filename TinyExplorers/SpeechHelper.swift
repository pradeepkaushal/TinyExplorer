import AVFoundation
import CryptoKit

/// Shared speech for all games. Fixed phrases were pre-rendered with a
/// neural voice and bundled in BundledVoice/ (file name = sha256 of the
/// exact text), so most lines play as natural recorded audio; live
/// text-to-speech is only the fallback for dynamic text.
enum SpeechHelper {
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

    /// Playful character voices that ship with iOS (Superstar, Jester,
    /// Grandma…). Whatever subset is installed gets used for celebrations.
    private static let funVoiceNames = [
        "Superstar", "Jester", "Bubbles", "Good News", "Grandma", "Grandpa", "Junior",
    ]
    static let funVoices: [AVSpeechSynthesisVoice] = {
        let english = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        return funVoiceNames.compactMap { name in
            english.first { $0.name.localizedCaseInsensitiveContains(name) }
        }
    }()

    private static let synthesizer = AVSpeechSynthesizer()
    private static var clipPlayer: AVAudioPlayer?

    /// Speak with natural pacing. Bundled neural recordings play first;
    /// live TTS (with slight pitch jitter so repeats never sound identical)
    /// covers anything dynamic.
    static func speak(_ text: String, rate: Float = 0.48, pitch: Float = 1.12) {
        if playBundledClip(for: text) { return }
        let jitter = Float.random(in: -0.05...0.08)
        utter(text, voice: preferredVoice, rate: rate, pitch: pitch + jitter)
    }

    /// Celebration lines: bundled recording with playful speed variation,
    /// else a random silly character voice, else the main voice.
    static func cheer(_ text: String) {
        if playBundledClip(for: text, rateJitter: true) { return }
        let voice = funVoices.randomElement() ?? preferredVoice
        utter(text, voice: voice, rate: 0.5, pitch: 1.05)
    }

    static func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        clipPlayer?.stop()
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
        clipPlayer?.stop()
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return false }
        if rateJitter {
            player.enableRate = true
            player.rate = Float.random(in: 0.94...1.12)
        }
        player.play()
        clipPlayer = player
        return true
    }

    private static func utter(_ text: String, voice: AVSpeechSynthesisVoice?, rate: Float, pitch: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.voice = voice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
