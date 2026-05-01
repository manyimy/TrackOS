import Foundation

public protocol BudgetServiceProtocol: Sendable {
    func current(for date: Date) async throws -> [BudgetDTO]
    func create(categoryID: UUID, limit: Decimal, period: BudgetPeriod) async throws
    func update(id: UUID, limit: Decimal) async throws
    func delete(id: UUID) async throws
}
