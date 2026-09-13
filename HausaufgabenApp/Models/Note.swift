import Foundation

/// Eine Notiz – wie ein Blatt Papier: antippen, schreiben, fertig.
///
/// Es gibt kein Titelfeld: Wie in Apples Notizen ist die erste beschriebene
/// Zeile der Titel, der Rest die Vorschau in der Liste.
struct Note: Identifiable, Codable, Hashable {
    var id: UUID
    /// Der ganze Text der Notiz, mehrzeilig.
    var text: String
    var createdAt: Date
    /// Zuletzt geschrieben – danach ist die Liste sortiert.
    var updatedAt: Date

    init(id: UUID = UUID(),
         text: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Ältere Sicherungen kennen updatedAt noch nicht; frühere Zusatzfelder
    // (Fach, Termin) werden beim Einlesen einfach übergangen.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        let created = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        createdAt = created
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? created
    }

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Titel und Vorschau aus dem Text

    private var lines: [String] {
        text.components(separatedBy: .newlines)
    }

    /// Die erste beschriebene Zeile.
    var title: String {
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { return trimmed }
        }
        return "Neue Notiz"
    }

    /// Alles nach der Titelzeile, zu einer Zeile zusammengefasst.
    var preview: String {
        guard let titleIndex = lines.firstIndex(where: {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }) else { return "" }

        let rest = lines.dropFirst(titleIndex + 1)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return String(rest.prefix(200))
    }
}
