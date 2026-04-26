#if os(iOS)
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Vision)
import Vision
#endif

// ReceiptData is Foundation-only so views can reference it on all platforms.
// The OCR implementation requires UIKit + Vision (iOS/iPadOS only).

final class ReceiptOCRService {

    struct ReceiptData {
        let merchant: String?
        let amount: Double?
        let currency: String
        let date: Date?
        let items: [LineItem]
        let rawText: String

        struct LineItem: Identifiable {
            let id = UUID()
            let description: String
            let amount: Double?
        }
    }

    enum OCRError: LocalizedError {
        case invalidImage
        var errorDescription: String? { "The image could not be processed for text recognition." }
    }

#if canImport(UIKit) && canImport(Vision)
    func recognizeText(in image: UIImage) async throws -> ReceiptData {
        guard let cgImage = image.cgImage else { throw OCRError.invalidImage }

        let lines: [String] = try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let strings = (request.results as? [VNRecognizedTextObservation] ?? [])
                    .compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            do {
                try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }

        return parseLines(lines)
    }
#endif

    // MARK: - Field Extraction

    private func parseLines(_ lines: [String]) -> ReceiptData {
        let rawText = lines.joined(separator: "\n")
        return ReceiptData(
            merchant: extractMerchant(from: lines),
            amount: extractTotal(from: lines).0,
            currency: extractTotal(from: lines).1,
            date: extractDate(from: lines),
            items: extractLineItems(from: lines),
            rawText: rawText
        )
    }

    private func extractMerchant(from lines: [String]) -> String? {
        for line in lines.prefix(6) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.count > 2 else { continue }
            let lowered = trimmed.lowercased()
            if lowered.contains("receipt") || lowered.contains("invoice") || lowered.contains("tel:") {
                continue
            }
            let letterRatio = Double(trimmed.filter { $0.isLetter }.count) / Double(trimmed.count)
            if letterRatio > 0.5 { return trimmed }
        }
        return nil
    }

    private func extractTotal(from lines: [String]) -> (Double?, String) {
        let totalKeywords = ["total", "amount due", "grand total", "balance due", "charge", "subtotal"]
        for line in lines.reversed() {
            let lowered = line.lowercased()
            if totalKeywords.contains(where: { lowered.contains($0) }),
               let (amount, currency) = extractAmountFromLine(line) {
                return (amount, currency)
            }
        }
        var max: Double = 0
        var currency = "MYR"
        for line in lines {
            if let (amount, curr) = extractAmountFromLine(line), amount > max {
                max = amount; currency = curr
            }
        }
        return max > 0 ? (max, currency) : (nil, "MYR")
    }

    func extractAmountFromLine(_ line: String) -> (Double, String)? {
        let patterns: [(String, String)] = [
            ("RM\\s?([\\d,]+\\.\\d{2})", "MYR"),
            ("S\\$([\\d,]+\\.\\d{2})", "SGD"),
            ("HK\\$([\\d,]+\\.\\d{2})", "HKD"),
            ("A\\$([\\d,]+\\.\\d{2})", "AUD"),
            ("C\\$([\\d,]+\\.\\d{2})", "CAD"),
            ("RMB\\s?([\\d,]+\\.?\\d{0,2})", "CNY"),
            ("\\$([\\d,]+\\.\\d{2})", "USD"),
            ("€([\\d,]+\\.\\d{2})", "EUR"),
            ("£([\\d,]+\\.\\d{2})", "GBP"),
            ("¥([\\d,]+\\.?\\d{0,2})", "JPY"),
            ("₹([\\d,]+\\.\\d{2})", "INR"),
            ("฿([\\d,]+\\.\\d{2})", "THB"),
        ]
        for (pattern, currency) in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                  match.numberOfRanges > 1,
                  let range = Range(match.range(at: 1), in: line)
            else { continue }
            let cleaned = String(line[range]).replacingOccurrences(of: ",", with: "")
            if let amount = Double(cleaned) { return (amount, currency) }
        }
        return nil
    }

    private func extractDate(from lines: [String]) -> Date? {
        let patterns = [
            "\\b(\\d{1,2})[/\\-](\\d{1,2})[/\\-](\\d{2,4})\\b",
            "\\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\\.?\\s+(\\d{1,2}),?\\s+(\\d{4})\\b",
        ]
        let formats = ["MM/dd/yyyy", "MM-dd-yyyy", "dd/MM/yyyy", "MMM dd, yyyy", "MMMM dd, yyyy",
                       "MM/dd/yy", "dd-MM-yyyy"]
        let formatter = DateFormatter()
        for line in lines {
            for pattern in patterns {
                guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                      let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
                      let range = Range(match.range, in: line)
                else { continue }
                let dateStr = String(line[range])
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateStr) { return date }
                }
            }
        }
        return nil
    }

    private func extractLineItems(from lines: [String]) -> [ReceiptData.LineItem] {
        lines.compactMap { line in
            guard let (amount, _) = extractAmountFromLine(line) else { return nil }
            let description = line
                .replacingOccurrences(of: "[$€£][\\d,]+\\.\\d{2}", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
            guard !description.isEmpty else { return nil }
            return ReceiptData.LineItem(description: description, amount: amount)
        }
    }
}
#endif
