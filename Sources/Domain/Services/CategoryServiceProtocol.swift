import Foundation

public protocol CategoryServiceProtocol: Sendable {
    func fetchAll() async throws -> [CategoryDTO]
}

public struct CategoryDTO: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let colorHex: String
    public let symbolName: String
    public let sortOrder: Int

    public init(id: UUID, name: String, colorHex: String, symbolName: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.sortOrder = sortOrder
    }
}
