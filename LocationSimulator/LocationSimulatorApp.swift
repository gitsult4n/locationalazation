import SwiftUI
import SwiftData

@main
struct LocationSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedLocation.self)
    }
}
