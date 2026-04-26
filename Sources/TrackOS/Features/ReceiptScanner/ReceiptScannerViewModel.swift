import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class ReceiptScannerViewModel: ObservableObject {
    @Published var scannedData: ReceiptOCRService.ReceiptData?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showImagePicker = false

    private let ocrService = ReceiptOCRService()

#if canImport(UIKit)
    func processImage(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            scannedData = try await ocrService.recognizeText(in: image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
#endif

    func clear() {
        scannedData = nil
        errorMessage = nil
    }
}
