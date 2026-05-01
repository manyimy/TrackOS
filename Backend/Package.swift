// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrackOSBackend",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git",        from: "4.99.0"),
        .package(url: "https://github.com/vapor/fluent.git",       from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.0"),
        .package(url: "https://github.com/vapor/jwt.git",          from: "4.2.2"),
        .package(url: "https://github.com/vapor/queues.git",        from: "1.14.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.0"),
        // Shared domain types from the iOS package
        .package(path: "../iOS"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor",                   package: "vapor"),
                .product(name: "Fluent",                  package: "fluent"),
                .product(name: "FluentPostgresDriver",    package: "fluent-postgres-driver"),
                .product(name: "JWT",                     package: "jwt"),
                .product(name: "Queues",                  package: "queues"),
                .product(name: "QueuesRedisDriver",       package: "queues-redis-driver"),
                .product(name: "Domain",                  package: "TrackOS"),
            ],
            path: "Sources/App",
            swiftSettings: [.unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        ),
    ]
)
