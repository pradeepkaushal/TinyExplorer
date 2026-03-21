import SwiftUI
import AVFoundation

struct SocialScenario: Identifiable {
    let id = UUID()
    let situation: String
    let emoji: String
    let options: [SocialOption]
    let category: String
}

struct SocialOption: Identifiable {
    let id = UUID()
    let text: String
    let emoji: String
    let isCorrect: Bool
    let explanation: String
}

struct SocialGameView: View {
    let scenarios: [SocialScenario] = [
        // Manners & Politeness
        SocialScenario(
            situation: "Someone gives you a gift. What do you say?",
            emoji: "🎁",
            options: [
                SocialOption(text: "Thank you!", emoji: "😊", isCorrect: true, explanation: "Saying 'thank you' shows you appreciate the gift!"),
                SocialOption(text: "I don't like it", emoji: "😒", isCorrect: false, explanation: "Even if you don't love the gift, it's kind to say thank you."),
                SocialOption(text: "Give me more!", emoji: "😤", isCorrect: false, explanation: "Asking for more can hurt someone's feelings."),
            ],
            category: "Manners"
        ),
        SocialScenario(
            situation: "You accidentally bump into someone. What do you do?",
            emoji: "💥",
            options: [
                SocialOption(text: "Say 'Sorry!'", emoji: "🙏", isCorrect: true, explanation: "Apologizing shows you care about others!"),
                SocialOption(text: "Walk away", emoji: "🚶", isCorrect: false, explanation: "Walking away without saying sorry can make someone feel bad."),
                SocialOption(text: "Laugh at them", emoji: "😂", isCorrect: false, explanation: "Laughing can hurt their feelings. It's better to say sorry."),
            ],
            category: "Manners"
        ),
        // Emotions
        SocialScenario(
            situation: "Your friend is crying. What should you do?",
            emoji: "😢",
            options: [
                SocialOption(text: "Ask if they're OK", emoji: "🤗", isCorrect: true, explanation: "Asking shows you care and want to help your friend!"),
                SocialOption(text: "Ignore them", emoji: "🙈", isCorrect: false, explanation: "Friends need us when they're sad. Try to help!"),
                SocialOption(text: "Tell them to stop", emoji: "🛑", isCorrect: false, explanation: "Everyone needs to express their feelings. Be patient and kind."),
            ],
            category: "Emotions"
        ),
        SocialScenario(
            situation: "You feel really angry. What's the best thing to do?",
            emoji: "😡",
            options: [
                SocialOption(text: "Take deep breaths", emoji: "🌬️", isCorrect: true, explanation: "Breathing deeply helps calm you down so you can think clearly!"),
                SocialOption(text: "Yell at someone", emoji: "🗣️", isCorrect: false, explanation: "Yelling can hurt others. Try calming down first."),
                SocialOption(text: "Break something", emoji: "💔", isCorrect: false, explanation: "Breaking things doesn't help. Deep breaths are much better!"),
            ],
            category: "Emotions"
        ),
        // Sharing
        SocialScenario(
            situation: "You have cookies and your friend has none. What do you do?",
            emoji: "🍪",
            options: [
                SocialOption(text: "Share some!", emoji: "🤝", isCorrect: true, explanation: "Sharing makes everyone happy and is a great way to be kind!"),
                SocialOption(text: "Eat them all", emoji: "😋", isCorrect: false, explanation: "Eating them all when your friend has none isn't very kind."),
                SocialOption(text: "Hide them", emoji: "🙈", isCorrect: false, explanation: "Hiding food from a friend can make them sad. Sharing is caring!"),
            ],
            category: "Sharing"
        ),
        SocialScenario(
            situation: "A new kid joins your class. What should you do?",
            emoji: "👋",
            options: [
                SocialOption(text: "Say hello and be friendly", emoji: "😄", isCorrect: true, explanation: "Being friendly helps new kids feel welcome and happy!"),
                SocialOption(text: "Ignore them", emoji: "😐", isCorrect: false, explanation: "Being ignored feels lonely. Saying hi can make their whole day!"),
                SocialOption(text: "Whisper about them", emoji: "🤫", isCorrect: false, explanation: "Whispering about someone can hurt their feelings."),
            ],
            category: "Friendship"
        ),
        // Safety
        SocialScenario(
            situation: "A stranger asks you to go with them. What do you do?",
            emoji: "⚠️",
            options: [
                SocialOption(text: "Say NO and tell a grown-up", emoji: "🚫", isCorrect: true, explanation: "Always say no to strangers and tell a trusted adult right away!"),
                SocialOption(text: "Go with them", emoji: "🚶", isCorrect: false, explanation: "Never go with strangers! Always tell a trusted grown-up."),
                SocialOption(text: "Take their candy", emoji: "🍬", isCorrect: false, explanation: "Never accept things from strangers. Tell a grown-up instead!"),
            ],
            category: "Safety"
        ),
        // Teamwork
        SocialScenario(
            situation: "Your team is working on a project but one person isn't helping. What do you do?",
            emoji: "🏗️",
            options: [
                SocialOption(text: "Ask them nicely to help", emoji: "💬", isCorrect: true, explanation: "Asking nicely encourages everyone to participate!"),
                SocialOption(text: "Do all the work yourself", emoji: "😩", isCorrect: false, explanation: "It's better to include everyone. Ask them what they'd like to do!"),
                SocialOption(text: "Tell on them", emoji: "☝️", isCorrect: false, explanation: "Try asking them first. Maybe they don't know how to help!"),
            ],
            category: "Teamwork"
        ),
    ]

    @State private var currentIndex = 0
    @State private var selectedOption: SocialOption? = nil
    @State private var score = 0
    @State private var answeredCount = 0
    @State private var showExplanation = false
    @State private var shuffledScenarios: [SocialScenario] = []

    let synthesizer = AVSpeechSynthesizer()

    var currentScenario: SocialScenario {
        shuffledScenarios.isEmpty ? scenarios[0] : shuffledScenarios[currentIndex % shuffledScenarios.count]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.85), Color(red: 0.95, green: 0.88, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Score bar
                HStack(spacing: 24) {
                    Label("\(score) Stars", systemImage: "star.fill")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Spacer()

                    Text("Category: \(currentScenario.category)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.7)))

                    Spacer()

                    Text("Question \(answeredCount + 1)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)

                // Scenario card
                VStack(spacing: 16) {
                    Text(currentScenario.emoji)
                        .font(.system(size: 100))

                    Text(currentScenario.situation)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Button("🔊 Read aloud") {
                        speakText(currentScenario.situation)
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .padding(28)
                .frame(maxWidth: 700)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.white.opacity(0.85))
                        .shadow(radius: 8)
                )

                // Options
                VStack(spacing: 14) {
                    ForEach(currentScenario.options) { option in
                        Button(action: {
                            selectOption(option)
                        }) {
                            HStack(spacing: 20) {
                                Text(option.emoji)
                                    .font(.system(size: 48))

                                Text(option.text)
                                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                Spacer()

                                if selectedOption?.id == option.id {
                                    Image(systemName: option.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(option.isCorrect ? .green : .red)
                                }
                            }
                            .padding(22)
                            .frame(maxWidth: 700)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(backgroundColor(for: option))
                                    .shadow(radius: 3)
                            )
                        }
                        .disabled(selectedOption != nil)
                    }
                }

                // Explanation
                if showExplanation, let option = selectedOption {
                    VStack(spacing: 8) {
                        Text(option.isCorrect ? "Great choice!" : "Let's learn from this!")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(option.isCorrect ? .green : .orange)

                        Text(option.explanation)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Next Question") {
                            nextQuestion()
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.blue))
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: 600)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.9))
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
            .padding(.top, 16)
        }
        .navigationTitle("Social Skills")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shuffledScenarios = scenarios.shuffled()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakText(currentScenario.situation)
            }
        }
    }

    func backgroundColor(for option: SocialOption) -> Color {
        guard let selected = selectedOption else {
            return .white.opacity(0.9)
        }
        if option.id == selected.id {
            return option.isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        if option.isCorrect {
            return Color.green.opacity(0.1)
        }
        return .white.opacity(0.5)
    }

    func selectOption(_ option: SocialOption) {
        withAnimation(.spring()) {
            selectedOption = option
            showExplanation = true
        }

        if option.isCorrect {
            score += 1
            speakText("Great choice! \(option.explanation)")
        } else {
            speakText("Let's learn from this. \(option.explanation)")
        }
    }

    func nextQuestion() {
        withAnimation {
            selectedOption = nil
            showExplanation = false
            answeredCount += 1
            currentIndex += 1

            if currentIndex >= shuffledScenarios.count {
                shuffledScenarios = scenarios.shuffled()
                currentIndex = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            speakText(currentScenario.situation)
        }
    }

    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.1
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}

#Preview {
    NavigationStack {
        SocialGameView()
    }
}
