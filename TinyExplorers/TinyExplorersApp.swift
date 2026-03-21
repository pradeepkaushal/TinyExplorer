import SwiftUI

@main
struct TinyExplorersApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
        }
    }
}
