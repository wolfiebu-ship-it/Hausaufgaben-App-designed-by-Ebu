import SwiftUI

enum NoteEditorMode: Identifiable {
    case create
    case edit(Note)

    var id: String {
        switch self {
        case .create: return "neu"
        case .edit(let note): return note.id.uuidString
        }
    }

    var existingNote: Note? {
        if case .edit(let note) = self { return note }
        return nil
    }
}

/// Notiz schreiben oder ändern.
struct NoteEditorView: View {
    let mode: NoteEditorMode

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var textFocused: Bool

    @State private var text: String
    @State private var subjectID: UUID?
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(mode: NoteEditorMode) {
        self.mode = mode
        let note = mode.existingNote
        _text = State(initialValue: note?.text ?? "")
        _subjectID = State(initialValue: note?.subjectID)
        _hasDueDate = State(initialValue: note?.dueDate != nil)
        _dueDate = State(initialValue: note?.dueDate ?? SchoolCalendar.startOfDay(Date()))
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Worum geht es? z. B. Mathe-Arbeit über Kapitel 3",
                              text: $text, axis: .vertical)
                        .lineLimit(3...8)
                        .focused($textFocused)
                } header: {
                    Text("Notiz")
                }

                Section {
                    Toggle("Termin", isOn: $hasDueDate.animation())

                    if hasDueDate {
                        DatePicker("Datum",
                                   selection: $dueDate,
                                   displayedComponents: [.date])
                            .environment(\.locale, Locale(identifier: "de_DE"))
                    }
                } footer: {
                    Text("Mit Termin steht die Notiz oben in der Liste und zeigt, wie viele Tage es noch sind.")
                }

                Section("Fach") {
                    Button {
                        subjectID = nil
                    } label: {
                        HStack {
                            Text("Kein Fach")
                                .foregroundStyle(.primary)
                            Spacer()
                            if subjectID == nil {
                                Image(systemName: "checkmark").foregroundStyle(.tint)
                            }
                        }
                    }

                    ForEach(store.sortedSubjects) { subject in
                        Button {
                            subjectID = subject.id
                        } label: {
                            HStack(spacing: 12) {
                                SubjectBadge(subject: subject, width: 40)
                                Text(subject.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if subjectID == subject.id {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }

                if let note = mode.existingNote {
                    Section {
                        Button(role: .destructive) {
                            store.deleteNote(id: note.id)
                            dismiss()
                        } label: {
                            Label("Notiz löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(mode.existingNote == nil ? "Neue Notiz" : "Notiz bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern", action: save)
                        .disabled(trimmed.isEmpty)
                }
            }
            .onAppear {
                if mode.existingNote == nil { textFocused = true }
            }
        }
    }

    private func save() {
        let key = hasDueDate ? SchoolCalendar.dayKey(dueDate) : nil

        if var note = mode.existingNote {
            note.text = trimmed
            note.subjectID = subjectID
            note.dueDayKey = key
            store.updateNote(note)
        } else {
            store.addNote(Note(text: trimmed, subjectID: subjectID, dueDayKey: key))
        }
        dismiss()
    }
}
