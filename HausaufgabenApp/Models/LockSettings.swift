import Foundation
import CryptoKit

/// Wann Homy nach dem Code fragt.
enum LockTiming: String, Codable, Hashable, CaseIterable, Identifiable {
    /// Jedes Mal, wenn die App in den Vordergrund kommt.
    case always
    /// Erst, wenn die App fünf Minuten weg war.
    case afterFiveMinutes
    /// Erst, wenn die App eine Stunde weg war.
    case afterOneHour
    /// Nur beim Neustart der App – der Schnellstart für einen selbst.
    case onlyOnLaunch

    var id: String { rawValue }

    var title: String {
        switch self {
        case .always:           return "Jedes Mal"
        case .afterFiveMinutes: return "Nach 5 Minuten"
        case .afterOneHour:     return "Nach 1 Stunde"
        case .onlyOnLaunch:     return "Nur beim Neustart"
        }
    }

    var explanation: String {
        switch self {
        case .always:
            return "Sobald du Homy verlässt, ist die App wieder zu."
        case .afterFiveMinutes:
            return "Kurz auf WhatsApp und zurück? Dann fragt Homy nicht nach."
        case .afterOneHour:
            return "Innerhalb einer Stunde bleibt Homy offen."
        case .onlyOnLaunch:
            return "Homy bleibt offen, bis du die App ganz schließt."
        }
    }

    /// Wie lange die App weg sein darf, ohne dass der Code nötig wird.
    /// `nil` heißt: während der Laufzeit nie wieder nachfragen.
    var grace: TimeInterval? {
        switch self {
        case .always:           return 0
        case .afterFiveMinutes: return 5 * 60
        case .afterOneHour:     return 60 * 60
        case .onlyOnLaunch:     return nil
        }
    }
}

/// Die Anmeldung: ein Zahlencode, dazu wahlweise Face ID oder Touch ID.
///
/// Gespeichert wird nur ein Prüfwert des Codes (SHA-256 mit Zufallsbeigabe),
/// nicht der Code selbst.
struct LockSettings: Codable, Hashable {
    /// Ist die Anmeldung eingeschaltet?
    var isEnabled: Bool
    /// Zufallsbeigabe, damit gleiche Codes nicht gleich aussehen.
    var salt: String
    /// Prüfwert des Codes.
    var codeHash: String
    /// Wie viele Ziffern der Code hat (für die Punkte auf dem Anmeldebild).
    var codeLength: Int
    /// Schnellstart mit Face ID oder Touch ID.
    var useBiometrics: Bool
    /// Wann nachgefragt wird.
    var timing: LockTiming
    /// Freiwilliger Merkzettel, falls man den Code vergisst.
    var hint: String

    init(isEnabled: Bool = false,
         salt: String = "",
         codeHash: String = "",
         codeLength: Int = 4,
         useBiometrics: Bool = true,
         timing: LockTiming = .always,
         hint: String = "") {
        self.isEnabled = isEnabled
        self.salt = salt
        self.codeHash = codeHash
        self.codeLength = codeLength
        self.useBiometrics = useBiometrics
        self.timing = timing
        self.hint = hint
    }

    /// Ist überhaupt ein Code hinterlegt?
    var hasCode: Bool { !codeHash.isEmpty && !salt.isEmpty }

    /// Fragt die App beim Start nach dem Code?
    var isActive: Bool { isEnabled && hasCode }

    var trimmedHint: String {
        hint.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Gültige Codelängen.
    static let allowedLengths = 4...8

    static func isValidCode(_ code: String) -> Bool {
        allowedLengths.contains(code.count) && code.allSatisfy(\.isNumber)
    }

    // MARK: - Code setzen und prüfen

    /// Legt einen neuen Code fest. Gespeichert wird nur der Prüfwert.
    mutating func setCode(_ code: String) {
        let newSalt = LockSettings.makeSalt()
        salt = newSalt
        codeHash = LockSettings.hash(code: code, salt: newSalt)
        codeLength = code.count
    }

    /// Stimmt der eingegebene Code?
    func matches(_ code: String) -> Bool {
        guard hasCode else { return false }
        return LockSettings.hash(code: code, salt: salt) == codeHash
    }

    /// Entfernt den Code vollständig.
    mutating func clearCode() {
        isEnabled = false
        salt = ""
        codeHash = ""
        codeLength = 4
        hint = ""
    }

    static func makeSalt() -> String {
        // Der Zufallsgenerator von Swift ist auf Apple-Geräten der des Systems.
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<16).map { _ in UInt8.random(in: 0...255, using: &generator) }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    static func hash(code: String, salt: String) -> String {
        let input = Data((salt + ":" + code).utf8)
        return SHA256.hash(data: input).map { String(format: "%02x", $0) }.joined()
    }

    // Ältere Sicherungen kennen diesen Abschnitt noch nicht.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        salt = try container.decodeIfPresent(String.self, forKey: .salt) ?? ""
        codeHash = try container.decodeIfPresent(String.self, forKey: .codeHash) ?? ""
        codeLength = try container.decodeIfPresent(Int.self, forKey: .codeLength) ?? 4
        useBiometrics = try container.decodeIfPresent(Bool.self, forKey: .useBiometrics) ?? true
        timing = try container.decodeIfPresent(LockTiming.self, forKey: .timing) ?? .always
        hint = try container.decodeIfPresent(String.self, forKey: .hint) ?? ""
    }
}
