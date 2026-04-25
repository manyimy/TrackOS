import Foundation

final class NotificationParserService {

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
        // Symbol-based patterns — ordered by specificity (multi-char symbols first)
        let symbolPatterns: [(pattern: String, currency: String)] = [
            // RM must come before bare $ to avoid partial matches
            ("RM\\s?([\\d,]+\\.?\\d{0,2})", "MYR"),
            ("\\$([\\d,]+\\.?\\d{0,2})", "USD"),
            ("€([\\d,]+\\.?\\d{0,2})", "EUR"),
            ("£([\\d,]+\\.?\\d{0,2})", "GBP"),
            // ¥ is shared by JPY and CNY — context resolved below by ISO code fallback
            ("¥([\\d,]+\\.?\\d{0,2})", "JPY"),
            ("₹([\\d,]+\\.?\\d{0,2})", "INR"),
            ("₩([\\d,]+)", "KRW"),
            ("฿([\\d,]+\\.?\\d{0,2})", "THB"),
            ("S\\$([\\d,]+\\.?\\d{0,2})", "SGD"),
            ("HK\\$([\\d,]+\\.?\\d{0,2})", "HKD"),
            ("A\\$([\\d,]+\\.?\\d{0,2})", "AUD"),
            ("C\\$([\\d,]+\\.?\\d{0,2})", "CAD"),
            // RMB text marker for CNY
            ("RMB\\s?([\\d,]+\\.?\\d{0,2})", "CNY"),
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

        // ISO code patterns: "150.00 MYR" or "MYR 150.00"
        let codes = "MYR|USD|CNY|JPY|GBP|EUR|SGD|HKD|AUD|CAD|CHF|INR|KRW|THB|IDR|TWD"
        let codePatterns = [
            "([\\d,]+\\.?\\d{0,2})\\s*(\(codes))",
            "(\(codes))\\s*([\\d,]+\\.?\\d{0,2})",
        ]
        for pattern in codePatterns {
            if let groups = firstMatch(pattern: pattern, in: text, groupCount: 2), groups.count == 2 {
                let (amountStr, code) = groups[0].first?.isNumber == true
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
            "\\bat\\s+([A-Za-z][A-Za-z0-9\\s&'\\-\\.\\*]{1,40}?)(?=\\s+(?:for|on|with|was|is|–|\\.|,)|\\s*$)",
            "\\bto\\s+([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=\\s+(?:for|of|completed|was|–|\\.|,)|\\s*$)",
            "\\bfrom\\s+([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=\\s+(?:for|of|–|\\.|,)|\\s*$)",
            "(?:purchase|payment|charge|transaction)\\s+at\\s+([A-Za-z][A-Za-z0-9\\s&'\\-\\.]{1,40}?)(?=\\s|$)",
            "^([A-Z][A-Za-z0-9\\s&'\\-\\.]{1,30}?)(?=:)",
        ]

        for pattern in patterns {
            if let groups = firstMatch(pattern: pattern, in: text, groupCount: 1),
               let merchant = groups.first {
                let trimmed = merchant.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        return nil
    }

    // MARK: - Category Inference

    private func inferCategory(from text: String, merchant: String) -> ExpenseCategory {
        let haystack = "\(text) \(merchant)".lowercased()

        let rules: [(ExpenseCategory, [String])] = [
            (.food, [
                // Global
                "restaurant", "café", "cafe", "coffee", "starbucks", "mcdonald", "burger",
                "pizza", "sushi", "taco", "doordash", "ubereats", "grubhub", "chipotle",
                // Malaysia / SEA
                "grabfood", "foodpanda", "mamak", "kopitiam", "nasi lemak", "dim sum",
                "old town", "secret recipe", "marrybrown", "myburgerlab",
            ]),
            (.groceries, [
                // Global
                "grocery", "groceries", "supermarket", "walmart", "costco", "aldi",
                // Malaysia
                "jaya grocer", "village grocer", "cold storage", "giant", "tesco", "aeon",
                "mydin", "99 speedmart", "mercato", "ben's independent",
                // China
                "hema", "freshippo",
            ]),
            (.transport, [
                // Global
                "uber", "lyft", "taxi", "parking", "gas station", "shell", "petrol",
                // Malaysia
                "grab", "rapidkl", "mrt", "lrt", "monorail", "rapidpenang", "bas",
                "petronas", "bhp", "caltex", "touch 'n go", "touchngo", "plus highway",
                // China
                "didi", "meituan taxi",
            ]),
            (.travel, [
                "airline", "hotel", "airbnb", "booking.com", "expedia", "agoda",
                "airasia", "malaysia airlines", "mas", "malindo", "firefly",
                "marriott", "hilton", "shangri-la", "mandarin oriental",
            ]),
            (.shopping, [
                // Global
                "amazon", "ebay", "etsy", "zara", "h&m", "nike", "adidas", "ikea", "uniqlo",
                // Malaysia / SEA
                "shopee", "lazada", "zalora", "parkson", "isetan", "suria klcc",
                "mid valley", "pavilion", "sunway",
                // China
                "taobao", "tmall", "jd.com", "pinduoduo",
            ]),
            (.entertainment, [
                "netflix", "spotify", "hulu", "disney+", "apple tv", "youtube premium",
                "cinema", "movie", "theater", "concert", "ticketmaster", "steam",
                // Malaysia
                "tgv", "gsc", "mbo cinema", "astro",
            ]),
            (.health, [
                "pharmacy", "hospital", "clinic", "doctor", "dental", "medical",
                // Malaysia
                "guardian", "watsons", "caring pharmacy", "columbia asia", "kpj",
                "pantai hospital", "sunway medical",
            ]),
            (.utilities, [
                "electric", "water", "internet",
                // Malaysia
                "tnb", "unifi", "maxis", "celcom", "digi", "u mobile", "time dotcom",
                "syabas", "indah water",
                // Global
                "at&t", "verizon", "t-mobile", "comcast",
            ]),
            (.subscriptions, [
                "subscription", "membership", "monthly plan", "annual plan", "renewal", "premium",
            ]),
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
