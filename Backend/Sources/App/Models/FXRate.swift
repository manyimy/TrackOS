import Fluent
import Vapor

final class FXRate: Model, @unchecked Sendable {
    static let schema = "fx_rates"

    @ID(key: .id)               var id: UUID?
    @Field(key: "base")         var base: String
    @Field(key: "quote")        var quote: String
    @Field(key: "rate")         var rate: Double
    @Field(key: "fetched_at")   var fetchedAt: Date

    init() {}

    init(id: UUID? = nil, base: String, quote: String, rate: Double, fetchedAt: Date = .now) {
        self.id = id
        self.base = base
        self.quote = quote
        self.rate = rate
        self.fetchedAt = fetchedAt
    }
}
