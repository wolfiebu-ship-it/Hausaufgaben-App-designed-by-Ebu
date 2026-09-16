import SwiftUI
import UserNotifications

/// Ferien eintragen: wie sie heißen, wann sie anfangen und wann sie enden.
struct HolidayEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Holiday
    @State private var start: Date
    @State private var end: Date
    @State private var showsDeleteConfirmation = false
    @State private var reminderProblem: String?

    /// Gab es die Ferien schon? Dann ist der Löschen-Knopf sinnvoll.
    private let isExisting: Bool

    init(holiday: Holiday) {
        _draft = State(initialValue: holiday)
        let anfang = holiday.startDate ?? SchoolCalendar.startOfDay(Date())
        _start = State(initialValue: anfang)
        _end = State(initialValue: holiday.endDate ?? anfang)
        isExisting = !holiday.trimmedName.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                rangeSection
                summarySection
                reminderSection
                noteSection

                if isExisting {
                    Section {
                        Button(role: .destructive) {
                            showsDeleteConfirmation = true
                        } label: {
                            Label("Ferien löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .task { await checkNotificationPermission() }
            .navigationTitle(isExisting ? "Ferien" : "Neue Ferien")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { save() }
                        .disabled(draft.trimmedName.isEmpty)
                }
            }
            .confirmationDialog("Diese Ferien löschen?",
                                isPresented: $showsDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    store.deleteHoliday(id: draft.id)
                    dismiss()
                }
            } message: {
                Text("Die Erinnerung dazu wird mit gelöscht. Das lässt sich nicht rückgängig machen.")
            }
            // Das Ende darf nicht vor dem Anfang liegen.
            .onChange(of: start) { _, neu in
                if end < neu { end = neu }
            }
        }
    }

    // MARK: - Abschnitte

    private var nameSection: some View {
        Section {
            TextField("Wie heißen die Ferien?", text: $draft.name)

            Menu {
                ForEach(Holiday.suggestedNames, id: \.self) { vorschlag in
                    Button(vorschlag) { draft.name = vorschlag }
                }
            } label: {
                Label("Namen auswählen", systemImage: "list.bullet")
            }
        } header: {
            Text("Name")
        } footer: {
            Text("Zum Beispiel „Herbstferien“ oder „Weihnachtsferien“.")
        }
    }

    private var rangeSection: some View {
        Section {
            DatePicker("Erster Ferientag", selection: $start, displayedComponents: .date)
                .environment(\.calendar, SchoolCalendar.calendar)

            DatePicker("Letzter Ferientag", selection: $end,
                       in: start..., displayedComponents: .date)
                .environment(\.calendar, SchoolCalendar.calendar)
        } header: {
            Text("Von wann bis wann")
        } footer: {
            Text("Der letzte Ferientag zählt noch dazu – trag den Tag ein, an dem du noch frei hast, nicht den ersten Schultag danach.")
        }
    }

    /// Die Zusammenfassung in Worten – damit man sieht, ob es stimmt.
    private var summarySection: some View {
        Section {
            LabeledContent("Anfang") {
                Text(Holiday.longWeekdayText(start))
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Ende") {
                Text(Holiday.longWeekdayText(end))
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Dauer", value: dauerText)
            if let ersterSchultag {
                LabeledContent("Wieder Schule") {
                    Text(Holiday.longWeekdayText(ersterSchultag))
                        .multilineTextAlignment(.trailing)
                }
            }
        } header: {
            Text("So steht es im Kalender")
        }
    }

    private var reminderSection: some View {
        Section {
            Picker("Erinnerung", selection: $draft.reminder) {
                ForEach(ReminderOffset.allCases) { offset in
                    Text(offset.title).tag(offset)
                }
            }
            .pickerStyle(.navigationLink)

            if let reminderProblem {
                Label(reminderProblem, systemImage: "bell.slash.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            } else if draft.reminder != .none, let wann = previewDate {
                Label(wann, systemImage: "bell.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Erinnerung")
        } footer: {
            Text(draft.reminder == .none
                 ? "Homy sagt zum Ferienbeginn nichts."
                 : "Homy meldet sich vor dem ersten Ferientag.")
        }
    }

    private var noteSection: some View {
        Section {
            TextField("Was du in den Ferien vorhast …", text: $draft.note, axis: .vertical)
                .lineLimit(3...8)
        } header: {
            Text("Notiz")
        }
    }

    // MARK: - Texte

    private var probe: Holiday {
        var holiday = draft
        holiday.startDayKey = SchoolCalendar.dayKey(start)
        holiday.endDayKey = SchoolCalendar.dayKey(end)
        return holiday
    }

    private var dauerText: String {
        let tage = probe.dayCount
        return tage == 1 ? "1 Tag" : "\(tage) Tage"
    }

    /// Der erste Tag, an dem wirklich wieder Schule ist – Wochenenden und
    /// andere Ferien werden übersprungen.
    private var ersterSchultag: Date? {
        store.firstSchoolDay(after: end, ignoring: draft.id)
    }

    private var previewDate: String? {
        guard let datum = probe.reminderDate else { return nil }
        let text = "\(SchoolCalendar.weekdayShortName(SchoolCalendar.weekdayIndex(of: datum))), "
            + "\(SchoolCalendar.dayMonth(datum)) um "
            + PeriodTime.text(forMinutes: SchoolCalendar.minutesSinceMidnight(from: datum))
            + " Uhr"
        if datum <= Date() {
            return text + " – der Zeitpunkt ist schon vorbei, es kommt nichts mehr."
        }
        return text
    }

    // MARK: - Sichern

    private func save() {
        var holiday = draft
        holiday.name = holiday.trimmedName
        holiday.note = holiday.note.trimmingCharacters(in: .whitespacesAndNewlines)
        holiday.startDayKey = SchoolCalendar.dayKey(start)
        holiday.endDayKey = SchoolCalendar.dayKey(end)

        let brauchtErlaubnis = holiday.reminder != .none && store.settings.remindersEnabled
        store.saveHoliday(holiday)
        Haptics.success()
        dismiss()

        if brauchtErlaubnis {
            let store = store
            Task {
                let erlaubt = await Reminders.requestAuthorization()
                if erlaubt {
                    await MainActor.run { store.syncReminders() }
                }
            }
        }
    }

    private func checkNotificationPermission() async {
        let status = await Reminders.authorizationStatus()
        await MainActor.run {
            reminderProblem = status == .denied
                ? "iOS lässt für Homy keine Benachrichtigungen zu. In den Einstellungen von Homy steht, wie du das änderst."
                : nil
        }
    }
}
