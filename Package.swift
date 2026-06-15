// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftBlocks",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftBlocks",
            targets: ["SwiftBlocks"]
        )
    ],
    targets: [
        .target(
            name: "SwiftBlocks",
            path: "Sources/SwiftBlocks"
        )
    ]
)
