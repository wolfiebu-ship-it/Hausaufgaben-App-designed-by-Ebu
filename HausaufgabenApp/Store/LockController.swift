import Foundation
import SwiftUI

/// Merkt sich, ob Homy gerade zu ist, und entscheidet beim Zurückkommen,
/// ob wieder nach dem Code gefragt werden muss.
final class LockController: ObservableObject {

    /// Ist die App gerade gesperrt?
    @Published private(set) var isLocked = false
    /// Zu viele Fehlversuche: bis zu diesem Zeitpunkt geht gar nichts.
    @Published private(set) var blockedUntil: Date?
    /// Wie viele Versuche schon danebengingen.
    @Published private(set) var failedAttempts = 0

    /// Wann die App zuletzt in den Hintergrund ging.
    private var leftAt: Date?
    /// Die zuletzt bekannten Einstellungen.
    private var settings = LockSettings()
    /// Beim allerersten Erscheinen einmal sperren – danach nicht mehr.
    private var didStart = false

    /// Nach so vielen Fehlversuchen muss man kurz warten.
    private let attemptsBeforePause = 5
    private let pauseSeconds: TimeInterval = 30

    // MARK: - Ablauf

    /// Wird beim Start der App einmal aufgerufen.
    func start(with settings: LockSettings) {
        self.settings = settings
        guard !didStart else { return }
        didStart = true
        isLocked = settings.isActive
    }

    /// Wird aufgerufen, wenn sich die Einstellungen ändern.
    func update(with settings: LockSettings) {
        self.settings = settings
        // Wer die Anmeldung ausschaltet, soll nicht ausgesperrt bleiben.
        if !settings.isActive {
            isLocked = false
            resetAttempts()
        }
    }

    /// Die App verschwindet in den Hintergrund.
    func willResignActive() {
        guard settings.isActive else { return }
        leftAt = Date()
        // Bei „Jedes Mal“ sofort zumachen – dann zeigt auch das Vorschaubild
        // in der App-Übersicht schon das Anmeldebild statt der Hausaufgaben.
        if settings.timing == .always {
            isLocked = true
        }
    }

    /// Die App kommt zurück in den Vordergrund.
    func didBecomeActive() {
        guard settings.isActive, !isLocked else { return }
        // Kein Zeitlimit („Nur beim Neustart“): offen lassen.
        guard let grace = settings.timing.grace, let leftAt else { return }
        if Date().timeIntervalSince(leftAt) >= grace {
            isLocked = true
        }
    }

    // MARK: - Auf- und zumachen

    /// Von Hand zusperren (Knopf in den Einstellungen).
    func lockNow() {
        guard settings.isActive else { return }
        isLocked = true
    }

    /// Prüft den eingetippten Code und macht bei Erfolg auf.
    /// Liefert `false`, wenn der Code falsch war.
    @discardableResult
    func submit(code: String) -> Bool {
        guard !isPaused else { return false }
        if settings.matches(code) {
            unlock()
            return true
        }
        failedAttempts += 1
        if failedAttempts >= attemptsBeforePause {
            blockedUntil = Date().addingTimeInterval(pauseSeconds)
        }
        return false
    }

    func unlock() {
        isLocked = false
        resetAttempts()
        leftAt = nil
    }

    private func resetAttempts() {
        failedAttempts = 0
        blockedUntil = nil
    }

    /// Läuft gerade eine Wartezeit wegen Fehlversuchen?
    var isPaused: Bool {
        guard let blockedUntil else { return false }
        if Date() >= blockedUntil {
            return false
        }
        return true
    }

    /// Wie viele Sekunden noch zu warten sind.
    func remainingPause(at now: Date = Date()) -> Int {
        guard let blockedUntil, blockedUntil > now else { return 0 }
        return Int(blockedUntil.timeIntervalSince(now).rounded(.up))
    }

    /// Hebt eine abgelaufene Wartezeit auf.
    func clearExpiredPause() {
        guard let blockedUntil, Date() >= blockedUntil else { return }
        resetAttempts()
    }
}
