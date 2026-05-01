import Fluent
import Vapor

final class Budget: Model, @unchecked Sendable {
    static let schema = "budgets"

    @ID(key: .id)               var id: UUID?
    @Parent(key: "user_id")     var user: User
    @OptionalParent(key: "category_id") var category: Category?
    @Field(key: "limit_amount") var limitAmount: Double
    @Field(key: "period")       var period: String
    @Field(key: "starts_at")    var startsAt: Date
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, categoryID: UUID? = nil,
         limitAmount: Double, period: String, startsAt: Date) {
        self.id = id
        self.$user.id = userID
        self.$category.id = categoryID
        self.limitAmount = limitAmount
        self.period = period
        self.startsAt = startsAt
    }
}
