import SwiftUI

/// Eine Zeile im Hausaufgabenheft: links das Kürzel des Fachs, rechts das Eingabefeld.
struct HomeworkRow: View {
    let day: Date
    let subject: Subject

    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var text: String
    @State private var isDone: Bool

    init(day: Date, subject: Subject, entry: HomeworkEntry?) {
        self.day = day
        self.subject = subject
        _text = State(initialValue: entry?.text ?? "")
        _isDone = State(initialValue: entry?.isDone ?? false)
    }

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            SubjectBadge(subject: subject)
                .padding(.top, 2)

            TextField("Hausaufgabe eintragen …", text: $text, axis: .vertical)
                .lineLimit(1...6)
                .foregroundStyle(isDone ? Color.secondary : Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasText {
                Button {
                    toggleDone()
                } label: {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isDone ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 1)
                .accessibilityLabel(isDone ? "Als offen markieren" : "Als erledigt markieren")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contextMenu {
            if hasText {
                Button {
                    toggleDone()
                } label: {
                    Label(isDone ? "Als offen markieren" : "Als erledigt markieren",
                          systemImage: isDone ? "arrow.uturn.backward" : "checkmark")
                }
                Button(role: .destructive) {
                    clear()
                } label: {
                    Label("Eintrag löschen", systemImage: "trash")
                }
            }
        }
        // Kurz nach dem Tippen speichern – nicht bei jedem einzelnen Zeichen.
        .task(id: text) {
            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }
            save()
        }
        // Beim Wegblättern oder Wegscrollen auf jeden Fall sichern.
        .onDisappear { save() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { save() }
        }
    }

    // MARK: - Aktionen

    private func save() {
        if !hasText && isDone { isDone = false }
        store.setHomeworkText(text, day: day, subjectID: subject.id)
    }

    private func toggleDone() {
        // Der Eintrag muss existieren, bevor er abgehakt werden kann.
        store.setHomeworkText(text, day: day, subjectID: subject.id)
        isDone.toggle()
        store.setHomeworkDone(isDone, day: day, subjectID: subject.id)
    }

    private func clear() {
        text = ""
        isDone = false
        store.deleteHomework(day: day, subjectID: subject.id)
    }
}

/// Farbiges Kürzel eines Fachs.
struct SubjectBadge: View {
    let subject: Subject
    var width: CGFloat = 44

    var body: some View {
        Text(subject.displayShort)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(width: width)
            .padding(.vertical, 6)
            .background(subject.color, in: RoundedRectangle(cornerRadius: AppTheme.badgeCornerRadius))
            .accessibilityLabel(subject.displayName)
    }
}
