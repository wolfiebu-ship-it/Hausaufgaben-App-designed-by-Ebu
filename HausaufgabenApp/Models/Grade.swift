import Foundation

/// Schriftlich oder mündlich.
enum GradeKind: String, Codable, Hashable, CaseIterable, Identifiable {
    case written
    case oral

    var id: String { rawValue }

    var title: String {
        switch self {
        case .written: return "Schriftlich"
        case .oral:    return "Mündlich"
        }
    }

    var examples: String {
        switch self {
        case .written: return "Klassenarbeiten, Tests, Lernkontrollen"
        case .oral:    return "Mitarbeit, Referate, Abfragen"
        }
    }
}

/// Eine Note in einem Fach.
struct Grade: Codable, Hashable, Identifiable {
    var id: UUID
    var subjectID: UUID
    var kind: GradeKind
    /// Der Notenwert: 1+ ist 0,7, 1 ist 1,0, 1- ist 1,3 … 6 ist 6,0.
    var value: Double
    /// Der Tag ("yyyy-MM-dd"). Danach richtet sich auch das Halbjahr.
    var dayKey: String
    /// Wofür es die Note gab, z. B. „Klassenarbeit 2“. Freiwillig.
    var title: String

    init(id: UUID = UUID(),
         subjectID: UUID,
         kind: GradeKind,
         value: Double,
         dayKey: String,
         title: String = "") {
        self.id = id
        self.subjectID = subjectID
        self.kind = kind
        self.value = value
        self.dayKey = dayKey
        self.title = title
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        subjectID = try container.decode(UUID.self, forKey: .subjectID)
        kind = try container.decodeIfPresent(GradeKind.self, forKey: .kind) ?? .written
        value = try container.decodeIfPresent(Double.self, forKey: .value) ?? 3
        dayKey = try container.decodeIfPresent(String.self, forKey: .dayKey) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    }

    var halfYear: SchoolHalfYear? { SchoolHalfYear(dayKey: dayKey) }

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
}

/// Eine Stufe der Notenskala, z. B. „2-“ mit dem Wert 2,3.
struct GradeStep: Hashable, Identifiable {
    let name: String
    let value: Double
    var id: String { name }
}

/// Die übliche Notenskala von 1+ bis 6.
enum GradeScale {
    static let steps: [GradeStep] = [
        GradeStep(name: "1+", value: 0.7), GradeStep(name: "1", value: 1.0), GradeStep(name: "1-", value: 1.3),
        GradeStep(name: "2+", value: 1.7), GradeStep(name: "2", value: 2.0), GradeStep(name: "2-", value: 2.3),
        GradeStep(name: "3+", value: 2.7), GradeStep(name: "3", value: 3.0), GradeStep(name: "3-", value: 3.3),
        GradeStep(name: "4+", value: 3.7), GradeStep(name: "4", value: 4.0), GradeStep(name: "4-", value: 4.3),
        GradeStep(name: "5+", value: 4.7), GradeStep(name: "5", value: 5.0), GradeStep(name: "5-", value: 5.3),
        GradeStep(name: "6", value: 6.0)
    ]

    static let validValues: ClosedRange<Double> = 0.7...6.0

    /// „2-“ für 2,3 usw.
    static func name(for value: Double) -> String {
        steps.first { abs($0.value - value) < 0.01 }?.name ?? averageText(value)
    }

    /// Ein Schnitt mit einer Nachkommastelle, kaufmännisch gerundet: 1,65 wird 1,7.
    /// Ohne das kleine Plus landet 1,65 wegen der Rechengenauigkeit bei 1,6.
    static func averageText(_ value: Double) -> String {
        let gerundet = (value * 10 + 1e-9).rounded() / 10
        return String(format: "%.1f", gerundet).replacingOccurrences(of: ".", with: ",")
    }

    /// Wie viel Prozent die schriftlichen Noten zählen – zur Auswahl.
    static let writtenShares: [Int] = [70, 60, 50, 40, 30]
    static let defaultWrittenShare = 50
}

/// Ein Schulhalbjahr: August bis Januar ist das erste, Februar bis Juli das zweite.
///
/// `year` ist das Jahr, in dem das Schuljahr beginnt – 2026 steht für 2026/27.
struct SchoolHalfYear: Hashable, Comparable {
    var year: Int
    var half: Int

    init(year: Int, half: Int) {
        self.year = year
        self.half = half
    }

    init?(dayKey: String) {
        let teile = dayKey.split(separator: "-").compactMap { Int($0) }
        guard teile.count == 3 else { return nil }
        self.init(year: teile[0], month: teile[1])
    }

    init(date: Date) {
        let komponenten = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: date)
        self.init(year: komponenten.year ?? 2000, month: komponenten.month ?? 1)
    }

    private init(year: Int, month: Int) {
        if month >= 8 {
            self.year = year; half = 1
        } else if month == 1 {
            self.year = year - 1; half = 1
        } else {
            self.year = year - 1; half = 2
        }
    }

    static var current: SchoolHalfYear { SchoolHalfYear(date: Date()) }

    /// „1. Halbjahr 2026/27“
    var title: String {
        let folgejahr = String(year + 1).suffix(2)
        return "\(half). Halbjahr \(year)/\(folgejahr)"
    }

    var next: SchoolHalfYear {
        half == 1 ? SchoolHalfYear(year: year, half: 2) : SchoolHalfYear(year: year + 1, half: 1)
    }

    var previous: SchoolHalfYear {
        half == 2 ? SchoolHalfYear(year: year, half: 1) : SchoolHalfYear(year: year - 1, half: 2)
    }

    static func < (lhs: SchoolHalfYear, rhs: SchoolHalfYear) -> Bool {
        (lhs.year, lhs.half) < (rhs.year, rhs.half)
    }
}

/// Der Stand eines Fachs in einem Halbjahr.
struct SubjectGradeSummary {
    var grades: [Grade]
    var writtenAverage: Double?
    var oralAverage: Double?
    /// Anteil der schriftlichen Noten am Schnitt, 0…1.
    var writtenShare: Double

    /// Schriftlich und mündlich getrennt gemittelt, dann gewichtet.
    /// Fehlt eine Seite, zählt nur die andere.
    var total: Double? {
        switch (writtenAverage, oralAverage) {
        case let (s?, m?): return s * writtenShare + m * (1 - writtenShare)
        case let (s?, nil): return s
        case let (nil, m?): return m
        default: return nil
        }
    }

    func grades(of kind: GradeKind) -> [Grade] {
        grades.filter { $0.kind == kind }.sorted { $0.dayKey < $1.dayKey }
    }

    static func average(_ values: [Double]) -> Double? {
        values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }
}

/// Ein Fach mit seinen Noten in einem Halbjahr – für Listen in der Oberfläche.
struct SubjectGrades: Identifiable {
    let subject: Subject
    let summary: SubjectGradeSummary
    var id: UUID { subject.id }
}
