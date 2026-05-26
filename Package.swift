// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IOSAppTimeTracker",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IOSAppTimeTracker",
            targets: ["IOSAppTimeTracker"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-data.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "IOSAppTimeTracker",
            dependencies: [
                .product(name: "SwiftData", package: "swift-data")
            ]
        )
    ]
)