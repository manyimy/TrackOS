import Foundation

public struct DailySpend: Identifiable, Sendable {
    public let id: Date
    public let date: Date
    public let amount: Decimal
    public let currency: CurrencyCode

    public init(date: Date, amount: Decimal, currency: CurrencyCode) {
        self.id = date
        self.date = date
        self.amount = amount
        self.currency = currency
    }
}

public struct CategorySpend: Identifiable, Sendable {
    public let id: UUID
    public let categoryID: UUID
    public let categoryName: String
    public let categoryColor: String
    public let categorySymbol: String
    public let amount: Decimal
    public let currency: CurrencyCode

    public init(
        categoryID: UUID,
        categoryName: String,
        categoryColor: String,
        categorySymbol: String,
        amount: Decimal,
        currency: CurrencyCode
    ) {
        self.id = categoryID
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.categoryColor = categoryColor
        self.categorySymbol = categorySymbol
        self.amount = amount
        self.currency = currency
    }
}

public struct SmartTip: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let body: String
    public let icon: String

    public init(title: String, body: String, icon: String) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.icon = icon
    }
}
