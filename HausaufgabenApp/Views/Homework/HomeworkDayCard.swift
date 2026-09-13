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

    /// Steht an diesem Tag schon etwas?
    private var hasEntries: Bool {
        store.homeworkEntries(on: day).contains(where: \.hasText)
    }

    private var isMarkedFree: Bool {
        store.isMarkedNoHomework(day: day)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if isMarkedFree {
                // Als „nichts auf“ vermerkt: Zeilen bleiben eingeklappt.
                freeMarker
            } else if rowSubjects.isEmpty {
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

            if !isMarkedFree && !hasEntries && !rowSubjects.isEmpty {
                Divider().padding(.leading, 68)
                freeToggle
            }

            if !isMarkedFree && !addableSubjects.isEmpty {
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

    /// Der Vermerk, wenn der Tag als „nichts auf“ markiert ist.
    private var freeMarker: some View {
        Button {
            withAnimation { store.setNoHomework(false, day: day) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Keine Hausaufgaben")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Antippen, um doch etwas einzutragen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Keine Hausaufgaben an diesem Tag. Antippen zum Aufheben.")
    }

    /// Das Feld zum Abhaken, solange nichts eingetragen ist.
    private var freeToggle: some View {
        Button {
            withAnimation { store.setNoHomework(true, day: day) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("Keine Hausaufgaben")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Vermerken, dass an diesem Tag nichts aufgegeben wurde")
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
