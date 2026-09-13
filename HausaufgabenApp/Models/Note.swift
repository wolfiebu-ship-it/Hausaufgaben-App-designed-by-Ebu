import Foundation

/// Eine Notiz – wie ein Blatt Papier: man schreibt einfach los.
///
/// Es gibt kein eigenes Titelfeld. Wie in Apples Notizen ist die erste
/// beschriebene Zeile der Titel, der Rest die Vorschau.
struct Note: Identifiable, Codable, Hashable {
    var id: UUID
    /// Der ganze Text der Notiz, mehrzeilig.
    var text: String
    /// Fach, falls die Notiz zu einem gehört (freiwillig).
    var subjectID: UUID?
    /// Termin als "yyyy-MM-dd", falls es einen gibt (freiwillig).
    var dueDayKey: String?
    var isDone: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(),
         text: String = "",
         subjectID: UUID? = nil,
         dueDayKey: String? = nil,
         isDone: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.text = text
        self.subjectID = subjectID
        self.dueDayKey = dueDayKey
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Ältere Sicherungen kennen updatedAt noch nicht.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        subjectID = try container.decodeIfPresent(UUID.self, forKey: .subjectID)
        dueDayKey = try container.decodeIfPresent(String.self, forKey: .dueDayKey)
        isDone = try container.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
        let created = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        createdAt = created
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? created
    }

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Titel und Vorschau aus dem Text

    private var lines: [String] {
        text.components(separatedBy: .newlines)
    }

    /// Die erste beschriebene Zeile.
    var title: String {
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { return trimmed }
        }
        return "Neue Notiz"
    }

    /// Alles nach der Titelzeile, zu einer Zeile zusammengefasst.
    var preview: String {
        guard let titleIndex = lines.firstIndex(where: {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }) else { return "" }

        let rest = lines.dropFirst(titleIndex + 1)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return String(rest.prefix(200))
    }

    // MARK: - Termin

    var dueDate: Date? {
        guard let dueDayKey else { return nil }
        return SchoolCalendar.date(fromDayKey: dueDayKey)
    }

    /// Wie viele Tage sind es noch? Negativ heißt: schon vorbei.
    var daysUntilDue: Int? {
        guard let dueDate else { return nil }
        let heute = SchoolCalendar.startOfDay(Date())
        return SchoolCalendar.calendar.dateComponents([.day], from: heute, to: dueDate).day
    }

    /// „Do, 24.9. · in 4 Tagen“ – für das Termin-Zeichen.
    var dueText: String? {
        guard let dueDate else { return nil }
        let datum = SchoolCalendar.shortWeekdayDate(dueDate)
        guard let tage = daysUntilDue else { return datum }

        switch tage {
        case 0:      return "\(datum) · heute"
        case 1:      return "\(datum) · morgen"
        case 2...7:  return "\(datum) · in \(tage) Tagen"
        case ..<0:   return "\(datum) · vorbei"
        default:     return datum
        }
    }

    var isSoon: Bool {
        guard let tage = daysUntilDue else { return false }
        return tage >= 0 && tage <= 2
    }

    var isOverdue: Bool {
        guard let tage = daysUntilDue else { return false }
        return tage < 0
    }

    /// Steht der Termin noch bevor? Solche Notizen stehen oben in der Liste.
    var isUpcoming: Bool {
        guard !isDone, let tage = daysUntilDue else { return false }
        return tage >= 0
    }
}
