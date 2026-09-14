import SwiftUI

/// Ein Tag im Hausaufgabenheft mit einer Zeile je Fach.
struct HomeworkDayCard: View {
    let day: Date

    @EnvironmentObject private var store: AppStore
    /// Fächer, die für diesen Tag von Hand ergänzt wurden (z. B. Vertretungsstunde).
    @State private var extraSubjectIDs: [UUID] = []
    /// Tage starten zugeklappt; ein Tipp auf den Kopf klappt sie auf.
    @State private var isExpanded = false

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
            headerButton

            if isExpanded {
                if isMarkedFree {
                    // Als „nichts auf“ vermerkt: Zeilen bleiben eingeklappt.
                    freeMarker
                } else if rowSubjects.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        columnLegend

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
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .strokeBorder(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Teile

    /// Der ganze Kopf ist ein Knopf: antippen klappt den Tag auf und zu.
    private var headerButton: some View {
        Button {
            Haptics.tap()
            withAnimation(.easeInOut(duration: 0.22)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                header

                // Zugeklappt zeigt der Kopf, was an dem Tag ansteht –
                // damit man nicht blind aufklappen muss.
                if !isExpanded {
                    collapsedSummary
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityHeaderLabel)
        .accessibilityHint(isExpanded ? "Antippen zum Zuklappen" : "Antippen zum Aufklappen")
    }

    /// Kurzfassung für den zugeklappten Zustand.
    @ViewBuilder
    private var collapsedSummary: some View {
        if isMarkedFree {
            Label("Keine Hausaufgaben", systemImage: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(.tint)
        } else if hasEntries {
            // Die Kürzel der Fächer, zu denen etwas eingetragen ist –
            // Erledigtes blasser als das, was noch ansteht.
            HStack(spacing: 5) {
                ForEach(store.homeworkEntries(on: day).filter(\.hasText)) { entry in
                    if let subject = store.subject(id: entry.subjectID) {
                        SubjectBadge(subject: subject, width: 34, dimmed: entry.isDone)
                    }
                }
                Spacer(minLength: 0)
            }
        } else if rowSubjects.isEmpty {
            Text(store.hasAnyLesson ? "Keine Stunden an diesem Tag" : "Noch kein Stundenplan")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } else if store.allSubjectsSettled(on: day) {
            // In jedem Fach steht entweder etwas oder „nichts auf“.
            Label("Keine Hausaufgaben", systemImage: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(.tint)
        } else {
            Text("Nichts eingetragen")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var accessibilityHeaderLabel: String {
        let tag = "\(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: day))), \(SchoolCalendar.dayMonth(day))"
        if isMarkedFree { return "\(tag). Keine Hausaufgaben." }
        if openCount > 0 { return "\(tag). \(openCount) offen." }
        if hasEntries { return "\(tag). Alles erledigt." }
        return "\(tag). Nichts eingetragen."
    }

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
            }

            if openCount > 0 {
                Text("\(openCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                    .accessibilityLabel("\(openCount) offene Aufgaben")
            } else if hasEntries {
                // Alles abgehakt.
                Image(systemName: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .accessibilityLabel("Alles erledigt")
            }

            Image(systemName: "chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .padding(.leading, 2)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, isExpanded ? 12 : 6)
    }

    /// Erklärt die beiden Felder rechts an jeder Zeile.
    private var columnLegend: some View {
        HStack(spacing: 12) {
            HStack(spacing: 5) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.noHomeworkTint)
                Text("keine Hausaufgaben")
            }

            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentColor)
                Text("fertig")
            }

            Spacer(minLength: 0)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rechts an jeder Zeile: gelb für keine Hausaufgaben, blau für erledigt")
    }

    /// Der Vermerk, wenn der Tag als „nichts auf“ markiert ist.
    private var freeMarker: some View {
        Button {
            Haptics.tap()
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
            Haptics.tap()
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
