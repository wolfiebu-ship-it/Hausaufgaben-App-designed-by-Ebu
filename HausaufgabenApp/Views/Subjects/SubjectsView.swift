import SwiftUI

/// Liste aller Fächer mit Kürzel, Farbe, Lehrkraft und Raum.
struct SubjectsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editorMode: SubjectEditorMode?
    @State private var subjectToDelete: Subject?

    var body: some View {
        NavigationStack {
            Group {
                if store.subjects.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Fächer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorMode = .create
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Fach hinzufügen")
                }
            }
            .sheet(item: $editorMode) { mode in
                SubjectEditorView(mode: mode)
                    .environmentObject(store)
            }
            .confirmationDialog("Fach löschen?",
                                isPresented: Binding(
                                    get: { subjectToDelete != nil },
                                    set: { if !$0 { subjectToDelete = nil } }
                                ),
                                titleVisibility: .visible,
                                presenting: subjectToDelete) { subject in
                Button("„\(subject.displayName)“ löschen", role: .destructive) {
                    store.deleteSubject(id: subject.id)
                    subjectToDelete = nil
                }
                Button("Abbrechen", role: .cancel) { subjectToDelete = nil }
            } message: { subject in
                Text(deleteMessage(for: subject))
            }
        }
    }

    /// Der Tag, dessen Stunden oben stehen – heute, oder der nächste Schultag.
    private var schoolDay: Date? { store.currentSchoolDay() }

    private var dayTitle: String {
        guard let schoolDay else { return "" }
        let name = SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: schoolDay))
        if SchoolCalendar.isToday(schoolDay) { return "Heute · \(name)" }
        if SchoolCalendar.isSameDay(schoolDay,
                                    SchoolCalendar.calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()) {
            return "Morgen · \(name)"
        }
        return name
    }

    private var todaysLessons: [Lesson] {
        guard let schoolDay else { return [] }
        return store.lessons(onWeekday: SchoolCalendar.weekdayIndex(of: schoolDay))
    }

    private var list: some View {
        List {
            // Was an diesem Tag ansteht – in der Reihenfolge des Stundenplans.
            if !todaysLessons.isEmpty {
                Section {
                    ForEach(todaysLessons) { lesson in
                        if let subject = store.subject(id: lesson.subjectID) {
                            Button {
                                editorMode = .edit(subject)
                            } label: {
                                TodayLessonRow(lesson: lesson,
                                               subject: subject,
                                               time: store.settings.time(forPeriod: lesson.period),
                                               showTime: store.settings.showTimes,
                                               room: store.room(for: lesson))
                            }
                        }
                    }
                } header: {
                    Text(dayTitle)
                } footer: {
                    Text("Diese Stunden hast du an dem Tag – die Liste stellt sich jeden Tag von allein um.")
                }
            }

            Section {
                ForEach(store.sortedSubjects) { subject in
                    Button {
                        editorMode = .edit(subject)
                    } label: {
                        SubjectRow(subject: subject,
                                   lessonCount: store.lessonCount(forSubject: subject.id))
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            subjectToDelete = subject
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text(todaysLessons.isEmpty ? "" : "Alle Fächer")
            } footer: {
                Text("Das Kürzel steht im Stundenplan und links neben dem Hausaufgabenfeld.")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 44))
                .foregroundStyle(.tint)

            Text("Noch keine Fächer")
                .font(.headline)

            Text("Lege deine Fächer an – oder übernimm die typischen Schulfächer und passe sie danach an.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    store.addStarterSubjects()
                } label: {
                    Label("Typische Fächer übernehmen", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    editorMode = .create
                } label: {
                    Label("Eigenes Fach anlegen", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(32)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteMessage(for subject: Subject) -> String {
        let lessons = store.lessonCount(forSubject: subject.id)
        let homework = store.homeworkCount(forSubject: subject.id)

        if lessons == 0 && homework == 0 {
            return "Das Fach wird entfernt."
        }

        var parts: [String] = []
        if lessons > 0 {
            parts.append(lessons == 1 ? "1 Stunde im Stundenplan" : "\(lessons) Stunden im Stundenplan")
        }
        if homework > 0 {
            parts.append(homework == 1 ? "1 Hausaufgabe" : "\(homework) Hausaufgaben")
        }
        return "Dabei werden auch \(parts.joined(separator: " und ")) gelöscht. Das lässt sich nicht rückgängig machen."
    }
}

/// Eine Stunde des Tages: Nummer, Uhrzeit, Fach, Raum.
struct TodayLessonRow: View {
    let lesson: Lesson
    let subject: Subject
    let time: PeriodTime?
    let showTime: Bool
    let room: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text("\(lesson.period).")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                if showTime, let time {
                    Text(time.startText)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospacedDigit()
                }
            }
            .frame(width: 38, alignment: .leading)

            SubjectBadge(subject: subject, width: 44)

            Text(subject.displayName)
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            if !room.isEmpty {
                Text(room)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lesson.period). Stunde, \(subject.displayName)\(room.isEmpty ? "" : ", Raum \(room)")")
    }
}

/// Eine Zeile in der Fächerliste.
struct SubjectRow: View {
    let subject: Subject
    let lessonCount: Int

    var body: some View {
        HStack(spacing: 12) {
            SubjectBadge(subject: subject, width: 46)

            VStack(alignment: .leading, spacing: 2) {
                Text(subject.displayName)
                    .foregroundStyle(.primary)

                if !detailText.isEmpty {
                    Text(detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }

    private var detailText: String {
        var parts: [String] = []
        let teacher = subject.teacher.trimmingCharacters(in: .whitespacesAndNewlines)
        let room = subject.room.trimmingCharacters(in: .whitespacesAndNewlines)
        if !teacher.isEmpty { parts.append(teacher) }
        if !room.isEmpty { parts.append("Raum \(room)") }
        if lessonCount > 0 {
            parts.append(lessonCount == 1 ? "1 Stunde/Woche" : "\(lessonCount) Stunden/Woche")
        }
        return parts.joined(separator: " · ")
    }
}
