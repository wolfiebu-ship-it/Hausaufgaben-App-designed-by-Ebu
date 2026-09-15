import SwiftUI

/// Das Anmeldebild: ohne den richtigen Code kommt man nicht in die App.
///
/// Wer den Schnellstart eingeschaltet hat, wird gleich beim Öffnen von
/// Face ID bzw. Touch ID begrüßt und muss gar nichts tippen.
struct LockView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var lock: LockController

    @State private var code = ""
    @State private var wobble = 0
    @State private var message: String?
    @State private var showsHint = false
    @State private var isAskingBiometrics = false
    @State private var didAskAutomatically = false
    @State private var now = Date()

    private let clock = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var settings: LockSettings { store.lock }
    private var biometrics: BiometricKind { BiometricAuth.availableKind() }
    private var usesBiometrics: Bool { settings.useBiometrics && biometrics.isAvailable }

    private var greeting: String {
        let name = store.profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Willkommen zurück" : "Hallo, \(name)!"
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: 12)

                HomyWordmark(markSize: 78, showsSubtitle: false)

                Text(greeting)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 14)

                dots
                    .padding(.top, 26)

                statusLine
                    .padding(.top, 10)

                Spacer(minLength: 16)

                keypad
                    .frame(maxWidth: 320)

                forgotButton
                    .padding(.top, 16)

                Spacer(minLength: 12)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .onReceive(clock) { value in
            // Nur während der Wartezeit ticken – sonst bliebe die Ansicht
            // dauerhaft jede Sekunde in Bewegung.
            guard lock.isPaused else { return }
            now = value
            lock.clearExpiredPause()
        }
        .task {
            // Beim Öffnen einmal von selbst nach Face ID fragen.
            guard !didAskAutomatically else { return }
            didAskAutomatically = true
            guard usesBiometrics, !lock.isPaused else { return }
            await askBiometrics()
        }
        .alert("Code vergessen?", isPresented: $showsHint) {
            Button("Verstanden", role: .cancel) { }
        } message: {
            Text(forgotText)
        }
    }

    // MARK: - Teile

    private var background: some View {
        ZStack {
            Color(.systemGroupedBackground)
            DoodleCanvas()
        }
        .ignoresSafeArea()
    }

    /// Ein Punkt je Ziffer – gefüllt, sobald getippt.
    private var dots: some View {
        HStack(spacing: 16) {
            ForEach(0..<max(4, settings.codeLength), id: \.self) { index in
                Circle()
                    .strokeBorder(Color.secondary.opacity(0.45), lineWidth: 1.5)
                    .background(
                        Circle().fill(index < code.count ? Color.accentColor : .clear)
                    )
                    .frame(width: 15, height: 15)
            }
        }
        .offset(x: wobbleOffset)
        .animation(.spring(response: 0.18, dampingFraction: 0.25), value: wobble)
        .accessibilityLabel("\(code.count) von \(settings.codeLength) Ziffern eingegeben")
    }

    /// Bei einem falschen Code wackeln die Punkte kurz.
    private var wobbleOffset: CGFloat {
        wobble == 0 ? 0 : (wobble % 2 == 0 ? 9 : -9)
    }

    @ViewBuilder
    private var statusLine: some View {
        if lock.isPaused {
            Text("Zu viele Versuche. Noch \(lock.remainingPause(at: now)) Sekunden warten.")
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        } else if let message {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        } else {
            Text("Code eingeben")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var keypad: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 18) {
                    ForEach(1...3, id: \.self) { column in
                        digitKey("\(row * 3 + column)")
                    }
                }
            }

            HStack(spacing: 18) {
                biometricKey
                digitKey("0")
                deleteKey
            }
        }
    }

    private func digitKey(_ digit: String) -> some View {
        Button {
            append(digit)
        } label: {
            Text(digit)
                .font(.system(size: 30, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
                .frame(width: 74, height: 74)
                .background(Color(.secondarySystemGroupedBackground), in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(lock.isPaused)
        .opacity(lock.isPaused ? 0.45 : 1)
        .accessibilityLabel("Ziffer \(digit)")
    }

    @ViewBuilder
    private var biometricKey: some View {
        if usesBiometrics {
            Button {
                Task { await askBiometrics() }
            } label: {
                Image(systemName: biometrics.symbol)
                    .font(.system(size: 28))
                    .foregroundStyle(.tint)
                    .frame(width: 74, height: 74)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(lock.isPaused || isAskingBiometrics)
            .opacity(lock.isPaused ? 0.45 : 1)
            .accessibilityLabel("Mit \(biometrics.title) öffnen")
        } else {
            Color.clear.frame(width: 74, height: 74)
        }
    }

    private var deleteKey: some View {
        Button {
            guard !code.isEmpty else { return }
            Haptics.tap()
            code.removeLast()
            message = nil
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 24))
                .foregroundStyle(code.isEmpty ? .secondary : .primary)
                .frame(width: 74, height: 74)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(code.isEmpty || lock.isPaused)
        .accessibilityLabel("Letzte Ziffer löschen")
    }

    private var forgotButton: some View {
        Button("Code vergessen?") {
            showsHint = true
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private var forgotText: String {
        let hint = settings.trimmedHint
        let base = hint.isEmpty
            ? "Für diesen Code ist kein Merkzettel hinterlegt."
            : "Dein Merkzettel: „\(hint)“"
        return base + "\n\nDer Code selbst ist nirgends gespeichert, auch nicht in der App – er lässt sich deshalb nicht anzeigen. Wenn du ihn wirklich nicht mehr weißt, hilft nur, Homy zu löschen und neu zu laden. Dabei gehen die Hausaufgaben mit verloren, wenn du keine Sicherung hast."
    }

    // MARK: - Eingabe

    private func append(_ digit: String) {
        guard !lock.isPaused, code.count < settings.codeLength else { return }
        Haptics.tap()
        message = nil
        code.append(digit)

        if code.count == settings.codeLength {
            check()
        }
    }

    private func check() {
        if lock.submit(code: code) {
            Haptics.success()
            code = ""
            message = nil
        } else {
            Haptics.error()
            withAnimation { wobble += 1 }
            message = lock.isPaused ? nil : "Falscher Code. Versuch es noch einmal."
            // Kurz stehen lassen, damit man sieht, dass alle Punkte voll waren.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                code = ""
            }
        }
    }

    private func askBiometrics() async {
        guard !isAskingBiometrics, !lock.isPaused else { return }
        isAskingBiometrics = true
        let reason = "Homy öffnen"
        let ok = await BiometricAuth.authenticate(reason: reason)
        isAskingBiometrics = false
        if ok {
            Haptics.success()
            code = ""
            lock.unlock()
        }
    }
}
