import Foundation

/// Übliche Fachkürzel an deutschen Schulen und der Name dahinter.
///
/// Damit trägt Homy nach dem Abfotografieren nicht „BIO“ als Fachnamen ein,
/// sondern „Biologie“. Das Kürzel aus dem Foto bleibt trotzdem stehen – im
/// Stundenplan steht ja genau das, was auch auf dem Zettel steht.
///
/// Die Liste ist eine Hilfe, keine Vorschrift: Steht ein Kürzel nicht drin,
/// wird es einfach selbst zum Namen und lässt sich unter „Fächer“ ändern.
enum SubjectNames {

    /// Kürzel → Fachname. Alles klein geschrieben, verglichen wird ohne Groß-/Kleinschreibung.
    private static let table: [String: String] = [
        // Hauptfächer
        "d": "Deutsch", "de": "Deutsch", "deu": "Deutsch",
        "m": "Mathematik", "ma": "Mathematik", "mat": "Mathematik", "mathe": "Mathematik",
        "e": "Englisch", "en": "Englisch", "eng": "Englisch",

        // Weitere Sprachen
        "f": "Französisch", "fr": "Französisch", "frz": "Französisch",
        "l": "Latein", "la": "Latein", "lat": "Latein",
        "s": "Spanisch", "spa": "Spanisch", "span": "Spanisch",
        "ru": "Russisch", "it": "Italienisch", "tü": "Türkisch", "tu": "Türkisch",
        "gr": "Griechisch", "nl": "Niederländisch",

        // Naturwissenschaften
        "bi": "Biologie", "bio": "Biologie",
        "ch": "Chemie", "che": "Chemie", "c": "Chemie",
        "ph": "Physik", "phy": "Physik", "p": "Physik",
        "nw": "Naturwissenschaften", "nawi": "Naturwissenschaften",
        "if": "Informatik", "inf": "Informatik", "ifo": "Informatik",
        "tc": "Technik", "te": "Technik", "tech": "Technik",

        // Gesellschaft
        "g": "Geschichte", "ge": "Geschichte", "ges": "Geschichte", "gesch": "Geschichte",
        "ek": "Erdkunde", "erd": "Erdkunde", "geo": "Erdkunde", "gg": "Geographie",
        "po": "Politik", "pol": "Politik", "sw": "Sozialwissenschaften",
        "sowi": "Sozialwissenschaften", "gk": "Gemeinschaftskunde",
        "wi": "Wirtschaft", "wn": "Wirtschaft", "wl": "Wirtschaftslehre",
        "al": "Arbeitslehre", "hw": "Hauswirtschaft",

        // Religion, Ethik, Philosophie
        "re": "Religion", "rel": "Religion",
        "kr": "Katholische Religion", "ka": "Katholische Religion",
        "er": "Evangelische Religion", "ev": "Evangelische Religion",
        "eth": "Ethik", "et": "Ethik", "ethik": "Ethik",
        "pl": "Philosophie", "phi": "Philosophie", "pp": "Praktische Philosophie",
        "lk": "Lebenskunde",

        // Musisch und Sport
        "ku": "Kunst", "kun": "Kunst", "bk": "Bildende Kunst",
        "mu": "Musik", "mus": "Musik",
        "sp": "Sport", "spo": "Sport", "sport": "Sport",
        "ds": "Darstellendes Spiel", "th": "Theater", "wk": "Werken",

        // Schulalltag
        "kl": "Klassenlehrerstunde", "klr": "Klassenrat",
        "lz": "Lernzeit", "lb": "Lernbüro", "fö": "Förderunterricht",
        "foe": "Förderunterricht", "wp": "Wahlpflicht", "ag": "Arbeitsgemeinschaft",
        "mi": "Mittagspause", "vt": "Vertretung", "frei": "Freistunde"
    ]

    /// Der Fachname zu einem Kürzel – oder das Kürzel selbst, wenn es unbekannt ist.
    static func fullName(for code: String) -> String {
        let cleaned = code
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".-"))
        guard !cleaned.isEmpty else { return code }

        // Steht der ganze Name schon da („Mathematik“), bleibt er stehen.
        if cleaned.count > 6 { return cleaned }
        return table[cleaned.lowercased()] ?? cleaned
    }

    /// Kennt die Liste dieses Kürzel?
    static func isKnown(_ code: String) -> Bool {
        let cleaned = code
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".-"))
            .lowercased()
        return table[cleaned] != nil
    }
}
