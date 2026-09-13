import SwiftUI

/// Ein Tag im Hausaufgabenheft mit einer Zeile je Fach.
struct HomeworkDayCard: View {
    let day: Date

    @EnvironmentObject private var store: AppStore
    /// Fächer, die für diesen Tag von Hand ergänzt wurden (z. B. Vertretungsstunde).
    @State private var extraSubjectIDs: [UUID] = []

    private var isToday: Bool { SchoolCalendar.isToday(day) }

    /// Fächer aus dem Stundenplan, plus bereits eingetragene, plus von Hand ergänzte.
    private var rowSubjects: [Subject] {
        var result = store.homeworkSubjects(on: day)
        var seen = Set(result.map(\.id))

        for id in extraSubjectIDs where !seen.contains(id) {
            if let subject = store.subject(id: id) {
                seen.insert(id)
                result.append(subject)
            }
        }

        if !store.settings.showEmptySubjects {
            result = result.filter { subject in
                store.homeworkEntry(day: day, subjectID: subject.id) != nil
                    || extraSubjectIDs.contains(subject.id)
            }
        }
        return result
    }

    private var addableSubjects: [Subject] {
        let shown = Set(rowSubjects.map(\.id))
        return store.sortedSubjects.filter { !shown.contains($0.id) }
    }

    private var openCount: Int {
        store.homeworkEntries(on: day).filter { !$0.isDone && $0.hasText }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if rowSubjects.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(rowSubjects) { subject in
                        if subject.id != rowSubjects.first?.id {
                            Divider().padding(.leading, 68)
                        }
                        HomeworkRow(day: day,
                                    subject: subject,
                                    entry: store.homeworkEntry(day: day, subjectID: subject.id))
                    }
                }
            }

            if !addableSubjects.isEmpty {
                Divider().padding(.leading, 68)
                addSubjectMenu
            }
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .strokeBorder(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Teile

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: day)))
                .font(.headline)

            Text(SchoolCalendar.dayMonth(day))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            if isToday {
                Text("Heute")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor, in: Capsule())
            } else if openCount > 0 {
                Text("\(openCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                    .accessibilityLabel("\(openCount) offene Aufgaben")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var emptyState: some View {
        Text(store.hasAnyLesson ? "Keine Stunden an diesem Tag." : "Noch kein Stundenplan hinterlegt.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
    }

    private var addSubjectMenu: some View {
        Menu {
            ForEach(addableSubjects) { subject in
                Button {
                    withAnimation {
                        extraSubjectIDs.append(subject.id)
                    }
                } label: {
                    Label("\(subject.displayShort) – \(subject.displayName)", systemImage: "plus")
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Fach ergänzen")
                Spacer(minLength: 0)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
    }
}
