// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntelligentMarking",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "IntelligentMarking",
            targets: ["IntelligentMarking"]
        ),
    ],
    dependencies: [
        .package(name: "DataStructures", path: "./DataStructures")
    ],
    targets: [
        .target(
            name: "IntelligentMarking",
            dependencies: [
                "DataStructures"
            ]
        ),
        .testTarget(
            name: "IntelligentMarkingTests",
            dependencies: ["IntelligentMarking"]
        ),
    ]
)
