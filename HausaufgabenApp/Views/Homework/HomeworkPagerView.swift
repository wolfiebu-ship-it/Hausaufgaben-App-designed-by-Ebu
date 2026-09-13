import SwiftUI

/// Das Hausaufgabenheft: eine Seite pro Woche, zum Blättern nach links und rechts.
struct HomeworkPagerView: View {
    @EnvironmentObject private var store: AppStore

    /// Der Montag der Woche, in der die App geöffnet wurde. Alle Seiten zählen von hier.
    @State private var referenceWeek = SchoolCalendar.startOfWeek(for: Date())
    @State private var weekOffset = 0
    @State private var showDatePicker = false
    @State private var pickedDate = Date()

    /// So viele Wochen lassen sich vor und zurück blättern (gut zwei Schuljahre).
    private static let range = -80...80

    private var weekStart: Date {
        SchoolCalendar.weekStart(offsetBy: weekOffset, from: referenceWeek)
    }

    private var dayCount: Int { store.settings.weekdays.count }

    var body: some View {
        NavigationStack {
            TabView(selection: $weekOffset) {
                ForEach(Self.range, id: \.self) { offset in
                    HomeworkWeekView(weekStart: SchoolCalendar.weekStart(offsetBy: offset,
                                                                        from: referenceWeek))
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .id(store.dataRevision)
            .navigationTitle("Hausaufgaben")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    weekHeader
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        step(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(weekOffset <= Self.range.lowerBound)
                    .accessibilityLabel("Vorherige Woche")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        step(1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(weekOffset >= Self.range.upperBound)
                    .accessibilityLabel("Nächste Woche")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { hideKeyboard() }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                weekPickerSheet
            }
        }
    }

    // MARK: - Kopfzeile

    private var weekHeader: some View {
        Button {
            pickedDate = weekStart
            showDatePicker = true
        } label: {
            VStack(spacing: 1) {
                HStack(spacing: 4) {
                    Text(titleText)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
                Text(SchoolCalendar.weekRangeText(weekStart: weekStart, dayCount: dayCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Woche wählen. \(titleText)")
    }

    private var titleText: String {
        if weekOffset == currentWeekOffset { return "Diese Woche" }
        if weekOffset == currentWeekOffset + 1 { return "Nächste Woche" }
        if weekOffset == currentWeekOffset - 1 { return "Letzte Woche" }
        return "KW \(SchoolCalendar.calendarWeek(of: weekStart))"
    }

    private var currentWeekOffset: Int {
        SchoolCalendar.weekOffset(from: referenceWeek, to: Date())
    }

    // MARK: - Wochenauswahl

    private var weekPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("Woche",
                           selection: $pickedDate,
                           displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "de_DE"))
                    .padding(.horizontal)

                Button {
                    jump(to: Date())
                    showDatePicker = false
                } label: {
                    Label("Zur aktuellen Woche", systemImage: "calendar.badge.clock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()

                Spacer(minLength: 0)
            }
            .navigationTitle("Zu Woche springen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { showDatePicker = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Öffnen") {
                        jump(to: pickedDate)
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Navigation

    private func step(_ delta: Int) {
        let target = weekOffset + delta
        guard Self.range.contains(target) else { return }
        withAnimation { weekOffset = target }
    }

    private func jump(to date: Date) {
        let target = SchoolCalendar.weekOffset(from: referenceWeek, to: date)
        let clamped = min(max(target, Self.range.lowerBound), Self.range.upperBound)
        withAnimation { weekOffset = clamped }
    }
}
