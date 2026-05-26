// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IOSAppTimeTracker",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "IOSAppTimeTracker",
            targets: ["IOSAppTimeTracker"]),
    ],
    dependencies: [
        // Add dependencies here
    ],
    targets: [
        .target(
            name: "IOSAppTimeTracker",
            dependencies: []),
        .testTarget(
            name: "IOSAppTimeTrackerTests",
            dependencies: ["IOSAppTimeTracker"]),
    ]
)