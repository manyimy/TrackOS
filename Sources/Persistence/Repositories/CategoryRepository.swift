import Foundation
import SwiftData
import Domain

@ModelActor
public actor CategoryRepository {

    public func all() throws -> [Category] {
        try modelContext.fetch(FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.sortOrder)]
        ))
    }

    public func find(id: UUID) throws -> Category? {
        let predicate = #Predicate<Category> { $0.id == id }
        return try modelContext.fetch(FetchDescriptor(predicate: predicate)).first
    }

    public func create(
        name: String,
        colorHex: String,
        symbolName: String,
        sortOrder: Int = 0
    ) throws -> Category {
        let entity = Category(name: name, colorHex: colorHex, symbolName: symbolName, sortOrder: sortOrder)
        modelContext.insert(entity)
        try modelContext.save()
        return entity
    }

    public func seed(defaults: [(name: String, colorHex: String, symbolName: String)]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<Category>())
        guard existing.isEmpty else { return }
        for (idx, seed) in defaults.enumerated() {
            let cat = Category(name: seed.name, colorHex: seed.colorHex,
                               symbolName: seed.symbolName, sortOrder: idx)
            modelContext.insert(cat)
        }
        try modelContext.save()
    }

    public func nameToIDMap() throws -> [String: UUID] {
        let categories = try all()
        return Dictionary(uniqueKeysWithValues: categories.map { ($0.name, $0.id) })
    }
}
