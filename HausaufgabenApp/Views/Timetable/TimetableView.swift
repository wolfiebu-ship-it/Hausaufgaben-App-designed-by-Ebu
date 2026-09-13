import SwiftUI

/// Der eigene Stundenplan als Raster: Spalten = Wochentage, Zeilen = Stunden.
struct TimetableView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editingSlot: LessonSlot?

    struct LessonSlot: Identifiable, Hashable {
        let weekday: Int
        let period: Int
        var id: String { "\(weekday)-\(period)" }
    }

    private var weekdays: [Int] { store.settings.weekdays }
    private var periods: [Int] { store.settings.periods }
    private var todayIndex: Int { SchoolCalendar.weekdayIndex(of: Date()) }

    private var timeColumnWidth: CGFloat {
        store.settings.showTimes ? AppTheme.timetableTimeColumnWidth : 32
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.subjects.isEmpty {
                    emptyState
                } else {
                    grid
                }
            }
            .navigationTitle("Stundenplan")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .sheet(item: $editingSlot) { slot in
                LessonEditorView(weekday: slot.weekday, period: slot.period)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Raster

    private static let outerPadding: CGFloat = 12
    private static let gridSpacing: CGFloat = 4

    /// Spaltenbreite: möglichst die volle Breite ausnutzen, aber nie schmaler
    /// als `timetableMinColumnWidth` – sonst wird waagerecht gescrollt.
    private func columnWidth(availableWidth: CGFloat) -> CGFloat {
        let dayCount = CGFloat(max(1, weekdays.count))
        let usable = availableWidth - Self.outerPadding * 2 - timeColumnWidth
            - Self.gridSpacing * dayCount
        return max(usable / dayCount, AppTheme.timetableMinColumnWidth)
    }

    private var grid: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                gridContent(columnWidth: columnWidth(availableWidth: geometry.size.width))
                    .padding(Self.outerPadding)
            }
        }
    }

    private func gridContent(columnWidth: CGFloat) -> some View {
        VStack(spacing: Self.gridSpacing) {
            headerRow(columnWidth: columnWidth)

            ForEach(periods, id: \.self) { period in
                periodRow(period: period, columnWidth: columnWidth)
            }
        }
    }

    private func headerRow(columnWidth: CGFloat) -> some View {
        HStack(spacing: Self.gridSpacing) {
            Color.clear
                .frame(width: timeColumnWidth, height: 30)

            ForEach(weekdays, id: \.self) { weekday in
                dayHeader(weekday: weekday, columnWidth: columnWidth)
            }
        }
    }

    private func dayHeader(weekday: Int, columnWidth: CGFloat) -> some View {
        Text(SchoolCalendar.weekdayShortName(weekday))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(weekday == todayIndex ? Color.accentColor : Color.primary)
            .frame(width: columnWidth, height: 30)
            .background(weekday == todayIndex ? Color.accentColor.opacity(0.12) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 8))
    }

    private func periodRow(period: Int, columnWidth: CGFloat) -> some View {
        HStack(spacing: Self.gridSpacing) {
            periodLabel(period: period)

            ForEach(weekdays, id: \.self) { weekday in
                cell(weekday: weekday, period: period, columnWidth: columnWidth)
            }
        }
    }

    private func cell(weekday: Int, period: Int, columnWidth: CGFloat) -> some View {
        let lesson = store.lesson(weekday: weekday, period: period)
        return TimetableCell(subject: store.subject(id: lesson?.subjectID),
                             room: lesson.map { store.room(for: $0) } ?? "",
                             width: columnWidth) {
            editingSlot = LessonSlot(weekday: weekday, period: period)
        }
    }

    private func periodLabel(period: Int) -> some View {
        VStack(spacing: 1) {
            Text("\(period).")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if store.settings.showTimes, let time = store.settings.time(forPeriod: period) {
                Text(time.startText)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Text(time.endText)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: timeColumnWidth, height: AppTheme.timetableCellHeight)
    }

    // MARK: - Leerer Zustand

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 44))
                .foregroundStyle(.tint)

            Text("Zuerst die Fächer anlegen")
                .font(.headline)

            Text("Im Tab „Fächer“ legst du fest, welche Fächer du hast und welches Kürzel sie bekommen. Danach kannst du sie hier in den Stundenplan eintragen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                store.addStarterSubjects()
            } label: {
                Label("Typische Fächer übernehmen", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Eine Zelle im Stundenplan.
struct TimetableCell: View {
    let subject: Subject?
    let room: String
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let subject {
                    Text(subject.displayShort)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    if !room.isEmpty {
                        Text(room)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                } else {
                    Image(systemName: "plus")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: width, height: AppTheme.timetableCellHeight)
            .background(subject?.color ?? Color(.tertiarySystemFill),
                        in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(subject?.displayName ?? "Freie Stunde")
        .accessibilityHint("Antippen zum Bearbeiten")
    }
}
