import SwiftUI

/// Suche über alle Wochen: „Wo stand nochmal das Arbeitsblatt?“
/// Findet Hausaufgaben und Notizen.
struct SearchView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var searchFocused: Bool

    @State private var query = ""

    /// Wird aufgerufen, wenn ein Treffer angetippt wird – der Pager
    /// springt dann zu der Woche, in der die Aufgabe steht.
    var onOpenDay: (Date) -> Void = { _ in }

    private var results: [AppStore.SearchResult] { store.search(query) }

    var body: some View {
        NavigationStack {
            Group {
                if query.trimmingCharacters(in: .whitespaces).count < 2 {
                    hint
                } else if results.isEmpty {
                    noResults
                } else {
                    list
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Suchen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Hausaufgaben und Notizen durchsuchen")
        }
    }

    private var list: some View {
        List {
            Section {
                ForEach(results) { result in
                    Button {
                        if let day = result.day {
                            onOpenDay(day)
                        }
                        dismiss()
                    } label: {
                        SearchResultRow(result: result,
                                        subject: store.subject(id: result.subjectID))
                    }
                    .buttonStyle(.plain)
                    .disabled(result.kind == .note)
                }
            } footer: {
                Text(results.count == 1
                     ? "1 Treffer"
                     : "\(results.count) Treffer. Tippe eine Hausaufgabe an, um zu ihrer Woche zu springen.")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var hint: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("Alles durchsuchen")
                .font(.headline)
            Text("Tippe mindestens zwei Buchstaben ein. Gesucht wird in allen Hausaufgaben – auch in älteren Wochen – und in deinen Notizen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(32)
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 38))
                .foregroundStyle(.secondary)
            Text("Nichts gefunden")
                .font(.headline)
            Text("Zu „\(query)“ gibt es keinen Eintrag.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Ein Treffer in der Ergebnisliste.
struct SearchResultRow: View {
    let result: AppStore.SearchResult
    let subject: Subject?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let subject {
                SubjectBadge(subject: subject, width: 42)
            } else {
                Image(systemName: "note.text")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(width: 42, height: 26)
                    .background(Color(.tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: AppTheme.badgeCornerRadius))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(result.title)
                    .foregroundStyle(result.isDone ? Color.secondary : Color.primary)
                    .strikethrough(result.isDone, color: .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(result.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if result.isDone {
                Image(systemName: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
    }
}
