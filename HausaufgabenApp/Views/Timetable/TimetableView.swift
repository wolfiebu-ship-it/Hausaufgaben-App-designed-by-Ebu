import SwiftUI

/// Der eigene Stundenplan als Raster: Spalten = Wochentage, Zeilen = Stunden.
struct TimetableView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editingSlot: LessonSlot?
    @State private var showScanner = false
    @State private var showSubjects = false

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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSubjects = true
                    } label: {
                        Label("Fächer", systemImage: "books.vertical")
                    }
                    .accessibilityLabel("Fächer verwalten")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showScanner = true
                    } label: {
                        Image(systemName: "doc.viewfinder")
                    }
                    .accessibilityLabel("Stundenplan scannen")
                }
            }
            .sheet(isPresented: $showSubjects) {
                SubjectsView(showsDoneButton: true)
                    .environmentObject(store)
            }
            .sheet(item: $editingSlot) { slot in
                LessonEditorView(weekday: slot.weekday, period: slot.period)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showScanner) {
                TimetableScanFlow()
                    .environmentObject(store)
            }
        }
    }

    /// Hinweis über dem Raster: den eigenen Plan abfotografieren statt tippen.
    private var scanBanner: some View {
        Button {
            showScanner = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.viewfinder")
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Eigenen Stundenplan scannen")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Plan abfotografieren – die Fächer werden automatisch eingetragen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .buttonStyle(.plain)
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
        VStack(spacing: 0) {
            scanBanner
                .padding(.horizontal, Self.outerPadding)
                .padding(.top, Self.outerPadding)

            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    gridContent(columnWidth: columnWidth(availableWidth: geometry.size.width))
                        .padding(Self.outerPadding)
                }
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

            Text("Noch kein Stundenplan")
                .font(.headline)

            Text("Fotografiere deinen Plan ab – die Fächer werden dabei gleich mit angelegt. Oder fang mit den typischen Schulfächern an und trage den Plan von Hand ein.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    showScanner = true
                } label: {
                    Label("Stundenplan scannen", systemImage: "doc.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    store.addStarterSubjects()
                } label: {
                    Label("Typische Fächer übernehmen", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(32)
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Eine Zelle im Stundenplan: helle Fläche in der Fachfarbe, links ein
/// kräftiger Streifen – so bleiben die Fächer auch bei hellen Tönen
/// gut auseinanderzuhalten.
struct TimetableCell: View {
    let subject: Subject?
    let room: String
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if let subject {
                    Rectangle()
                        .fill(subject.tint)
                        .frame(width: 4)
                }

                VStack(spacing: 2) {
                    if let subject {
                        Text(subject.displayShort)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(subject.tint)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        if !room.isEmpty {
                            Text(room)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(subject.tint.opacity(0.75))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    } else {
                        Image(systemName: "plus")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 3)
            }
            .frame(width: width, height: AppTheme.timetableCellHeight)
            .background(subject?.fill ?? Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(subject?.displayName ?? "Freie Stunde")
        .accessibilityHint("Antippen zum Bearbeiten")
    }
}
