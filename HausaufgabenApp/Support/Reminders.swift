import Foundation
import UserNotifications

/// Die Erinnerungen zu Kalenderterminen.
///
/// Alles läuft über iOS: Homy übergibt Text und Zeitpunkt, den Rest macht
/// das System. Es geht nichts ins Internet, und die App muss dafür nicht
/// laufen – die Benachrichtigung kommt auch, wenn Homy geschlossen ist.
enum Reminders {

    /// Damit lassen sich die eigenen Benachrichtigungen wiederfinden.
    private static let prefix = "homy-termin-"

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
    static func reschedule(events: [CalendarEvent],
                           subjectName: (UUID?) -> String?,
                           enabled: Bool) async {
        center.removeAllPendingNotificationRequests()

        guard enabled else { return }
        guard await requestAuthorizationIfAlreadyDecided() else { return }

        let anstehend = events
            .filter { $0.hasFutureReminder() }
            .sorted { ($0.reminderDate ?? .distantFuture) < ($1.reminderDate ?? .distantFuture) }
            .prefix(maximumScheduled)

        for event in anstehend {
            await add(event, subject: subjectName(event.subjectID))
        }
    }

    /// Wie `requestAuthorization`, fragt aber nicht von sich aus nach –
    /// das soll nur passieren, wenn der Mensch gerade eine Erinnerung einstellt.
    private static func requestAuthorizationIfAlreadyDecided() async -> Bool {
        switch await authorizationStatus() {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    private static func add(_ event: CalendarEvent, subject: String?) async {
        guard let fireDate = event.reminderDate, fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = event.displayTitle
        content.subtitle = subtitle(for: event, subject: subject)
        content.body = body(for: event, fireDate: fireDate)
        content.sound = .default

        let parts = SchoolCalendar.calendar.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)

        let request = UNNotificationRequest(identifier: prefix + event.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        try? await center.add(request)
    }

    // MARK: - Texte

    private static func subtitle(for event: CalendarEvent, subject: String?) -> String {
        var parts: [String] = []
        // Steht als Titel schon die Art da, wäre sie hier doppelt.
        if event.hasTitle { parts.append(event.kind.title) }
        if let subject, !subject.isEmpty { parts.append(subject) }
        return parts.joined(separator: " · ")
    }

    /// „Morgen um 8:00 Uhr“, „Heute, ganztägig“, „In 7 Tagen (Mi, 24.9.)“
    private static func body(for event: CalendarEvent, fireDate: Date) -> String {
        guard let day = event.date else { return "" }

        let calendar = SchoolCalendar.calendar
        let tageDazwischen = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: fireDate),
            to: SchoolCalendar.startOfDay(day)).day ?? 0

        let wann: String
        switch tageDazwischen {
        case ..<0:  wann = "War am \(SchoolCalendar.shortDate(day))"
        case 0:     wann = "Heute"
        case 1:     wann = "Morgen"
        case 2:     wann = "Übermorgen"
        default:
            let tag = SchoolCalendar.weekdayShortName(SchoolCalendar.weekdayIndex(of: day))
            wann = "In \(tageDazwischen) Tagen (\(tag), \(SchoolCalendar.shortDate(day)))"
        }

        if let zeit = event.timeText {
            return "\(wann) um \(zeit)"
        }
        return wann
    }
}
