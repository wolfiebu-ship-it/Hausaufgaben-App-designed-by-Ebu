import SwiftUI

/// Zeigt, was aus dem Foto gelesen wurde, und lässt alles korrigieren,
/// bevor es den eigenen Stundenplan ersetzt.
struct ScanReviewView: View {
    let result: ScanResult
    let onApply: ([Lesson]) -> Void
    let onRetry: () -> Void

    @EnvironmentObject private var store: AppStore
    @State private var cells: [ScannedCell]
    @State private var editTarget: EditTarget?

    struct EditTarget: Identifiable {
        let weekday: Int
        let period: Int
        var id: String { "\(weekday)-\(period)" }
    }

    init(result: ScanResult,
         onApply: @escaping ([Lesson]) -> Void,
         onRetry: @escaping () -> Void) {
        self.result = result
        self.onApply = onApply
        self.onRetry = onRetry
        _cells = State(initialValue: result.cells)
    }

    private var weekdays: [Int] {
        let höchster = cells.map(\.weekday).max() ?? 5
        return Array(1...max(5, min(6, höchster)))
    }

    private var periods: [Int] {
        let höchste = cells.map(\.period).max() ?? 1
        return Array(1...max(1, min(14, höchste)))
    }

    private var offeneKuerzel: [String] {
        var gesehen = Set<String>()
        var liste: [String] = []
        for cell in cells where cell.subjectID == nil {
            let code = cell.code.uppercased()
            guard !code.isEmpty, !gesehen.contains(code) else { continue }
            gesehen.insert(code)
            liste.append(code)
        }
        return liste
    }

    private var zugeordnet: Int { cells.filter { $0.subjectID != nil }.count }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    kopf

                    if !offeneKuerzel.isEmpty {
                        unbekannteKuerzel
                    }

                    raster

                    Text("Tippe auf ein Feld, um das Fach zu ändern oder es zu leeren. Felder, die beim Scannen übersehen wurden, kannst du hier ergänzen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
            }

            fussleiste
        }
        .background(Color(.systemGroupedBackground))
        .sheet(item: $editTarget) { target in
            ScanCellEditor(weekday: target.weekday,
                           period: target.period,
                           aktuell: cell(weekday: target.weekday, period: target.period)) { auswahl in
                setze(weekday: target.weekday, period: target.period, subjectID: auswahl)
            }
            .environmentObject(store)
        }
    }

    // MARK: - Teile

    private var kopf: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(zugeordnet) von \(cells.count) Feldern zugeordnet")
                    .font(.subheadline.weight(.semibold))
                Text("Bitte kurz prüfen – beim Abfotografieren passieren leicht Lesefehler.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var unbekannteKuerzel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(offeneKuerzel.count == 1
                 ? "Ein Kürzel kennt die App noch nicht:"
                 : "\(offeneKuerzel.count) Kürzel kennt die App noch nicht:")
                .font(.subheadline.weight(.semibold))

            Text(offeneKuerzel.joined(separator: " · "))
                .font(.callout)
                .foregroundStyle(.secondary)

            Button {
                legeFaecherAn()
            } label: {
                Label("Als neue Fächer anlegen", systemImage: "plus.circle")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)

            Text("Namen und Farben kannst du danach im Tab „Fächer“ ändern.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var raster: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Color.clear.frame(width: 28, height: 24)
                ForEach(weekdays, id: \.self) { weekday in
                    Text(SchoolCalendar.weekdayShortName(weekday))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(periods, id: \.self) { period in
                HStack(spacing: 4) {
                    Text("\(period).")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28)

                    ForEach(weekdays, id: \.self) { weekday in
                        feld(weekday: weekday, period: period)
                    }
                }
            }
        }
    }

    private func feld(weekday: Int, period: Int) -> some View {
        let zelle = cell(weekday: weekday, period: period)
        let fach = store.subject(id: zelle?.subjectID)

        return Button {
            editTarget = EditTarget(weekday: weekday, period: period)
        } label: {
            VStack(spacing: 1) {
                if let fach {
                    Text(fach.displayShort)
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(fach.tint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                } else if let zelle, !zelle.code.isEmpty {
                    Text(zelle.code)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("?")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "plus")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(hintergrund(fach: fach, zelle: zelle),
                        in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                if fach == nil, let zelle, !zelle.code.isEmpty {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.orange, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(beschriftung(weekday: weekday, period: period, fach: fach, zelle: zelle))
    }

    private func hintergrund(fach: Subject?, zelle: ScannedCell?) -> Color {
        if let fach { return fach.fill }
        if let zelle, !zelle.code.isEmpty { return Color.orange.opacity(0.10) }
        return Color(.tertiarySystemFill)
    }

    private func beschriftung(weekday: Int, period: Int, fach: Subject?, zelle: ScannedCell?) -> String {
        let wo = "\(SchoolCalendar.weekdayName(weekday)), \(period). Stunde"
        if let fach { return "\(wo): \(fach.displayName)" }
        if let zelle, !zelle.code.isEmpty { return "\(wo): \(zelle.code), noch keinem Fach zugeordnet" }
        return "\(wo): leer"
    }

    private var fussleiste: some View {
        VStack(spacing: 10) {
            Button {
                onApply(alsStunden())
            } label: {
                Text("Stundenplan übernehmen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(zugeordnet == 0)

            Button("Noch einmal scannen", action: onRetry)
                .font(.subheadline)
        }
        .padding(16)
        .background(.bar)
    }

    // MARK: - Daten

    private func cell(weekday: Int, period: Int) -> ScannedCell? {
        cells.first { $0.weekday == weekday && $0.period == period }
    }

    private func setze(weekday: Int, period: Int, subjectID: UUID?) {
        if let index = cells.firstIndex(where: { $0.weekday == weekday && $0.period == period }) {
            if let subjectID {
                cells[index].subjectID = subjectID
                cells[index].code = store.subject(id: subjectID)?.displayShort ?? cells[index].code
            } else {
                cells.remove(at: index)
            }
        } else if let subjectID {
            let fach = store.subject(id: subjectID)
            cells.append(ScannedCell(weekday: weekday,
                                     period: period,
                                     rawText: fach?.displayName ?? "",
                                     code: fach?.displayShort ?? "",
                                     subjectID: subjectID,
                                     room: ""))
        }
    }

    private func legeFaecherAn() {
        let zuordnung = store.createSubjects(forCodes: offeneKuerzel)
        for index in cells.indices where cells[index].subjectID == nil {
            let code = cells[index].code.trimmingCharacters(in: .whitespacesAndNewlines)
            if let id = zuordnung[code] ?? zuordnung[code.uppercased()] {
                cells[index].subjectID = id
            }
        }
    }

    private func alsStunden() -> [Lesson] {
        var gesehen = Set<String>()
        var stunden: [Lesson] = []
        for zelle in cells.sorted(by: { ($0.period, $0.weekday) < ($1.period, $1.weekday) }) {
            guard let id = zelle.subjectID else { continue }
            let schluessel = "\(zelle.weekday)-\(zelle.period)"
            guard !gesehen.contains(schluessel) else { continue }
            gesehen.insert(schluessel)
            stunden.append(Lesson(weekday: zelle.weekday,
                                  period: zelle.period,
                                  subjectID: id,
                                  room: zelle.room,
                                  teacher: ""))
        }
        return stunden
    }
}

/// Fachauswahl für ein einzelnes Feld der Prüfansicht.
struct ScanCellEditor: View {
    let weekday: Int
    let period: Int
    let aktuell: ScannedCell?
    let onSelect: (UUID?) -> Void

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let aktuell, !aktuell.rawText.isEmpty {
                    Section("Im Foto stand hier") {
                        Text(aktuell.rawText)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button {
                        onSelect(nil)
                        dismiss()
                    } label: {
                        HStack {
                            Text("Feld leeren")
                                .foregroundStyle(.primary)
                            Spacer()
                            if aktuell == nil {
                                Image(systemName: "checkmark").foregroundStyle(.tint)
                            }
                        }
                    }

                    ForEach(store.sortedSubjects) { subject in
                        Button {
                            onSelect(subject.id)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                SubjectBadge(subject: subject, width: 40)
                                Text(subject.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if aktuell?.subjectID == subject.id {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Fach")
                }
            }
            .navigationTitle("\(SchoolCalendar.weekdayShortName(weekday)), \(period). Stunde")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
