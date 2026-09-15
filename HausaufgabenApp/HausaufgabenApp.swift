import SwiftUI

@main
struct HausaufgabenApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var lock = LockController()

    var body: some Scene {
        WindowGroup {
            AppGateView()
                .environmentObject(store)
                .environmentObject(lock)
                // Gilt für die ganze App, auch für Blätter und Auswahlfenster.
                .preferredColorScheme(store.settings.appearance.colorScheme)
        }
    }
}
