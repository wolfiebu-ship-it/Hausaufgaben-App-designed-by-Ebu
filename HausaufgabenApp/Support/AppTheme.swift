import SwiftUI
import UIKit

/// Farben der App. Alle Fachfarben sind dunkel genug, damit weiße Schrift
/// darauf im hellen wie im dunklen Modus gut lesbar bleibt.
enum AppTheme {

    static let subjectColors: [Color] = [
        Color(red: 0.851, green: 0.188, blue: 0.145), // 0  Rot
        Color(red: 0.761, green: 0.255, blue: 0.047), // 1  Orange
        Color(red: 0.631, green: 0.384, blue: 0.027), // 2  Gold
        Color(red: 0.082, green: 0.502, blue: 0.239), // 3  Grün
        Color(red: 0.059, green: 0.463, blue: 0.431), // 4  Petrol
        Color(red: 0.055, green: 0.455, blue: 0.565), // 5  Türkis
        Color(red: 0.114, green: 0.306, blue: 0.847), // 6  Blau
        Color(red: 0.263, green: 0.220, blue: 0.792), // 7  Indigo
        Color(red: 0.427, green: 0.157, blue: 0.851), // 8  Violett
        Color(red: 0.745, green: 0.094, blue: 0.365), // 9  Pink
        Color(red: 0.471, green: 0.208, blue: 0.059), // 10 Braun
        Color(red: 0.278, green: 0.333, blue: 0.412)  // 11 Grau
    ]

    static let subjectColorNames = [
        "Rot", "Orange", "Gold", "Grün", "Petrol", "Türkis",
        "Blau", "Indigo", "Violett", "Pink", "Braun", "Grau"
    ]

    static func color(at index: Int) -> Color {
        guard !subjectColors.isEmpty else { return .gray }
        let count = subjectColors.count
        return subjectColors[((index % count) + count) % count]
    }

    static func colorName(at index: Int) -> String {
        guard !subjectColorNames.isEmpty else { return "" }
        let count = subjectColorNames.count
        return subjectColorNames[((index % count) + count) % count]
    }

    /// Farbindex, der unter den vorhandenen Fächern am seltensten benutzt wird.
    static func suggestedColorIndex(usedBy subjects: [Subject]) -> Int {
        var counts = Array(repeating: 0, count: subjectColors.count)
        for subject in subjects {
            let count = subjectColors.count
            let index = ((subject.colorIndex % count) + count) % count
            counts[index] += 1
        }
        let minimum = counts.min() ?? 0
        return counts.firstIndex(of: minimum) ?? 0
    }

    // Maße, die an mehreren Stellen gebraucht werden.
    static let cornerRadius: CGFloat = 12
    static let badgeCornerRadius: CGFloat = 8
    static let timetableCellHeight: CGFloat = 58
    static let timetableTimeColumnWidth: CGFloat = 52
    static let timetableMinColumnWidth: CGFloat = 64
}

/// Schließt die Tastatur.
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
}
