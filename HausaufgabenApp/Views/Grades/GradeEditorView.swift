import SwiftUI

/// Eine Note eintragen oder ändern.
struct GradeEditorView: View {
    /// Die Note, die geändert wird – `nil` für eine neue.
    let existing: Grade?
    /// Welches Fach bei einer neuen Note vorausgewählt ist.
    var defaultSubjectID: UUID?
    /// Wird nach dem Sichern aufgerufen.
    var onSaved: (Grade) -> Void = { _ in }

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var subjectID: UUID?
    @State private var kind: GradeKind = .written
    @State private var value: Double?
    @State private var date = Date()
    @State private var title = ""
    @State private var problem: String?
    @State private var confirmDelete = false
    @State private var didLoad = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Fach", selection: $subjectID) {
                        ForEach(store.sortedSubjects) { fach in
                            Text(fach.displayName).tag(Optional(fach.id))
                        }
                    }
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    TextField("Wofür, z. B. Klassenarbeit 2", text: $title)
                }

                Section {
                    Picker("Art", selection: $kind) {
                        ForEach(GradeKind.allCases) { art in
                            Text(art.title).tag(art)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Art")
                } footer: {
                    Text("\(kind.title): \(kind.examples).")
                }

                Section {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(GradeScale.steps) { stufe in
                            gradeButton(stufe)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Note")
                }

                if let problem {
                    Section {
                        Label(problem, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if existing != nil {
                    Section {
                        Button("Note löschen", role: .destructive) {
                            confirmDelete = true
                        }
                    }
                }
            }
            .environment(\.locale, Locale(identifier: "de_DE"))
            .navigationTitle(existing == nil ? "Note eintragen" : "Note ändern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { save() }
                        .font(.body.weight(.semibold))
                }
            }
            .confirmationDialog("Note löschen?",
                                isPresented: $confirmDelete,
                                titleVisibility: .visible) {
                Button("Löschen", role: .destructive) {
                    if let existing {
                        store.deleteGrade(id: existing.id)
                    }
                    dismiss()
                }
            }
            .onAppear(perform: load)
        }
    }

    private func gradeButton(_ stufe: GradeStep) -> some View {
        let gewaehlt = value == stufe.value
        return Button {
            value = stufe.value
            problem = nil
            Haptics.tap()
        } label: {
            Text(stufe.name)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(gewaehlt ? Color.white : Color.primary)
                .background(gewaehlt ? Color.accentColor : Color(.tertiarySystemFill),
                            in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Note \(stufe.name)")
        .accessibilityAddTraits(gewaehlt ? .isSelected : [])
    }

    // MARK: - Laden und Sichern

    private func load() {
        guard !didLoad else { return }
        didLoad = true

        if let existing {
            subjectID = existing.subjectID
            kind = existing.kind
            value = existing.value
            date = SchoolCalendar.date(fromDayKey: existing.dayKey) ?? Date()
            title = existing.title
        } else {
            let gibtEs = defaultSubjectID.flatMap { id in store.subjects.contains { $0.id == id } ? id : nil }
            subjectID = gibtEs ?? store.sortedSubjects.first?.id
        }
    }

    private func save() {
        guard let subjectID else {
            problem = "Wähl ein Fach aus. Fächer legst du unter „Fächer“ an."
            return
        }
        guard let value else {
            problem = "Tipp noch die Note an."
            return
        }

        let note = Grade(id: existing?.id ?? UUID(),
                         subjectID: subjectID,
                         kind: kind,
                         value: value,
                         dayKey: SchoolCalendar.dayKey(date),
                         title: title)
        store.saveGrade(note)
        Haptics.success()
        onSaved(note)
        dismiss()
    }
}
