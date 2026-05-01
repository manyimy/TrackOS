import Fluent

struct CreateCategories: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("categories")
            .id()
            .field("user_id",    .uuid,   .required, .references("users", "id", onDelete: .cascade))
            .field("name",       .string, .required)
            .field("color_hex",  .string, .required)
            .field("symbol_name",.string, .required)
            .field("sort_order", .int,    .required)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("categories").delete()
    }
}
