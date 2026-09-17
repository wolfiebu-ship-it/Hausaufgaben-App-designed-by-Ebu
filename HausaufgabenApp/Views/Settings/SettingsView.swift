import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var lockController: LockController

    @State private var exportDocument: BackupDocument?
    @State private var showExporter = false
    @State private var showImportWarning = false
    @State private var showImporter = false
    @State private var showResetConfirmation = false
    @State private var showDeleteHomeworkConfirmation = false
    @State private var infoMessage: String?
    @State private var showLockSetup = false
    @State private var isChangingCode = false
    @State private var showLockOffConfirmation = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

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

                profileSection
                subjectsSection
                stateSection
                remindersSection
                lockSection
                legendSection
                dotLegendSection
                appearanceSection
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

    // MARK: - Fächer

    /// Die Fächer wohnen beim Stundenplan – von hier führt ebenfalls ein Weg hin.
    private var subjectsSection: some View {
        Section {
            NavigationLink {
                SubjectsView()
                    .environmentObject(store)
            } label: {
                Label("Fächer", systemImage: "books.vertical.fill")
            }
        } footer: {
            Text("Name, Kürzel, Farbe, Lehrkraft und Raum. Im Stundenplan oben links kommst du auch hierhin.")
        }
    }

    // MARK: - Bundesland

    /// Das Bundesland: davon hängen die gesetzlichen Feiertage ab.
    private var stateSection: some View {
        Section {
            Picker(selection: stateBinding) {
                Text("Nicht angegeben").tag(FederalState.none)
                ForEach(FederalState.allStates) { land in
                    Text(land.name).tag(land)
                }
            } label: {
                Label("Bundesland", systemImage: "map.fill")
            }
            .pickerStyle(.navigationLink)

            if store.settings.federalState.isSet {
                ForEach(store.upcomingPublicHolidays(limit: 4)) { feiertag in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(Holiday.tint)
                            .frame(width: 7, height: 7)
                            .padding(.top, 5)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(feiertag.name)
                                .font(.subheadline)
                            if let note = feiertag.note {
                                Text(note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer(minLength: 0)

                        Text(Holiday.longWeekdayText(feiertag.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        } header: {
            Text("Bundesland")
        } footer: {
            Text(stateFooter)
        }
    }

    private var stateBinding: Binding<FederalState> {
        Binding(get: { store.settings.federalState },
                set: { neu in
                    store.settings.federalState = neu
                    Haptics.tap()
                })
    }

    private var stateFooter: String {
        let land = store.settings.federalState
        guard land.isSet else {
            return "Stell dein Bundesland ein, dann trägt Homy die gesetzlichen Feiertage von selbst in den Kalender ein – grün, wie die Ferien.\n\nDie Schulferien kann dir das nicht abnehmen: Die legt jedes Land für jedes Schuljahr neu fest, und erfundene Termine wären schlimmer als gar keine. Die trägst du einmal aus dem Ferienplan deiner Schule im Kalender ein."
        }

        var text = "Oben stehen die nächsten Feiertage in \(land.name). Homy rechnet sie selbst aus – auch für kommende Jahre, ohne Internet und ohne dass du etwas eintragen musst. Im Kalender sind sie grün wie die Ferien.\n\n"
        text += "Die Schulferien stecken da nicht mit drin: Die legt jedes Land für jedes Schuljahr neu fest, sie lassen sich nicht ausrechnen. Trag sie einmal aus dem Ferienplan deiner Schule im Kalender ein – dann stehen sie."

        if land == .bayern {
            text += "\n\nIn Bayern ist Mariä Himmelfahrt nur in überwiegend katholischen Gemeinden frei."
        }
        if land == .sachsen || land == .thueringen {
            text += "\n\nIn einzelnen Gemeinden kann zusätzlich Fronleichnam frei sein – das steht hier nicht mit drin."
        }
        return text
    }

    // MARK: - Erinnerungen

    /// Benachrichtigungen zu Kalenderterminen.
    private var remindersSection: some View {
        Section {
            Toggle(isOn: remindersBinding) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("An Termine erinnern")
                    Text("Homy meldet sich, bevor eine Arbeit ansteht oder die Ferien anfangen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if store.settings.remindersEnabled {
                Picker(selection: defaultReminderBinding) {
                    ForEach(ReminderOffset.allCases) { offset in
                        Text(offset.title).tag(offset)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neue Termine erinnern")
                        Text(store.settings.defaultReminder.explanation)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .pickerStyle(.navigationLink)

                if notificationStatus == .denied {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("iOS lässt keine Benachrichtigungen zu", systemImage: "bell.slash.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.orange)
                        Text("Solange das so ist, kommt keine Erinnerung an. Du kannst es in den Einstellungen des iPhones wieder erlauben.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Einstellungen des iPhones öffnen") {
                            openSystemSettings()
                        }
                        .font(.footnote)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Text("Erinnerungen")
        } footer: {
            Text(remindersFooter)
        }
        .task { await refreshNotificationStatus() }
    }

    private var remindersBinding: Binding<Bool> {
        Binding(get: { store.settings.remindersEnabled },
                set: { neu in
                    store.settings.remindersEnabled = neu
                    store.syncReminders()
                    if neu {
                        Task {
                            await Reminders.requestAuthorization()
                            await refreshNotificationStatus()
                            store.syncReminders()
                        }
                    }
                })
    }

    private var defaultReminderBinding: Binding<ReminderOffset> {
        Binding(get: { store.settings.defaultReminder },
                set: { store.settings.defaultReminder = $0 })
    }

    private var remindersFooter: String {
        guard store.settings.remindersEnabled else {
            return "Aus. Bereits eingetragene Termine bleiben im Kalender stehen, es kommt nur keine Benachrichtigung mehr."
        }
        var text = "Bei jedem Termin lässt sich die Erinnerung auch einzeln einstellen. "
        text += "Die Benachrichtigung schickt iOS – sie kommt auch, wenn Homy geschlossen ist, und nichts davon geht ins Internet."
        if store.events.isEmpty && store.holidays.isEmpty {
            text += "\n\nNoch nichts eingetragen: Termine und Ferien legst du im Kalender über das Plus oben rechts an."
        }
        return text
    }

    private func refreshNotificationStatus() async {
        let status = await Reminders.authorizationStatus()
        await MainActor.run { notificationStatus = status }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Anmeldung

    /// Die Anmeldung: ein Code für alle – und der Schnellstart für einen selbst.
    @ViewBuilder
    private var lockSection: some View {
        Section {
            if store.lock.isActive {
                activeLockRows
            } else {
                Button {
                    isChangingCode = false
                    showLockSetup = true
                } label: {
                    Label("Anmeldung einrichten", systemImage: "lock.fill")
                }
            }
        } header: {
            Text("Anmeldung")
        } footer: {
            Text(lockFooter)
        }
        .sheet(isPresented: $showLockSetup) {
            LockSetupView(isChanging: isChangingCode)
                .environmentObject(store)
        }
        .confirmationDialog("Anmeldung ausschalten?",
                            isPresented: $showLockOffConfirmation,
                            titleVisibility: .visible) {
            Button("Ausschalten", role: .destructive) {
                var neu = store.lock
                neu.clearCode()
                store.lock = neu
            }
        } message: {
            Text("Danach kann jeder, der das Gerät in der Hand hat, Homy öffnen. Der Code wird gelöscht.")
        }
    }

    @ViewBuilder
    private var activeLockRows: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text("Anmeldung ist an")
                    .font(.body.weight(.semibold))
                Text("\(store.lock.codeLength)-stelliger Code")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "lock.fill")
                .foregroundStyle(.green)
        }

        if biometrics.isAvailable {
            Toggle(isOn: biometricsBinding) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Schnellstart mit \(biometrics.title)")
                    Text("Nur ansehen statt tippen – gilt für dich, nicht für andere.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }

        Picker(selection: timingBinding) {
            ForEach(LockTiming.allCases) { timing in
                Text(timing.title).tag(timing)
            }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text("Code abfragen")
                Text(store.lock.timing.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .pickerStyle(.navigationLink)

        Button {
            var neu = store.lock
            neu.useBiometrics = biometrics.isAvailable
            neu.timing = .onlyOnLaunch
            store.lock = neu
            Haptics.success()
            infoMessage = biometrics.isAvailable
                ? "Schnellstart an: \(biometrics.title) genügt, und nur beim Neustart wird gefragt."
                : "Homy fragt jetzt nur noch beim Neustart nach dem Code."
        } label: {
            Label("Schnellstart für mich einrichten", systemImage: "bolt.fill")
        }

        Button {
            isChangingCode = true
            showLockSetup = true
        } label: {
            Label("Code ändern", systemImage: "key.fill")
        }

        Button {
            lockController.lockNow()
        } label: {
            Label("Homy jetzt zusperren", systemImage: "lock.rotation")
        }

        Button(role: .destructive) {
            showLockOffConfirmation = true
        } label: {
            Label("Anmeldung ausschalten", systemImage: "lock.open")
        }
    }

    private var biometrics: BiometricKind { BiometricAuth.availableKind() }

    private var biometricsBinding: Binding<Bool> {
        Binding(get: { store.lock.useBiometrics },
                set: { store.lock.useBiometrics = $0 })
    }

    private var timingBinding: Binding<LockTiming> {
        Binding(get: { store.lock.timing },
                set: { store.lock.timing = $0 })
    }

    private var lockFooter: String {
        if store.lock.isActive {
            var text = "Ohne den Code kommt niemand an deine Hausaufgaben, Notizen und Daten. Mit dem Schnellstart musst du selbst so gut wie nie etwas eingeben."
            if biometrics.isAvailable {
                text += " \(biometrics.title) prüft iOS – Homy bekommt dein Gesicht bzw. deinen Finger nie zu sehen."
            }
            text += "\n\nDer Code steht nicht in den Sicherungsdateien: Eine Sicherung kann die Anmeldung weder setzen noch aufheben."
            return text
        }
        return "Wenn du magst, verlangt Homy beim Öffnen einen Zahlencode. Für dich selbst lässt sich danach ein Schnellstart einstellen, damit du nicht jedes Mal tippen musst."
    }

    // MARK: - Abschnitte

    /// Der Einstieg zu den eigenen Angaben.
    private var profileSection: some View {
        Section {
            NavigationLink {
                ProfileView()
                    .environmentObject(store)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.tint)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.profile.isEmpty ? "Meine Daten" : store.profile.summary)
                            .font(.body.weight(.semibold))
                        Text(store.profile.isEmpty
                             ? "Name, Klasse, Telefon, Adresse eintragen"
                             : "Angaben ansehen und ändern")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // Die Klasse steht auch unter „Meine Daten“ – hier direkt, weil
            // sie sich jedes Jahr ändert und man sie sonst lange sucht.
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.tint)
                    .frame(width: 24)

                Text("Klasse")

                Spacer(minLength: 12)

                TextField("z. B. 8b", text: $store.profile.schoolClass)
                    .multilineTextAlignment(.trailing)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .frame(maxWidth: 140)
            }
        } header: {
            Text("Über mich")
        } footer: {
            Text("Die Klasse steht auch auf der Seite „Meine Daten“ – hier kannst du sie am Schuljahresanfang schnell ändern.")
        }
    }

    /// Erklärt die beiden Felder, die an jeder Hausaufgabenzeile stehen.
    private var legendSection: some View {
        Section {
            legendRow(color: AppTheme.noHomeworkTint,
                      title: "Keine Hausaufgaben",
                      text: "Kreuze das gelbe Feld an, wenn in dem Fach nichts aufgegeben wurde. Die Zeile zeigt dann „Keine Hausaufgaben“.")

            legendRow(color: .accentColor,
                      title: "Erledigt",
                      text: "Kreuze das blaue Feld an, wenn du die Hausaufgabe gemacht hast. Aufschreiben kannst du sie im Feld daneben.")
        } header: {
            Text("Die Felder im Hausaufgabenheft")
        } footer: {
            Text("Beide lassen sich bei jedem Fach ankreuzen. Sie schließen einander aus: Kreuzt du „Keine Hausaufgaben“ an, wird ein schon eingetragener Text verworfen.")
        }
    }

    /// Erklärt die Punkte unter den Tagen im Kalender.
    private var dotLegendSection: some View {
        Section {
            dotRow(color: Holiday.tint,
                   title: "Grün: schulfrei",
                   text: "Ferien und gesetzliche Feiertage. Jeder Ferientag bekommt einen grünen Punkt – der erste, der letzte und alle dazwischen; die ganzen Ferien sind zusätzlich grün hinterlegt. Die Feiertage kommen von allein, sobald oben dein Bundesland eingestellt ist.")

            dotRow(color: EventKind.exam.tint,
                   title: "Farbig: ein Termin",
                   text: "Je Termin ein Punkt. Die Farbe sagt, was für einer: rot Arbeit, orange Test, lila Abgabe, braun Ausflug, grau Sonstiges.")

            dotRow(color: Color.secondary.opacity(0.55),
                   title: "Grau: offene Hausaufgaben",
                   text: "An diesem Tag ist noch etwas aufgeschrieben, das du nicht abgehakt hast.")
        } header: {
            Text("Die Punkte im Kalender")
        } footer: {
            Text("Dieselbe Erklärung steht auch klein unter dem Monat im Kalender.")
        }
    }

    private func dotRow(color: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .padding(.top, 5)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }

    private func legendRow(color: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }

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
            HStack(spacing: 14) {
                HomyMark(size: 54)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Homy")
                        .font(.title3.weight(.bold))
                    Text("Dein Hausaufgabenheft")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            LabeledContent("Fächer", value: "\(store.subjects.count)")
            LabeledContent("Stunden im Plan", value: "\(store.lessons.filter { $0.subjectID != nil }.count)")
            LabeledContent("Hausaufgaben", value: "\(store.homework.filter(\.hasText).count)")
            LabeledContent("Termine", value: "\(store.events.count)")
            LabeledContent("Ferien", value: "\(store.holidays.count)")
            LabeledContent("Version", value: appVersion)
        } header: {
            Text("Über die App")
        } footer: {
            Text("Alles bleibt auf diesem Gerät: kein Konto, keine Anmeldung im Internet, keine Werbung.")
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
