import Fluent

struct CreateFXRates: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("fx_rates")
            .id()
            .field("base",       .string,   .required)
            .field("quote",      .string,   .required)
            .field("rate",       .double,   .required)
            .field("fetched_at", .datetime, .required)
            .unique(on: "base", "quote")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("fx_rates").delete()
    }
}
