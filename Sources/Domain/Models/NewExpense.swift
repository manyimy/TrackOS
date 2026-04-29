import Foundation

public struct NewExpense: Sendable {
    public let amount: Decimal
    public let currency: CurrencyCode
    public let categoryID: UUID?
    public let accountID: UUID?
    public let merchant: String
    public let note: String
    public let occurredAt: Date

    public init(
        amount: Decimal,
        currency: CurrencyCode = .myr,
        categoryID: UUID? = nil,
        accountID: UUID? = nil,
        merchant: String,
        note: String = "",
        occurredAt: Date = .now
    ) {
        self.amount = amount
        self.currency = currency
        self.categoryID = categoryID
        self.accountID = accountID
        self.merchant = merchant
        self.note = note
        self.occurredAt = occurredAt
    }
}
