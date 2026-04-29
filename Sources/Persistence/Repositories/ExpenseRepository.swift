import Foundation
import SwiftData
import Domain

@ModelActor
public actor ExpenseRepository {

    public func create(_ new: NewExpense) throws {
        let entity = Expense(
            amount: new.amount,
            currency: new.currency,
            merchant: new.merchant,
            note: new.note,
            occurredAt: new.occurredAt
        )
        if let categoryID = new.categoryID {
            let pred = #Predicate<Category> { $0.id == categoryID }
            entity.category = try modelContext.fetch(FetchDescriptor(predicate: pred)).first
        }
        modelContext.insert(entity)
        try modelContext.save()
    }

    public func update(id: UUID, with new: NewExpense) throws {
        let pred = #Predicate<Expense> { $0.id == id }
        guard let entity = try modelContext.fetch(FetchDescriptor(predicate: pred)).first
        else { throw DomainError.expenseNotFound }
        entity.amount = new.amount
        entity.currencyRaw = new.currency.rawValue
        entity.merchant = new.merchant
        entity.note = new.note
        entity.occurredAt = new.occurredAt
        entity.updatedAt = .now
        if let categoryID = new.categoryID {
            let catPred = #Predicate<Category> { $0.id == categoryID }
            entity.category = try modelContext.fetch(FetchDescriptor(predicate: catPred)).first
        }
        try modelContext.save()
    }

    public func delete(id: UUID) throws {
        let pred = #Predicate<Expense> { $0.id == id }
        try modelContext.delete(model: Expense.self, where: pred)
        try modelContext.save()
    }

    public func fetch(in range: DateInterval) throws -> [Expense] {
        let start = range.start
        let end = range.end
        let pred = #Predicate<Expense> { e in
            e.occurredAt >= start && e.occurredAt <= end
        }
        return try modelContext.fetch(FetchDescriptor(
            predicate: pred,
            sortBy: [SortDescriptor(\.occurredAt, order: .reverse)]
        ))
    }

    public func total(in range: DateInterval, categoryID: UUID?) throws -> Decimal {
        let expenses = try fetch(in: range)
        let filtered = categoryID.map { id in expenses.filter { $0.category?.id == id } } ?? expenses
        return filtered.reduce(Decimal.zero) { $0 + $1.amount }
    }
}
