import SwiftUI

/// Eine Notiz schreiben – ein leeres Blatt, in das man einfach lostippt.
/// Es gibt keinen Sichern-Knopf: Geschriebenes wird automatisch gespeichert.
struct NoteDetailView: View {
    let noteID: UUID

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var isWriting: Bool

    @State private var text: String = ""
    @State private var didLoad = false
    @State private var showSubjectPicker = false
    @State private var showDatePicker = false
    @State private var pickedDate = SchoolCalendar.startOfDay(Date())

    private var note: Note? { store.note(id: noteID) }
    private var subject: Subject? { store.subject(id: note?.subjectID) }

    var body: some View {
        VStack(spacing: 0) {
            chipBar

            TextEditor(text: $text)
                .focused($isWriting)
                .font(.body)
                .lineSpacing(2)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.top, 4)
        }
        .background(Color(.systemBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isWriting {
                    Button("Fertig") { isWriting = false }
                } else {
                    menu
                }
            }
        }
        .task {
            // Beim ersten Öffnen den gespeicherten Text übernehmen und,
            // wenn die Notiz noch leer ist, gleich die Tastatur zeigen.
            guard !didLoad else { return }
            didLoad = true
            text = note?.text ?? ""
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
        .sheet(isPresented: $showSubjectPicker) {
            subjectPicker
        }
        .sheet(isPresented: $showDatePicker) {
            datePicker
        }
    }

    // MARK: - Leiste über dem Blatt

    private var chipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    showSubjectPicker = true
                } label: {
                    if let subject {
                        chip(subject.displayShort, systemImage: nil,
                             foreground: subject.tint, background: subject.fill)
                    } else {
                        chip("Fach", systemImage: "plus",
                             foreground: .secondary, background: Color(.tertiarySystemFill))
                    }
                }

                Button {
                    pickedDate = note?.dueDate ?? SchoolCalendar.startOfDay(Date())
                    showDatePicker = true
                } label: {
                    if let dueText = note?.dueText {
                        chip(dueText, systemImage: "calendar",
                             foreground: dueColor, background: dueColor.opacity(0.13))
                    } else {
                        chip("Termin", systemImage: "plus",
                             foreground: .secondary, background: Color(.tertiarySystemFill))
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private func chip(_ title: String,
                      systemImage: String?,
                      foreground: Color,
                      background: Color) -> some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2.weight(.bold))
            }
            Text(title)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(background, in: Capsule())
    }

    private var dueColor: Color {
        guard let note else { return .secondary }
        if note.isOverdue { return .red }
        if note.isSoon { return .orange }
        return .secondary
    }

    // MARK: - Menü

    private var menu: some View {
        Menu {
            if let note {
                Button {
                    store.setNoteDone(!note.isDone, id: noteID)
                } label: {
                    Label(note.isDone ? "Als offen markieren" : "Als erledigt markieren",
                          systemImage: note.isDone ? "arrow.uturn.backward" : "checkmark.circle")
                }
            }

            if note?.dueDayKey != nil {
                Button {
                    store.setNoteDueDate(nil, id: noteID)
                } label: {
                    Label("Termin entfernen", systemImage: "calendar.badge.minus")
                }
            }

            Divider()

            Button(role: .destructive) {
                store.deleteNote(id: noteID)
                dismiss()
            } label: {
                Label("Notiz löschen", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    // MARK: - Auswahlblätter

    private var subjectPicker: some View {
        NavigationStack {
            List {
                Button {
                    store.setNoteSubject(nil, id: noteID)
                    showSubjectPicker = false
                } label: {
                    HStack {
                        Text("Kein Fach").foregroundStyle(.primary)
                        Spacer()
                        if note?.subjectID == nil {
                            Image(systemName: "checkmark").foregroundStyle(.tint)
                        }
                    }
                }

                ForEach(store.sortedSubjects) { item in
                    Button {
                        store.setNoteSubject(item.id, id: noteID)
                        showSubjectPicker = false
                    } label: {
                        HStack(spacing: 12) {
                            SubjectBadge(subject: item, width: 40)
                            Text(item.displayName).foregroundStyle(.primary)
                            Spacer()
                            if note?.subjectID == item.id {
                                Image(systemName: "checkmark").foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { showSubjectPicker = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var datePicker: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("Termin", selection: $pickedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "de_DE"))
                    .padding(.horizontal)

                if note?.dueDayKey != nil {
                    Button(role: .destructive) {
                        store.setNoteDueDate(nil, id: noteID)
                        showDatePicker = false
                    } label: {
                        Label("Termin entfernen", systemImage: "calendar.badge.minus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Termin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { showDatePicker = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Übernehmen") {
                        store.setNoteDueDate(pickedDate, id: noteID)
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
