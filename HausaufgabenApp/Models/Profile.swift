import Foundation

/// Die eigenen Angaben – Name, Klasse, Telefonnummer und so weiter.
///
/// Alles freiwillig und alles nur auf dem eigenen Gerät: Diese Angaben
/// werden nirgendwohin geschickt und von niemandem ausgelesen.
struct Profile: Codable, Hashable {
    var firstName: String
    var lastName: String
    var schoolClass: String
    var school: String
    var phone: String
    var email: String
    var address: String
    /// Platz für alles Weitere – Spind-Nummer, Busline, Notfallkontakt …
    var notes: String

    init(firstName: String = "",
         lastName: String = "",
         schoolClass: String = "",
         school: String = "",
         phone: String = "",
         email: String = "",
         address: String = "",
         notes: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.schoolClass = schoolClass
        self.school = school
        self.phone = phone
        self.email = email
        self.address = address
        self.notes = notes
    }

    // Ältere Sicherungen kennen diese Angaben noch nicht.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        schoolClass = try container.decodeIfPresent(String.self, forKey: .schoolClass) ?? ""
        school = try container.decodeIfPresent(String.self, forKey: .school) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

    /// Vor- und Nachname zusammen, soweit vorhanden.
    var fullName: String {
        [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Ist überhaupt etwas eingetragen?
    var isEmpty: Bool {
        [firstName, lastName, schoolClass, school, phone, email, address, notes]
            .allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// Kurzfassung für die Zeile in den Einstellungen.
    var summary: String {
        let name = fullName
        let klasse = schoolClass.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty && !klasse.isEmpty { return "\(name) · \(klasse)" }
        if !name.isEmpty { return name }
        if !klasse.isEmpty { return klasse }
        return "Noch nichts eingetragen"
    }
}
