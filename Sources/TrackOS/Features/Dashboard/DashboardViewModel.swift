import Foundation

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Greeting

    var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    // MARK: - Filtering

    func filteredExpenses(_ expenses: [Expense], for period: TimePeriod) -> [Expense] {
        let start: Date
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .week:  start = cal.date(byAdding: .day, value: -7, to: now)!
        case .month: start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        case .year:  start = cal.date(from: cal.dateComponents([.year], from: now))!
        }
        return expenses.filter { $0.date >= start }
    }

    func total(_ expenses: [Expense], period: TimePeriod) -> Double {
        filteredExpenses(expenses, for: period).reduce(0) { $0 + $1.amount }
    }

    func categoryBreakdown(_ expenses: [Expense], period: TimePeriod) -> [(category: ExpenseCategory, total: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for expense in filteredExpenses(expenses, for: period) {
            totals[expense.expenseCategory, default: 0] += expense.amount
        }
        return totals.map { ($0.key, $0.value) }.sorted { $0.total > $1.total }
    }

    // MARK: - Currency

    func dominantCurrency(_ expenses: [Expense]) -> String {
        var counts: [String: Int] = [:]
        for expense in expenses { counts[expense.currency, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key ?? "MYR"
    }

    // MARK: - Date Grouping (for ExpenseListView)

    func groupedByDate(_ expenses: [Expense]) -> [(label: String, expenses: [Expense])] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let weekAgo = cal.date(byAdding: .day, value: -7, to: today)!

        var buckets: [(key: Date, label: String, items: [Expense])] = []

        for expense in expenses {
            let day = cal.startOfDay(for: expense.date)
            let label: String
            if day == today { label = "Today" }
            else if day == yesterday { label = "Yesterday" }
            else if day >= weekAgo { label = "Earlier this week" }
            else {
                let f = DateFormatter()
                f.dateFormat = "MMMM yyyy"
                label = f.string(from: expense.date)
            }

            if let idx = buckets.firstIndex(where: { $0.label == label }) {
                buckets[idx].items.append(expense)
            } else {
                buckets.append((key: day, label: label, items: [expense]))
            }
        }

        return buckets.sorted { $0.key > $1.key }.map { ($0.label, $0.items) }
    }
}
