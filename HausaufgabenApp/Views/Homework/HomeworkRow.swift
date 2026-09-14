import SwiftUI

/// Eine Zeile im Hausaufgabenheft: links das Kürzel des Fachs, daneben das
/// Eingabefeld – und rechts der Haken zum Abhaken, wenn die Aufgabe fertig ist.
///
/// Solange nichts eingetragen ist, steht dort stattdessen „nichts auf“:
/// damit lässt sich für jedes Fach einzeln festhalten, dass es nichts
/// aufgegeben hat.
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

    /// Ist für dieses Fach „nichts auf“ vermerkt?
    private var isFree: Bool {
        store.isNoHomework(day: day, subjectID: subject.id)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            SubjectBadge(subject: subject, dimmed: !hasText && !isFree)
                .padding(.top, 2)

            if isFree {
                // Für dieses Fach ist nichts aufgegeben.
                Text("Keine Hausaufgaben")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 3)
            } else {
                TextField("Hausaufgabe eintragen …", text: $text, axis: .vertical)
                    .lineLimit(1...6)
                    .foregroundStyle(isDone ? Color.secondary : Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            trailingControl
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

    // MARK: - Das Bedienelement rechts

    @ViewBuilder
    private var trailingControl: some View {
        if isFree {
            // Vermerk wieder aufheben.
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    store.setNoHomework(false, day: day, subjectID: subject.id)
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("„Keine Hausaufgaben“ für \(subject.displayName) aufheben")

        } else if hasText {
            // Abhaken, wenn die Aufgabe fertig ist.
            Button {
                toggleDone()
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isDone ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 1)
            .accessibilityLabel(isDone
                                ? "\(subject.displayName) als offen markieren"
                                : "\(subject.displayName) als erledigt markieren")

        } else {
            // Nichts eingetragen: für dieses Fach „nichts auf“ vermerken.
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    store.setNoHomework(true, day: day, subjectID: subject.id)
                }
            } label: {
                Text("nichts auf")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 1)
            .accessibilityLabel("In \(subject.displayName) ist nichts aufgegeben")
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

/// Farbiges Kürzel eines Fachs – helle Fläche, kräftige Schrift.
struct SubjectBadge: View {
    let subject: Subject
    var width: CGFloat = 44
    /// Blasser, solange zu diesem Fach noch nichts eingetragen ist.
    var dimmed: Bool = false

    var body: some View {
        Text(subject.displayShort)
            .font(.caption.weight(.bold))
            .foregroundStyle(subject.tint)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(width: width)
            .padding(.vertical, 6)
            .background(subject.fill, in: RoundedRectangle(cornerRadius: AppTheme.badgeCornerRadius))
            .opacity(dimmed ? 0.55 : 1)
            .accessibilityLabel(subject.displayName)
    }
}
