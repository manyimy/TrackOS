import Vapor
import Fluent

// Delta-sync: iOS sends local changes + last-sync timestamp,
// server returns everything that changed server-side since that timestamp.
struct SyncController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("sync", use: sync)
    }

    func sync(req: Request) async throws -> SyncResponse {
        let userID = try req.userPayload.userID
        let body = try req.content.decode(SyncRequest.self)

        // 1. Apply client upserts
        for dto in body.expenses {
            if let existing = try await Expense.query(on: req.db)
                .filter(\.$id == dto.id ?? UUID())
                .filter(\.$user.$id == userID)
                .first() {
                existing.amount = dto.amount
                existing.merchant = dto.merchant
                existing.currency = dto.currency
                existing.occurredAt = dto.occurredAt
                existing.note = dto.note
                existing.$category.id = dto.categoryID
                try await existing.save(on: req.db)
            } else {
                let e = Expense(id: dto.id, userID: userID, categoryID: dto.categoryID,
                                amount: dto.amount, currency: dto.currency, merchant: dto.merchant,
                                occurredAt: dto.occurredAt, source: dto.source, note: dto.note,
                                receiptURL: dto.receiptURL)
                try await e.save(on: req.db)
            }
        }

        // 2. Apply client deletes (soft)
        for id in body.deletedIDs {
            if let e = try await Expense.query(on: req.db)
                .filter(\.$id == id).filter(\.$user.$id == userID).first() {
                e.deletedAt = .now
                try await e.save(on: req.db)
            }
        }

        // 3. Return server-side changes since client's last sync
        let serverChanges = try await Expense.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$updatedAt >= body.since)
            .all()

        let deletedIDs = serverChanges.compactMap { $0.deletedAt != nil ? $0.id : nil }
        let upserts = serverChanges.filter { $0.deletedAt == nil }.map(\.response)

        return SyncResponse(expenses: upserts, deletedIDs: deletedIDs, serverTime: .now)
    }
}

private extension Expense {
    var response: ExpenseResponse {
        ExpenseResponse(id: id!, categoryID: $category.id, amount: amount,
                        currency: currency, merchant: merchant, occurredAt: occurredAt,
                        source: source, note: note, receiptURL: receiptURL,
                        updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
