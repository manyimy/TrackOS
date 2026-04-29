import Foundation
import Observation
import Domain

@Observable
@MainActor
public final class DashboardModel {

    // MARK: - State
    public var expenses: [ExpenseDTO] = []
    public var budgets: [BudgetDTO] = []
    public var isLoading = false
    public var error: UserFacingError?
    public var selectedPeriod: Period = .month

    // MARK: - Derived
    public var totalSpent: Decimal {
        expenses.reduce(.zero) { $0 + $1.amount }
    }

    public var currency: CurrencyCode {
        expenses.first?.currency ?? .myr
    }

    public var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    // MARK: - Dependencies
    private let expenseService: any ExpenseServiceProtocol
    private let budgetService: any BudgetServiceProtocol

    public init(
        expenseService: any ExpenseServiceProtocol,
        budgetService: any BudgetServiceProtocol
    ) {
        self.expenseService = expenseService
        self.budgetService = budgetService
    }

    // MARK: - Intents
    public func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let fetchedExpenses = expenseService.fetch(in: selectedPeriod.interval)
            async let fetchedBudgets  = budgetService.current(for: Date())
            (expenses, budgets) = try await (fetchedExpenses, fetchedBudgets)
        } catch {
            self.error = UserFacingError(from: error)
        }
    }
}

// MARK: - Period

public extension DashboardModel {
    enum Period: String, CaseIterable, Sendable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var interval: DateInterval {
            let cal = Calendar.current
            let now = Date()
            switch self {
            case .week:
                let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: now))!
                return DateInterval(start: start, end: now)
            case .month:
                let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
                return DateInterval(start: start, end: now)
            case .year:
                let start = cal.date(from: cal.dateComponents([.year], from: now))!
                return DateInterval(start: start, end: now)
            }
        }
    }
}
