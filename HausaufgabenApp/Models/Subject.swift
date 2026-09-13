import SwiftUI

/// Ein Schulfach, z. B. "Mathematik" mit dem Kürzel "M".
struct Subject: Identifiable, Codable, Hashable {
    var id: UUID
    /// Voller Name, z. B. "Mathematik".
    var name: String
    /// Kürzel, das im Stundenplan und neben dem Hausaufgabenfeld steht, z. B. "M".
    var short: String
    /// Index in `AppTheme.subjectColors`.
    var colorIndex: Int
    /// Standard-Lehrkraft (optional, kann pro Stunde überschrieben werden).
    var teacher: String
    /// Standard-Raum (optional, kann pro Stunde überschrieben werden).
    var room: String

    init(id: UUID = UUID(),
         name: String,
         short: String,
         colorIndex: Int,
         teacher: String = "",
         room: String = "") {
        self.id = id
        self.name = name
        self.short = short
        self.colorIndex = colorIndex
        self.teacher = teacher
        self.room = room
    }

    /// Kräftiger Ton für Kürzel und Schrift.
    var tint: Color { AppTheme.tint(at: colorIndex) }
    /// Helle Fläche als Hintergrund.
    var fill: Color { AppTheme.fill(at: colorIndex) }

    /// Kürzel für die Anzeige – fällt auf den Namensanfang zurück, falls leer.
    var displayShort: String {
        let trimmed = short.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let fallback = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if fallback.isEmpty { return "?" }
        return String(fallback.prefix(2)).uppercased()
    }

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? displayShort : trimmed
    }
}

extension Subject {
    /// Fächervorschläge, die beim ersten Start angelegt werden.
    /// Alles davon lässt sich in der App umbenennen oder löschen.
    static let starterSubjects: [Subject] = [
        Subject(name: "Deutsch", short: "D", colorIndex: 0),
        Subject(name: "Mathematik", short: "M", colorIndex: 6),
        Subject(name: "Englisch", short: "E", colorIndex: 3),
        Subject(name: "Biologie", short: "BIO", colorIndex: 4),
        Subject(name: "Chemie", short: "CH", colorIndex: 5),
        Subject(name: "Physik", short: "PH", colorIndex: 7),
        Subject(name: "Geschichte", short: "GE", colorIndex: 10),
        Subject(name: "Erdkunde", short: "EK", colorIndex: 8),
        Subject(name: "Sport", short: "SP", colorIndex: 1),
        Subject(name: "Kunst", short: "KU", colorIndex: 9),
        Subject(name: "Musik", short: "MU", colorIndex: 2),
        Subject(name: "Informatik", short: "INF", colorIndex: 11)
    ]
}
