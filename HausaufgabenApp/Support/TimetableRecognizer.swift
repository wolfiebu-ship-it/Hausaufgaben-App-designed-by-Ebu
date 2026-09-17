import Foundation
import UIKit
import Vision

/// Eine erkannte Zelle aus dem abfotografierten Stundenplan.
struct ScannedCell: Identifiable, Hashable {
    let id = UUID()
    var weekday: Int          // 1 = Montag
    var period: Int           // 1 = erste Stunde
    /// Was in dem Feld stand, ungefiltert.
    var rawText: String
    /// Das Kürzel, das als Fach gedeutet wurde.
    var code: String
    /// Zugeordnetes Fach – `nil`, wenn kein passendes gefunden wurde.
    var subjectID: UUID?
    /// Zusatz aus dem Feld, meist der Raum.
    var room: String
}

struct ScanResult {
    var cells: [ScannedCell] = []
    var weekdayCount: Int = 5
    var periodCount: Int = 0
    /// Kürzel, zu denen es noch kein Fach gibt.
    var unknownCodes: [String] = []
    /// Wurde überhaupt Text gefunden?
    var foundText = false
    /// Unterrichtszeiten aus der Spalte links – leer, wenn keine zu lesen waren.
    var times: [PeriodTime] = []
    /// Fächer, die wegen dieses Fotos neu angelegt wurden (für die Prüfansicht).
    var createdSubjects: [Subject] = []
}

/// Liest einen fotografierten Stundenplan aus: Text erkennen, das Raster aus
/// den Textpositionen ableiten, die Kürzel den vorhandenen Fächern zuordnen.
///
/// Das Ergebnis ist bewusst ein *Vorschlag*. Ein Foto kann schief, verknittert
/// oder handschriftlich sein – deshalb prüft und korrigiert man das Ergebnis
/// in `ScanReviewView`, bevor es den eigenen Stundenplan ersetzt.
enum TimetableRecognizer {

    // MARK: - Öffentlich

    static func recognize(image: UIImage, subjects: [Subject]) async -> ScanResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: analyse(image: image, subjects: subjects))
            }
        }
    }

    // MARK: - Texterkennung

    /// Ein Stück erkannter Text mit seiner Lage im Bild.
    /// y zählt hier von oben (Vision selbst rechnet von unten).
    private struct Piece {
        var text: String
        var x: CGFloat
        var y: CGFloat
        var height: CGFloat
    }

    private static func analyse(image: UIImage, subjects: [Subject]) -> ScanResult {
        guard let cgImage = image.normalizedUp().cgImage else { return ScanResult() }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["de-DE"]
        // Kürzel wie „BIO“ oder „EK“ sind keine Wörter – die Autokorrektur
        // würde daraus sonst etwas anderes machen.
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return ScanResult()
        }

        let observations = request.results ?? []
        var pieces: [Piece] = []
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            let box = observation.boundingBox
            pieces.append(Piece(text: text,
                                x: box.midX,
                                y: 1 - box.midY,        // von oben zählen
                                height: box.height))
        }

        guard !pieces.isEmpty else { return ScanResult() }

        var result = ScanResult()
        result.foundText = true

        // MARK: Spalten (Wochentage)

        let headerPieces = pieces.filter { weekdayIndex(for: $0.text) != nil }
        var columns: [(weekday: Int, x: CGFloat)] = []
        var headerY: CGFloat = 0

        if headerPieces.count >= 3 {
            // Die Kopfzeile ist die Zeile, in der die meisten Wochentage stehen.
            let sortedByY = headerPieces.sorted { $0.y < $1.y }
            headerY = sortedByY[sortedByY.count / 2].y
            let tolerance = max(0.05, (pieces.map(\.height).reduce(0, +) / CGFloat(pieces.count)) * 2.5)

            var seen = Set<Int>()
            for piece in headerPieces.filter({ abs($0.y - headerY) <= tolerance }).sorted(by: { $0.x < $1.x }) {
                guard let weekday = weekdayIndex(for: piece.text), !seen.contains(weekday) else { continue }
                seen.insert(weekday)
                columns.append((weekday, piece.x))
            }
        }

        // Keine Wochentage lesbar: Spalten aus der Verteilung der Textpositionen schätzen.
        if columns.count < 2 {
            let bodyPieces = pieces.filter { $0.x > 0.12 }
            let centers = clusterValues(bodyPieces.map(\.x), tolerance: 0.06)
            guard centers.count >= 2 else { return result }
            columns = centers.enumerated().map { (index, x) in (min(index + 1, 7), x) }
            headerY = 0
        }

        result.weekdayCount = columns.count

        // MARK: Zeilen (Stunden)

        // Alles unterhalb der Kopfzeile zählt zum Raster.
        let body = pieces.filter { $0.y > headerY + 0.01 }
        guard !body.isEmpty else { return result }

        let averageHeight = body.map(\.height).reduce(0, +) / CGFloat(body.count)
        let rowTolerance = max(0.02, averageHeight * 1.2)
        let rowCenters = clusterValues(body.map(\.y), tolerance: rowTolerance)
        guard !rowCenters.isEmpty else { return result }

        result.periodCount = min(rowCenters.count, 14)

        // MARK: Text den Feldern zuordnen

        let firstColumnX = columns.first?.x ?? 0
        // Alles deutlich links der ersten Wochentagsspalte ist die Stunden-
        // bzw. Zeitspalte und gehört nicht in den Plan.
        let leftEdge = firstColumnX - 0.09

        var buckets: [String: [Piece]] = [:]
        // Was links neben dem Raster steht, ist die Stunden- und Zeitspalte.
        var timeColumn: [Piece] = []
        for piece in body {
            guard piece.x > leftEdge else {
                timeColumn.append(piece)
                continue
            }
            guard let column = nearestIndex(of: piece.x, in: columns.map(\.x)) else { continue }
            guard let row = nearestIndex(of: piece.y, in: rowCenters) else { continue }
            guard row < 14 else { continue }
            buckets["\(row)-\(column)", default: []].append(piece)
        }

        var unknown = Set<String>()

        for (key, group) in buckets {
            let parts = key.split(separator: "-")
            guard parts.count == 2,
                  let row = Int(parts[0]), let column = Int(parts[1]),
                  column < columns.count else { continue }

            let ordered = group.sorted { $0.y < $1.y }
            let rawText = ordered.map(\.text).joined(separator: " ")
            let (code, room) = splitCodeAndRoom(ordered.map(\.text))
            guard !code.isEmpty else { continue }

            let match = matchSubject(code: code, subjects: subjects)
            if match == nil { unknown.insert(code.uppercased()) }

            result.cells.append(ScannedCell(weekday: columns[column].weekday,
                                            period: row + 1,
                                            rawText: rawText,
                                            code: code,
                                            subjectID: match?.id,
                                            room: room))
        }

        result.cells.sort { ($0.period, $0.weekday) < ($1.period, $1.weekday) }
        result.unknownCodes = unknown.sorted()
        result.times = readTimes(from: timeColumn, rowCenters: rowCenters)
        return result
    }

    // MARK: - Unterrichtszeiten

    /// Liest die Zeiten aus der Spalte links neben dem Raster.
    ///
    /// Erkannt wird alles, was wie eine Uhrzeit aussieht: „8:00 – 8:45“,
    /// „08.00-08.45“, oder Anfang und Ende in zwei Zeilen untereinander.
    /// Steht nur der Anfang da, werden 45 Minuten angenommen.
    private static func readTimes(from pieces: [Piece], rowCenters: [CGFloat]) -> [PeriodTime] {
        guard !pieces.isEmpty, !rowCenters.isEmpty else { return [] }

        // Jedes Textstück der nächstgelegenen Zeile zuordnen.
        var proZeile: [Int: [Piece]] = [:]
        for piece in pieces {
            guard let row = nearestIndex(of: piece.y, in: rowCenters), row < 14 else { continue }
            proZeile[row, default: []].append(piece)
        }

        var gefunden: [PeriodTime] = []
        for (row, group) in proZeile {
            let text = group.sorted { $0.y < $1.y }.map(\.text).joined(separator: " ")
            let minuten = minutesInText(text)
            guard let start = minuten.first else { continue }

            // Der zweite Wert ist das Ende – aber nur, wenn er danach liegt
            // und die Stunde nicht länger als drei Zeitstunden dauert.
            var ende = start + 45
            if minuten.count >= 2 {
                let kandidat = minuten[1]
                if kandidat > start && kandidat - start <= 180 { ende = kandidat }
            }
            gefunden.append(PeriodTime(period: row + 1, startMinutes: start, endMinutes: ende))
        }

        gefunden.sort { $0.period < $1.period }

        // Zeiten müssen im Lauf des Tages größer werden. Was aus der Reihe
        // fällt, war ein Lesefehler – lieber weglassen als falsch eintragen.
        var geprueft: [PeriodTime] = []
        for zeit in gefunden {
            if let letzte = geprueft.last, zeit.startMinutes <= letzte.startMinutes { continue }
            geprueft.append(zeit)
        }

        // Einzelne Treffer sind eher Zufall als eine gelesene Zeitspalte.
        return geprueft.count >= 3 ? geprueft : []
    }

    /// Alle Uhrzeiten in einem Text, als Minuten seit Mitternacht.
    /// Aus „1. Std 8:00 - 8:45“ wird [480, 525]; die „1.“ zählt nicht mit.
    private static func minutesInText(_ text: String) -> [Int] {
        var ergebnis: [Int] = []
        let zeichen = Array(text)
        var index = 0

        while index < zeichen.count {
            guard zeichen[index].isNumber else { index += 1; continue }

            var stundeText = ""
            while index < zeichen.count, zeichen[index].isNumber, stundeText.count < 2 {
                stundeText.append(zeichen[index])
                index += 1
            }
            // Ein Trenner muss folgen, sonst ist es keine Uhrzeit, sondern
            // eine Stundennummer oder eine Raumnummer.
            guard index < zeichen.count, zeichen[index] == ":" || zeichen[index] == "." else { continue }
            let trenner = zeichen[index]
            index += 1

            var minuteText = ""
            while index < zeichen.count, zeichen[index].isNumber, minuteText.count < 2 {
                minuteText.append(zeichen[index])
                index += 1
            }
            // „1.“ am Zeilenanfang hat keine zwei Ziffern dahinter.
            guard minuteText.count == 2 else { continue }
            // Ein Punkt als Trenner kommt auch in Datumsangaben vor – bei
            // „1.9“ fehlt die zweite Ziffer, das fängt die Prüfung oben ab.
            _ = trenner

            guard let stunde = Int(stundeText), let minute = Int(minuteText),
                  (0...23).contains(stunde), (0...59).contains(minute) else { continue }
            ergebnis.append(stunde * 60 + minute)
        }
        return ergebnis
    }

    // MARK: - Hilfsmittel

    /// Fasst nahe beieinanderliegende Werte zu Gruppen zusammen und gibt
    /// deren Mittelpunkte zurück – so entstehen aus Textpositionen Zeilen bzw. Spalten.
    private static func clusterValues(_ values: [CGFloat], tolerance: CGFloat) -> [CGFloat] {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return [] }

        var clusters: [[CGFloat]] = [[sorted[0]]]
        for value in sorted.dropFirst() {
            if let last = clusters.last?.last, value - last <= tolerance {
                clusters[clusters.count - 1].append(value)
            } else {
                clusters.append([value])
            }
        }
        return clusters.map { $0.reduce(0, +) / CGFloat($0.count) }
    }

    private static func nearestIndex(of value: CGFloat, in centers: [CGFloat]) -> Int? {
        guard !centers.isEmpty else { return nil }
        var bestIndex = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude
        for (index, center) in centers.enumerated() {
            let distance = abs(center - value)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }
        return bestIndex
    }

    private static let weekdayNames: [(Int, [String])] = [
        (1, ["montag", "mo", "mon"]),
        (2, ["dienstag", "di", "die", "dien"]),
        (3, ["mittwoch", "mi", "mit", "mitt"]),
        (4, ["donnerstag", "do", "don"]),
        (5, ["freitag", "fr", "fre"]),
        (6, ["samstag", "sa", "sam", "sonnabend"]),
        (7, ["sonntag", "so", "son"])
    ]

    private static func weekdayIndex(for text: String) -> Int? {
        let cleaned = text.lowercased()
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard !cleaned.isEmpty, cleaned.count <= 12 else { return nil }
        for (index, variants) in weekdayNames where variants.contains(cleaned) {
            return index
        }
        return nil
    }

    /// Trennt das Fachkürzel von Zusatzangaben wie dem Raum.
    /// „M 112“ wird zu ("M", "112"), „BIO“ zu ("BIO", "").
    private static func splitCodeAndRoom(_ parts: [String]) -> (String, String) {
        let tokens = parts
            .flatMap { $0.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "/" }) }
            .map(String.init)
            .map { $0.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) }
            .filter { !$0.isEmpty }

        guard !tokens.isEmpty else { return ("", "") }

        // Das Kürzel ist der erste Eintrag, der mindestens einen Buchstaben hat.
        guard let codeIndex = tokens.firstIndex(where: { $0.rangeOfCharacter(from: .letters) != nil }) else {
            return ("", "")
        }
        let code = String(tokens[codeIndex].prefix(6))
        var rest = tokens
        rest.remove(at: codeIndex)
        return (code, rest.joined(separator: " "))
    }

    /// Sucht das Fach zu einem erkannten Kürzel – erst genau, dann großzügig.
    static func matchSubject(code: String, subjects: [Subject]) -> Subject? {
        let needle = code.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return nil }

        if let exact = subjects.first(where: { $0.short.lowercased() == needle }) { return exact }
        if let byName = subjects.first(where: { $0.name.lowercased() == needle }) { return byName }
        if needle.count >= 3,
           let byPrefix = subjects.first(where: { $0.name.lowercased().hasPrefix(needle) }) {
            return byPrefix
        }
        // Ein Zeichen Abweichung erlauben, aber nur bei längeren Kürzeln –
        // sonst würde aus „D“ schnell „E“.
        if needle.count >= 2 {
            if let fuzzy = subjects.first(where: {
                editDistance($0.short.lowercased(), needle) <= 1 && !$0.short.isEmpty
            }) {
                return fuzzy
            }
        }
        return nil
    }

    private static func editDistance(_ a: String, _ b: String) -> Int {
        let first = Array(a), second = Array(b)
        if first.isEmpty { return second.count }
        if second.isEmpty { return first.count }

        var previous = Array(0...second.count)
        var current = [Int](repeating: 0, count: second.count + 1)

        for i in 1...first.count {
            current[0] = i
            for j in 1...second.count {
                let cost = first[i - 1] == second[j - 1] ? 0 : 1
                current[j] = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
            }
            previous = current
        }
        return previous[second.count]
    }
}

extension UIImage {
    /// Zeichnet das Bild aufrecht neu – sonst liest Vision ein gedrehtes Foto falsch.
    func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
