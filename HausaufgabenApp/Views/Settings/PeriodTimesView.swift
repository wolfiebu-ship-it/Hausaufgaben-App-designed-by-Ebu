import SwiftUI

/// Beginn und Ende jeder Unterrichtsstunde einstellen.
struct PeriodTimesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section {
                ForEach($store.settings.periodTimes) { $time in
                    HStack(spacing: 8) {
                        Text("\(time.period).")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 26, alignment: .leading)

                        DatePicker("Beginn",
                                   selection: dateBinding($time.startMinutes),
                                   displayedComponents: .hourAndMinute)
                            .labelsHidden()

                        Text("bis")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        DatePicker("Ende",
                                   selection: dateBinding($time.endMinutes),
                                   displayedComponents: .hourAndMinute)
                            .labelsHidden()

                        Spacer(minLength: 0)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(time.period). Stunde, \(time.startText) bis \(time.endText)")
                }
            } header: {
                Text("Unterrichtszeiten")
            } footer: {
                Text("Diese Zeiten stehen links im Stundenplan.")
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Standardzeiten wiederherstellen", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .environment(\.locale, Locale(identifier: "de_DE"))
        .navigationTitle("Unterrichtszeiten")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Standardzeiten wiederherstellen?", isPresented: $showResetConfirmation) {
            Button("Wiederherstellen", role: .destructive) {
                store.settings.periodTimes = PeriodTime.defaultTimes(count: store.settings.periodCount)
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Die Stunden beginnen dann wieder um 8:00 Uhr, dauern 45 Minuten und haben nach der 2. und 4. Stunde eine große Pause.")
        }
    }

    /// Verbindet die gespeicherten Minuten mit dem Uhrzeit-Auswahlrad.
    private func dateBinding(_ minutes: Binding<Int>) -> Binding<Date> {
        Binding(
            get: { SchoolCalendar.date(fromMinutesSinceMidnight: minutes.wrappedValue) },
            set: { minutes.wrappedValue = SchoolCalendar.minutesSinceMidnight(from: $0) }
        )
    }
}
