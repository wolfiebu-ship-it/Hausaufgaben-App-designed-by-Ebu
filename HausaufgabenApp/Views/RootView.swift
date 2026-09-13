import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Tab = .homework

    enum Tab: Hashable {
        case homework, timetable, subjects, settings
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeworkPagerView()
                .tabItem { Label("Hausaufgaben", systemImage: "square.and.pencil") }
                .tag(Tab.homework)

            TimetableView()
                .tabItem { Label("Stundenplan", systemImage: "calendar") }
                .tag(Tab.timetable)

            SubjectsView()
                .tabItem { Label("Fächer", systemImage: "books.vertical") }
                .tag(Tab.subjects)

            SettingsView()
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Beim Wechsel in den Hintergrund sofort sichern.
            if newPhase != .active {
                store.saveNow()
            }
        }
    }
}
