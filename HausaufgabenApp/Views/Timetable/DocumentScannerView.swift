import SwiftUI
import VisionKit

/// Apples Dokumentenscanner: erkennt den Papierrand, entzerrt und schneidet zu.
/// Läuft nur auf einem echten Gerät – im Simulator gibt es keine Kamera.
struct DocumentScannerView: UIViewControllerRepresentable {
    /// Liefert das aufgenommene Bild, oder `nil` bei Abbruch bzw. Fehler.
    var onFinish: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: VNDocumentCameraViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let onFinish: (UIImage?) -> Void

        init(onFinish: @escaping (UIImage?) -> Void) {
            self.onFinish = onFinish
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.pageCount > 0 ? scan.imageOfPage(at: 0) : nil
            onFinish(image)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onFinish(nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            onFinish(nil)
        }
    }

    /// Steht der Scanner auf diesem Gerät zur Verfügung?
    static var isAvailable: Bool {
        VNDocumentCameraViewController.isSupported
    }
}
