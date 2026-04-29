import Foundation

public enum Tab: Hashable, Sendable {
    case dashboard
    case insights
    case budgets
}

public enum DeepLink: Equatable, Sendable {
    case addExpense(prefillText: String?)
}
