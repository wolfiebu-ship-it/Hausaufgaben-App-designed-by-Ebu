import SwiftUI

/// Der Bearbeiten-Modus für den Stundenplan: Stunden, Wochentage und alle
/// Unterrichtszeiten an einer Stelle.
///
/// Anders als sonst in Homy wird hier *nicht* sofort gespeichert. Gearbeitet
/// wird an einem Entwurf; erst „Sichern“ übernimmt ihn. „Abbrechen“ wirft ihn
/// weg – und fragt vorher nach, wenn wirklich etwas geändert wurde.
struct TimetableSettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    /// Die Arbeitskopie. Was hier steht, steht noch nirgendwo sonst.
    @State private var entwurf: AppSettings

    // Der Rechner oben: ab wann, wie lange, wie viel Pause.
    @State private var beginn: Int
    @State private var laenge: Int
    @State private var pause: Int
    @State private var grossePause: Int
    @State private var mitGrosserPause: Bool

    @State private var zeigeAbbruchFrage = false
    @State private var zeigeZuruecksetzenFrage = false

    init(settings: AppSettings) {
        var kopie = settings
        kopie.normalizeTimes()
        _entwurf = State(initialValue: kopie)

        let erste = kopie.periodTimes.first
        _beginn = State(initialValue: erste?.startMinutes ?? 8 * 60)
        _laenge = State(initialValue: max(5, (erste.map { $0.endMinutes - $0.startMinutes }) ?? 45))
        _pause = State(initialValue: 5)
        _grossePause = State(initialValue: 15)
        _mitGrosserPause = State(initialValue: true)
    }

    private var hatAenderungen: Bool { entwurf != store.settings }

    var body: some View {
        NavigationStack {
            Form {
                aufbauSection
                rechnerSection
                zeitenSection
                zuruecksetzenSection
            }
            .environment(\.locale, Locale(identifier: "de_DE"))
            // Kurz, weil links „Abbrechen“ und rechts „Sichern“ stehen –
            // für „Stundenplan bearbeiten“ ist dazwischen kein Platz.
            .navigationTitle("Stundenplan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if hatAenderungen { zeigeAbbruchFrage = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { sichern() }
                        .font(.body.weight(.semibold))
                        .disabled(!hatAenderungen)
                }
            }
            .interactiveDismissDisabled(hatAenderungen)
            .confirmationDialog("Änderungen verwerfen?",
                                isPresented: $zeigeAbbruchFrage,
                                titleVisibility: .visible) {
                Button("Verwerfen", role: .destructive) { dismiss() }
                Button("Weiter bearbeiten", role: .cancel) { }
            } message: {
                Text("Was du hier eingestellt hast, ist noch nicht gespeichert.")
            }
            .alert("Standardzeiten wiederherstellen?", isPresented: $zeigeZuruecksetzenFrage) {
                Button("Wiederherstellen", role: .destructive) {
                    entwurf.periodTimes = PeriodTime.defaultTimes(count: entwurf.periodCount)
                }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text("Die Stunden beginnen dann wieder um 8:00 Uhr, dauern 45 Minuten und haben nach der 2. und 4. Stunde eine große Pause.")
            }
        }
    }

    // MARK: - Aufbau

    private var aufbauSection: some View {
        Section {
            Stepper(value: $entwurf.periodCount, in: 1...14) {
                HStack {
                    Text("Stunden pro Tag")
                    Spacer()
                    Text("\(entwurf.periodCount)")
                        .foregroundStyle(.secondary)
                        .font(.body.monospacedDigit())
                }
            }
            .onChange(of: entwurf.periodCount) { _, _ in
                entwurf.normalizeTimes()
            }

            Toggle("Samstag ist ein Schultag", isOn: $entwurf.includeSaturday)
            Toggle("Uhrzeiten im Plan anzeigen", isOn: $entwurf.showTimes)
        } header: {
            Text("Aufbau")
        } footer: {
            Text("Der Plan zeigt \(entwurf.periodCount) \(entwurf.periodCount == 1 ? "Stunde" : "Stunden") an \(entwurf.includeSaturday ? "sechs" : "fünf") Tagen: \(entwurf.includeSaturday ? "Montag bis Samstag" : "Montag bis Freitag").")
        }
    }

    // MARK: - Alle Zeiten auf einmal

    private var rechnerSection: some View {
        Section {
            HStack {
                Text("Erste Stunde ab")
                Spacer()
                DatePicker("Erste Stunde ab",
                           selection: dateBinding($beginn),
                           displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }

            Stepper(value: $laenge, in: 30...120, step: 5) {
                HStack {
                    Text("Eine Stunde dauert")
                    Spacer()
                    Text("\(laenge) Min.")
                        .foregroundStyle(.secondary)
                        .font(.body.monospacedDigit())
                }
            }

            Stepper(value: $pause, in: 0...30, step: 5) {
                HStack {
                    Text("Pause dazwischen")
                    Spacer()
                    Text("\(pause) Min.")
                        .foregroundStyle(.secondary)
                        .font(.body.monospacedDigit())
                }
            }

            Toggle("Große Pause nach der 2. und 4.", isOn: $mitGrosserPause)

            if mitGrosserPause {
                Stepper(value: $grossePause, in: 10...45, step: 5) {
                    HStack {
                        Text("Große Pause dauert")
                        Spacer()
                        Text("\(grossePause) Min.")
                            .foregroundStyle(.secondary)
                            .font(.body.monospacedDigit())
                    }
                }
            }

            Button {
                entwurf.periodTimes = PeriodTime.times(
                    count: entwurf.periodCount,
                    firstStartMinutes: beginn,
                    lengthMinutes: laenge,
                    breakMinutes: pause,
                    longBreakMinutes: mitGrosserPause ? grossePause : pause,
                    longBreakAfter: mitGrosserPause ? [2, 4] : [])
                entwurf.normalizeTimes()
            } label: {
                Label("Alle Zeiten so ausrechnen", systemImage: "wand.and.stars")
            }
        } header: {
            Text("Alle Zeiten auf einmal")
        } footer: {
            Text("Rechnet den ganzen Tag durch, statt jede Stunde einzeln einzustellen. Unten kannst du einzelne Stunden danach noch anpassen.")
        }
    }

    // MARK: - Einzelne Stunden

    private var zeitenSection: some View {
        Section {
            ForEach($entwurf.periodTimes) { $zeit in
                HStack(spacing: 8) {
                    Text("\(zeit.period).")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, alignment: .leading)

                    DatePicker("Beginn",
                               selection: dateBinding($zeit.startMinutes),
                               displayedComponents: .hourAndMinute)
                        .labelsHidden()

                    Text("bis")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    DatePicker("Ende",
                               selection: dateBinding($zeit.endMinutes),
                               displayedComponents: .hourAndMinute)
                        .labelsHidden()

                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(zeit.period). Stunde, \(zeit.startText) bis \(zeit.endText)")
            }
        } header: {
            Text("Unterrichtszeiten")
        } footer: {
            Text(schultagText)
        }
    }

    private var zuruecksetzenSection: some View {
        Section {
            Button(role: .destructive) {
                zeigeZuruecksetzenFrage = true
            } label: {
                Label("Standardzeiten wiederherstellen", systemImage: "arrow.counterclockwise")
            }
        }
    }

    /// „Schultag von 08:00 bis 15:45“ – zeigt im Entwurf, was dabei herauskommt.
    private var schultagText: String {
        guard let erste = entwurf.periodTimes.first,
              let letzte = entwurf.periodTimes.last else {
            return "Diese Zeiten stehen links im Stundenplan."
        }
        return "Schultag von \(erste.startText) bis \(letzte.endText). Diese Zeiten stehen links im Stundenplan."
    }

    // MARK: - Sichern

    private func sichern() {
        var fertig = entwurf
        fertig.normalizeTimes()
        store.settings = fertig
        store.saveNow()
        Haptics.success()
        dismiss()
    }

    /// Verbindet die gespeicherten Minuten mit dem Uhrzeit-Auswahlrad.
    private func dateBinding(_ minutes: Binding<Int>) -> Binding<Date> {
        Binding(
            get: { SchoolCalendar.date(fromMinutesSinceMidnight: minutes.wrappedValue) },
            set: { minutes.wrappedValue = SchoolCalendar.minutesSinceMidnight(from: $0) }
        )
    }
}
