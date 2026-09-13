import Foundation

/// Eine freie Notiz – zum Beispiel eine anstehende Arbeit, ein Referat
/// oder etwas, das man einfach nicht vergessen will.
struct Note: Identifiable, Codable, Hashable {
    var id: UUID
    /// Worum es geht, z. B. „Mathe-Arbeit über Kapitel 3 und 4“.
    var text: String
    /// Fach, falls die Notiz zu einem gehört.
    var subjectID: UUID?
    /// Termin als "yyyy-MM-dd", falls es einen gibt.
    var dueDayKey: String?
    var isDone: Bool
    var createdAt: Date

    init(id: UUID = UUID(),
         text: String,
         subjectID: UUID? = nil,
         dueDayKey: String? = nil,
         isDone: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.subjectID = subjectID
        self.dueDayKey = dueDayKey
        self.isDone = isDone
        self.createdAt = createdAt
    }

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var dueDate: Date? {
        guard let dueDayKey else { return nil }
        return SchoolCalendar.date(fromDayKey: dueDayKey)
    }

    /// Wie viele Tage sind es noch? Negativ heißt: schon vorbei.
    var daysUntilDue: Int? {
        guard let dueDate else { return nil }
        let heute = SchoolCalendar.startOfDay(Date())
        return SchoolCalendar.calendar.dateComponents([.day], from: heute, to: dueDate).day
    }

    /// „Heute“, „Morgen“, „in 5 Tagen“ … – für die Anzeige neben dem Datum.
    var dueText: String? {
        guard let dueDate else { return nil }
        let datum = SchoolCalendar.shortWeekdayDate(dueDate)
        guard let tage = daysUntilDue else { return datum }

        switch tage {
        case 0:           return "\(datum) · heute"
        case 1:           return "\(datum) · morgen"
        case 2...7:       return "\(datum) · in \(tage) Tagen"
        case ..<0:        return "\(datum) · vorbei"
        default:          return datum
        }
    }

    /// Steht der Termin unmittelbar bevor?
    var isSoon: Bool {
        guard let tage = daysUntilDue else { return false }
        return tage >= 0 && tage <= 2
    }

    var isOverdue: Bool {
        guard let tage = daysUntilDue else { return false }
        return tage < 0
    }
}
