// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TrackOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TrackOS",
            targets: ["TrackOS"]
        ),
    ],
    targets: [
        .target(
            name: "TrackOS",
            path: "Sources/TrackOS"
        ),
        .testTarget(
            name: "TrackOSTests",
            dependencies: ["TrackOS"],
            path: "Tests/TrackOSTests"
        ),
    ]
)
