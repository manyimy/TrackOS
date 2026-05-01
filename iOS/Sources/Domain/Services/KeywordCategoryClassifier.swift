import Foundation

/// Keyword-based classifier. Configure with `updateCategories(_:)` after seeding the store.
public final class KeywordCategoryClassifier: CategoryClassifierProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private var nameToID: [String: UUID] = [:]

    private static let rules: [(keywords: [String], category: String)] = [
        (["restaurant", "café", "cafe", "coffee", "starbucks", "mcdonald", "burger",
          "pizza", "sushi", "taco", "food", "eat", "dining", "mamak", "kopitiam",
          "grabfood", "foodpanda", "deliveroo", "ubereats", "doordash"],        "Food & Dining"),
        (["grab", "uber", "lyft", "taxi", "bus", "train", "mrt", "lrt", "parking",
          "petrol", "shell", "petronas", "bhp", "caltex", "rapidkl", "rapidpenang"], "Transportation"),
        (["amazon", "shopee", "lazada", "mall", "market", "nike", "zara", "h&m",
          "uniqlo", "ikea", "adidas", "shopping", "ebay", "taobao"],              "Shopping"),
        (["electric", "water", "internet", "telco", "maxis", "celcom", "digi",
          "unifi", "tnb", "syabas", "bill", "utilities", "at&t", "verizon"],      "Bills & Utilities"),
        (["clinic", "hospital", "pharmacy", "doctor", "dental", "medical",
          "health", "guardian", "watsons", "caring"],                             "Health"),
        (["netflix", "spotify", "hulu", "disney", "cinema", "tgv", "gsc",
          "movie", "concert", "steam", "game", "entertainment", "astro"],         "Entertainment"),
        (["rent", "mortgage", "hoa", "property", "lease", "hotel",
          "airbnb", "booking.com", "agoda"],                                       "Housing"),
        (["salary", "income", "bonus", "dividend", "transfer"],                   "Other"),
    ]

    public init() {}

    public func updateCategories(_ map: [String: UUID]) {
        lock.withLock { nameToID = map }
    }

    public func predict(merchant: String, note: String) -> UUID? {
        let haystack = "\(merchant) \(note)".lowercased()
        let snapshot = lock.withLock { nameToID }
        for rule in Self.rules {
            if rule.keywords.contains(where: { haystack.contains($0) }) {
                if let id = snapshot[rule.category] { return id }
            }
        }
        return snapshot["Other"]
    }
}
