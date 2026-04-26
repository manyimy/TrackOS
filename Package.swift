// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrackOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),   // SwiftData requires macOS 14+; TrackOSCore + tests run on macOS CI
    ],
    products: [
        .library(name: "TrackOSCore", targets: ["TrackOSCore"]),
        .library(name: "TrackOS", targets: ["TrackOS"]),
    ],
    targets: [
        // Pure-Foundation core: models, enums, notification parser.
        // No UIKit / SwiftUI / Vision — compiles on macOS and Linux.
        .target(
            name: "TrackOSCore",
            path: "Sources/TrackOSCore"
        ),

        // iOS-only layer: SwiftUI views, SwiftData, Vision OCR, UserNotifications.
        .target(
            name: "TrackOS",
            dependencies: ["TrackOSCore"],
            path: "Sources/TrackOS"
        ),

        // Unit tests target only TrackOSCore so they run without a simulator.
        .testTarget(
            name: "TrackOSTests",
            dependencies: ["TrackOSCore"],
            path: "Tests/TrackOSTests"
        ),
    ]
)
