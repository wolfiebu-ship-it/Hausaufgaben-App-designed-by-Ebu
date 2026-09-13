import SwiftUI

/// Eine Seite des Hausaufgabenhefts: eine komplette Woche.
struct HomeworkWeekView: View {
    let weekStart: Date

    @EnvironmentObject private var store: AppStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var days: [Date] {
        store.settings.weekdays.map { SchoolCalendar.date(inWeekOf: weekStart, weekday: $0) }
    }

    /// Auf dem iPad nebeneinander, auf dem iPhone untereinander.
    private var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [GridItem(.adaptive(minimum: 340), spacing: 16, alignment: .top)]
        }
        return [GridItem(.flexible(), spacing: 16, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if store.subjects.isEmpty {
                    NoSubjectsHint()
                } else if !store.hasAnyLesson {
                    NoTimetableHint()
                }

                WeekSummary(days: days)

                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ForEach(days, id: \.self) { day in
                        HomeworkDayCard(day: day)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
    }
}

/// Überblick über die ganze Woche: wie viel steht noch an, was ist geschafft.
struct WeekSummary: View {
    let days: [Date]
    @EnvironmentObject private var store: AppStore

    private var entries: [HomeworkEntry] {
        days.flatMap { store.homeworkEntries(on: $0) }.filter(\.hasText)
    }

    private var open: Int { entries.filter { !$0.isDone }.count }
    private var done: Int { entries.filter(\.isDone).count }
    private var total: Int { entries.count }

    var body: some View {
        if total > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(headline)
                        .font(.subheadline.weight(.semibold))

                    Spacer(minLength: 0)

                    Text("\(done) von \(total) erledigt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                // Ein Balken je Aufgabe – auf einen Blick sichtbar, wie viel noch offen ist.
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }

    private var progress: Double {
        total > 0 ? Double(done) / Double(total) : 0
    }

    private var headline: String {
        if open == 0 { return "Alles erledigt 🎉" }
        if open == 1 { return "Noch 1 Aufgabe offen" }
        return "Noch \(open) Aufgaben offen"
    }
}

// MARK: - Hinweise, wenn noch nichts eingerichtet ist

private struct NoSubjectsHint: View {
    var body: some View {
        HintBox(icon: "books.vertical",
                title: "Noch keine Fächer",
                message: "Lege deine Fächer im Tab „Fächer“ an. Danach erscheinen hier die Kürzel zum Eintragen.")
    }
}

private struct NoTimetableHint: View {
    var body: some View {
        HintBox(icon: "calendar",
                title: "Stundenplan ist noch leer",
                message: "Trage im Tab „Stundenplan“ ein, welche Fächer du wann hast. Dann stehen die Kürzel automatisch bei jedem Tag.")
    }
}

struct HintBox: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
