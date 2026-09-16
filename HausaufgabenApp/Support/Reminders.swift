import Foundation
import UserNotifications

/// Eine fertig gerechnete Erinnerung – aus einem Termin oder aus Ferien.
struct ReminderItem {
    /// Kennung des Termins bzw. der Ferien.
    let id: UUID
    let title: String
    /// Zweite Zeile, z. B. „Arbeit · Mathematik“.
    let subtitle: String
    /// Der Tag, um den es geht.
    let targetDay: Date
    /// Uhrzeit des Termins, falls es eine gibt („08:00 Uhr“).
    let timeText: String?
    /// Wann die Benachrichtigung kommen soll.
    let fireDate: Date
}

/// Die Erinnerungen zu Terminen und Ferien.
///
/// Alles läuft über iOS: Homy übergibt Text und Zeitpunkt, den Rest macht
/// das System. Es geht nichts ins Internet, und die App muss dafür nicht
/// laufen – die Benachrichtigung kommt auch, wenn Homy geschlossen ist.
enum Reminders {

    /// Damit lassen sich die eigenen Benachrichtigungen wiederfinden.
    private static let prefix = "homy-erinnerung-"

    private static var center: UNUserNotificationCenter { .current() }

    /// iOS erlaubt höchstens 64 wartende Benachrichtigungen je App.
    /// Wir stellen die nächsten und lassen weit entfernte weg – die kommen
    /// beim nächsten Öffnen an die Reihe.
    private static let maximumScheduled = 56

    // MARK: - Erlaubnis

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    /// Fragt nach der Erlaubnis, falls noch nie gefragt wurde.
    /// Liefert `true`, wenn Homy Benachrichtigungen schicken darf.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        let status = await authorizationStatus()
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            // iOS fragt kein zweites Mal – das geht nur in den Einstellungen.
            return false
        default:
            let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted ?? false
        }
    }

    // MARK: - Stellen und löschen

    /// Setzt alle Erinnerungen neu: erst die alten weg, dann die anstehenden stellen.
    ///
    /// So bleibt das, was iOS vorgemerkt hat, immer gleich dem, was in der App steht –
    /// auch nach Ändern, Löschen oder dem Einspielen einer Sicherung.
    static func reschedule(items: [ReminderItem], enabled: Bool) async {
        center.removeAllPendingNotificationRequests()

        guard enabled else { return }
        guard await hasPermission() else { return }

        let jetzt = Date()
        let anstehend = items
            .filter { $0.fireDate > jetzt }
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(maximumScheduled)

        for item in anstehend {
            await add(item)
        }
    }

    /// Wie `requestAuthorization`, fragt aber nicht von sich aus nach –
    /// das soll nur passieren, wenn jemand gerade eine Erinnerung einstellt.
    private static func hasPermission() async -> Bool {
        switch await authorizationStatus() {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    private static func add(_ item: ReminderItem) async {
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.subtitle = item.subtitle
        content.body = body(for: item)
        content.sound = .default

        let parts = SchoolCalendar.calendar.dateComponents(
            [.year, .month, .day, .hour, .minute], from: item.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)

        let request = UNNotificationRequest(identifier: prefix + item.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        try? await center.add(request)
    }

    // MARK: - Texte

    /// „Morgen um 8:00 Uhr“, „Heute“, „In 7 Tagen (Mi, 24.9.)“
    private static func body(for item: ReminderItem) -> String {
        let calendar = SchoolCalendar.calendar
        let tageDazwischen = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: item.fireDate),
            to: SchoolCalendar.startOfDay(item.targetDay)).day ?? 0

        let wann: String
        switch tageDazwischen {
        case ..<0:  wann = "War am \(SchoolCalendar.shortDate(item.targetDay))"
        case 0:     wann = "Heute"
        case 1:     wann = "Morgen"
        case 2:     wann = "Übermorgen"
        default:
            let tag = SchoolCalendar.weekdayShortName(SchoolCalendar.weekdayIndex(of: item.targetDay))
            wann = "In \(tageDazwischen) Tagen (\(tag), \(SchoolCalendar.shortDate(item.targetDay)))"
        }

        if let zeit = item.timeText {
            return "\(wann) um \(zeit)"
        }
        return wann
    }
}

// MARK: - Aus Terminen und Ferien werden Erinnerungen

extension CalendarEvent {
    /// Die Erinnerung zu diesem Termin – `nil`, wenn keine eingestellt ist.
    func reminderItem(subjectName: String?) -> ReminderItem? {
        guard let fireDate = reminderDate, let day = date else { return nil }

        var parts: [String] = []
        // Steht als Titel schon die Art da, wäre sie hier doppelt.
        if hasTitle { parts.append(kind.title) }
        if let subjectName, !subjectName.isEmpty { parts.append(subjectName) }

        return ReminderItem(id: id,
                            title: displayTitle,
                            subtitle: parts.joined(separator: " · "),
                            targetDay: day,
                            timeText: timeText,
                            fireDate: fireDate)
    }
}

extension Holiday {
    /// Die Erinnerung an den ersten Ferientag.
    var reminderItem: ReminderItem? {
        guard let fireDate = reminderDate, let (start, end) = orderedDates else { return nil }

        let dauer = dayCount == 1 ? "1 Tag" : "\(dayCount) Tage"
        let untertitel = "Ferien · \(dauer) bis \(SchoolCalendar.shortDate(end))"

        return ReminderItem(id: id,
                            title: displayName,
                            subtitle: untertitel,
                            targetDay: start,
                            timeText: nil,
                            fireDate: fireDate)
    }
}
