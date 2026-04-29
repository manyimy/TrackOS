import Foundation
import Domain

public final class BudgetService: BudgetServiceProtocol {

    private let budgetRepo: BudgetRepository
    private let expenseRepo: ExpenseRepository

    public init(budgetRepo: BudgetRepository, expenseRepo: ExpenseRepository) {
        self.budgetRepo = budgetRepo
        self.expenseRepo = expenseRepo
    }

    public func current(for date: Date) async throws -> [BudgetDTO] {
        let budgets = try await budgetRepo.all()
        var result: [BudgetDTO] = []
        for budget in budgets {
            guard let category = budget.category else { continue }
            let interval = budget.period.interval(containing: date)
            let spent = try await expenseRepo.total(in: interval, categoryID: category.id)
            result.append(BudgetDTO(
                id: budget.id,
                categoryID: category.id,
                categoryName: category.name,
                limit: budget.limitAmount,
                spent: spent,
                currency: budget.currency,
                period: budget.period,
                rolloverEnabled: budget.rolloverEnabled
            ))
        }
        return result
    }

    public func create(categoryID: UUID, limit: Decimal, period: BudgetPeriod) async throws {
        try await budgetRepo.create(categoryID: categoryID, limit: limit, period: period)
    }

    public func update(id: UUID, limit: Decimal) async throws {
        try await budgetRepo.update(id: id, limit: limit)
    }

    public func delete(id: UUID) async throws {
        try await budgetRepo.delete(id: id)
    }
}

private extension BudgetPeriod {
    func interval(containing date: Date) -> DateInterval {
        let cal = Calendar.current
        switch self {
        case .daily:
            let start = cal.startOfDay(for: date)
            return DateInterval(start: start, duration: 86_400)
        case .weekly:
            let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            let start = cal.date(from: comps) ?? date
            return DateInterval(start: start, duration: 7 * 86_400)
        case .monthly:
            let comps = cal.dateComponents([.year, .month], from: date)
            let start = cal.date(from: comps) ?? date
            let end = cal.date(byAdding: .month, value: 1, to: start) ?? date
            return DateInterval(start: start, end: end)
        case .yearly:
            let comps = cal.dateComponents([.year], from: date)
            let start = cal.date(from: comps) ?? date
            let end = cal.date(byAdding: .year, value: 1, to: start) ?? date
            return DateInterval(start: start, end: end)
        }
    }
}
