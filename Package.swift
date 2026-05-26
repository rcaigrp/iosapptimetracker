// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "IOSAppTimeTracker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IOSAppTimeTracker",
            targets: ["IOSAppTimeTracker"]),
        .executable(
            name: "iosapptimetracker",
            targets: ["iosapptimetracker"])
    ],
    targets: [
        .target(
            name: "IOSAppTimeTracker",
            dependencies: [],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "iosapptimetracker",
            dependencies: ["IOSAppTimeTracker"],
            path: "Sources/CLI"
        ),
        .testTarget(
            name: "IOSAppTimeTrackerTests",
            dependencies: ["IOSAppTimeTracker"],
            path: "Tests/AppTests"
        )
    ]
)