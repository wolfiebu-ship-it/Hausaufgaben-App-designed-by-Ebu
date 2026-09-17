import SwiftUI
import PhotosUI

/// Der Weg vom Foto zum eigenen Stundenplan:
/// erklären → aufnehmen → erkennen → prüfen → übernehmen.
struct TimetableScanFlow: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private enum Stage {
        case intro
        case working
        case review(ScanResult)
        case nothingFound
    }

    @State private var stage: Stage = .intro
    @State private var showCamera = false
    @State private var showPhotos = false
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .intro:        introView
                case .working:      workingView
                case .nothingFound: nothingFoundView
                case .review(let result):
                    ScanReviewView(result: result) { lessons in
                        store.replaceTimetable(with: lessons, times: result.times)
                        dismiss()
                    } onRetry: {
                        stage = .intro
                    }
                }
            }
            .navigationTitle("Stundenplan scannen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            DocumentScannerView { image in
                showCamera = false
                if let image { verarbeite(image) }
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showPhotos, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            stage = .working
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    stage = .nothingFound
                    return
                }
                photoItem = nil
                verarbeite(image)
            }
        }
    }

    // MARK: - Schritte

    private var introView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 34))
                        .foregroundStyle(.tint)
                    Text("Fotografiere deinen Stundenplan ab – Homy trägt Fächer und Unterrichtszeiten von allein ein.")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Tipp(nummer: 1, text: "Leg den Plan flach hin und sorge für gutes Licht.")
                    Tipp(nummer: 2, text: "Halte die Kamera gerade darüber, sodass alle Wochentage und Stunden im Bild sind – auch die Spalte mit den Uhrzeiten links.")
                    Tipp(nummer: 3, text: "Gedruckte Pläne werden deutlich besser erkannt als handgeschriebene.")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))

                VStack(spacing: 10) {
                    if DocumentScannerView.isAvailable {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Mit der Kamera scannen", systemImage: "camera.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }

                    Button {
                        showPhotos = true
                    } label: {
                        Label("Foto aus der Mediathek wählen", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text("Die Erkennung läuft vollständig auf deinem Gerät – das Foto verlässt es nicht. Fächer, die Homy noch nicht kennt, werden dabei gleich angelegt. Danach siehst du das fertige Ergebnis und kannst es noch ändern, bevor es übernommen wird.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var workingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Stundenplan wird gelesen …")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var nothingFoundView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.viewfinder")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("Auf dem Bild war nichts zu lesen")
                .font(.headline)

            Text("Versuch es noch einmal mit mehr Licht, näher dran und möglichst gerade von oben. Du kannst den Stundenplan auch weiterhin von Hand eintragen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button("Noch einmal versuchen") { stage = .intro }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding(32)
        .frame(maxWidth: 460)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Erkennung anstoßen

    private func verarbeite(_ image: UIImage) {
        stage = .working
        Task {
            var result = await TimetableRecognizer.recognize(image: image, subjects: store.subjects)
            guard !result.cells.isEmpty else {
                stage = .nothingFound
                return
            }

            // Alles, was auf dem Foto stand, wird gleich eingetragen: Für jedes
            // Kürzel ohne passendes Fach wird eins angelegt, und die Felder
            // werden ihm zugeordnet. Nachsehen kann man trotzdem gleich – aber
            // von Hand nachtragen muss niemand mehr.
            if !result.unknownCodes.isEmpty {
                let (zuordnung, neue) = store.createSubjects(forCodes: result.unknownCodes)
                result.createdSubjects = neue
                for index in result.cells.indices where result.cells[index].subjectID == nil {
                    let code = result.cells[index].code.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let id = zuordnung[code] ?? zuordnung[code.uppercased()] {
                        result.cells[index].subjectID = id
                    }
                }
                result.unknownCodes = []
            }

            stage = .review(result)
        }
    }
}

private struct Tipp: View {
    let nummer: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(nummer)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.accentColor, in: Circle())

            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}
