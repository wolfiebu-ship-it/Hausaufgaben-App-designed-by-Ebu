import SwiftUI

/// Die Tür vor der App: Solange gesperrt ist, gibt es nur das Anmeldebild.
/// Ist die Anmeldung ausgeschaltet, merkt man von dieser Ansicht nichts.
struct AppGateView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var lock: LockController
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            if lock.isLocked {
                LockView()
                    .transition(.opacity)
            } else {
                RootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: lock.isLocked)
        .onAppear { lock.start(with: store.lock) }
        .onChange(of: store.lock) { _, newValue in
            lock.update(with: newValue)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                lock.didBecomeActive()
            default:
                // Vor dem Zusperren sichern – danach ist die Hausaufgaben-
                // ansicht weg und kann selbst nichts mehr schreiben.
                store.saveNow()
                lock.willResignActive()
            }
        }
    }
}
