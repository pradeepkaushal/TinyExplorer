import SwiftUI

@main
struct TinyExplorersApp: App {
    var body: some Scene {
        WindowGroup {
            rootView
                .preferredColorScheme(.light)
        }
    }

    /// Normally HomeView. In DEBUG builds, `-screen <name>` (e.g. via
    /// `simctl launch ... -screen abc`) opens a game directly so automated
    /// UI checks can screenshot any screen without tap input.
    @ViewBuilder
    private var rootView: some View {
        #if DEBUG
        if let screen = Self.launchScreenOverride() {
            NavigationStack { screen }
        } else {
            HomeView()
        }
        #else
        HomeView()
        #endif
    }

    #if DEBUG
    private static func launchScreenOverride() -> AnyView? {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "-screen"), args.count > flagIndex + 1 else {
            return nil
        }
        switch args[flagIndex + 1] {
        case "abc": return AnyView(ABCGameView())
        case "numbers": return AnyView(NumberGameView())
        case "math": return AnyView(MathGameView())
        case "shapes": return AnyView(ShapesGameView())
        case "animals": return AnyView(AnimalGameView())
        case "social": return AnyView(SocialGameView())
        case "memory": return AnyView(MemoryGameView())
        case "puzzle": return AnyView(PuzzleGameView())
        case "drawing": return AnyView(DrawingGameView())
        case "music": return AnyView(MusicGameView())
        case "pattern": return AnyView(PatternGameView())
        case "oddOneOut": return AnyView(OddOneOutGameView())
        case "counting": return AnyView(CountingGameView())
        case "emotions": return AnyView(EmotionsGameView())
        default: return nil
        }
    }
    #endif
}
