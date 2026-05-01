import Fluent

struct CreateDevices: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("devices")
            .id()
            .field("user_id",      .uuid,    .required, .references("users", "id", onDelete: .cascade))
            .field("push_token",   .string,  .required)
            .field("last_sync_at", .datetime)
            .field("created_at",   .datetime)
            .unique(on: "push_token")
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("devices").delete()
    }
}
