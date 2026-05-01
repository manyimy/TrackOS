import Vapor
import Fluent

struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cats = routes.grouped("categories")
        cats.get(use: list)
        cats.post(use: create)
        cats.group(":categoryID") { c in
            c.put(use: update)
            c.delete(use: delete)
        }
    }

    func list(req: Request) async throws -> [CategoryResponse] {
        let userID = try req.userPayload.userID
        return try await Category.query(on: req.db)
            .filter(\.$user.$id == userID)
            .sort(\.$sortOrder)
            .all()
            .map(\.response)
    }

    func create(req: Request) async throws -> CategoryResponse {
        let userID = try req.userPayload.userID
        let body = try req.content.decode(CategoryRequest.self)
        let cat = Category(userID: userID, name: body.name,
                           colorHex: body.colorHex, symbolName: body.symbolName, sortOrder: body.sortOrder)
        try await cat.save(on: req.db)
        return cat.response
    }

    func update(req: Request) async throws -> CategoryResponse {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("categoryID", as: UUID.self),
              let cat = try await Category.query(on: req.db)
                .filter(\.$id == id).filter(\.$user.$id == userID).first()
        else { throw Abort(.notFound) }
        let body = try req.content.decode(CategoryRequest.self)
        cat.name = body.name; cat.colorHex = body.colorHex
        cat.symbolName = body.symbolName; cat.sortOrder = body.sortOrder
        try await cat.save(on: req.db)
        return cat.response
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let userID = try req.userPayload.userID
        guard let id = req.parameters.get("categoryID", as: UUID.self),
              let cat = try await Category.query(on: req.db)
                .filter(\.$id == id).filter(\.$user.$id == userID).first()
        else { throw Abort(.notFound) }
        try await cat.delete(on: req.db)
        return .noContent
    }
}

struct CategoryRequest: Content {
    var name: String
    var colorHex: String
    var symbolName: String
    var sortOrder: Int
}

struct CategoryResponse: Content {
    var id: UUID
    var name: String
    var colorHex: String
    var symbolName: String
    var sortOrder: Int
    var updatedAt: Date?
}

private extension Category {
    var response: CategoryResponse {
        CategoryResponse(id: id!, name: name, colorHex: colorHex,
                         symbolName: symbolName, sortOrder: sortOrder, updatedAt: updatedAt)
    }
}
