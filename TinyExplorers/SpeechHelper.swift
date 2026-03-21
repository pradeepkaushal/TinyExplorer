import AVFoundation

/// Shared speech helper providing a clear, high-quality voice across all games
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
}
