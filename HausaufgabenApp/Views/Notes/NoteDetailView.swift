import SwiftUI

/// Eine Notiz schreiben – ein leeres Blatt, in das man einfach lostippt.
/// Es gibt keinen Sichern-Knopf: Geschriebenes wird automatisch gespeichert.
struct NoteDetailView: View {
    let noteID: UUID

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isWriting: Bool

    @State private var text = ""
    @State private var didLoad = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        TextEditor(text: $text)
            .focused($isWriting)
            .font(.body)
            .lineSpacing(3)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .padding(.horizontal, 12)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isWriting {
                        Button("Fertig") { isWriting = false }
                    } else {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("Notiz löschen")
                    }
                }
            }
            .task {
                // Beim Öffnen den gespeicherten Text übernehmen und, wenn die
                // Notiz noch leer ist, gleich die Tastatur zeigen.
                guard !didLoad else { return }
                didLoad = true
                text = store.note(id: noteID)?.text ?? ""
                if text.isEmpty {
                    try? await Task.sleep(for: .seconds(0.35))
                    isWriting = true
                }
            }
            // Kurz nach dem Tippen sichern – nicht bei jedem Zeichen.
            .task(id: text) {
                guard didLoad else { return }
                try? await Task.sleep(for: .seconds(0.5))
                guard !Task.isCancelled else { return }
                store.setNoteText(text, id: noteID)
            }
            .onDisappear {
                store.setNoteText(text, id: noteID)
                // Eine Notiz, in der nie etwas stand, wird nicht behalten.
                store.discardIfEmpty(id: noteID)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { store.setNoteText(text, id: noteID) }
            }
            .confirmationDialog("Diese Notiz löschen?",
                                isPresented: $showDeleteConfirmation,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    store.deleteNote(id: noteID)
                    dismiss()
                }
                Button("Abbrechen", role: .cancel) { }
            }
    }
}
