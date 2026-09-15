import Foundation
import LocalAuthentication

/// Womit sich das Gerät entsperren lässt.
enum BiometricKind {
    case faceID
    case touchID
    case opticID
    case none

    var title: String {
        switch self {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none:    return "Schnellstart"
        }
    }

    var symbol: String {
        switch self {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        case .none:    return "bolt.fill"
        }
    }

    var isAvailable: Bool { self != .none }
}

/// Der Schnellstart: mit dem Gesicht oder dem Finger öffnen, statt den Code zu tippen.
///
/// Die App bekommt dabei nie das Gesicht oder den Fingerabdruck zu sehen –
/// iOS prüft das selbst und sagt nur Ja oder Nein.
enum BiometricAuth {

    /// Was dieses Gerät kann. Ist nichts eingerichtet, kommt `.none` zurück.
    static func availableKind() -> BiometricKind {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        default:
            // Neuere Geräte (Vision Pro) melden Typen, die dieses SDK
            // noch nicht namentlich kennt – der Schnellstart geht trotzdem.
            return .opticID
        }
    }

    /// Fragt iOS nach der Entsperrung. Liefert `true`, wenn es geklappt hat.
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Code eingeben"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
}
