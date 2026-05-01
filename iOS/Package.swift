// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrackOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Domain",            targets: ["Domain"]),
        .library(name: "Persistence",       targets: ["Persistence"]),
        .library(name: "DesignSystem",      targets: ["DesignSystem"]),
        .library(name: "FeatureDashboard",  targets: ["FeatureDashboard"]),
        .library(name: "FeatureInsights",   targets: ["FeatureInsights"]),
        .library(name: "FeatureAddExpense", targets: ["FeatureAddExpense"]),
        .library(name: "FeatureBudgets",    targets: ["FeatureBudgets"]),
        .library(name: "AppShell",          targets: ["AppShell"]),
    ],
    targets: [
        // Pure Foundation — no UIKit, no SwiftUI, no SwiftData.
        .target(name: "Domain", path: "Sources/Domain"),

        // SwiftData + CloudKit + Domain services.
        .target(name: "Persistence", dependencies: ["Domain"], path: "Sources/Persistence"),

        // SwiftUI design tokens and shared components.
        .target(name: "DesignSystem", dependencies: ["Domain"], path: "Sources/DesignSystem"),

        // Feature modules — depend on Domain + DesignSystem only.
        .target(name: "FeatureDashboard",  dependencies: ["Domain", "DesignSystem"], path: "Sources/FeatureDashboard"),
        .target(name: "FeatureInsights",   dependencies: ["Domain", "DesignSystem"], path: "Sources/FeatureInsights"),
        .target(name: "FeatureAddExpense", dependencies: ["Domain", "DesignSystem"], path: "Sources/FeatureAddExpense"),
        .target(name: "FeatureBudgets",    dependencies: ["Domain", "DesignSystem"], path: "Sources/FeatureBudgets"),

        // Thin composition shell — wires everything together.
        .target(
            name: "AppShell",
            dependencies: [
                "Domain", "Persistence", "DesignSystem",
                "FeatureDashboard", "FeatureInsights", "FeatureAddExpense", "FeatureBudgets",
            ],
            path: "Sources/AppShell"
        ),

        // ── Tests ──────────────────────────────────────────────────────────────
        .testTarget(name: "DomainTests",           dependencies: ["Domain"],           path: "Tests/DomainTests"),
        .testTarget(name: "PersistenceTests",      dependencies: ["Persistence"],      path: "Tests/PersistenceTests"),
        .testTarget(name: "FeatureAddExpenseTests",dependencies: ["FeatureAddExpense"],path: "Tests/FeatureAddExpenseTests"),
    ]
)
