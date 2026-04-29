import Foundation

public struct ExpenseDTO: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let amount: Decimal
    public let currency: CurrencyCode
    public let amountInBaseCurrency: Decimal
    public let categoryID: UUID?
    public let categoryName: String?
    public let categoryColor: String?
    public let categorySymbol: String?
    public let merchant: String
    public let note: String
    public let occurredAt: Date

    public init(
        id: UUID,
        amount: Decimal,
        currency: CurrencyCode,
        amountInBaseCurrency: Decimal,
        categoryID: UUID?,
        categoryName: String?,
        categoryColor: String?,
        categorySymbol: String?,
        merchant: String,
        note: String,
        occurredAt: Date
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.amountInBaseCurrency = amountInBaseCurrency
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.categoryColor = categoryColor
        self.categorySymbol = categorySymbol
        self.merchant = merchant
        self.note = note
        self.occurredAt = occurredAt
    }
}
