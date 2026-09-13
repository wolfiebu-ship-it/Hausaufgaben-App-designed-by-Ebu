import Foundation

/// Alles, was die App speichert – als eine Datei auf dem Gerät und als Sicherungsdatei.
struct AppData: Codable {
    var version: Int
    var subjects: [Subject]
    var lessons: [Lesson]
    var homework: [HomeworkEntry]
    var settings: AppSettings

    static let currentVersion = 1

    init(version: Int = AppData.currentVersion,
         subjects: [Subject] = [],
         lessons: [Lesson] = [],
         homework: [HomeworkEntry] = [],
         settings: AppSettings = AppSettings()) {
        self.version = version
        self.subjects = subjects
        self.lessons = lessons
        self.homework = homework
        self.settings = settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? AppData.currentVersion
        subjects = try container.decodeIfPresent([Subject].self, forKey: .subjects) ?? []
        lessons = try container.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        homework = try container.decodeIfPresent([HomeworkEntry].self, forKey: .homework) ?? []
        settings = try container.decodeIfPresent(AppSettings.self, forKey: .settings) ?? AppSettings()
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
        homework = homework.filter { validIDs.contains($0.subjectID) && $0.hasText }
    }
}
