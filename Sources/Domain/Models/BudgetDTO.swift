import Foundation

public struct BudgetDTO: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let categoryID: UUID
    public let categoryName: String
    public let limit: Decimal
    public let spent: Decimal
    public let currency: CurrencyCode
    public let period: BudgetPeriod
    public let rolloverEnabled: Bool

    public var percentUsed: Double {
        guard limit > 0 else { return 0 }
        let ratio = (spent as NSDecimalNumber).doubleValue / (limit as NSDecimalNumber).doubleValue
        return min(ratio, 1.0)
    }

    public var remaining: Decimal { max(.zero, limit - spent) }
    public var isExceeded: Bool { spent > limit }

    public init(
        id: UUID,
        categoryID: UUID,
        categoryName: String,
        limit: Decimal,
        spent: Decimal,
        currency: CurrencyCode,
        period: BudgetPeriod,
        rolloverEnabled: Bool
    ) {
        self.id = id
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.limit = limit
        self.spent = spent
        self.currency = currency
        self.period = period
        self.rolloverEnabled = rolloverEnabled
    }
}
