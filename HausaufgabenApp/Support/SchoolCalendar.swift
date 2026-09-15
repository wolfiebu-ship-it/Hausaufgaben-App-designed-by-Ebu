import Foundation

/// Alle Datumsberechnungen der App an einer Stelle.
/// Die Woche beginnt immer am Montag.
enum SchoolCalendar {

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2          // Montag
        calendar.minimumDaysInFirstWeek = 4 // ISO-8601-Kalenderwochen
        calendar.locale = Locale(identifier: "de_DE")
        return calendar
    }()

    static let weekdayNames = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    static let weekdayShortNames = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    /// Name für den eigenen Index (1 = Montag … 7 = Sonntag).
    static func weekdayName(_ index: Int) -> String {
        guard (1...7).contains(index) else { return "" }
        return weekdayNames[index - 1]
    }

    static func weekdayShortName(_ index: Int) -> String {
        guard (1...7).contains(index) else { return "" }
        return weekdayShortNames[index - 1]
    }

    /// Rechnet den Kalender-Wochentag (1 = Sonntag) in unseren Index (1 = Montag) um.
    static func weekdayIndex(of date: Date) -> Int {
        let component = calendar.component(.weekday, from: date)
        return ((component + 5) % 7) + 1
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Montag der Woche, in der `date` liegt.
    static func startOfWeek(for date: Date) -> Date {
        let day = startOfDay(date)
        let offset = weekdayIndex(of: day) - 1
        return calendar.date(byAdding: .day, value: -offset, to: day) ?? day
    }

    /// Montag der Woche, die `weeks` Wochen von heute entfernt liegt.
    static func weekStart(offsetBy weeks: Int, from reference: Date = Date()) -> Date {
        let base = startOfWeek(for: reference)
        return calendar.date(byAdding: .weekOfYear, value: weeks, to: base) ?? base
    }

    /// Anzahl ganzer Wochen zwischen den Wochen zweier Daten.
    static func weekOffset(from reference: Date, to date: Date) -> Int {
        let a = startOfWeek(for: reference)
        let b = startOfWeek(for: date)
        return calendar.dateComponents([.weekOfYear], from: a, to: b).weekOfYear ?? 0
    }

    /// Datum eines bestimmten Wochentags innerhalb der Woche von `weekStart`.
    static func date(inWeekOf weekStart: Date, weekday: Int) -> Date {
        calendar.date(byAdding: .day, value: max(0, weekday - 1), to: startOfDay(weekStart)) ?? weekStart
    }

    static func calendarWeek(of date: Date) -> Int {
        calendar.component(.weekOfYear, from: date)
    }

    // MARK: - Monate (für den Kalender)

    /// Der Erste des Monats, in dem `date` liegt.
    static func startOfMonth(_ date: Date) -> Date {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: parts) ?? startOfDay(date)
    }

    /// Alle Tage, die im Monatsraster stehen: der Monat selbst, davor die
    /// letzten Tage des Vormonats und dahinter die ersten des nächsten –
    /// damit jede Zeile von Montag bis Sonntag voll ist.
    static func gridDays(forMonthOf date: Date) -> [Date] {
        let first = startOfMonth(date)
        let dayCount = calendar.range(of: .day, in: .month, for: first)?.count ?? 30
        let leading = weekdayIndex(of: first) - 1          // Tage vor dem Ersten
        guard let start = calendar.date(byAdding: .day, value: -leading, to: first) else {
            return []
        }
        // Immer volle Wochen, damit das Raster nicht springt.
        let total = Int((Double(leading + dayCount) / 7).rounded(.up)) * 7
        return (0..<total).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    private static let monthYearFormatter = formatter("MMMM yyyy")

    /// z. B. "September 2026"
    static func monthYear(_ date: Date) -> String {
        monthYearFormatter.string(from: date)
    }

    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    // MARK: - Schlüssel für gespeicherte Tage

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dayKey(_ date: Date) -> String {
        keyFormatter.string(from: date)
    }

    static func date(fromDayKey key: String) -> Date? {
        keyFormatter.date(from: key)
    }

    // MARK: - Anzeige

    private static func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = format
        return formatter
    }

    private static let dayMonthFormatter = formatter("d. MMMM")
    private static let shortDayFormatter = formatter("d.M.")
    private static let dayMonthYearFormatter = formatter("d. MMMM yyyy")
    private static let timeFormatter = formatter("HH:mm")

    /// Wann eine Notiz zuletzt geschrieben wurde: heute die Uhrzeit,
    /// sonst das Datum – wie in Apples Notizen.
    static func noteTimestamp(_ date: Date) -> String {
        if calendar.isDateInToday(date) { return timeFormatter.string(from: date) }
        if calendar.isDateInYesterday(date) { return "Gestern" }
        return shortDate(date)
    }

    /// z. B. "15. September"
    static func dayMonth(_ date: Date) -> String {
        dayMonthFormatter.string(from: date)
    }

    /// z. B. "15.9."
    static func shortDate(_ date: Date) -> String {
        shortDayFormatter.string(from: date)
    }

    static func longDate(_ date: Date) -> String {
        dayMonthYearFormatter.string(from: date)
    }

    /// z. B. "15.9. – 19.9.2025"
    static func weekRangeText(weekStart: Date, dayCount: Int) -> String {
        let end = calendar.date(byAdding: .day, value: max(0, dayCount - 1), to: weekStart) ?? weekStart
        return "\(shortDate(weekStart)) – \(longDate(end))"
    }

    /// Uhrzeit aus Minuten seit Mitternacht als Date (für DatePicker).
    static func date(fromMinutesSinceMidnight minutes: Int) -> Date {
        let clamped = max(0, min(24 * 60 - 1, minutes))
        let base = startOfDay(Date())
        return calendar.date(byAdding: .minute, value: clamped, to: base) ?? base
    }

    /// Minuten seit Mitternacht aus einem Date (für DatePicker).
    static func minutesSinceMidnight(from date: Date) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}
