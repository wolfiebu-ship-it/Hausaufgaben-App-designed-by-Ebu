import Foundation

/// Ein Feld im Stundenplan: Wochentag + Stunde + Fach.
struct Lesson: Identifiable, Codable, Hashable {
    var id: UUID
    /// 1 = Montag … 7 = Sonntag (siehe `SchoolCalendar.weekdayIndex`).
    var weekday: Int
    /// 1 = erste Stunde, 2 = zweite Stunde …
    var period: Int
    /// Das Fach. `nil` bedeutet Freistunde.
    var subjectID: UUID?
    /// Raum für genau diese Stunde (leer = Standardraum des Fachs).
    var room: String
    /// Lehrkraft für genau diese Stunde (leer = Standard-Lehrkraft des Fachs).
    var teacher: String

    init(id: UUID = UUID(),
         weekday: Int,
         period: Int,
         subjectID: UUID? = nil,
         room: String = "",
         teacher: String = "") {
        self.id = id
        self.weekday = weekday
        self.period = period
        self.subjectID = subjectID
        self.room = room
        self.teacher = teacher
    }

    var isEmpty: Bool {
        subjectID == nil
            && room.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && teacher.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
