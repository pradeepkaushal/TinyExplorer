import SwiftUI
import AVFoundation

struct NumberGameView: View {
    @State private var currentNumber = 1
    @State private var tappedCount = 0
    @State private var items: [CountItem] = []
    @State private var showCelebration = false
    @State private var bounceNumber = false

    let synthesizer = AVSpeechSynthesizer()

    let numberEmojis: [Int: String] = [
        1: "🍎", 2: "🌟", 3: "🐱", 4: "🌺", 5: "🦋",
        6: "🐠", 7: "🎈", 8: "🍪", 9: "🐤", 10: "🌈",
        11: "🍩", 12: "🐸", 13: "🌻", 14: "🍬", 15: "🦄",
        16: "🎵", 17: "🍓", 18: "🐙", 19: "🌮", 20: "🎂"
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.85, green: 0.9, blue: 1.0), Color(red: 0.9, green: 0.85, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Number display
                HStack(spacing: 32) {
                    Button(action: { changeNumber(-1) }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(currentNumber > 1 ? .blue : .gray)
                    }
                    .disabled(currentNumber <= 1)

                    VStack(spacing: 4) {
                        Text("\(currentNumber)")
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                            )
                            .scaleEffect(bounceNumber ? 1.3 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.4), value: bounceNumber)

                        Text(numberWord(currentNumber))
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    Button(action: { changeNumber(1) }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(currentNumber < 20 ? .blue : .gray)
                    }
                    .disabled(currentNumber >= 20)
                }

                // Counting area
                Text("Tap to count to \(currentNumber)! (\(tappedCount)/\(currentNumber))")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                // Items grid
                let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 16), count: min(currentNumber, 5))
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(items) { item in
                        Button(action: {
                            tapItem(item)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(item.tapped ? Color.green.opacity(0.3) : Color.white.opacity(0.8))
                                    .frame(width: 110, height: 110)
                                    .shadow(radius: 3)

                                if item.tapped {
                                    Text(numberEmojis[currentNumber] ?? "⭐")
                                        .font(.system(size: 56))
                                        .transition(.scale)
                                } else {
                                    Text("?")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .disabled(item.tapped)
                        .animation(.spring(), value: item.tapped)
                    }
                }
                .padding(.horizontal, 40)

                // Reset button
                Button(action: resetCounting) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.blue))
                }

                Spacer()
            }
            .padding(.top, 16)

            if showCelebration {
                VStack {
                    Text("🎉 Great job! 🎉")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(.white).shadow(radius: 10))
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationTitle("123 Numbers")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { resetCounting() }
    }

    func changeNumber(_ delta: Int) {
        currentNumber = max(1, min(20, currentNumber + delta))
        bounceNumber = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { bounceNumber = false }
        resetCounting()
        speakNumber()
    }

    func tapItem(_ item: CountItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }), !items[index].tapped else { return }
        items[index].tapped = true
        tappedCount += 1

        speak("\(tappedCount)")

        if tappedCount == currentNumber {
            withAnimation {
                showCelebration = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                speak("Great job! You counted to \(currentNumber)!")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showCelebration = false }
            }
        }
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.3
        utterance.pitchMultiplier = 1.2
        utterance.voice = SpeechHelper.preferredVoice
        synthesizer.speak(utterance)
    }

    func resetCounting() {
        tappedCount = 0
        showCelebration = false
        items = (0..<currentNumber).map { _ in CountItem() }
    }

    func speakNumber() {
        speak("\(currentNumber), \(numberWord(currentNumber))")
    }

    func numberWord(_ n: Int) -> String {
        let words = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
                     "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
                     "Eighteen", "Nineteen", "Twenty"]
        return n <= 20 ? words[n] : "\(n)"
    }
}

struct CountItem: Identifiable {
    let id = UUID()
    var tapped = false
}

#Preview {
    NavigationStack {
        NumberGameView()
    }
}
