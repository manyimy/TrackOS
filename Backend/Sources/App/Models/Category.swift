import Fluent
import Vapor

final class Category: Model, @unchecked Sendable {
    static let schema = "categories"

    @ID(key: .id)                  var id: UUID?
    @Parent(key: "user_id")        var user: User
    @Field(key: "name")            var name: String
    @Field(key: "color_hex")       var colorHex: String
    @Field(key: "symbol_name")     var symbolName: String
    @Field(key: "sort_order")      var sortOrder: Int
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, name: String,
         colorHex: String, symbolName: String, sortOrder: Int) {
        self.id = id
        self.$user.id = userID
        self.name = name
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.sortOrder = sortOrder
    }
}
