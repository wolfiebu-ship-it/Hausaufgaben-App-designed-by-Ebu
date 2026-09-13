import SwiftUI

/// Die Notizen-Liste – aufgebaut wie in Apples Notizen:
/// Titel fett, darunter Datum und der Anfang des Textes.
struct NotesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var openNoteID: UUID?

    private var upcoming: [Note] { store.upcomingNotes }
    private var others: [Note] { store.otherNotes }
    private var isEmpty: Bool { store.notes.isEmpty }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(DoodleCanvas())
            .navigationTitle("Notizen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: newNote) {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("Neue Notiz")
                }
            }
            .navigationDestination(item: $openNoteID) { id in
                NoteDetailView(noteID: id)
                    .environmentObject(store)
            }
        }
    }

    private var list: some View {
        List {
            if !upcoming.isEmpty {
                Section {
                    ForEach(upcoming) { note in
                        row(note)
                    }
                } header: {
                    Text("Termine")
                }
            }

            if !others.isEmpty {
                Section {
                    ForEach(others) { note in
                        row(note)
                    }
                } header: {
                    Text(upcoming.isEmpty ? "" : "Weitere Notizen")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func row(_ note: Note) -> some View {
        Button {
            openNoteID = note.id
        } label: {
            NoteRow(note: note)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                store.deleteNote(id: note.id)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                store.setNoteDone(!note.isDone, id: note.id)
            } label: {
                Label(note.isDone ? "Offen" : "Erledigt",
                      systemImage: note.isDone ? "arrow.uturn.backward" : "checkmark")
            }
            .tint(note.isDone ? .gray : .green)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "note.text")
                .font(.system(size: 46))
                .foregroundStyle(.tint)

            Text("Noch keine Notizen")
                .font(.headline)

            Text("Hier ist Platz für alles, was keine Hausaufgabe ist: die nächste Arbeit, ein Referat, Material zum Mitbringen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: newNote) {
                Label("Notiz schreiben", systemImage: "square.and.pencil")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func newNote() {
        openNoteID = store.createNote()
    }
}

/// Eine Zeile der Liste: Titel, Datum, Textanfang.
struct NoteRow: View {
    let note: Note
    @EnvironmentObject private var store: AppStore

    private var subject: Subject? { store.subject(id: note.subjectID) }

    var body: some View {
        HStack(spacing: 10) {
            if let subject {
                RoundedRectangle(cornerRadius: 2)
                    .fill(subject.tint)
                    .frame(width: 4)
                    .padding(.vertical, 2)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(note.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(note.isDone ? Color.secondary : Color.primary)
                        .strikethrough(note.isDone, color: .secondary)
                        .lineLimit(1)

                    if note.isDone {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 6) {
                    Text(SchoolCalendar.shortDate(note.updatedAt))
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if !note.preview.isEmpty {
                        Text(note.preview)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if note.dueText != nil || subject != nil {
                    HStack(spacing: 6) {
                        if let subject {
                            Text(subject.displayShort)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(subject.tint)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(subject.fill, in: Capsule())
                        }

                        if let dueText = note.dueText {
                            Label(dueText, systemImage: "calendar")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(dueColor)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(dueColor.opacity(0.13), in: Capsule())
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.top, 1)
                }
            }
        }
        .padding(.vertical, 3)
        .opacity(note.isDone ? 0.6 : 1)
        .contentShape(Rectangle())
    }

    private var dueColor: Color {
        if note.isDone { return .secondary }
        if note.isOverdue { return .red }
        if note.isSoon { return .orange }
        return .secondary
    }
}
