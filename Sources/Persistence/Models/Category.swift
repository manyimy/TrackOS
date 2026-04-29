import Foundation
import SwiftData

@Model
public final class Category {
    @Attribute(.unique) public var id: UUID = UUID()
    public var name: String = ""
    public var colorHex: String = "#A1A1AA"
    public var symbolName: String = "questionmark.circle"
    public var sortOrder: Int = 0
    public var isArchived: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \Expense.category)
    public var expenses: [Expense]? = []

    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        symbolName: String,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.sortOrder = sortOrder
    }
}
