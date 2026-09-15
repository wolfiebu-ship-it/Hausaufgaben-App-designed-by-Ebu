import SwiftUI

/// Das Zeichen von Homy: ein Haus, in dem ein Stift steckt.
///
/// Dieselbe Form wie das App-Symbol auf dem Home-Bildschirm, nur gezeichnet
/// statt als Bild – so bleibt es in jeder Größe scharf.
struct HomyMark: View {
    var size: CGFloat = 76

    /// Die Farben des Zeichens – hell wie dunkel dieselben,
    /// damit das Zeichen immer gleich aussieht.
    static let backgroundGradient = LinearGradient(
        colors: [Color(UIColor(hex: 0x3B72FF)), Color(UIColor(hex: 0x7A5AF0))],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let pencilBody = Color(UIColor(hex: 0xFFC44D))
    static let pencilBand = Color(UIColor(hex: 0xF0A52E))
    static let pencilTip = Color(UIColor(hex: 0x4A3A22))

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
                .fill(HomyMark.backgroundGradient)

            HomyHouseShape()
                .stroke(.white,
                        style: StrokeStyle(lineWidth: size * 0.075, lineJoin: .round))
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(y: -size * 0.01)

            pencil
                .frame(width: size * 0.105, height: size * 0.30)
                .rotationEffect(.degrees(38))
                .offset(y: size * 0.10)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    /// Ein Stift: oben die Spitze, darunter der Schaft mit Blechring.
    private var pencil: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Triangle()
                        .fill(HomyMark.pencilTip)
                        .frame(height: h * 0.24)
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: w * 0.38,
                        bottomTrailingRadius: w * 0.38,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                    .fill(HomyMark.pencilBody)
                }

                Rectangle()
                    .fill(HomyMark.pencilBand)
                    .frame(height: h * 0.07)
                    .offset(y: h * 0.32)
            }
        }
    }
}

/// Der Umriss eines Hauses: Dach und Wände in einem Zug.
struct HomyHouseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + w * x, y: rect.minY + h * y)
        }

        var path = Path()
        path.move(to: point(0.5, 0.0))      // Dachspitze
        path.addLine(to: point(1.0, 0.44))  // rechte Traufe
        path.addLine(to: point(1.0, 1.0))   // rechte Wand
        path.addLine(to: point(0.0, 1.0))   // Boden
        path.addLine(to: point(0.0, 0.44))  // linke Wand
        path.closeSubpath()
        return path
    }
}

/// Ein Dreieck, das nach oben zeigt – die Stiftspitze.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Zeichen und Name nebeneinander – für das Anmeldebild und die Einstellungen.
struct HomyWordmark: View {
    var markSize: CGFloat = 76
    var showsSubtitle: Bool = true

    var body: some View {
        VStack(spacing: 14) {
            HomyMark(size: markSize)
                .shadow(color: .black.opacity(0.18), radius: 14, y: 6)

            VStack(spacing: 3) {
                Text("Homy")
                    .font(.system(size: markSize * 0.42, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                if showsSubtitle {
                    Text("Dein Hausaufgabenheft")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Homy – dein Hausaufgabenheft")
    }
}
