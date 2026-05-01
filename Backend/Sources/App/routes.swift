import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api", "v1")

    // Public
    try api.register(collection: AuthController())

    // Authenticated
    let protected = api.grouped(JWTAuthMiddleware())
    try protected.register(collection: ExpenseController())
    try protected.register(collection: BudgetController())
    try protected.register(collection: CategoryController())
    try protected.register(collection: SyncController())

    // Webhooks (HMAC-signed, not JWT)
    let webhooks = app.grouped("webhooks")
    try webhooks.register(collection: WebhookController())
}
