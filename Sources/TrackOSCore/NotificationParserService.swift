import Foundation

final class NotificationParserService {

    private let currencySymbolMap: [String: String] = [
        "$": "USD",
        "€": "EUR",
        "£": "GBP",
        "¥": "JPY",
        "₹": "INR",
        "₩": "KRW",
    ]

    func parse(notificationTitle: String, notificationBody: String) -> ParsedExpense? {
        parse(text: "\(notificationTitle) \(notificationBody)")
    }

    func parse(text: String) -> ParsedExpense? {
        guard let (amount, currency) = extractAmount(from: text) else { return nil }
        let merchant = extractMerchant(from: text) ?? "Unknown Merchant"
        let category = inferCategory(from: text, merchant: merchant)
        return ParsedExpense(
            amount: amount,
            currency: currency,
            merchant: merchant,
            category: category,
            date: Date(),
            rawText: text.trimmingCharacters(in: .whitespaces)
        )
    }

    // MARK: - Amount Extraction

    private func extractAmount(from text: String) -> (Double, String)? {
        let symbolPatterns: [(pattern: String, currency: String)] = [
            ("\\$([\\d,]+\\.?\\d{0,2})", "USD"),
            ("€([\\d,]+\\.?\\d{0,2})", "EUR"),
            ("£([\\d,]+\\.?\\d{0,2})", "GBP"),
            ("¥([\\d,]+)", "JPY"),
            ("₹([\\d,]+\\.?\\d{0,2})", "INR"),
        ]

        for (pattern, currency) in symbolPatterns {
            if let groups = firstMatch(pattern: pattern, in: text, groupCount: 1),
               let amountStr = groups.first {
                let cleaned = amountStr.replacingOccurrences(of: ",", with: "")
                if let amount = Double(cleaned), amount > 0 {
                    return (amount, currency)
                }
            }
        }

        // ISO code patterns: "150.00 USD" or "USD 150.00"
        let codePatterns = [
            "([\\d,]+\\.?\\d{0,2})\\s*(USD|EUR|GBP|CAD|AUD|CHF|JPY|INR)",
            "(USD|EUR|GBP|CAD|AUD|CHF|JPY|INR)\\s*([\\d,]+\\.?\\d{0,2})",
        ]
        for pattern in codePatterns {
            if let groups = firstMatch(pattern: pattern, in: text, groupCount: 2), groups.count == 2 {
                let (amountStr, code) = groups[0].contains(".") || groups[0].first?.isNumber == true
                    ? (groups[0], groups[1])
                    : (groups[1], groups[0])
                let cleaned = amountStr.replacingOccurrences(of: ",", with: "")
                if let amount = Double(cleaned), amount > 0 {
                    return (amount, code)
                }
            }
        }

        return nil
    }

    // MARK: - Merchant Extraction

    private func extractMerchant(from text: String) -> String? {
        let patterns = [
            // "at MERCHANT" — most common bank format
            "\\bat\\s+([A-Za-z][A-Za-z0-9\\s&'\\-\\.\\*]{1,40}?)(?=\\s+(?:for|on|with|was|is|–|\\.|,)|\\s*$)",
            // "to MERCHANT" — payment apps
            "\\bto\\s+([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=\\s+(?:for|of|completed|was|–|\\.|,)|\\s*$)",
            // "from MERCHANT"
            "\\bfrom\\s+([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=\\s+(?:for|of|–|\\.|,)|\\s*$)",
            // "purchase/payment/charge at MERCHANT"
            "(?:purchase|payment|charge|transaction)\\s+at\\s+([A-Za-z][A-Za-z0-9\\s&'\\-\\.]{1,40}?)(?=\\s|$)",
            // "MERCHANT:" prefix (notification title format)
            "^([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=:)",
        ]

        for pattern in patterns {
            if let groups = firstMatch(pattern: pattern, in: text, groupCount: 1),
               let merchant = groups.first {
                let trimmed = merchant.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    return trimmed
                }
            }
        }
        return nil
    }

    // MARK: - Category Inference

    private func inferCategory(from text: String, merchant: String) -> ExpenseCategory {
        let haystack = "\(text) \(merchant)".lowercased()

        let rules: [(ExpenseCategory, [String])] = [
            (.food, ["restaurant", "café", "cafe", "coffee", "starbucks", "mcdonald", "burger", "pizza",
                     "sushi", "taco", "doordash", "ubereats", "grubhub", "chipotle", "subway"]),
            (.groceries, ["grocery", "groceries", "supermarket", "whole foods", "trader joe",
                          "kroger", "safeway", "publix", "costco", "aldi", "walmart", "target"]),
            (.transport, ["uber", "lyft", "taxi", "transit", "metro", "subway trip", "bus", "train",
                          "parking", "gas station", "shell", "chevron", "bp", "exxon", "mobil"]),
            (.travel, ["airline", "hotel", "airbnb", "booking.com", "expedia", "marriott",
                       "hilton", "hyatt", "delta", "united airlines", "american airlines", "southwest"]),
            (.shopping, ["amazon", "ebay", "etsy", "zara", "h&m", "nike", "adidas", "apple store",
                         "best buy", "ikea", "uniqlo"]),
            (.entertainment, ["netflix", "spotify", "hulu", "disney+", "apple tv", "youtube premium",
                               "cinema", "movie", "theater", "concert", "ticketmaster", "steam"]),
            (.health, ["pharmacy", "cvs", "walgreens", "hospital", "clinic", "doctor", "dental",
                       "medical", "health", "optometrist", "urgent care"]),
            (.utilities, ["electric", "water bill", "internet", "at&t", "verizon", "t-mobile",
                          "comcast", "xfinity", "pg&e", "con edison"]),
            (.subscriptions, ["subscription", "membership", "monthly plan", "annual plan", "renewal",
                               "premium", "pro plan"]),
            (.housing, ["rent", "mortgage", "hoa", "property", "lease"]),
        ]

        for (category, keywords) in rules {
            if keywords.contains(where: { haystack.contains($0) }) {
                return category
            }
        }
        return .other
    }

    // MARK: - Regex Helpers

    private func firstMatch(pattern: String, in text: String, groupCount: Int) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }

        var groups: [String] = []
        for i in 1...groupCount {
            guard i < match.numberOfRanges,
                  let groupRange = Range(match.range(at: i), in: text) else { continue }
            groups.append(String(text[groupRange]))
        }
        return groups.isEmpty ? nil : groups
    }
}
