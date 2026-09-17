import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Tab = .homework

    enum Tab: Hashable {
        case homework, calendar, timetable, notes, settings
    }

    var body: some View {
        TabView(selection: $selection) {
            HomeworkPagerView()
                .tabItem { Label("Hausaufgaben", systemImage: "square.and.pencil") }
                .tag(Tab.homework)

            CalendarView()
                .tabItem { Label("Kalender", systemImage: "calendar") }
                .tag(Tab.calendar)

            TimetableView()
                // iOS schreibt die Beschriftung in der Tab-Leiste immer auf
                // eine Zeile und kürzt sie auf schmalen Geräten ab – zwei
                // Zeilen lässt die eingebaute Leiste nicht zu.
                .tabItem { Label("Stundenplan & Fächer", systemImage: "tablecells") }
                .tag(Tab.timetable)

            NotesView()
                .tabItem { Label("Notizen", systemImage: "note.text") }
                .tag(Tab.notes)

            SettingsView()
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .task {
            // Beim Start einmal abgleichen: Was iOS vorgemerkt hat, soll dem
            // entsprechen, was im Kalender steht – auch nach einer Sicherung
            // oder wenn Termine vorbei sind.
            store.syncReminders()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Beim Wechsel in den Hintergrund sofort sichern.
            if newPhase != .active {
                store.saveNow()
            }
        }
    }
}
