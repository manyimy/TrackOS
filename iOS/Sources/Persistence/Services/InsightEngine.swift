import Foundation
import Domain

public final class InsightEngine: InsightEngineProtocol {

    private let expenseRepo: ExpenseRepository
    private let budgetRepo: BudgetRepository

    public init(expenseRepo: ExpenseRepository, budgetRepo: BudgetRepository) {
        self.expenseRepo = expenseRepo
        self.budgetRepo = budgetRepo
    }

    public func weeklyTrend(endingOn date: Date) async throws -> [DailySpend] {
        let cal = Calendar.current
        let end = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: date) ?? date)
        let start = cal.date(byAdding: .day, value: -6, to: end) ?? end
        let interval = DateInterval(start: start, end: end)
        let expenses = try await expenseRepo.fetch(in: interval)

        var dailyMap: [Date: Decimal] = [:]
        for expense in expenses {
            let day = cal.startOfDay(for: expense.occurredAt)
            dailyMap[day, default: .zero] += expense.amount
        }

        return (0..<7).compactMap { offset -> DailySpend? in
            guard let day = cal.date(byAdding: .day, value: offset, to: start) else { return nil }
            return DailySpend(date: day, amount: dailyMap[day] ?? .zero, currency: .myr)
        }
    }

    public func categoryBreakdown(in range: DateInterval) async throws -> [CategorySpend] {
        let expenses = try await expenseRepo.fetch(in: range)
        var map: [UUID: (name: String, color: String, symbol: String, total: Decimal)] = [:]
        for expense in expenses {
            guard let cat = expense.category else { continue }
            var entry = map[cat.id] ?? (cat.name, cat.colorHex, cat.symbolName, .zero)
            entry.total += expense.amount
            map[cat.id] = entry
        }
        return map.map { id, value in
            CategorySpend(categoryID: id, categoryName: value.name,
                          categoryColor: value.color, categorySymbol: value.symbol,
                          amount: value.total, currency: .myr)
        }.sorted { $0.amount > $1.amount }
    }

    public func smartTips(for date: Date) async throws -> [SmartTip] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        let start = cal.date(from: comps) ?? date
        let end = cal.date(byAdding: .month, value: 1, to: start) ?? date
        let interval = DateInterval(start: start, end: end)
        let total = try await expenseRepo.total(in: interval, categoryID: nil)
        let budgets = try await budgetRepo.all()

        var tips: [SmartTip] = []

        if total == 0 {
            tips.append(SmartTip(
                title: "Start Tracking",
                body: "Log your first expense to get personalised spending insights.",
                icon: "plus.circle"
            ))
        }

        for budget in budgets {
            guard let cat = budget.category else { continue }
            let spent = try await expenseRepo.total(in: interval, categoryID: cat.id)
            let ratio = budget.limitAmount > 0
                ? (spent as NSDecimalNumber).doubleValue / (budget.limitAmount as NSDecimalNumber).doubleValue
                : 0
            if ratio >= 0.9 {
                tips.append(SmartTip(
                    title: "\(cat.name) budget \(ratio >= 1 ? "exceeded" : "almost full")",
                    body: "\(cat.currency.format(spent)) of \(cat.currency.format(budget.limitAmount)) used this \(budget.period.displayName.lowercased()).",
                    icon: ratio >= 1 ? "exclamationmark.triangle" : "exclamationmark.circle"
                ))
            }
        }

        return tips
    }
}

private extension Category {
    var currency: CurrencyCode { .myr }
}
