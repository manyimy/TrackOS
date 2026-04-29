import Foundation

public protocol ExpenseServiceProtocol: Sendable {
    func create(_ new: NewExpense) async throws
    func update(id: UUID, with new: NewExpense) async throws
    func delete(id: UUID) async throws
    func fetch(in range: DateInterval) async throws -> [ExpenseDTO]
    func total(in range: DateInterval, categoryID: UUID?) async throws -> Decimal
}
