import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)           var id: UUID?
    @Field(key: "apple_sub") var appleSub: String
    @Field(key: "email")     var email: String?
    @Field(key: "home_currency") var homeCurrency: String
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Children(for: \.$user) var expenses: [Expense]
    @Children(for: \.$user) var budgets: [Budget]
    @Children(for: \.$user) var categories: [Category]

    init() {}

    init(id: UUID? = nil, appleSub: String, email: String? = nil, homeCurrency: String = "MYR") {
        self.id = id
        self.appleSub = appleSub
        self.email = email
        self.homeCurrency = homeCurrency
    }
}
