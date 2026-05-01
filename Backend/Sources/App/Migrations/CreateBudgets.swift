import Fluent

struct CreateBudgets: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("budgets")
            .id()
            .field("user_id",      .uuid,   .required, .references("users", "id", onDelete: .cascade))
            .field("category_id",  .uuid,   .references("categories", "id", onDelete: .setNull))
            .field("limit_amount", .double, .required)
            .field("period",       .string, .required)
            .field("starts_at",    .datetime, .required)
            .field("updated_at",   .datetime)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("budgets").delete()
    }
}
