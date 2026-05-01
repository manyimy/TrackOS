import Foundation
import SwiftData
import Domain

@ModelActor
public actor BudgetRepository {

    public func all() throws -> [Budget] {
        try modelContext.fetch(FetchDescriptor<Budget>())
    }

    public func find(id: UUID) throws -> Budget? {
        let pred = #Predicate<Budget> { $0.id == id }
        return try modelContext.fetch(FetchDescriptor(predicate: pred)).first
    }

    public func create(categoryID: UUID, limit: Decimal, period: BudgetPeriod) throws {
        let budget = Budget(limit: limit, period: period)
        let catPred = #Predicate<Category> { $0.id == categoryID }
        budget.category = try modelContext.fetch(FetchDescriptor(predicate: catPred)).first
        modelContext.insert(budget)
        try modelContext.save()
    }

    public func update(id: UUID, limit: Decimal) throws {
        guard let budget = try find(id: id) else { throw DomainError.budgetNotFound }
        budget.limitAmount = limit
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let pred = #Predicate<Budget> { $0.id == id }
        try modelContext.delete(model: Budget.self, where: pred)
        try modelContext.save()
    }
}
