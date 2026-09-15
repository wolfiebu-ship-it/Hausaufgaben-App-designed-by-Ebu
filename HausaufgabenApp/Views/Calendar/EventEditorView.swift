import SwiftUI
import UserNotifications

/// Einen Termin eintragen oder ändern.
struct EventEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: CalendarEvent
    @State private var day: Date
    @State private var hasTime: Bool
    @State private var time: Date
    @State private var showsDeleteConfirmation = false
    @State private var reminderProblem: String?

    /// Gab es den Termin schon? Dann ist der Löschen-Knopf sinnvoll.
    private let isExisting: Bool

    init(event: CalendarEvent) {
        _draft = State(initialValue: event)
        _day = State(initialValue: event.date ?? SchoolCalendar.startOfDay(Date()))
        _hasTime = State(initialValue: event.startMinutes != nil)
        _time = State(initialValue: SchoolCalendar.date(
            fromMinutesSinceMidnight: event.startMinutes ?? 8 * 60))
        // Ein Termin, der noch nie Text hatte, ist neu.
        isExisting = event.hasTitle || !event.details.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                titleSection
                whenSection
                reminderSection
                detailsSection

                if isExisting {
                    Section {
                        Button(role: .destructive) {
                            showsDeleteConfirmation = true
                        } label: {
                            Label("Termin löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .task { await checkNotificationPermission() }
            .navigationTitle(isExisting ? "Termin" : "Neuer Termin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { save() }
                        .disabled(!canSave)
                }
            }
            .confirmationDialog("Diesen Termin löschen?",
                                isPresented: $showsDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    store.deleteEvent(id: draft.id)
                    dismiss()
                }
            } message: {
                Text("Die Erinnerung dazu wird mit gelöscht. Das lässt sich nicht rückgängig machen.")
            }
        }
    }

    // MARK: - Abschnitte

    private var titleSection: some View {
        Section {
            TextField("Worum geht es?", text: $draft.title)

            Picker("Art", selection: $draft.kind) {
                ForEach(EventKind.allCases) { kind in
                    Label(kind.title, systemImage: kind.symbol).tag(kind)
                }
            }

            Picker("Fach", selection: $draft.subjectID) {
                Text("Kein Fach").tag(UUID?.none)
                ForEach(store.sortedSubjects) { subject in
                    Text(subject.displayName).tag(UUID?.some(subject.id))
                }
            }
        } header: {
            Text("Termin")
        } footer: {
            Text("Zum Beispiel „Mathe-Arbeit: Wurzeln“ oder „Referat abgeben“.")
        }
    }

    private var whenSection: some View {
        Section {
            DatePicker("Tag", selection: $day, displayedComponents: .date)
                .environment(\.calendar, SchoolCalendar.calendar)

            Toggle("Mit Uhrzeit", isOn: $hasTime)

            if hasTime {
                DatePicker("Uhrzeit", selection: $time, displayedComponents: .hourAndMinute)
                    .environment(\.calendar, SchoolCalendar.calendar)
            }
        } header: {
            Text("Wann")
        } footer: {
            Text(hasTime
                 ? "Die Uhrzeit steht am Termin und zählt für die Erinnerung."
                 : "Ohne Uhrzeit gilt der Termin für den ganzen Tag.")
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
            Text(footerText)
        }
    }

    private var detailsSection: some View {
        Section {
            TextField("Was drankommt, was mitzubringen ist …",
                      text: $draft.details, axis: .vertical)
                .lineLimit(3...8)
        } header: {
            Text("Notiz")
        }
    }

    // MARK: - Texte

    /// Wann die Benachrichtigung käme – mit dem, was gerade eingestellt ist.
    private var previewDate: String? {
        var probe = draft
        probe.dayKey = SchoolCalendar.dayKey(day)
        probe.startMinutes = hasTime ? SchoolCalendar.minutesSinceMidnight(from: time) : nil
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

    private var footerText: String {
        if draft.reminder == .none {
            return "Homy meldet sich zu diesem Termin nicht."
        }
        if !store.settings.remindersEnabled {
            return "Erinnerungen sind in den Einstellungen ausgeschaltet – so lange kommt nichts."
        }
        return draft.reminder.explanation
            + " Die Benachrichtigung kommt von iOS, auch wenn Homy geschlossen ist."
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !draft.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Sichern

    private func save() {
        var event = draft
        event.dayKey = SchoolCalendar.dayKey(day)
        event.startMinutes = hasTime ? SchoolCalendar.minutesSinceMidnight(from: time) : nil
        event.title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.details = event.details.trimmingCharacters(in: .whitespacesAndNewlines)

        let brauchtErlaubnis = event.reminder != .none && store.settings.remindersEnabled
        store.saveEvent(event)
        Haptics.success()
        dismiss()

        // Nach der Erlaubnis wird erst gefragt, wenn klar ist, dass sie
        // gebraucht wird – nicht schon beim ersten Start der App.
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

    /// Zeigt gleich im Formular, wenn iOS keine Benachrichtigungen zulässt –
    /// sonst stellt man eine Erinnerung ein, die nie kommt.
    private func checkNotificationPermission() async {
        let status = await Reminders.authorizationStatus()
        await MainActor.run {
            reminderProblem = status == .denied
                ? "iOS lässt für Homy keine Benachrichtigungen zu. In den Einstellungen von Homy steht, wie du das änderst."
                : nil
        }
    }
}
