import Foundation

public enum DomainError: Error, Sendable {
    case invalidAmount
    case invalidMerchant
    case fxUnavailable
    case budgetNotFound
    case expenseNotFound
    case categoryNotFound
}
