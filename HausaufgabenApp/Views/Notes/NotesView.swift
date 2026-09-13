import SwiftUI

/// Eigene Notizen: anstehende Arbeiten, Referate, alles zum Nichtvergessen.
struct NotesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var editorMode: NoteEditorMode?
    @State private var showDoneConfirmation = false

    private var notes: [Note] { store.sortedNotes }
    private var doneCount: Int { store.notes.filter(\.isDone).count }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(DoodleCanvas())
            .navigationTitle("Notizen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorMode = .create
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Notiz hinzufügen")
                }
                if doneCount > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showDoneConfirmation = true
                        } label: {
                            Image(systemName: "checkmark.circle.badge.xmark")
                        }
                        .accessibilityLabel("Erledigte Notizen löschen")
                    }
                }
            }
            .sheet(item: $editorMode) { mode in
                NoteEditorView(mode: mode)
                    .environmentObject(store)
            }
            .alert("Erledigte Notizen löschen?", isPresented: $showDoneConfirmation) {
                Button("Löschen", role: .destructive) { store.deleteDoneNotes() }
                Button("Abbrechen", role: .cancel) { }
            } message: {
                Text(doneCount == 1
                     ? "Die erledigte Notiz wird entfernt."
                     : "Die \(doneCount) erledigten Notizen werden entfernt.")
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(notes) { note in
                    NoteCard(note: note) {
                        store.setNoteDone(!note.isDone, id: note.id)
                    } onTap: {
                        editorMode = .edit(note)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
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

            Button {
                editorMode = .create
            } label: {
                Label("Erste Notiz schreiben", systemImage: "square.and.pencil")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Eine Notiz als Karte, mit Fachfarbe als Streifen und Termin-Hinweis.
struct NoteCard: View {
    let note: Note
    let onToggleDone: () -> Void
    let onTap: () -> Void

    @EnvironmentObject private var store: AppStore

    private var subject: Subject? { store.subject(id: note.subjectID) }

    private var accent: Color {
        subject?.tint ?? Color.accentColor
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 5)

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(note.text)
                            .font(.body)
                            .foregroundStyle(note.isDone ? Color.secondary : Color.primary)
                            .strikethrough(note.isDone, color: .secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 6) {
                            if let subject {
                                Text(subject.displayShort)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(subject.tint)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(subject.fill, in: Capsule())
                            }

                            if let dueText = note.dueText {
                                Label(dueText, systemImage: "calendar")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(dueColor)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(dueColor.opacity(0.12), in: Capsule())
                            }

                            Spacer(minLength: 0)
                        }
                    }

                    Button(action: onToggleDone) {
                        Image(systemName: note.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(note.isDone ? Color.accentColor : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(note.isDone ? "Als offen markieren" : "Als erledigt markieren")
                }
                .padding(14)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .opacity(note.isDone ? 0.65 : 1)
        }
        .buttonStyle(.plain)
    }

    private var dueColor: Color {
        if note.isDone { return .secondary }
        if note.isOverdue { return .red }
        if note.isSoon { return .orange }
        return .secondary
    }
}
