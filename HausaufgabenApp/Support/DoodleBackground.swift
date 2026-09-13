import SwiftUI

/// Stifte, Pinsel und andere Schulsachen, ganz blass hinter dem Inhalt –
/// damit die Seiten zum Schreiben einladen statt leer zu wirken.
///
/// Die Anordnung ist fest eingetragen und nicht zufällig: So sieht sie bei
/// jedem Öffnen gleich aus und springt beim Scrollen nicht herum.
struct DoodleBackground: View {

    struct Doodle: Identifiable {
        let id: Int
        let symbol: String
        /// Anteil der Breite bzw. Höhe (0 … 1).
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let rotation: Double
        let colorIndex: Int
    }

    static let doodles: [Doodle] = [
        Doodle(id:  0, symbol: "pencil",                x: 0.08, y: 0.05, size: 46, rotation: -18, colorIndex: 6),
        Doodle(id:  1, symbol: "function",              x: 0.88, y: 0.10, size: 38, rotation:  12, colorIndex: 7),
        Doodle(id:  2, symbol: "paintbrush.pointed",    x: 0.72, y: 0.21, size: 40, rotation:  24, colorIndex: 9),
        Doodle(id:  3, symbol: "book.closed",           x: 0.16, y: 0.27, size: 42, rotation:  10, colorIndex: 0),
        Doodle(id:  4, symbol: "ruler",                 x: 0.93, y: 0.36, size: 44, rotation: -32, colorIndex: 4),
        Doodle(id:  5, symbol: "globe.europe.africa",   x: 0.06, y: 0.45, size: 40, rotation:   6, colorIndex: 3),
        Doodle(id:  6, symbol: "music.note",            x: 0.79, y: 0.52, size: 34, rotation: -12, colorIndex: 2),
        Doodle(id:  7, symbol: "flask",                 x: 0.24, y: 0.59, size: 38, rotation:  16, colorIndex: 5),
        Doodle(id:  8, symbol: "paintpalette",          x: 0.90, y: 0.67, size: 40, rotation:  -8, colorIndex: 1),
        Doodle(id:  9, symbol: "textformat.abc",        x: 0.11, y: 0.72, size: 42, rotation: -14, colorIndex: 8),
        Doodle(id: 10, symbol: "graduationcap",         x: 0.68, y: 0.80, size: 40, rotation:  18, colorIndex: 11),
        Doodle(id: 11, symbol: "backpack",              x: 0.30, y: 0.88, size: 42, rotation:  -6, colorIndex: 10),
        Doodle(id: 12, symbol: "atom",                  x: 0.85, y: 0.93, size: 36, rotation:  22, colorIndex: 4),
        Doodle(id: 13, symbol: "pencil.and.outline",    x: 0.50, y: 0.36, size: 38, rotation: -22, colorIndex: 3),
        Doodle(id: 14, symbol: "scissors",              x: 0.44, y: 0.66, size: 34, rotation:  30, colorIndex: 0),
        Doodle(id: 15, symbol: "checkmark.seal",        x: 0.55, y: 0.09, size: 32, rotation:   8, colorIndex: 5)
    ]

    /// Wie kräftig die Motive durchscheinen.
    var opacity: Double = 0.13

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Self.doodles) { doodle in
                    Image(systemName: doodle.symbol)
                        .font(.system(size: doodle.size, weight: .light))
                        .foregroundStyle(AppTheme.tint(at: doodle.colorIndex))
                        .rotationEffect(.degrees(doodle.rotation))
                        .position(x: doodle.x * geometry.size.width,
                                  y: doodle.y * geometry.size.height)
                }
            }
            .opacity(opacity)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Der übliche Untergrund der Schreib-Seiten: Gruppenfarbe plus Motive.
struct DoodleCanvas: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
            DoodleBackground()
        }
        .ignoresSafeArea()
    }
}
