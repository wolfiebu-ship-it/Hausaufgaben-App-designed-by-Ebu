import SwiftUI

enum SubjectEditorMode: Identifiable {
    case create
    case edit(Subject)

    var id: String {
        switch self {
        case .create: return "neu"
        case .edit(let subject): return subject.id.uuidString
        }
    }

    var existingSubject: Subject? {
        if case .edit(let subject) = self { return subject }
        return nil
    }
}

/// Legt ein Fach an oder ändert es.
struct SubjectEditorView: View {
    let mode: SubjectEditorMode

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var short: String
    @State private var colorIndex: Int
    @State private var teacher: String
    @State private var room: String
    /// Solange das Kürzel nicht von Hand geändert wurde, wird es aus dem Namen vorgeschlagen.
    @State private var shortWasEdited: Bool
    @State private var didPickStartColor = false

    init(mode: SubjectEditorMode) {
        self.mode = mode
        let subject = mode.existingSubject
        _name = State(initialValue: subject?.name ?? "")
        _short = State(initialValue: subject?.short ?? "")
        _colorIndex = State(initialValue: subject?.colorIndex ?? 0)
        _teacher = State(initialValue: subject?.teacher ?? "")
        _room = State(initialValue: subject?.room ?? "")
        _shortWasEdited = State(initialValue: subject != nil)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool { !trimmedName.isEmpty }

    private var previewSubject: Subject {
        Subject(name: trimmedName.isEmpty ? "Neues Fach" : trimmedName,
                short: short,
                colorIndex: colorIndex)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name, z. B. Mathematik", text: $name)

                    HStack {
                        // Eigenes Binding: nur eine Eingabe von Hand schaltet den
                        // automatischen Vorschlag aus dem Namen ab.
                        TextField("Kürzel, z. B. M", text: Binding(
                            get: { short },
                            set: { newValue in
                                shortWasEdited = true
                                short = String(newValue.prefix(4))
                            }
                        ))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                        SubjectBadge(subject: previewSubject, width: 46)
                    }
                } header: {
                    Text("Fach")
                } footer: {
                    Text("Das Kürzel darf bis zu 4 Zeichen lang sein.")
                }

                Section("Farbe") {
                    colorPicker
                }

                Section {
                    TextField("Lehrkraft", text: $teacher)
                        .autocorrectionDisabled()
                    TextField("Raum", text: $room)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                } header: {
                    Text("Standardangaben")
                } footer: {
                    Text("Diese Angaben gelten für alle Stunden des Fachs. Einzelne Stunden lassen sich im Stundenplan abweichend einstellen.")
                }
            }
            .navigationTitle(mode.existingSubject == nil ? "Neues Fach" : "Fach bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern", action: save)
                        .disabled(!canSave)
                }
            }
            .onAppear {
                if mode.existingSubject == nil && !didPickStartColor {
                    didPickStartColor = true
                    colorIndex = AppTheme.suggestedColorIndex(usedBy: store.subjects)
                }
            }
            .onChange(of: name) { _, newValue in
                guard !shortWasEdited else { return }
                let cleaned = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                short = String(cleaned.prefix(2)).uppercased()
            }
        }
    }

    private var colorPicker: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 46), spacing: 12)], spacing: 12) {
            ForEach(AppTheme.subjectColors.indices, id: \.self) { index in
                Button {
                    colorIndex = index
                } label: {
                    // Der Kreis zeigt beide Töne des Fachs: helle Fläche, kräftige Schrift.
                    Circle()
                        .fill(AppTheme.fill(at: index))
                        .frame(width: 36, height: 36)
                        .overlay {
                            if colorIndex == index {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(AppTheme.tint(at: index))
                            } else {
                                Circle()
                                    .fill(AppTheme.tint(at: index))
                                    .frame(width: 13, height: 13)
                            }
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(AppTheme.tint(at: index)
                                                .opacity(colorIndex == index ? 0.9 : 0),
                                              lineWidth: 2)
                                .padding(-3)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppTheme.colorName(at: index))
                .accessibilityAddTraits(colorIndex == index ? [.isSelected] : [])
            }
        }
        .padding(.vertical, 4)
    }

    private func save() {
        let cleanedShort = short.trimmingCharacters(in: .whitespacesAndNewlines)

        if var subject = mode.existingSubject {
            subject.name = trimmedName
            subject.short = cleanedShort
            subject.colorIndex = colorIndex
            subject.teacher = teacher.trimmingCharacters(in: .whitespacesAndNewlines)
            subject.room = room.trimmingCharacters(in: .whitespacesAndNewlines)
            store.updateSubject(subject)
        } else {
            store.addSubject(Subject(name: trimmedName,
                                     short: cleanedShort,
                                     colorIndex: colorIndex,
                                     teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
                                     room: room.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        dismiss()
    }
}
