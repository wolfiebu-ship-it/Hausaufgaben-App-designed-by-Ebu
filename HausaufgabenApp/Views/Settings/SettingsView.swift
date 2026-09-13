import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var exportDocument: BackupDocument?
    @State private var showExporter = false
    @State private var showImportWarning = false
    @State private var showImporter = false
    @State private var showResetConfirmation = false
    @State private var showDeleteHomeworkConfirmation = false
    @State private var infoMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                if let error = store.lastErrorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }

                appearanceSection
                timetableSection
                homeworkSection
                dataSection
                aboutSection
            }
            .navigationTitle("Einstellungen")
            .fileExporter(isPresented: $showExporter,
                          document: exportDocument,
                          contentType: .json,
                          defaultFilename: exportFilename) { result in
                switch result {
                case .success:
                    infoMessage = "Die Sicherung wurde gespeichert."
                case .failure(let error):
                    infoMessage = "Die Sicherung ist fehlgeschlagen: \(error.localizedDescription)"
                }
            }
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.json],
                          allowsMultipleSelection: false) { result in
                handleImport(result)
            }
            .alert("Sicherung wiederherstellen?",
                   isPresented: $showImportWarning) {
                Button("Datei auswählen") { showImporter = true }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Alle Fächer, der Stundenplan und alle Hausaufgaben auf diesem Gerät werden durch den Inhalt der Sicherung ersetzt.")
            }
            .alert("Alle Hausaufgaben löschen?",
                   isPresented: $showDeleteHomeworkConfirmation) {
                Button("Löschen", role: .destructive) {
                    store.deleteAllHomework()
                    infoMessage = "Alle Hausaufgaben wurden gelöscht."
                }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Fächer und Stundenplan bleiben erhalten. Das lässt sich nicht rückgängig machen.")
            }
            .alert("App zurücksetzen?",
                   isPresented: $showResetConfirmation) {
                Button("Zurücksetzen", role: .destructive) {
                    store.resetToFactoryDefaults()
                    infoMessage = "Die App wurde zurückgesetzt."
                }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Fächer, Stundenplan und alle Hausaufgaben werden gelöscht. Das lässt sich nicht rückgängig machen.")
            }
            .alert("Hinweis",
                   isPresented: Binding(get: { infoMessage != nil },
                                        set: { if !$0 { infoMessage = nil } })) {
                Button("OK") { infoMessage = nil }
            } message: {
                Text(infoMessage ?? "")
            }
        }
    }

    // MARK: - Abschnitte

    private var appearanceSection: some View {
        Section {
            Picker("Erscheinungsbild", selection: $store.settings.appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.vertical, 2)
        } header: {
            Text("Darstellung")
        } footer: {
            Text(appearanceFooter)
        }
    }

    private var appearanceFooter: String {
        switch store.settings.appearance {
        case .system: return "Die App richtet sich danach, ob dein Gerät gerade auf hell oder dunkel steht."
        case .light:  return "Die App bleibt immer hell – auch wenn das Gerät auf dunkel steht."
        case .dark:   return "Die App bleibt immer dunkel – auch wenn das Gerät auf hell steht."
        }
    }

    private var timetableSection: some View {
        Section {
            Stepper(value: $store.settings.periodCount, in: 1...14) {
                HStack {
                    Text("Stunden pro Tag")
                    Spacer()
                    Text("\(store.settings.periodCount)")
                        .foregroundStyle(.secondary)
                }
            }

            Toggle("Samstag anzeigen", isOn: $store.settings.includeSaturday)
            Toggle("Uhrzeiten anzeigen", isOn: $store.settings.showTimes)

            NavigationLink {
                PeriodTimesView()
                    .environmentObject(store)
            } label: {
                Text("Unterrichtszeiten")
            }
        } header: {
            Text("Stundenplan")
        }
    }

    private var homeworkSection: some View {
        Section {
            Toggle("Alle Fächer des Tages zeigen", isOn: $store.settings.showEmptySubjects)
        } header: {
            Text("Hausaufgaben")
        } footer: {
            Text(store.settings.showEmptySubjects
                 ? "Jeder Tag zeigt alle Fächer aus dem Stundenplan – bereit zum Eintragen."
                 : "Jeder Tag zeigt nur Fächer, zu denen schon etwas eingetragen ist. Weitere Fächer lassen sich über „Fach ergänzen“ hinzufügen.")
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                prepareExport()
            } label: {
                Label("Sicherung speichern", systemImage: "square.and.arrow.up")
            }

            Button {
                showImportWarning = true
            } label: {
                Label("Sicherung wiederherstellen", systemImage: "square.and.arrow.down")
            }

            Button(role: .destructive) {
                showDeleteHomeworkConfirmation = true
            } label: {
                Label("Alle Hausaufgaben löschen", systemImage: "trash")
            }

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("App zurücksetzen", systemImage: "arrow.counterclockwise")
            }
        } header: {
            Text("Daten")
        } footer: {
            Text("Alle Daten liegen nur auf diesem Gerät. Lege ab und zu eine Sicherung an, zum Beispiel in deiner iCloud Drive.")
        }
    }

    private var aboutSection: some View {
        Section {
            LabeledContent("Fächer", value: "\(store.subjects.count)")
            LabeledContent("Stunden im Plan", value: "\(store.lessons.filter { $0.subjectID != nil }.count)")
            LabeledContent("Hausaufgaben", value: "\(store.homework.filter(\.hasText).count)")
            LabeledContent("Version", value: appVersion)
        } header: {
            Text("Über die App")
        }
    }

    // MARK: - Sicherung

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var exportFilename: String {
        "Hausaufgaben-Sicherung-\(SchoolCalendar.dayKey(Date()))"
    }

    private func prepareExport() {
        store.saveNow()
        do {
            exportDocument = BackupDocument(data: try store.exportData())
            showExporter = true
        } catch {
            infoMessage = "Die Sicherung konnte nicht erstellt werden: \(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            infoMessage = "Die Datei konnte nicht geöffnet werden: \(error.localizedDescription)"

        case .success(let urls):
            guard let url = urls.first else { return }

            // Dateien außerhalb der App müssen für den Zugriff freigeschaltet werden.
            let needsRelease = url.startAccessingSecurityScopedResource()
            defer { if needsRelease { url.stopAccessingSecurityScopedResource() } }

            do {
                let data = try Data(contentsOf: url)
                let imported = try AppStore.decode(data)
                store.replaceAll(with: imported)
                infoMessage = "Die Sicherung wurde geladen: \(imported.subjects.count) Fächer, \(imported.homework.count) Hausaufgaben."
            } catch {
                infoMessage = "Die Datei ist keine gültige Sicherung dieser App."
            }
        }
    }
}
