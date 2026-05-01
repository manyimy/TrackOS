import Vapor
import Fluent

struct BudgetController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let budgets = routes.grouped("budgets")
        budgets.get(use: list)
        budgets.post(use: create)
        budgets.group(":budgetID") { b in
            b.put(use: update)
            b.delete(use: delete)
        }
    }

    func list(req: Request) async throws -> [BudgetResponse] {
        let userID = try req.userPayload.userID
        return try await Budget.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
            .map(\.response)
    }

    func create(req: Request) async throws -> BudgetResponse {
        let userID = try req.userPayload.userID
        let body = try req.content.decode(BudgetRequest.self)
        let budget = Budget(userID: userID, categoryID: body.categoryID,
                            limitAmount: body.limitAmount, period: body.period, startsAt: body.startsAt)
        try await budget.save(on: req.db)
        return budget.response
    }

    func update(req: Request) async throws -> BudgetResponse {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("budgetID", as: UUID.self),
              let budget = try await Budget.query(on: req.db)
                .filter(\.$id == id).filter(\.$user.$id == userID).first()
        else { throw Abort(.notFound) }
        let body = try req.content.decode(BudgetRequest.self)
        budget.limitAmount = body.limitAmount
        budget.period = body.period
        budget.startsAt = body.startsAt
        budget.$category.id = body.categoryID
        try await budget.save(on: req.db)
        return budget.response
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("budgetID", as: UUID.self),
              let budget = try await Budget.query(on: req.db)
                .filter(\.$id == id).filter(\.$user.$id == userID).first()
        else { throw Abort(.notFound) }
        try await budget.delete(on: req.db)
        return .noContent
    }
}

struct BudgetRequest: Content {
    var categoryID: UUID?
    var limitAmount: Double
    var period: String
    var startsAt: Date
}

struct BudgetResponse: Content {
    var id: UUID
    var categoryID: UUID?
    var limitAmount: Double
    var period: String
    var startsAt: Date
    var updatedAt: Date?
}

private extension Budget {
    var response: BudgetResponse {
        BudgetResponse(id: id!, categoryID: $category.id,
                       limitAmount: limitAmount, period: period,
                       startsAt: startsAt, updatedAt: updatedAt)
    }
}
