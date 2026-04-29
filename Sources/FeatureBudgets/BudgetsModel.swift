import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class BudgetsModel {

    // MARK: - State
    public var budgets: [BudgetDTO] = []
    public var isLoading = false
    public var error: UserFacingError?

    // MARK: - Derived
    public var exceededBudgets: [BudgetDTO] {
        budgets.filter { $0.isExceeded }
    }

    public var totalBudgeted: Decimal {
        budgets.reduce(.zero) { $0 + $1.limitAmount }
    }

    public var totalSpent: Decimal {
        budgets.reduce(.zero) { $0 + $1.spentAmount }
    }

    // MARK: - Dependencies
    private let budgetService: any BudgetServiceProtocol

    public init(budgetService: any BudgetServiceProtocol) {
        self.budgetService = budgetService
    }

    // MARK: - Intents
    public func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            budgets = try await budgetService.current(for: Date())
        } catch {
            self.error = UserFacingError(from: error)
        }
    }
}
