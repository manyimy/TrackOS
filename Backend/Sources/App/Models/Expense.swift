import Fluent
import Vapor

final class Expense: Model, @unchecked Sendable {
    static let schema = "expenses"

    @ID(key: .id)                    var id: UUID?
    @Parent(key: "user_id")          var user: User
    @OptionalParent(key: "category_id") var category: Category?
    @Field(key: "amount")            var amount: Double
    @Field(key: "currency")          var currency: String
    @Field(key: "merchant")          var merchant: String
    @Field(key: "occurred_at")       var occurredAt: Date
    @Field(key: "source")            var source: String
    @OptionalField(key: "note")      var note: String?
    @OptionalField(key: "receipt_url") var receiptURL: String?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @OptionalField(key: "deleted_at") var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userID: UUID,
        categoryID: UUID? = nil,
        amount: Double,
        currency: String,
        merchant: String,
        occurredAt: Date,
        source: String = "manual",
        note: String? = nil,
        receiptURL: String? = nil
    ) {
        self.id = id
        self.$user.id = userID
        self.$category.id = categoryID
        self.amount = amount
        self.currency = currency
        self.merchant = merchant
        self.occurredAt = occurredAt
        self.source = source
        self.note = note
        self.receiptURL = receiptURL
    }
}
