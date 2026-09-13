import SwiftUI
import UIKit

/// Farben der App.
///
/// Jedes Fach hat zwei Farben: eine helle, freundliche Fläche (`fill`) und
/// einen kräftigen Ton für Schrift und Akzente (`tint`). Beide gibt es in
/// einer hellen und einer dunklen Fassung, damit die App im Hell- wie im
/// Dunkelmodus gut lesbar bleibt.
enum AppTheme {

    struct SubjectColor {
        let name: String
        let tintLight: UInt32
        let fillLight: UInt32
        let tintDark: UInt32
        let fillDark: UInt32

        /// Kräftiger Ton – für Kürzel, Schrift und Streifen.
        var tint: Color { Color(lightHex: tintLight, darkHex: tintDark) }
        /// Helle Fläche – Hintergrund von Kürzeln und Stundenplanfeldern.
        var fill: Color { Color(lightHex: fillLight, darkHex: fillDark) }
    }

    static let subjectColors: [SubjectColor] = [
        SubjectColor(name: "Koralle",  tintLight: 0xC0392B, fillLight: 0xFDE7E3, tintDark: 0xFF9E90, fillDark: 0x42201C),
        SubjectColor(name: "Orange",   tintLight: 0xB15A0E, fillLight: 0xFDEDDA, tintDark: 0xFFBB72, fillDark: 0x3E2A13),
        SubjectColor(name: "Honig",    tintLight: 0x8A6304, fillLight: 0xFBF2D4, tintDark: 0xF5CE5E, fillDark: 0x3A3012),
        SubjectColor(name: "Grün",     tintLight: 0x217A4B, fillLight: 0xE2F5E8, tintDark: 0x74DFA2, fillDark: 0x15301F),
        SubjectColor(name: "Petrol",   tintLight: 0x0E7B72, fillLight: 0xDDF3F0, tintDark: 0x5DDCCB, fillDark: 0x0F2F2B),
        SubjectColor(name: "Himmel",   tintLight: 0x0A6FA8, fillLight: 0xDFF0FB, tintDark: 0x79C8F0, fillDark: 0x112C3D),
        SubjectColor(name: "Blau",     tintLight: 0x2A56C6, fillLight: 0xE6ECFD, tintDark: 0x9AB6FF, fillDark: 0x1A2450),
        SubjectColor(name: "Lavendel", tintLight: 0x5647C4, fillLight: 0xEBE9FC, tintDark: 0xB3A8FF, fillDark: 0x241F4C),
        SubjectColor(name: "Flieder",  tintLight: 0x7A3AC9, fillLight: 0xF1E8FC, tintDark: 0xC8A2FB, fillDark: 0x2C1B47),
        SubjectColor(name: "Pink",     tintLight: 0xB62A63, fillLight: 0xFCE6EF, tintDark: 0xFCA0C4, fillDark: 0x3F1A2B),
        SubjectColor(name: "Karamell", tintLight: 0x8A5A2B, fillLight: 0xF6EDE1, tintDark: 0xDFB183, fillDark: 0x34261A),
        SubjectColor(name: "Schiefer", tintLight: 0x4A5A70, fillLight: 0xEAEEF4, tintDark: 0xADBCD0, fillDark: 0x232B36)
    ]

    static func subjectColor(at index: Int) -> SubjectColor {
        let count = subjectColors.count
        guard count > 0 else {
            return SubjectColor(name: "", tintLight: 0x4A5A70, fillLight: 0xEAEEF4,
                                tintDark: 0xADBCD0, fillDark: 0x232B36)
        }
        return subjectColors[((index % count) + count) % count]
    }

    static func tint(at index: Int) -> Color { subjectColor(at: index).tint }
    static func fill(at index: Int) -> Color { subjectColor(at: index).fill }
    static func colorName(at index: Int) -> String { subjectColor(at: index).name }

    /// Farbindex, der unter den vorhandenen Fächern am seltensten benutzt wird.
    static func suggestedColorIndex(usedBy subjects: [Subject]) -> Int {
        let count = subjectColors.count
        guard count > 0 else { return 0 }
        var counts = Array(repeating: 0, count: count)
        for subject in subjects {
            counts[((subject.colorIndex % count) + count) % count] += 1
        }
        let minimum = counts.min() ?? 0
        return counts.firstIndex(of: minimum) ?? 0
    }

    // Maße, die an mehreren Stellen gebraucht werden.
    static let cornerRadius: CGFloat = 14
    static let badgeCornerRadius: CGFloat = 9
    static let timetableCellHeight: CGFloat = 60
    static let timetableTimeColumnWidth: CGFloat = 52
    static let timetableMinColumnWidth: CGFloat = 64
}

extension AppearanceMode {
    /// `nil` bedeutet: so, wie das Gerät eingestellt ist.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

extension Color {
    /// Eine Farbe, die sich dem Hell- bzw. Dunkelmodus anpasst.
    init(lightHex: UInt32, darkHex: UInt32) {
        self = Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: darkHex) : UIColor(hex: lightHex)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

/// Schließt die Tastatur.
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
}
