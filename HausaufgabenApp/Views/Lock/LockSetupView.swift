import SwiftUI

/// Code festlegen oder ändern.
struct LockSetupView: View {
    /// Gibt es schon einen Code? Dann muss er zuerst eingegeben werden.
    let isChanging: Bool

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var oldCode = ""
    @State private var newCode = ""
    @State private var repeated = ""
    @State private var hint = ""
    @State private var problem: String?

    private var biometrics: BiometricKind { BiometricAuth.availableKind() }

    var body: some View {
        NavigationStack {
            Form {
                if isChanging {
                    Section {
                        SecureField("Bisheriger Code", text: $oldCode)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Zur Sicherheit")
                    }
                }

                Section {
                    SecureField("Neuer Code", text: $newCode)
                        .keyboardType(.numberPad)
                    SecureField("Noch einmal", text: $repeated)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Code")
                } footer: {
                    Text("Vier bis acht Ziffern. Den Code brauchen alle, die Homy auf diesem Gerät öffnen wollen.")
                }

                Section {
                    TextField("z. B. „Geburtstag von Oma“", text: $hint)
                } header: {
                    Text("Merkzettel (freiwillig)")
                } footer: {
                    Text("Erscheint auf dem Anmeldebild unter „Code vergessen?“. Schreib also keinen Hinweis hin, aus dem sich der Code erraten lässt.")
                }

                if let problem {
                    Section {
                        Label(problem, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Text(warningText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(isChanging ? "Code ändern" : "Anmeldung einrichten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") { save() }
                }
            }
            .onAppear { hint = store.lock.hint }
        }
    }

    private var warningText: String {
        var text = "Der Code wird nicht im Klartext gespeichert – die App kann ihn dir später nicht mehr zeigen. Vergisst du ihn, hilft nur noch, Homy zu löschen und neu zu laden; die Hausaufgaben sind dann weg, falls du keine Sicherung hast."
        if biometrics.isAvailable {
            text += "\n\nDanach kannst du den Schnellstart mit \(biometrics.title) einschalten, damit du selbst nicht jedes Mal tippen musst."
        }
        return text
    }

    private func save() {
        let new = newCode.trimmingCharacters(in: .whitespaces)
        let again = repeated.trimmingCharacters(in: .whitespaces)

        if isChanging, !store.lock.matches(oldCode.trimmingCharacters(in: .whitespaces)) {
            problem = "Der bisherige Code stimmt nicht."
            return
        }
        guard LockSettings.isValidCode(new) else {
            problem = "Der Code muss aus 4 bis 8 Ziffern bestehen."
            return
        }
        guard new == again else {
            problem = "Die beiden Eingaben sind nicht gleich."
            return
        }

        var lock = store.lock
        lock.setCode(new)
        lock.isEnabled = true
        lock.hint = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        // Beim allerersten Einrichten den Schnellstart gleich anbieten.
        if !isChanging, biometrics.isAvailable {
            lock.useBiometrics = true
        }
        store.lock = lock

        Haptics.success()
        dismiss()
    }
}
