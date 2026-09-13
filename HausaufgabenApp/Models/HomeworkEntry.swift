import Foundation

/// Eine Hausaufgabe für genau einen Tag und ein Fach.
struct HomeworkEntry: Identifiable, Codable, Hashable {
    var id: UUID
    /// Tag, an dem die Aufgabe aufgegeben wurde, als "yyyy-MM-dd".
    var dayKey: String
    /// Fach, zu dem die Aufgabe gehört.
    var subjectID: UUID
    /// Der eingetragene Text.
    var text: String
    /// Abgehakt?
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         dayKey: String,
         subjectID: UUID,
         text: String,
         isDone: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.dayKey = dayKey
        self.subjectID = subjectID
        self.text = text
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
