import Foundation
import SwiftData
import Domain

@Model
public final class Budget {
    @Attribute(.unique) public var id: UUID = UUID()
    public var limitAmount: Decimal = Decimal.zero
    public var currencyRaw: String = CurrencyCode.myr.rawValue
    public var periodRaw: String = BudgetPeriod.monthly.rawValue
    public var rolloverEnabled: Bool = false
    public var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify) public var category: Category?

    public var currency: CurrencyCode { CurrencyCode(rawValue: currencyRaw) ?? .myr }
    public var period: BudgetPeriod { BudgetPeriod(rawValue: periodRaw) ?? .monthly }

    public init(
        id: UUID = UUID(),
        limit: Decimal,
        currency: CurrencyCode = .myr,
        period: BudgetPeriod = .monthly,
        rolloverEnabled: Bool = false
    ) {
        self.id = id
        self.limitAmount = limit
        self.currencyRaw = currency.rawValue
        self.periodRaw = period.rawValue
        self.rolloverEnabled = rolloverEnabled
    }
}
