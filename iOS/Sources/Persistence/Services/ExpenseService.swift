import Foundation
import Domain

public final class ExpenseService: ExpenseServiceProtocol {

    private let repo: ExpenseRepository
    private let fx: any FXServiceProtocol
    private let classifier: any CategoryClassifierProtocol
    private let sync: any RemoteSyncServiceProtocol

    public init(
        repo: ExpenseRepository,
        fx: any FXServiceProtocol,
        classifier: any CategoryClassifierProtocol,
        sync: any RemoteSyncServiceProtocol = NoOpSyncService()
    ) {
        self.repo = repo
        self.fx = fx
        self.classifier = classifier
        self.sync = sync
    }

    public func create(_ new: NewExpense) async throws {
        try ExpenseValidation.validate(new)
        var validated = new
        if new.categoryID == nil, let predicted = classifier.predict(merchant: new.merchant, note: new.note) {
            validated = NewExpense(
                amount: new.amount, currency: new.currency,
                categoryID: predicted, accountID: new.accountID,
                merchant: new.merchant, note: new.note, occurredAt: new.occurredAt
            )
        }
        try await repo.create(validated)
        Task { await sync.sync() }
    }

    public func update(id: UUID, with new: NewExpense) async throws {
        try ExpenseValidation.validate(new)
        try await repo.update(id: id, with: new)
        Task { await sync.sync() }
    }

    public func delete(id: UUID) async throws {
        try await repo.delete(id: id)
        Task { await sync.sync() }
    }

    public func fetch(in range: DateInterval) async throws -> [ExpenseDTO] {
        let entities = try await repo.fetch(in: range)
        return entities.map(ExpenseDTO.init)
    }

    public func total(in range: DateInterval, categoryID: UUID?) async throws -> Decimal {
        try await repo.total(in: range, categoryID: categoryID)
    }
}
