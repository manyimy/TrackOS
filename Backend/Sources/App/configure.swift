import Vapor
import Fluent
import FluentPostgresDriver
import JWT
import QueuesRedisDriver

public func configure(_ app: Application) async throws {
    // MARK: - Database
    app.databases.use(
        .postgres(configuration: .init(
            hostname: Environment.get("DB_HOST")     ?? "localhost",
            port:     Int(Environment.get("DB_PORT") ?? "5432") ?? 5432,
            username: Environment.get("DB_USER")     ?? "trackos",
            password: Environment.get("DB_PASSWORD") ?? "trackos",
            database: Environment.get("DB_NAME")     ?? "trackos",
            tls: app.environment == .production ? .require(try .makeClientConfiguration()) : .disable
        )),
        as: .psql
    )

    // MARK: - Redis / Queues
    try app.queues.use(.redis(url: Environment.get("REDIS_URL") ?? "redis://localhost:6379"))

    // MARK: - JWT
    let jwtSecret = Environment.get("JWT_SECRET") ?? "dev-secret-change-me"
    await app.jwt.keys.add(hmac: .init(from: jwtSecret), digestAlgorithm: .sha256)

    // MARK: - Migrations
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateDevices())
    app.migrations.add(CreateCategories())
    app.migrations.add(CreateExpenses())
    app.migrations.add(CreateBudgets())
    app.migrations.add(CreateFXRates())
    try await app.autoMigrate()

    // MARK: - Middleware
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(RateLimitMiddleware(requestsPerMinute: 120))

    // MARK: - Routes
    try routes(app)

    // MARK: - Queue workers
    try app.queues.startInProcessJobs(on: .default)
}
