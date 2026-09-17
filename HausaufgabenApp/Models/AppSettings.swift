import Foundation

/// Start- und Endzeit einer Unterrichtsstunde, gespeichert als Minuten seit Mitternacht.
struct PeriodTime: Codable, Hashable, Identifiable {
    var period: Int
    var startMinutes: Int
    var endMinutes: Int

    var id: Int { period }

    var startText: String { PeriodTime.text(forMinutes: startMinutes) }
    var endText: String { PeriodTime.text(forMinutes: endMinutes) }
    var rangeText: String { "\(startText) – \(endText)" }

    static func text(forMinutes minutes: Int) -> String {
        let clamped = max(0, min(24 * 60 - 1, minutes))
        return String(format: "%02d:%02d", clamped / 60, clamped % 60)
    }

    /// Erzeugt einen üblichen Schultag: 45-Minuten-Stunden, 5 Minuten Wechselpause,
    /// nach der 2. und 4. Stunde eine große Pause.
    static func defaultTimes(count: Int) -> [PeriodTime] {
        times(count: count)
    }

    /// Rechnet einen ganzen Schultag aus: ab wann, wie lange, wie viel Pause.
    ///
    /// Damit muss niemand vierzehn Stunden einzeln einstellen – einmal
    /// „ab 8:00, 45 Minuten, 5 Minuten Pause“ angeben genügt.
    static func times(count: Int,
                      firstStartMinutes: Int = 8 * 60,
                      lengthMinutes: Int = 45,
                      breakMinutes: Int = 5,
                      longBreakMinutes: Int = 15,
                      longBreakAfter: Set<Int> = [2, 4]) -> [PeriodTime] {
        var result: [PeriodTime] = []
        var start = max(0, min(23 * 60, firstStartMinutes))
        let länge = max(5, min(240, lengthMinutes))

        for period in 1...max(1, min(14, count)) {
            let end = min(24 * 60 - 1, start + länge)
            result.append(PeriodTime(period: period, startMinutes: start, endMinutes: end))
            let pause = longBreakAfter.contains(period) ? longBreakMinutes : breakMinutes
            start = end + max(0, pause)
            // Über Mitternacht hinaus ergibt kein Schultag Sinn.
            if start >= 24 * 60 - länge { break }
        }
        return result
    }
}

/// Hell oder dunkel – oder so, wie das Gerät es gerade eingestellt hat.
enum AppearanceMode: String, Codable, Hashable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Automatisch"
        case .light:  return "Hell"
        case .dark:   return "Dunkel"
        }
    }

}

/// Einstellungen des Stundenplans.
struct AppSettings: Codable, Hashable {
    /// Anzahl der Stunden pro Tag (Zeilen im Stundenplan).
    var periodCount: Int
    /// Samstag als sechsten Schultag anzeigen.
    var includeSaturday: Bool
    /// Uhrzeiten im Stundenplan einblenden.
    var showTimes: Bool
    /// Im Hausaufgabenblatt auch Fächer zeigen, zu denen noch nichts eingetragen ist.
    /// Aus = nur eine Übersicht der eingetragenen Aufgaben.
    var showEmptySubjects: Bool
    /// Helles oder dunkles Erscheinungsbild der App.
    var appearance: AppearanceMode
    /// Das Bundesland – davon hängen die gesetzlichen Feiertage ab.
    var federalState: FederalState
    /// Erinnerungen an Kalendertermine verschicken.
    var remindersEnabled: Bool
    /// Welche Erinnerung ein neuer Termin von sich aus bekommt.
    var defaultReminder: ReminderOffset
    var periodTimes: [PeriodTime]

    init(periodCount: Int = 9,
         includeSaturday: Bool = false,
         showTimes: Bool = true,
         showEmptySubjects: Bool = true,
         appearance: AppearanceMode = .system,
         federalState: FederalState = .none,
         remindersEnabled: Bool = true,
         defaultReminder: ReminderOffset = .eveningBefore,
         periodTimes: [PeriodTime]? = nil) {
        self.periodCount = periodCount
        self.includeSaturday = includeSaturday
        self.showTimes = showTimes
        self.showEmptySubjects = showEmptySubjects
        self.appearance = appearance
        self.federalState = federalState
        self.remindersEnabled = remindersEnabled
        self.defaultReminder = defaultReminder
        self.periodTimes = periodTimes ?? PeriodTime.defaultTimes(count: periodCount)
    }

    /// Wochentage, die angezeigt werden (1 = Montag).
    var weekdays: [Int] { includeSaturday ? [1, 2, 3, 4, 5, 6] : [1, 2, 3, 4, 5] }

    var periods: [Int] { Array(1...max(1, periodCount)) }

    func time(forPeriod period: Int) -> PeriodTime? {
        periodTimes.first { $0.period == period }
    }

    /// Sorgt dafür, dass für jede Stunde eine Zeit hinterlegt ist.
    mutating func normalizeTimes() {
        periodCount = max(1, min(14, periodCount))
        let defaults = PeriodTime.defaultTimes(count: periodCount)
        var normalized: [PeriodTime] = []
        for period in 1...periodCount {
            if let existing = periodTimes.first(where: { $0.period == period }) {
                normalized.append(existing)
            } else if let fallback = defaults.first(where: { $0.period == period }) {
                normalized.append(fallback)
            }
        }
        periodTimes = normalized
    }

    // Fehlende Felder in älteren Sicherungen bekommen Standardwerte,
    // damit ein Update die Daten nicht unlesbar macht.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        periodCount = try container.decodeIfPresent(Int.self, forKey: .periodCount) ?? 9
        includeSaturday = try container.decodeIfPresent(Bool.self, forKey: .includeSaturday) ?? false
        showTimes = try container.decodeIfPresent(Bool.self, forKey: .showTimes) ?? true
        showEmptySubjects = try container.decodeIfPresent(Bool.self, forKey: .showEmptySubjects) ?? true
        appearance = try container.decodeIfPresent(AppearanceMode.self, forKey: .appearance) ?? .system
        federalState = try container.decodeIfPresent(FederalState.self, forKey: .federalState) ?? .none
        remindersEnabled = try container.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? true
        defaultReminder = try container.decodeIfPresent(ReminderOffset.self, forKey: .defaultReminder)
            ?? .eveningBefore
        periodTimes = try container.decodeIfPresent([PeriodTime].self, forKey: .periodTimes)
            ?? PeriodTime.defaultTimes(count: periodCount)
    }
}
