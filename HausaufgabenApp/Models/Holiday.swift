import SwiftUI

/// Ferien: ein Zeitraum mit Anfang und Ende, anders als ein einzelner Termin.
///
/// Für einen einzelnen freien Tag reicht ein Termin mit der Art „Schulfrei“ –
/// hier geht es um die Wochen am Stück.
struct Holiday: Identifiable, Codable, Hashable {
    var id: UUID
    /// Name der Ferien, z. B. „Herbstferien“.
    var name: String
    /// Erster Ferientag ("yyyy-MM-dd").
    var startDayKey: String
    /// Letzter Ferientag ("yyyy-MM-dd") – der Tag gehört noch dazu.
    var endDayKey: String
    /// Platz für Eigenes, etwa „Oma besuchen“ oder „Lernen für Mathe“.
    var note: String
    /// Erinnerung vor dem ersten Ferientag.
    var reminder: ReminderOffset
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         name: String = "",
         startDayKey: String,
         endDayKey: String,
         note: String = "",
         reminder: ReminderOffset = .eveningBefore,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.startDayKey = startDayKey
        self.endDayKey = endDayKey
        self.note = note
        self.reminder = reminder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Übliche Namen – als Vorschläge beim Eintragen.
    static let suggestedNames = [
        "Herbstferien",
        "Weihnachtsferien",
        "Winterferien",
        "Osterferien",
        "Pfingstferien",
        "Sommerferien",
        "Bewegliche Ferientage"
    ]

    /// Grün steht in Homy für „frei“ – nur Ferien und freie Tage sind grün,
    /// damit der grüne Punkt im Kalender eindeutig ist.
    static let tint = Color(lightHex: 0x1E8E3E, darkHex: 0x74DFA2)
    static let fill = Color(lightHex: 0xE2F5E8, darkHex: 0x15301F)

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var displayName: String {
        trimmedName.isEmpty ? "Ferien" : trimmedName
    }

    var startDate: Date? { SchoolCalendar.date(fromDayKey: startDayKey) }
    var endDate: Date? { SchoolCalendar.date(fromDayKey: endDayKey) }

    /// Anfang und Ende in der richtigen Reihenfolge – falls jemand sie vertauscht.
    var orderedDates: (start: Date, end: Date)? {
        guard let a = startDate, let b = endDate else { return nil }
        return a <= b ? (a, b) : (b, a)
    }

    /// Wie viele Tage die Ferien dauern (beide Enden zählen mit).
    var dayCount: Int {
        guard let (start, end) = orderedDates else { return 0 }
        let tage = SchoolCalendar.calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return tage + 1
    }

    /// Liegt dieser Tag in den Ferien?
    func contains(_ day: Date) -> Bool {
        guard let (start, end) = orderedDates else { return false }
        let tag = SchoolCalendar.startOfDay(day)
        return tag >= start && tag <= end
    }

    func isStart(_ day: Date) -> Bool {
        guard let (start, _) = orderedDates else { return false }
        return SchoolCalendar.isSameDay(day, start)
    }

    func isEnd(_ day: Date) -> Bool {
        guard let (_, end) = orderedDates else { return false }
        return SchoolCalendar.isSameDay(day, end)
    }

    /// Der wievielte Ferientag ist das? (1 = erster Tag)
    func dayNumber(of day: Date) -> Int? {
        guard let (start, _) = orderedDates, contains(day) else { return nil }
        let tage = SchoolCalendar.calendar.dateComponents(
            [.day], from: start, to: SchoolCalendar.startOfDay(day)).day ?? 0
        return tage + 1
    }

    /// Laufen die Ferien gerade?
    func isRunning(on reference: Date = Date()) -> Bool {
        contains(reference)
    }

    /// Sind die Ferien vorbei?
    func isOver(on reference: Date = Date()) -> Bool {
        guard let (_, end) = orderedDates else { return false }
        return SchoolCalendar.startOfDay(reference) > end
    }

    /// „Montag, 19. Oktober 2026“
    var startText: String {
        guard let (start, _) = orderedDates else { return "—" }
        return Holiday.longWeekdayText(start)
    }

    var endText: String {
        guard let (_, end) = orderedDates else { return "—" }
        return Holiday.longWeekdayText(end)
    }

    static func longWeekdayText(_ date: Date) -> String {
        "\(SchoolCalendar.weekdayName(SchoolCalendar.weekdayIndex(of: date))), \(SchoolCalendar.longDate(date))"
    }

    /// Der Kalendertag nach dem letzten Ferientag.
    ///
    /// Das ist noch **nicht** der erste Schultag – der kann auf ein Wochenende
    /// fallen. Den rechnet `AppStore.firstSchoolDay(after:)` aus, weil dafür
    /// die Schultage aus den Einstellungen gebraucht werden.
    var dayAfterEnd: Date? {
        guard let (_, end) = orderedDates else { return nil }
        return SchoolCalendar.calendar.date(byAdding: .day, value: 1, to: end)
    }

    /// Erinnerung vor dem ersten Ferientag – gerechnet wie bei einem Termin.
    var reminderDate: Date? {
        guard reminder != .none, let (start, _) = orderedDates else { return nil }
        // Ferien haben keine Uhrzeit: es zählt der Morgen des ersten Tages.
        let event = CalendarEvent(dayKey: SchoolCalendar.dayKey(start),
                                  title: displayName,
                                  kind: .free,
                                  reminder: reminder)
        return event.reminderDate
    }

    // Ältere Sicherungen kennen die Ferien noch nicht.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        startDayKey = try container.decodeIfPresent(String.self, forKey: .startDayKey) ?? ""
        endDayKey = try container.decodeIfPresent(String.self, forKey: .endDayKey) ?? ""
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        reminder = try container.decodeIfPresent(ReminderOffset.self, forKey: .reminder) ?? .none
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}
