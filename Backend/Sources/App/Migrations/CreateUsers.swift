import Fluent

struct CreateUsers: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("users")
            .id()
            .field("apple_sub",     .string,  .required)
            .field("email",         .string)
            .field("home_currency", .string,  .required)
            .field("created_at",    .datetime)
            .unique(on: "apple_sub")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("users").delete()
    }
}
