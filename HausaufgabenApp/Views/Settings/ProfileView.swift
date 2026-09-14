import SwiftUI
import UIKit

/// Die eigenen Angaben: Name, Klasse, Telefonnummer, Adresse …
/// Alles freiwillig, alles nur auf diesem Gerät.
struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showClearConfirmation = false

    var body: some View {
        Form {
            Section {
                LabeledField(title: "Vorname",
                             text: $store.profile.firstName,
                             contentType: .givenName)
                LabeledField(title: "Nachname",
                             text: $store.profile.lastName,
                             contentType: .familyName)
            } header: {
                Text("Name")
            }

            Section {
                LabeledField(title: "Klasse", text: $store.profile.schoolClass,
                             autocapitalization: .characters)
                LabeledField(title: "Schule", text: $store.profile.school,
                             contentType: .organizationName)
            } header: {
                Text("Schule")
            }

            Section {
                LabeledField(title: "Telefon",
                             text: $store.profile.phone,
                             contentType: .telephoneNumber,
                             keyboard: .phonePad)
                LabeledField(title: "E-Mail",
                             text: $store.profile.email,
                             contentType: .emailAddress,
                             keyboard: .emailAddress,
                             autocapitalization: .never)
            } header: {
                Text("Kontakt")
            }

            Section {
                TextField("Straße, Postleitzahl, Ort",
                          text: $store.profile.address,
                          axis: .vertical)
                    .lineLimit(2...5)
                    .textContentType(.fullStreetAddress)
            } header: {
                Text("Adresse")
            }

            Section {
                TextField("Alles Weitere – Spind-Nummer, Buslinie, wen man im Notfall anruft …",
                          text: $store.profile.notes,
                          axis: .vertical)
                    .lineLimit(3...10)
            } header: {
                Text("Weitere Angaben")
            }

            if !store.profile.isEmpty {
                Section {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        Label("Angaben löschen", systemImage: "trash")
                    }
                }
            }

            Section {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.tint)
                    Text("Diese Angaben bleiben auf deinem Gerät. Die App verschickt nichts und hat keine Verbindung ins Internet. Nur wenn du selbst eine Sicherung speicherst, stehen sie mit in dieser Datei.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Meine Daten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") { hideKeyboard() }
            }
        }
        .alert("Angaben löschen?", isPresented: $showClearConfirmation) {
            Button("Löschen", role: .destructive) {
                store.profile = Profile()
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Alle eingetragenen Angaben über dich werden entfernt. Hausaufgaben, Stundenplan und Notizen bleiben erhalten.")
        }
    }
}

/// Eine Zeile im Formular: Beschriftung links, Eingabefeld rechts.
struct LabeledField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 96, alignment: .leading)

            TextField(title, text: $text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .multilineTextAlignment(.leading)
        }
    }
}
