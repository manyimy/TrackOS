import Fluent

struct CreateExpenses: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("expenses")
            .id()
            .field("user_id",      .uuid,     .required, .references("users", "id", onDelete: .cascade))
            .field("category_id",  .uuid,     .references("categories", "id", onDelete: .setNull))
            .field("amount",       .double,   .required)
            .field("currency",     .string,   .required)
            .field("merchant",     .string,   .required)
            .field("occurred_at",  .datetime, .required)
            .field("source",       .string,   .required)
            .field("note",         .string)
            .field("receipt_url",  .string)
            .field("updated_at",   .datetime)
            .field("deleted_at",   .datetime)
            .create()

        // Index for delta-sync queries
        try await db.query(sql: """
            CREATE INDEX idx_expenses_user_updated
            ON expenses (user_id, updated_at);
        """)
    }

    func revert(on db: Database) async throws {
        try await db.schema("expenses").delete()
    }
}
