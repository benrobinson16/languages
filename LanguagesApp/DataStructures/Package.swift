// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataStructures",
    platforms: [
        .iOS(.v16),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "DataStructures",
            targets: ["DataStructures"]
        ),
    ],
    dependencies: [
        // None.
    ],
    targets: [
        .target(
            name: "DataStructures",
            dependencies: []
        ),
        .testTarget(
            name: "DataStructuresTests",
            dependencies: ["DataStructures"]
        ),
    ]
)
