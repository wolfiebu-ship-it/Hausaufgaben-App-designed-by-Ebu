import SwiftUI

/// Was für ein Termin das ist – bestimmt Farbe und Symbol im Kalender.
enum EventKind: String, Codable, Hashable, CaseIterable, Identifiable {
    case exam       // Klassenarbeit, Klausur
    case test       // Test, Vokabelabfrage
    case deadline   // Abgabe
    case trip       // Ausflug, Wandertag
    case free       // schulfrei, Ferien
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .exam:     return "Arbeit"
        case .test:     return "Test"
        case .deadline: return "Abgabe"
        case .trip:     return "Ausflug"
        case .free:     return "Schulfrei"
        case .other:    return "Sonstiges"
        }
    }

    var symbol: String {
        switch self {
        case .exam:     return "doc.text.fill"
        case .test:     return "questionmark.circle.fill"
        case .deadline: return "tray.and.arrow.up.fill"
        case .trip:     return "figure.walk"
        case .free:     return "sun.max.fill"
        case .other:    return "calendar"
        }
    }

    var tint: Color {
        switch self {
        case .exam:     return Color(lightHex: 0xC0392B, darkHex: 0xFF9E90)
        case .test:     return Color(lightHex: 0xB15A0E, darkHex: 0xFFBB72)
        case .deadline: return Color(lightHex: 0x7A3AC9, darkHex: 0xC8A2FB)
        case .trip:     return Color(lightHex: 0x217A4B, darkHex: 0x74DFA2)
        case .free:     return Color(lightHex: 0x0E7B72, darkHex: 0x5DDCCB)
        case .other:    return Color(lightHex: 0x4A5A70, darkHex: 0xADBCD0)
        }
    }

    var fill: Color {
        switch self {
        case .exam:     return Color(lightHex: 0xFDE7E3, darkHex: 0x42201C)
        case .test:     return Color(lightHex: 0xFDEDDA, darkHex: 0x3E2A13)
        case .deadline: return Color(lightHex: 0xF1E8FC, darkHex: 0x2C1B47)
        case .trip:     return Color(lightHex: 0xE2F5E8, darkHex: 0x15301F)
        case .free:     return Color(lightHex: 0xDDF3F0, darkHex: 0x0F2F2B)
        case .other:    return Color(lightHex: 0xEAEEF4, darkHex: 0x232B36)
        }
    }
}

/// Wann Homy an einen Termin erinnert.
enum ReminderOffset: String, Codable, Hashable, CaseIterable, Identifiable {
    /// Gar nicht erinnern.
    case none
    /// Zur Uhrzeit des Termins – bei ganztägigen Terminen um 7:30 Uhr.
    case atStart
    /// Eine Stunde vorher (bei ganztägigen Terminen: am Morgen um 7:30 Uhr).
    case hourBefore
    /// Am Abend davor um 18:00 Uhr.
    case eveningBefore
    /// Zwei Tage vorher um 18:00 Uhr.
    case twoDaysBefore
    /// Eine Woche vorher um 18:00 Uhr.
    case weekBefore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:          return "Keine Erinnerung"
        case .atStart:       return "Wenn es losgeht"
        case .hourBefore:    return "1 Stunde vorher"
        case .eveningBefore: return "Am Abend davor"
        case .twoDaysBefore: return "2 Tage vorher"
        case .weekBefore:    return "1 Woche vorher"
        }
    }

    /// Kurze Erklärung für die Auswahl.
    var explanation: String {
        switch self {
        case .none:          return "Homy sagt zu diesem Termin nichts."
        case .atStart:       return "Zur Uhrzeit des Termins. Ohne Uhrzeit: am Morgen um 7:30 Uhr."
        case .hourBefore:    return "Eine Stunde vorher. Ohne Uhrzeit: am Morgen um 7:30 Uhr."
        case .eveningBefore: return "Am Abend vorher um 18:00 Uhr – wenn noch Zeit zum Lernen ist."
        case .twoDaysBefore: return "Zwei Tage vorher um 18:00 Uhr."
        case .weekBefore:    return "Eine Woche vorher um 18:00 Uhr."
        }
    }

    /// Erinnerungen ohne Uhrzeit landen am Morgen des Tages.
    static let allDayHour = 7
    static let allDayMinute = 30
    /// Vorab-Erinnerungen kommen abends.
    static let eveningHour = 18
}

/// Ein Eintrag im Kalender – eine Arbeit, eine Abgabe, ein Ausflug.
struct CalendarEvent: Identifiable, Codable, Hashable {
    var id: UUID
    /// Tag des Termins ("yyyy-MM-dd").
    var dayKey: String
    var title: String
    /// Freier Text mit Einzelheiten (was drankommt, was mitzubringen ist …).
    var details: String
    /// Uhrzeit als Minuten seit Mitternacht; `nil` heißt: ganztägig.
    var startMinutes: Int?
    var kind: EventKind
    /// Zugehöriges Fach, falls es eins gibt.
    var subjectID: UUID?
    var reminder: ReminderOffset
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         dayKey: String,
         title: String = "",
         details: String = "",
         startMinutes: Int? = nil,
         kind: EventKind = .exam,
         subjectID: UUID? = nil,
         reminder: ReminderOffset = .eveningBefore,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.dayKey = dayKey
        self.title = title
        self.details = details
        self.startMinutes = startMinutes
        self.kind = kind
        self.subjectID = subjectID
        self.reminder = reminder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasTitle: Bool { !trimmedTitle.isEmpty }

    /// Titel für die Anzeige – fällt auf die Art zurück, falls nichts dasteht.
    var displayTitle: String {
        hasTitle ? trimmedTitle : kind.title
    }

    var isAllDay: Bool { startMinutes == nil }

    /// Der Tag des Termins als Datum.
    var date: Date? {
        SchoolCalendar.date(fromDayKey: dayKey)
    }

    /// Anfang des Termins als echter Zeitpunkt.
    var startDate: Date? {
        guard let date else { return nil }
        let minutes = startMinutes ?? (ReminderOffset.allDayHour * 60 + ReminderOffset.allDayMinute)
        return SchoolCalendar.calendar.date(byAdding: .minute,
                                            value: minutes,
                                            to: SchoolCalendar.startOfDay(date))
    }

    var timeText: String? {
        guard let startMinutes else { return nil }
        return PeriodTime.text(forMinutes: startMinutes) + " Uhr"
    }

    /// Wann die Benachrichtigung kommen soll – `nil`, wenn keine gewünscht ist.
    var reminderDate: Date? {
        guard reminder != .none, let day = date, let start = startDate else { return nil }
        let calendar = SchoolCalendar.calendar

        switch reminder {
        case .none:
            return nil
        case .atStart:
            return start
        case .hourBefore:
            // Bei ganztägigen Terminen gibt es keine sinnvolle „Stunde vorher“ –
            // dann bleibt es beim Morgen des Tages.
            guard startMinutes != nil else { return start }
            return calendar.date(byAdding: .hour, value: -1, to: start)
        case .eveningBefore:
            return evening(daysBefore: 1, from: day)
        case .twoDaysBefore:
            return evening(daysBefore: 2, from: day)
        case .weekBefore:
            return evening(daysBefore: 7, from: day)
        }
    }

    private func evening(daysBefore days: Int, from day: Date) -> Date? {
        let calendar = SchoolCalendar.calendar
        guard let earlier = calendar.date(byAdding: .day, value: -days, to: SchoolCalendar.startOfDay(day)) else {
            return nil
        }
        return calendar.date(byAdding: .hour, value: ReminderOffset.eveningHour, to: earlier)
    }

    /// Liegt die Erinnerung noch in der Zukunft? Nur solche lassen sich stellen.
    func hasFutureReminder(now: Date = Date()) -> Bool {
        guard let reminderDate else { return false }
        return reminderDate > now
    }

    // Ältere Sicherungen kennen den Kalender noch nicht – und in neueren
    // Fassungen könnten Felder dazukommen.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        dayKey = try container.decodeIfPresent(String.self, forKey: .dayKey) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        startMinutes = try container.decodeIfPresent(Int.self, forKey: .startMinutes)
        kind = try container.decodeIfPresent(EventKind.self, forKey: .kind) ?? .other
        subjectID = try container.decodeIfPresent(UUID.self, forKey: .subjectID)
        reminder = try container.decodeIfPresent(ReminderOffset.self, forKey: .reminder) ?? .none
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}
