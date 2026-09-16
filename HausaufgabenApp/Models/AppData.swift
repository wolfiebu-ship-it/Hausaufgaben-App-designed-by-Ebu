import Foundation

/// Alles, was die App speichert – als eine Datei auf dem Gerät und als Sicherungsdatei.
struct AppData: Codable {
    var version: Int
    var subjects: [Subject]
    var lessons: [Lesson]
    var homework: [HomeworkEntry]
    /// Tage ("yyyy-MM-dd"), an denen ausdrücklich nichts aufgegeben wurde.
    /// So bleibt unterscheidbar, ob es nichts gab oder nur nichts eingetragen wurde.
    var noHomeworkDays: Set<String>
    /// Einzelne Fächer, in denen an einem Tag nichts aufgegeben wurde.
    /// Schlüssel: "yyyy-MM-dd|Fach-Kennung".
    var noHomeworkSubjects: Set<String>
    /// Freie Notizen, etwa anstehende Arbeiten.
    var notes: [Note]
    /// Termine im Kalender (Arbeiten, Abgaben, Ausflüge).
    var events: [CalendarEvent]
    /// Ferien mit Anfang und Ende.
    var holidays: [Holiday]
    /// Die eigenen Angaben (Name, Klasse, Telefon …).
    var profile: Profile
    var settings: AppSettings
    /// Die Anmeldung (Code, Schnellstart). Enthält nur einen Prüfwert des Codes.
    var lock: LockSettings

    static let currentVersion = 1

    init(version: Int = AppData.currentVersion,
         subjects: [Subject] = [],
         lessons: [Lesson] = [],
         homework: [HomeworkEntry] = [],
         noHomeworkDays: Set<String> = [],
         noHomeworkSubjects: Set<String> = [],
         notes: [Note] = [],
         events: [CalendarEvent] = [],
         holidays: [Holiday] = [],
         profile: Profile = Profile(),
         settings: AppSettings = AppSettings(),
         lock: LockSettings = LockSettings()) {
        self.version = version
        self.subjects = subjects
        self.lessons = lessons
        self.homework = homework
        self.noHomeworkDays = noHomeworkDays
        self.noHomeworkSubjects = noHomeworkSubjects
        self.notes = notes
        self.events = events
        self.holidays = holidays
        self.profile = profile
        self.settings = settings
        self.lock = lock
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? AppData.currentVersion
        subjects = try container.decodeIfPresent([Subject].self, forKey: .subjects) ?? []
        lessons = try container.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        homework = try container.decodeIfPresent([HomeworkEntry].self, forKey: .homework) ?? []
        noHomeworkDays = try container.decodeIfPresent(Set<String>.self, forKey: .noHomeworkDays) ?? []
        noHomeworkSubjects = try container.decodeIfPresent(Set<String>.self, forKey: .noHomeworkSubjects) ?? []
        notes = try container.decodeIfPresent([Note].self, forKey: .notes) ?? []
        events = try container.decodeIfPresent([CalendarEvent].self, forKey: .events) ?? []
        holidays = try container.decodeIfPresent([Holiday].self, forKey: .holidays) ?? []
        profile = try container.decodeIfPresent(Profile.self, forKey: .profile) ?? Profile()
        settings = try container.decodeIfPresent(AppSettings.self, forKey: .settings) ?? AppSettings()
        lock = try container.decodeIfPresent(LockSettings.self, forKey: .lock) ?? LockSettings()
    }

    /// Startzustand beim allerersten Öffnen der App.
    static var initial: AppData {
        AppData(subjects: Subject.starterSubjects)
    }

    /// Entfernt Daten, die auf gelöschte Fächer zeigen, und sorgt für gültige Einstellungen.
    mutating func sanitize() {
        settings.normalizeTimes()

        let validIDs = Set(subjects.map(\.id))
        lessons = lessons.compactMap { lesson in
            var lesson = lesson
            if let id = lesson.subjectID, !validIDs.contains(id) {
                lesson.subjectID = nil
            }
            guard (1...7).contains(lesson.weekday), lesson.period >= 1 else { return nil }
            return lesson.isEmpty ? nil : lesson
        }
        homework = homework.filter { validIDs.contains($0.subjectID) && ($0.hasText || $0.isDone) }

        // Ein Tag mit eingetragenen Aufgaben kann nicht zugleich "nichts auf" sein.
        let tageMitAufgaben = Set(homework.filter(\.hasText).map(\.dayKey))
        noHomeworkDays = noHomeworkDays.filter { !tageMitAufgaben.contains($0) }

        // Dasselbe je Fach: wo etwas eingetragen ist, gilt "nichts auf" nicht.
        let belegt = Set(homework.map { "\($0.dayKey)|\($0.subjectID.uuidString)" })
        noHomeworkSubjects = noHomeworkSubjects.filter { schluessel in
            guard !belegt.contains(schluessel) else { return false }
            let teile = schluessel.split(separator: "|")
            guard teile.count == 2, let id = UUID(uuidString: String(teile[1])) else { return false }
            return validIDs.contains(id)
        }

        notes = notes.filter(\.hasText)

        // Termine ohne Tag oder ohne Inhalt sind nichts wert; Verweise auf
        // gelöschte Fächer werden gelöst statt den Termin mitzunehmen.
        events = events.compactMap { event in
            var event = event
            guard SchoolCalendar.date(fromDayKey: event.dayKey) != nil else { return nil }
            guard event.hasTitle || !event.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return nil }
            if let id = event.subjectID, !validIDs.contains(id) { event.subjectID = nil }
            if let minutes = event.startMinutes, !(0..<(24 * 60)).contains(minutes) {
                event.startMinutes = nil
            }
            return event
        }

        // Ferien ohne gültigen Zeitraum wären nur verwirrend.
        holidays = holidays.compactMap { holiday in
            var holiday = holiday
            guard let (start, end) = holiday.orderedDates else { return nil }
            // Vertauschte Angaben werden beim Laden geradegerückt.
            holiday.startDayKey = SchoolCalendar.dayKey(start)
            holiday.endDayKey = SchoolCalendar.dayKey(end)
            return holiday
        }
    }
}
