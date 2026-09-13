import SwiftUI

/// Bearbeitet eine einzelne Stunde des Stundenplans.
struct LessonEditorView: View {
    let weekday: Int
    let period: Int

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSubjectID: UUID?
    @State private var room = ""
    @State private var teacher = ""
    @State private var didLoad = false

    private var selectedSubject: Subject? { store.subject(id: selectedSubjectID) }

    private var timeText: String {
        guard let time = store.settings.time(forPeriod: period) else { return "" }
        return time.rangeText
    }

    /// Zeigt als Platzhalter, was aus den Fachangaben übernommen würde.
    private var roomPlaceholder: String {
        let fallback = selectedSubject?.room.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return fallback.isEmpty ? "Raum" : fallback
    }

    private var teacherPlaceholder: String {
        let fallback = selectedSubject?.teacher.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return fallback.isEmpty ? "Lehrkraft" : fallback
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        selectedSubjectID = nil
                    } label: {
                        HStack {
                            Text("Freistunde")
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedSubjectID == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }

                    ForEach(store.sortedSubjects) { subject in
                        Button {
                            selectedSubjectID = subject.id
                        } label: {
                            HStack(spacing: 12) {
                                SubjectBadge(subject: subject, width: 40)
                                Text(subject.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedSubjectID == subject.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Fach")
                } footer: {
                    if !timeText.isEmpty {
                        Text("Unterrichtszeit: \(timeText)")
                    }
                }

                Section {
                    TextField(roomPlaceholder, text: $room)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField(teacherPlaceholder, text: $teacher)
                        .autocorrectionDisabled()
                } header: {
                    Text("Abweichend für diese Stunde")
                } footer: {
                    Text("Leer lassen, um Raum und Lehrkraft aus den Angaben des Fachs zu übernehmen.")
                }

                if store.lesson(weekday: weekday, period: period) != nil {
                    Section {
                        Button(role: .destructive) {
                            store.clearLesson(weekday: weekday, period: period)
                            dismiss()
                        } label: {
                            Label("Stunde leeren", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("\(SchoolCalendar.weekdayShortName(weekday)), \(period). Stunde")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        store.setLesson(weekday: weekday,
                                        period: period,
                                        subjectID: selectedSubjectID,
                                        room: room,
                                        teacher: teacher)
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadIfNeeded)
        }
    }

    private func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        if let lesson = store.lesson(weekday: weekday, period: period) {
            selectedSubjectID = lesson.subjectID
            room = lesson.room
            teacher = lesson.teacher
        }
    }
}
