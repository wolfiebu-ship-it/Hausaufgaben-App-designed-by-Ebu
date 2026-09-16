import Foundation

/// Das Bundesland – davon hängt ab, welche gesetzlichen Feiertage gelten.
enum FederalState: String, Codable, Hashable, CaseIterable, Identifiable {
    case none
    case badenWuerttemberg
    case bayern
    case berlin
    case brandenburg
    case bremen
    case hamburg
    case hessen
    case mecklenburgVorpommern
    case niedersachsen
    case nordrheinWestfalen
    case rheinlandPfalz
    case saarland
    case sachsen
    case sachsenAnhalt
    case schleswigHolstein
    case thueringen

    var id: String { rawValue }

    var name: String {
        switch self {
        case .none:                  return "Nicht angegeben"
        case .badenWuerttemberg:     return "Baden-Württemberg"
        case .bayern:                return "Bayern"
        case .berlin:                return "Berlin"
        case .brandenburg:           return "Brandenburg"
        case .bremen:                return "Bremen"
        case .hamburg:               return "Hamburg"
        case .hessen:                return "Hessen"
        case .mecklenburgVorpommern: return "Mecklenburg-Vorpommern"
        case .niedersachsen:         return "Niedersachsen"
        case .nordrheinWestfalen:    return "Nordrhein-Westfalen"
        case .rheinlandPfalz:        return "Rheinland-Pfalz"
        case .saarland:              return "Saarland"
        case .sachsen:               return "Sachsen"
        case .sachsenAnhalt:         return "Sachsen-Anhalt"
        case .schleswigHolstein:     return "Schleswig-Holstein"
        case .thueringen:            return "Thüringen"
        }
    }

    /// Kfz-Kürzel, z. B. „NW“.
    var shortName: String {
        switch self {
        case .none:                  return "—"
        case .badenWuerttemberg:     return "BW"
        case .bayern:                return "BY"
        case .berlin:                return "BE"
        case .brandenburg:           return "BB"
        case .bremen:                return "HB"
        case .hamburg:               return "HH"
        case .hessen:                return "HE"
        case .mecklenburgVorpommern: return "MV"
        case .niedersachsen:         return "NI"
        case .nordrheinWestfalen:    return "NW"
        case .rheinlandPfalz:        return "RP"
        case .saarland:              return "SL"
        case .sachsen:               return "SN"
        case .sachsenAnhalt:         return "ST"
        case .schleswigHolstein:     return "SH"
        case .thueringen:            return "TH"
        }
    }

    var isSet: Bool { self != .none }

    /// Alle Bundesländer ohne den Platzhalter – alphabetisch.
    static var allStates: [FederalState] {
        allCases.filter(\.isSet).sorted { $0.name < $1.name }
    }
}
