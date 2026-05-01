import Foundation
import SwiftData
import Domain

// Carries server-side expense data into the repository without coupling to
// the network layer's Codable types.
public struct SyncServerExpense: Sendable {
    public let id: UUID
    public let categoryID: UUID?
    public let amount: Decimal
    public let currency: CurrencyCode
    public let merchant: String
    public let note: String
    public let occurredAt: Date
    public let updatedAt: Date?
    public let isDeleted: Bool
}

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

    // Records a tombstone before deleting so the next sync can inform the server.
    public func delete(id: UUID) throws {
        let pred = #Predicate<Expense> { $0.id == id }
        try modelContext.delete(model: Expense.self, where: pred)
        modelContext.insert(SyncTombstone(expenseID: id))
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

    // MARK: - Sync support

    public func fetchModified(since date: Date) throws -> [Expense] {
        let pred = #Predicate<Expense> { $0.updatedAt >= date }
        return try modelContext.fetch(FetchDescriptor(predicate: pred))
    }

    public func fetchTombstoneIDs(since date: Date) throws -> [UUID] {
        let pred = #Predicate<SyncTombstone> { $0.deletedAt >= date }
        let tombstones = try modelContext.fetch(FetchDescriptor(predicate: pred))
        return tombstones.map(\.expenseID)
    }

    // Upserts server expenses and hard-deletes server-deleted IDs.
    public func applyServerExpenses(_ expenses: [SyncServerExpense]) throws {
        for se in expenses {
            if se.isDeleted {
                let id = se.id
                try modelContext.delete(model: Expense.self, where: #Predicate { $0.id == id })
                continue
            }
            let id = se.id
            let existing = try modelContext.fetch(
                FetchDescriptor(predicate: #Predicate<Expense> { $0.id == id })
            ).first

            if let entity = existing {
                // Only overwrite if server version is newer
                if let serverUpdated = se.updatedAt, serverUpdated > entity.updatedAt {
                    entity.amount = se.amount
                    entity.currencyRaw = se.currency.rawValue
                    entity.merchant = se.merchant
                    entity.note = se.note
                    entity.occurredAt = se.occurredAt
                    entity.updatedAt = serverUpdated
                }
            } else {
                let entity = Expense(
                    id: se.id,
                    amount: se.amount,
                    currency: se.currency,
                    merchant: se.merchant,
                    note: se.note,
                    occurredAt: se.occurredAt
                )
                if let catID = se.categoryID {
                    entity.category = try modelContext.fetch(
                        FetchDescriptor(predicate: #Predicate<Category> { $0.id == catID })
                    ).first
                }
                modelContext.insert(entity)
            }
        }
        try modelContext.save()
    }

    public func clearTombstones(ids: [UUID]) throws {
        for id in ids {
            try modelContext.delete(
                model: SyncTombstone.self,
                where: #Predicate { $0.expenseID == id }
            )
        }
        try modelContext.save()
    }
}
