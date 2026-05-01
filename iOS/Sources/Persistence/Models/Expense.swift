import Foundation
import SwiftData
import Domain

@Model
public final class Expense {
    @Attribute(.unique) public var id: UUID = UUID()
    public var amount: Decimal = Decimal.zero
    public var currencyRaw: String = CurrencyCode.myr.rawValue
    public var merchant: String = ""
    public var note: String = ""
    public var occurredAt: Date = Date()
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()

    @Relationship(deleteRule: .nullify) public var category: Category?
    @Relationship(deleteRule: .nullify) public var account: Account?

    public var currency: CurrencyCode {
        CurrencyCode(rawValue: currencyRaw) ?? .myr
    }

    public init(
        id: UUID = UUID(),
        amount: Decimal,
        currency: CurrencyCode = .myr,
        merchant: String,
        note: String = "",
        occurredAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.currencyRaw = currency.rawValue
        self.merchant = merchant
        self.note = note
        self.occurredAt = occurredAt
    }
}
