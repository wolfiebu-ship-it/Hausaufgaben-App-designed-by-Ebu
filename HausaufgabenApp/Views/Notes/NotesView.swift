import SwiftUI

/// Die Notizen: oben ein Feld zum Antippen, darunter, was man selbst
/// geschrieben hat. Aufgebaut wie Apples Notizen.
struct NotesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var openNoteID: UUID?

    private var notes: [Note] { store.sortedNotes }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    newNoteField

                    ForEach(notes) { note in
                        NoteRow(note: note)
                            .onTapGesture { openNoteID = note.id }
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.deleteNote(id: note.id)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }

                    if notes.isEmpty {
                        hint
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(DoodleCanvas())
            .navigationTitle("Notizen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: newNote) {
                        Image(systemName: "square.and.pencil")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .accessibilityLabel("Neue Notiz")
                }
            }
            .navigationDestination(item: $openNoteID) { id in
                NoteDetailView(noteID: id)
                    .environmentObject(store)
            }
        }
    }

    /// Das Feld, auf das man tippt, um loszuschreiben.
    private var newNoteField: some View {
        Button(action: newNote) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .foregroundStyle(.tint)

                Text("Notiz schreiben …")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .strokeBorder(Color.accentColor.opacity(0.35),
                                  style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Neue Notiz schreiben")
    }

    private var hint: some View {
        Text("Tippe oben auf das Feld und schreib los. Alles, was du hier notierst, findest du beim nächsten Öffnen wieder.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 24)
            .padding(.top, 18)
    }

    private func newNote() {
        Haptics.tap()
        openNoteID = store.createNote()
    }
}

/// Eine Zeile der Liste: Titel, Datum, Textanfang.
struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(note.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text(SchoolCalendar.noteTimestamp(note.updatedAt))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !note.preview.isEmpty {
                    Text(note.preview)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .contentShape(Rectangle())
    }
}
