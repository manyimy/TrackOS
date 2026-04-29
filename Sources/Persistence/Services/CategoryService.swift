import Foundation
import Domain

public final class CategoryService: CategoryServiceProtocol {

    private let repo: CategoryRepository

    public init(repo: CategoryRepository) {
        self.repo = repo
    }

    public func fetchAll() async throws -> [CategoryDTO] {
        let entities = try await repo.all()
        return entities.map {
            CategoryDTO(id: $0.id, name: $0.name, colorHex: $0.colorHex,
                        symbolName: $0.symbolName, sortOrder: $0.sortOrder)
        }
    }
}
