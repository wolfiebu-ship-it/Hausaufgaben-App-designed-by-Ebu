import UIKit

/// Kleine Rückmeldung beim Antippen – das kurze Klopfen, das man von
/// guten iOS-Apps kennt. Auf dem iPad passiert nichts, dort gibt es
/// keinen Vibrationsmotor; das ist in Ordnung und stört nicht.
enum Haptics {

    /// Leichtes Tippen – zum Ankreuzen und Umschalten.
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Etwas kräftiger – wenn etwas abgeschlossen wurde.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
