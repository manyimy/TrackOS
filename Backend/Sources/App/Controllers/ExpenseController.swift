import Vapor
import Fluent

struct ExpenseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let expenses = routes.grouped("expenses")
        expenses.get(use: list)
        expenses.post(use: create)
        expenses.group(":expenseID") { expense in
            expense.put(use: update)
            expense.delete(use: delete)
        }
    }

    // GET /api/v1/expenses?since=<ISO8601>
    func list(req: Request) async throws -> [ExpenseResponse] {
        let userID = try req.userPayload.userID
        var query = Expense.query(on: req.db)
            .filter(\.$user.$id == userID)

        if let sinceStr = req.query[String.self, at: "since"],
           let since = ISO8601DateFormatter().date(from: sinceStr) {
            query = query.filter(\.$updatedAt >= since)
        }

        return try await query.all().map(\.response)
    }

    // POST /api/v1/expenses
    func create(req: Request) async throws -> ExpenseResponse {
        let userID = try req.userPayload.userID
        let body = try req.content.decode(CreateExpenseRequest.self)
        let expense = Expense(
            id: body.id,
            userID: userID,
            categoryID: body.categoryID,
            amount: body.amount,
            currency: body.currency,
            merchant: body.merchant,
            occurredAt: body.occurredAt,
            source: body.source,
            note: body.note,
            receiptURL: body.receiptURL
        )
        try await expense.save(on: req.db)
        return expense.response
    }

    // PUT /api/v1/expenses/:expenseID
    func update(req: Request) async throws -> ExpenseResponse {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("expenseID", as: UUID.self),
              let expense = try await Expense.query(on: req.db)
                .filter(\.$id == id)
                .filter(\.$user.$id == userID)
                .first()
        else { throw Abort(.notFound) }

        let body = try req.content.decode(CreateExpenseRequest.self)
        expense.amount = body.amount
        expense.currency = body.currency
        expense.merchant = body.merchant
        expense.occurredAt = body.occurredAt
        expense.source = body.source
        expense.note = body.note
        expense.receiptURL = body.receiptURL
        expense.$category.id = body.categoryID
        try await expense.save(on: req.db)
        return expense.response
    }

    // DELETE /api/v1/expenses/:expenseID  (soft delete via deletedAt)
    func delete(req: Request) async throws -> HTTPStatus {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("expenseID", as: UUID.self),
              let expense = try await Expense.query(on: req.db)
                .filter(\.$id == id)
                .filter(\.$user.$id == userID)
                .first()
        else { throw Abort(.notFound) }

        expense.deletedAt = .now
        try await expense.save(on: req.db)
        return .noContent
    }
}

private extension Expense {
    var response: ExpenseResponse {
        ExpenseResponse(
            id: id!,
            categoryID: $category.id,
            amount: amount,
            currency: currency,
            merchant: merchant,
            occurredAt: occurredAt,
            source: source,
            note: note,
            receiptURL: receiptURL,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
}
