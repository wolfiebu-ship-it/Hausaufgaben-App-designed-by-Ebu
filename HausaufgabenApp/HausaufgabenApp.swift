import SwiftUI

@main
struct HausaufgabenApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                // Gilt für die ganze App, auch für Blätter und Auswahlfenster.
                .preferredColorScheme(store.settings.appearance.colorScheme)
        }
    }
}
