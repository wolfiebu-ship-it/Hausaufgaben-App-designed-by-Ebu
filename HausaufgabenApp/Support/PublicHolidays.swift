import Foundation

/// Ein gesetzlicher Feiertag – von Homy ausgerechnet, nicht eingetragen.
struct PublicHoliday: Identifiable, Hashable {
    /// Der Tag als Schlüssel ("yyyy-MM-dd") – zugleich die Kennung.
    let id: String
    let name: String
    let date: Date
    /// Hinweis, wenn der Tag nicht überall im Land frei ist.
    let note: String?

    init(date: Date, name: String, note: String? = nil) {
        self.id = SchoolCalendar.dayKey(date)
        self.name = name
        self.date = date
        self.note = note
    }
}

/// Rechnet die gesetzlichen Feiertage eines Bundeslandes aus.
///
/// Das geht ohne Internet und ohne hinterlegte Listen: Die festen Feiertage
/// stehen im Kalender, die beweglichen hängen alle am Ostersonntag, und der
/// lässt sich für jedes Jahr ausrechnen.
///
/// **Nicht** ausrechnen lassen sich die Schulferien – die legt jedes Land für
/// jedes Schuljahr neu fest. Die trägt man in Homy selbst ein.
enum PublicHolidays {

    // MARK: - Ostersonntag

    /// Ostersonntag nach der gregorianischen Osterformel (Meeus/Jones/Butcher).
    static func easterSunday(year: Int) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        return SchoolCalendar.calendar.date(from: parts)
    }

    // MARK: - Die Feiertage eines Jahres

    /// Alle gesetzlichen Feiertage des Jahres in diesem Bundesland,
    /// nach Datum sortiert.
    static func all(year: Int, state: FederalState) -> [PublicHoliday] {
        guard state.isSet, let ostern = easterSunday(year: year) else { return [] }

        func fest(_ month: Int, _ day: Int, _ name: String, note: String? = nil) -> PublicHoliday? {
            var parts = DateComponents()
            parts.year = year
            parts.month = month
            parts.day = day
            guard let datum = SchoolCalendar.calendar.date(from: parts) else { return nil }
            return PublicHoliday(date: datum, name: name, note: note)
        }

        func umOstern(_ tage: Int, _ name: String, note: String? = nil) -> PublicHoliday? {
            guard let datum = SchoolCalendar.calendar.date(byAdding: .day, value: tage, to: ostern) else {
                return nil
            }
            return PublicHoliday(date: datum, name: name, note: note)
        }

        var liste: [PublicHoliday?] = []

        // In ganz Deutschland
        liste.append(fest(1, 1, "Neujahr"))
        liste.append(umOstern(-2, "Karfreitag"))
        liste.append(umOstern(1, "Ostermontag"))
        liste.append(fest(5, 1, "Tag der Arbeit"))
        liste.append(umOstern(39, "Christi Himmelfahrt"))
        liste.append(umOstern(50, "Pfingstmontag"))
        liste.append(fest(10, 3, "Tag der Deutschen Einheit"))
        liste.append(fest(12, 25, "1. Weihnachtstag"))
        liste.append(fest(12, 26, "2. Weihnachtstag"))

        // Nur in bestimmten Ländern
        if [.badenWuerttemberg, .bayern, .sachsenAnhalt].contains(state) {
            liste.append(fest(1, 6, "Heilige Drei Könige"))
        }
        if [.berlin, .mecklenburgVorpommern].contains(state) {
            liste.append(fest(3, 8, "Internationaler Frauentag"))
        }
        if state == .brandenburg {
            liste.append(umOstern(0, "Ostersonntag"))
            liste.append(umOstern(49, "Pfingstsonntag"))
        }
        if [.badenWuerttemberg, .bayern, .hessen,
            .nordrheinWestfalen, .rheinlandPfalz, .saarland].contains(state) {
            liste.append(umOstern(60, "Fronleichnam"))
        }
        if state == .saarland {
            liste.append(fest(8, 15, "Mariä Himmelfahrt"))
        }
        if state == .bayern {
            liste.append(fest(8, 15, "Mariä Himmelfahrt",
                              note: "nur in überwiegend katholischen Gemeinden"))
        }
        if state == .thueringen {
            liste.append(fest(9, 20, "Weltkindertag"))
        }
        if [.brandenburg, .bremen, .hamburg, .mecklenburgVorpommern, .niedersachsen,
            .sachsen, .sachsenAnhalt, .schleswigHolstein, .thueringen].contains(state) {
            liste.append(fest(10, 31, "Reformationstag"))
        }
        if [.badenWuerttemberg, .bayern, .nordrheinWestfalen,
            .rheinlandPfalz, .saarland].contains(state) {
            liste.append(fest(11, 1, "Allerheiligen"))
        }
        if state == .sachsen, let busstag = bussUndBettag(year: year) {
            liste.append(PublicHoliday(date: busstag, name: "Buß- und Bettag"))
        }

        return liste.compactMap { $0 }.sorted { $0.date < $1.date }
    }

    /// Buß- und Bettag: der Mittwoch vor dem 23. November.
    static func bussUndBettag(year: Int) -> Date? {
        var parts = DateComponents()
        parts.year = year
        parts.month = 11
        parts.day = 23
        guard let stichtag = SchoolCalendar.calendar.date(from: parts) else { return nil }

        // Vom 23. November aus rückwärts bis zum Mittwoch (Index 3).
        var tag = stichtag
        for _ in 0..<7 {
            guard let vortag = SchoolCalendar.calendar.date(byAdding: .day, value: -1, to: tag) else {
                return nil
            }
            tag = vortag
            if SchoolCalendar.weekdayIndex(of: tag) == 3 { return tag }
        }
        return nil
    }

    // MARK: - Nachschlagen

    /// Gemerkt je Jahr und Bundesland, damit das Monatsraster nicht
    /// für jede Zelle neu rechnet.
    private static var cache: [String: [String: PublicHoliday]] = [:]

    private static func table(year: Int, state: FederalState) -> [String: PublicHoliday] {
        let schluessel = "\(year)-\(state.rawValue)"
        if let fertig = cache[schluessel] { return fertig }

        var tabelle: [String: PublicHoliday] = [:]
        for feiertag in all(year: year, state: state) {
            tabelle[feiertag.id] = feiertag
        }
        cache[schluessel] = tabelle
        return tabelle
    }

    /// Ist dieser Tag ein gesetzlicher Feiertag?
    static func holiday(on day: Date, state: FederalState) -> PublicHoliday? {
        guard state.isSet else { return nil }
        let jahr = SchoolCalendar.calendar.component(.year, from: day)
        return table(year: jahr, state: state)[SchoolCalendar.dayKey(day)]
    }

    /// Die nächsten Feiertage ab heute – für die Vorschau in den Einstellungen.
    static func upcoming(from reference: Date = Date(),
                         state: FederalState,
                         limit: Int = 4) -> [PublicHoliday] {
        guard state.isSet else { return [] }
        let heute = SchoolCalendar.startOfDay(reference)
        let jahr = SchoolCalendar.calendar.component(.year, from: heute)

        // Das laufende und das nächste Jahr reichen für eine Vorschau.
        let alle = all(year: jahr, state: state) + all(year: jahr + 1, state: state)
        return alle.filter { $0.date >= heute }.prefix(limit).map { $0 }
    }
}
