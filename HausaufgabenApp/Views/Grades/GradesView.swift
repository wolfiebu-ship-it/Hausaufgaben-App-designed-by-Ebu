import SwiftUI

/// Die Noten: je Fach schriftlich und mündlich, mit Schnitt – Halbjahr für Halbjahr.
struct GradesView: View {
    @EnvironmentObject private var store: AppStore

    @State private var halfYear = SchoolHalfYear.current
    @State private var editing: GradeEditorTarget?
    /// Das zuletzt benutzte Fach – die nächste Note ist oft im selben.
    @State private var lastSubjectID: UUID?

    var body: some View {
        let faecher = store.subjectsWithGrades(in: halfYear)

        ScrollView {
            VStack(spacing: 12) {
                halfYearSwitcher

                if let gesamt = store.overallAverage(in: halfYear) {
                    overallCard(value: gesamt.value, subjectCount: gesamt.subjectCount)
                }

                addButton

                if faecher.isEmpty {
                    emptyHint
                }

                ForEach(faecher) { eintrag in
                    subjectCard(eintrag)
                }

                Text("Noten von 1+ bis 6. Für den Schnitt eines Fachs werden die schriftlichen und die mündlichen Noten getrennt gemittelt und dann nach der Gewichtung zusammengerechnet; fehlt eine Seite, zählt nur die andere. Wie stark was zählt, legt jede Lehrkraft selbst fest – frag am besten nach und stell es hier ein.\n\nDie Halbjahre gehen von August bis Januar und von Februar bis Juli. Homy ordnet jede Note nach ihrem Datum ein.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Noten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editing = .new
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Note eintragen")
            }
        }
        .sheet(item: $editing) { target in
            GradeEditorView(existing: target.grade,
                            defaultSubjectID: lastSubjectID) { gespeichert in
                lastSubjectID = gespeichert.subjectID
                // Das Halbjahr der Note zeigen – sonst wäre sie scheinbar verschwunden.
                if let hj = gespeichert.halfYear { halfYear = hj }
            }
            .environmentObject(store)
        }
    }

    // MARK: - Teile

    private var halfYearSwitcher: some View {
        HStack(spacing: 12) {
            Button {
                halfYear = halfYear.previous
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 34, height: 34)
                    .background(Color(.secondarySystemGroupedBackground), in: Circle())
            }
            .accessibilityLabel("Voriges Halbjahr")

            Text(halfYear.title)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 190)

            Button {
                halfYear = halfYear.next
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 34, height: 34)
                    .background(Color(.secondarySystemGroupedBackground), in: Circle())
            }
            .accessibilityLabel("Nächstes Halbjahr")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .padding(.bottom, 2)
    }

    private func overallCard(value: Double, subjectCount: Int) -> some View {
        HStack(spacing: 16) {
            Text(GradeScale.averageText(value))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text("Gesamtschnitt")
                    .font(.subheadline.weight(.semibold))
                Text("aus \(subjectCount) \(subjectCount == 1 ? "Fach" : "Fächern"), jedes Fach zählt gleich viel")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .accessibilityElement(children: .combine)
    }

    private var addButton: some View {
        Button {
            editing = .new
        } label: {
            Label("Note eintragen", systemImage: "plus")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .strokeBorder(Color.accentColor.opacity(0.35),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        .background(Color(.secondarySystemGroupedBackground),
                                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }

    private var emptyHint: some View {
        VStack(spacing: 8) {
            Text("Noch keine Noten in diesem Halbjahr")
                .font(.headline)
            Text("Trag jede Note ein, sobald du sie bekommst – schriftliche wie Klassenarbeiten und Tests, mündliche wie Mitarbeit und Referate. Homy rechnet den Schnitt je Fach und insgesamt aus.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
    }

    private func subjectCard(_ eintrag: SubjectGrades) -> some View {
        let fach = eintrag.subject
        let stand = eintrag.summary
        let prozent = store.writtenShare(forSubject: fach.id)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                SubjectBadge(subject: fach, width: 40)
                Text(fach.displayName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if let gesamt = stand.total {
                    Text(GradeScale.averageText(gesamt))
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                        .accessibilityLabel("Schnitt \(GradeScale.averageText(gesamt))")
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 6)

            ForEach(GradeKind.allCases) { art in
                kindRow(art, summary: stand)
            }

            Divider()
                .padding(.top, 6)

            Menu {
                ForEach(GradeScale.writtenShares, id: \.self) { anteil in
                    Button {
                        store.setWrittenShare(anteil, forSubject: fach.id)
                    } label: {
                        if anteil == prozent {
                            Label("\(anteil) % schriftlich, \(100 - anteil) % mündlich", systemImage: "checkmark")
                        } else {
                            Text("\(anteil) % schriftlich, \(100 - anteil) % mündlich")
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Zählt \(prozent) % schriftlich, \(100 - prozent) % mündlich")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .font(.footnote)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private func kindRow(_ art: GradeKind, summary: SubjectGradeSummary) -> some View {
        let liste = summary.grades(of: art)
        let schnitt = art == .written ? summary.writtenAverage : summary.oralAverage

        return HStack(spacing: 10) {
            Text(art.title)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 82, alignment: .leading)

            if liste.isEmpty {
                Text("–")
                    .foregroundStyle(.tertiary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(liste) { note in
                            gradeChip(note)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            if let schnitt {
                Text("Ø \(GradeScale.averageText(schnitt))")
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 5)
    }

    private func gradeChip(_ note: Grade) -> some View {
        Button {
            editing = .edit(note)
        } label: {
            Text(GradeScale.name(for: note.value))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 38)
                .padding(.vertical, 5)
                .padding(.horizontal, 6)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(chipLabel(note))
        .accessibilityHint("Zum Ändern antippen")
    }

    private func chipLabel(_ note: Grade) -> String {
        let titel = note.trimmedTitle
        return titel.isEmpty
            ? "Note \(GradeScale.name(for: note.value))"
            : "Note \(GradeScale.name(for: note.value)), \(titel)"
    }
}

/// Was der Noten-Editor öffnen soll: eine neue Note oder eine vorhandene.
enum GradeEditorTarget: Identifiable {
    case new
    case edit(Grade)

    var id: String {
        switch self {
        case .new: return "neu"
        case .edit(let note): return note.id.uuidString
        }
    }

    var grade: Grade? {
        if case .edit(let note) = self { return note }
        return nil
    }
}
