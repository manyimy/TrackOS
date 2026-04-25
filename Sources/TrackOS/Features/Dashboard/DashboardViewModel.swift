import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {

    func currentMonthExpenses(_ expenses: [Expense]) -> [Expense] {
        let start = Date().startOfMonth
        return expenses.filter { $0.date >= start }
    }

    func monthlyTotal(_ expenses: [Expense]) -> Double {
        currentMonthExpenses(expenses).reduce(0) { $0 + $1.amount }
    }

    /// Returns the most-used currency among this month's expenses, falling back to MYR.
    func dominantCurrency(_ expenses: [Expense]) -> String {
        var counts: [String: Int] = [:]
        for expense in currentMonthExpenses(expenses) {
            counts[expense.currency, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "MYR"
    }

    func categoryBreakdown(_ expenses: [Expense]) -> [(category: ExpenseCategory, total: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for expense in currentMonthExpenses(expenses) {
            totals[expense.expenseCategory, default: 0] += expense.amount
        }
        return totals.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }
}
