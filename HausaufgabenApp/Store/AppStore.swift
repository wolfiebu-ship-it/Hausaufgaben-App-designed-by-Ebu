import Foundation
import SwiftUI

/// Hält alle Daten der App und speichert sie als JSON-Datei im Dokumentenordner.
final class AppStore: ObservableObject {

    @Published private(set) var subjects: [Subject]
    @Published private(set) var lessons: [Lesson]
    @Published private(set) var homework: [HomeworkEntry]
    /// Tage, an denen ausdrücklich nichts aufgegeben wurde.
    @Published private(set) var noHomeworkDays: Set<String>
    /// Einzelne Fächer, in denen an einem Tag nichts aufgegeben wurde.
    @Published private(set) var noHomeworkSubjects: Set<String>
    /// Freie Notizen, etwa anstehende Arbeiten.
    @Published private(set) var notes: [Note]
    @Published var settings: AppSettings {
        didSet {
            guard settings != oldValue else { return }
            settings.normalizeTimes()
            scheduleSave()
        }
    }

    /// Wird hochgezählt, wenn die Daten komplett ersetzt wurden (Import, Zurücksetzen).
    /// Ansichten hängen sich mit `.id(store.dataRevision)` daran, um sich neu aufzubauen.
    @Published private(set) var dataRevision: Int = 0

    /// Letzter Fehler beim Speichern oder Laden – wird in den Einstellungen angezeigt.
    @Published var lastErrorMessage: String?

    private let fileURL: URL
    private var saveWorkItem: DispatchWorkItem?

    // MARK: - Start

    init(fileURL: URL? = nil) {
        let url = fileURL ?? AppStore.defaultFileURL()
        self.fileURL = url

        let loaded = AppStore.load(from: url) ?? AppData.initial
        var data = loaded
        data.sanitize()

        self.subjects = data.subjects
        self.lessons = data.lessons
        self.homework = data.homework
        self.noHomeworkDays = data.noHomeworkDays
        self.noHomeworkSubjects = data.noHomeworkSubjects
        self.notes = data.notes
        self.settings = data.settings

        // Beim allerersten Start die Datei gleich anlegen.
        if !FileManager.default.fileExists(atPath: url.path) {
            saveNow()
        }
    }

    static func defaultFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return directory.appendingPathComponent("hausaufgaben.json")
    }

    // MARK: - Fächer

    /// Fächer alphabetisch nach Namen.
    var sortedSubjects: [Subject] {
        subjects.sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    func subject(id: UUID?) -> Subject? {
        guard let id else { return nil }
        return subjects.first { $0.id == id }
    }

    func addSubject(_ subject: Subject) {
        subjects.append(subject)
        scheduleSave()
    }

    func updateSubject(_ subject: Subject) {
        guard let index = subjects.firstIndex(where: { $0.id == subject.id }) else { return }
        subjects[index] = subject
        scheduleSave()
    }

    /// Löscht ein Fach samt seiner Stundenplan-Einträge und Hausaufgaben.
    /// Notizen sind davon unabhängig und bleiben unverändert.
    func deleteSubject(id: UUID) {
        subjects.removeAll { $0.id == id }
        lessons.removeAll { $0.subjectID == id }
        homework.removeAll { $0.subjectID == id }
        scheduleSave()
    }

    /// Wie oft ein Fach im Stundenplan steht.
    func lessonCount(forSubject id: UUID) -> Int {
        lessons.filter { $0.subjectID == id }.count
    }

    /// Wie viele Hausaufgaben zu einem Fach gespeichert sind.
    func homeworkCount(forSubject id: UUID) -> Int {
        homework.filter { $0.subjectID == id }.count
    }

    func addStarterSubjects() {
        for subject in Subject.starterSubjects where !subjects.contains(where: {
            $0.displayName.localizedCaseInsensitiveCompare(subject.name) == .orderedSame
        }) {
            subjects.append(subject)
        }
        scheduleSave()
    }

    // MARK: - Stundenplan

    func lesson(weekday: Int, period: Int) -> Lesson? {
        lessons.first { $0.weekday == weekday && $0.period == period }
    }

    /// Legt die Stunde an, ändert sie oder löscht sie, wenn nichts mehr drinsteht.
    func setLesson(weekday: Int, period: Int, subjectID: UUID?, room: String, teacher: String) {
        let trimmedRoom = room.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTeacher = teacher.trimmingCharacters(in: .whitespacesAndNewlines)
        let index = lessons.firstIndex { $0.weekday == weekday && $0.period == period }

        if subjectID == nil && trimmedRoom.isEmpty && trimmedTeacher.isEmpty {
            if let index { lessons.remove(at: index) }
            scheduleSave()
            return
        }

        if let index {
            lessons[index].subjectID = subjectID
            lessons[index].room = trimmedRoom
            lessons[index].teacher = trimmedTeacher
        } else {
            lessons.append(Lesson(weekday: weekday,
                                  period: period,
                                  subjectID: subjectID,
                                  room: trimmedRoom,
                                  teacher: trimmedTeacher))
        }
        scheduleSave()
    }

    func clearLesson(weekday: Int, period: Int) {
        lessons.removeAll { $0.weekday == weekday && $0.period == period }
        scheduleSave()
    }

    /// Alle belegten Stunden eines Wochentags, nach Stundennummer sortiert.
    func lessons(onWeekday weekday: Int) -> [Lesson] {
        lessons
            .filter { $0.weekday == weekday && $0.subjectID != nil }
            .sorted { $0.period < $1.period }
    }

    /// Die Fächer eines Wochentags in der Reihenfolge des Stundenplans, jedes Fach nur einmal.
    func subjects(onWeekday weekday: Int) -> [Subject] {
        var seen = Set<UUID>()
        var result: [Subject] = []
        for lesson in lessons(onWeekday: weekday) {
            guard let id = lesson.subjectID, !seen.contains(id) else { continue }
            guard let subject = subject(id: id) else { continue }
            seen.insert(id)
            result.append(subject)
        }
        return result
    }

    /// Raum bzw. Lehrkraft der Stunde – mit Rückfall auf die Angaben des Fachs.
    func room(for lesson: Lesson) -> String {
        let own = lesson.room.trimmingCharacters(in: .whitespacesAndNewlines)
        if !own.isEmpty { return own }
        return subject(id: lesson.subjectID)?.room.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func teacher(for lesson: Lesson) -> String {
        let own = lesson.teacher.trimmingCharacters(in: .whitespacesAndNewlines)
        if !own.isEmpty { return own }
        return subject(id: lesson.subjectID)?.teacher.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    var hasAnyLesson: Bool { lessons.contains { $0.subjectID != nil } }

    /// Der Tag, um den es gerade geht: heute, wenn heute Unterricht ist,
    /// sonst der nächste Tag mit Stunden. Am Wochenende ist das der Montag.
    /// Gibt `nil` zurück, wenn im ganzen Plan keine Stunde steht.
    func currentSchoolDay(from reference: Date = Date()) -> Date? {
        let start = SchoolCalendar.startOfDay(reference)
        for offset in 0..<7 {
            guard let day = SchoolCalendar.calendar.date(byAdding: .day, value: offset, to: start) else { continue }
            let weekday = SchoolCalendar.weekdayIndex(of: day)
            guard settings.weekdays.contains(weekday) else { continue }
            if !lessons(onWeekday: weekday).isEmpty { return day }
        }
        return nil
    }

    /// Ersetzt den gesamten Stundenplan – wird nach einem geprüften Scan aufgerufen.
    /// Fächer und Hausaufgaben bleiben unangetastet.
    func replaceTimetable(with newLessons: [Lesson]) {
        let validIDs = Set(subjects.map(\.id))
        lessons = newLessons.filter { lesson in
            guard (1...7).contains(lesson.weekday), lesson.period >= 1 else { return false }
            guard let id = lesson.subjectID else { return false }
            return validIDs.contains(id)
        }
        // Der Plan darf nicht mehr Stunden haben, als angezeigt werden.
        if let höchste = lessons.map(\.period).max(), höchste > settings.periodCount {
            settings.periodCount = min(14, höchste)
        }
        if lessons.contains(where: { $0.weekday == 6 }) {
            settings.includeSaturday = true
        }
        dataRevision += 1
        saveNow()
    }

    /// Legt für erkannte, aber unbekannte Kürzel neue Fächer an und gibt zurück,
    /// welches Kürzel zu welchem Fach wurde.
    @discardableResult
    func createSubjects(forCodes codes: [String]) -> [String: UUID] {
        var mapping: [String: UUID] = [:]
        for code in codes {
            let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { continue }

            if let existing = subjects.first(where: {
                $0.short.localizedCaseInsensitiveCompare(cleaned) == .orderedSame
            }) {
                mapping[cleaned] = existing.id
                continue
            }

            let subject = Subject(name: cleaned,
                                  short: String(cleaned.prefix(4)),
                                  colorIndex: AppTheme.suggestedColorIndex(usedBy: subjects))
            subjects.append(subject)
            mapping[cleaned] = subject.id
        }
        scheduleSave()
        return mapping
    }

    // MARK: - Hausaufgaben

    func homeworkEntry(day: Date, subjectID: UUID) -> HomeworkEntry? {
        let key = SchoolCalendar.dayKey(day)
        return homework.first { $0.dayKey == key && $0.subjectID == subjectID }
    }

    /// Alle Hausaufgaben eines Tages, sortiert nach der Reihenfolge im Stundenplan.
    func homeworkEntries(on day: Date) -> [HomeworkEntry] {
        let key = SchoolCalendar.dayKey(day)
        let weekday = SchoolCalendar.weekdayIndex(of: day)
        let order = subjects(onWeekday: weekday).map(\.id)
        return homework
            .filter { $0.dayKey == key }
            .sorted { a, b in
                let indexA = order.firstIndex(of: a.subjectID) ?? Int.max
                let indexB = order.firstIndex(of: b.subjectID) ?? Int.max
                if indexA != indexB { return indexA < indexB }
                return a.createdAt < b.createdAt
            }
    }

    /// Fächer, die an diesem Tag im Hausaufgabenblatt auftauchen sollen:
    /// alle Fächer des Stundenplans plus Fächer, zu denen an dem Tag schon etwas eingetragen wurde.
    func homeworkSubjects(on day: Date) -> [Subject] {
        let weekday = SchoolCalendar.weekdayIndex(of: day)
        var result = subjects(onWeekday: weekday)
        var seen = Set(result.map(\.id))

        for entry in homeworkEntries(on: day) where !seen.contains(entry.subjectID) {
            if let subject = subject(id: entry.subjectID) {
                seen.insert(subject.id)
                result.append(subject)
            }
        }
        return result
    }

    /// Schreibt den Text einer Hausaufgabe. Leerer Text löscht den Eintrag.
    /// Ändert nichts, wenn der Text schon so gespeichert ist – dadurch sind
    /// wiederholte Aufrufe aus der Oberfläche unschädlich.
    func setHomeworkText(_ text: String, day: Date, subjectID: UUID) {
        // Eine Ansicht kann noch nachträglich speichern wollen, nachdem das Fach
        // gelöscht wurde – dann darf kein neuer Eintrag entstehen.
        guard subjects.contains(where: { $0.id == subjectID }) else { return }

        let key = SchoolCalendar.dayKey(day)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let index = homework.firstIndex { $0.dayKey == key && $0.subjectID == subjectID }

        if trimmed.isEmpty {
            guard let index else { return }
            // Ein abgehakter Eintrag ohne Text bleibt bestehen: „erledigt,
            // aber nicht aufgeschrieben“ ist eine gültige Angabe.
            if homework[index].isDone {
                guard homework[index].text != text else { return }
                homework[index].text = text
                homework[index].updatedAt = Date()
            } else {
                homework.remove(at: index)
            }
            scheduleSave()
            return
        }

        if let index {
            guard homework[index].text != text else { return }
            homework[index].text = text
            homework[index].updatedAt = Date()
        } else {
            homework.append(HomeworkEntry(dayKey: key, subjectID: subjectID, text: text))
        }
        // Sobald etwas eingetragen ist, stimmt „nichts auf“ nicht mehr.
        noHomeworkDays.remove(key)
        noHomeworkSubjects.remove(subjectKey(day: day, subjectID: subjectID))
        scheduleSave()
    }

    /// Hakt ein Fach ab. Das geht auch, wenn nichts eingetragen ist –
    /// dann entsteht ein Eintrag ohne Text, der für „erledigt“ steht.
    func setHomeworkDone(_ isDone: Bool, day: Date, subjectID: UUID) {
        guard subjects.contains(where: { $0.id == subjectID }) else { return }
        let key = SchoolCalendar.dayKey(day)

        if let index = homework.firstIndex(where: { $0.dayKey == key && $0.subjectID == subjectID }) {
            guard homework[index].isDone != isDone else { return }
            homework[index].isDone = isDone
            homework[index].updatedAt = Date()
            // Ohne Text und ohne Haken bleibt nichts übrig.
            if !isDone && !homework[index].hasText {
                homework.remove(at: index)
            }
        } else {
            guard isDone else { return }
            homework.append(HomeworkEntry(dayKey: key, subjectID: subjectID, text: "", isDone: true))
        }

        // „Erledigt“ und „keine Hausaufgaben“ schließen sich aus.
        if isDone {
            noHomeworkDays.remove(key)
            noHomeworkSubjects.remove(subjectKey(day: day, subjectID: subjectID))
        }
        scheduleSave()
    }

    func deleteHomework(day: Date, subjectID: UUID) {
        let key = SchoolCalendar.dayKey(day)
        homework.removeAll { $0.dayKey == key && $0.subjectID == subjectID }
        scheduleSave()
    }

    // MARK: - Tage ohne Hausaufgaben

    /// Ist der Tag ausdrücklich als „nichts auf“ vermerkt?
    func isMarkedNoHomework(day: Date) -> Bool {
        noHomeworkDays.contains(SchoolCalendar.dayKey(day))
    }

    func setNoHomework(_ value: Bool, day: Date) {
        let key = SchoolCalendar.dayKey(day)
        if value {
            // Der Vermerk gilt nur, solange nichts eingetragen ist.
            guard !homework.contains(where: { $0.dayKey == key && $0.hasText }) else { return }
            guard !noHomeworkDays.contains(key) else { return }
            noHomeworkDays.insert(key)
        } else {
            guard noHomeworkDays.contains(key) else { return }
            noHomeworkDays.remove(key)
        }
        scheduleSave()
    }

    // MARK: - "Nichts auf" je Fach

    private func subjectKey(day: Date, subjectID: UUID) -> String {
        "\(SchoolCalendar.dayKey(day))|\(subjectID.uuidString)"
    }

    /// Ist für dieses Fach an diesem Tag „nichts auf“ vermerkt?
    func isNoHomework(day: Date, subjectID: UUID) -> Bool {
        noHomeworkSubjects.contains(subjectKey(day: day, subjectID: subjectID))
    }

    /// Vermerkt „keine Hausaufgaben“ für ein Fach. Das geht immer –
    /// ein bereits eingetragener Text wird dabei verworfen, denn beides
    /// zugleich kann nicht stimmen.
    func setNoHomework(_ value: Bool, day: Date, subjectID: UUID) {
        guard subjects.contains(where: { $0.id == subjectID }) else { return }
        let key = subjectKey(day: day, subjectID: subjectID)
        let dayKey = SchoolCalendar.dayKey(day)

        if value {
            homework.removeAll { $0.dayKey == dayKey && $0.subjectID == subjectID }
            guard !noHomeworkSubjects.contains(key) else { return }
            noHomeworkSubjects.insert(key)
        } else {
            guard noHomeworkSubjects.contains(key) else { return }
            noHomeworkSubjects.remove(key)
        }
        scheduleSave()
    }

    /// Sind an dem Tag alle Fächer geklärt – also überall entweder etwas
    /// eingetragen oder „nichts auf“ vermerkt?
    func allSubjectsSettled(on day: Date) -> Bool {
        let faecher = homeworkSubjects(on: day)
        guard !faecher.isEmpty else { return false }
        return faecher.allSatisfy { fach in
            homeworkEntry(day: day, subjectID: fach.id)?.hasText == true
                || isNoHomework(day: day, subjectID: fach.id)
            }
    }

    /// Anzahl offener Hausaufgaben in einer Woche – für die Anzeige im Wochenkopf.
    func openHomeworkCount(weekStart: Date, dayCount: Int) -> Int {
        var count = 0
        for offset in 0..<max(0, dayCount) {
            let day = SchoolCalendar.date(inWeekOf: weekStart, weekday: offset + 1)
            count += homeworkEntries(on: day).filter { !$0.isDone && $0.hasText }.count
        }
        return count
    }

    // MARK: - Notizen

    func note(id: UUID?) -> Note? {
        guard let id else { return nil }
        return notes.first { $0.id == id }
    }

    /// Zuletzt geschriebene zuerst – wie in Apples Notizen.
    var sortedNotes: [Note] {
        notes.sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Legt eine leere Notiz an und gibt ihre Kennung zurück,
    /// damit sie sofort zum Schreiben geöffnet werden kann.
    func createNote() -> UUID {
        let note = Note()
        notes.append(note)
        scheduleSave()
        return note.id
    }

    /// Schreibt den Text während des Tippens.
    func setNoteText(_ text: String, id: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == id }),
              notes[index].text != text else { return }
        notes[index].text = text
        notes[index].updatedAt = Date()
        scheduleSave()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        scheduleSave()
    }

    /// Entfernt eine Notiz, in der nichts steht – etwa wenn man sie
    /// anlegt und ohne zu schreiben wieder zurückgeht.
    func discardIfEmpty(id: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == id }),
              !notes[index].hasText else { return }
        notes.remove(at: index)
        scheduleSave()
    }

    // MARK: - Daten ersetzen

    func replaceAll(with data: AppData) {
        var data = data
        data.sanitize()
        subjects = data.subjects
        lessons = data.lessons
        homework = data.homework
        noHomeworkDays = data.noHomeworkDays
        noHomeworkSubjects = data.noHomeworkSubjects
        notes = data.notes
        settings = data.settings
        dataRevision += 1
        saveNow()
    }

    func resetToFactoryDefaults() {
        replaceAll(with: AppData.initial)
    }

    func deleteAllHomework() {
        homework.removeAll()
        noHomeworkDays.removeAll()
        noHomeworkSubjects.removeAll()
        dataRevision += 1
        saveNow()
    }

    var currentData: AppData {
        AppData(subjects: subjects,
                lessons: lessons,
                homework: homework,
                noHomeworkDays: noHomeworkDays,
                noHomeworkSubjects: noHomeworkSubjects,
                notes: notes,
                settings: settings)
    }

    // MARK: - Speichern und Laden

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// JSON für Sicherungsdateien.
    func exportData() throws -> Data {
        try AppStore.makeEncoder().encode(currentData)
    }

    /// Liest eine Sicherungsdatei ein.
    static func decode(_ data: Data) throws -> AppData {
        try makeDecoder().decode(AppData.self, from: data)
    }

    private static func load(from url: URL) -> AppData? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try makeDecoder().decode(AppData.self, from: data)
        } catch {
            // Beschädigte Datei zur Seite legen, statt sie stillschweigend zu überschreiben.
            let backupURL = url.deletingPathExtension()
                .appendingPathExtension("beschaedigt-\(Int(Date().timeIntervalSince1970)).json")
            try? FileManager.default.moveItem(at: url, to: backupURL)
            return nil
        }
    }

    /// Sammelt Änderungen kurz, damit beim Tippen nicht bei jedem Zeichen geschrieben wird.
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.saveNow()
        }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
    }

    /// Schreibt sofort auf die Platte – beim Verlassen der App und nach großen Änderungen.
    func saveNow() {
        saveWorkItem?.cancel()
        saveWorkItem = nil
        do {
            let data = try AppStore.makeEncoder().encode(currentData)
            try data.write(to: fileURL, options: [.atomic])
            if lastErrorMessage != nil { lastErrorMessage = nil }
        } catch {
            lastErrorMessage = "Die Daten konnten nicht gespeichert werden: \(error.localizedDescription)"
        }
    }
}
