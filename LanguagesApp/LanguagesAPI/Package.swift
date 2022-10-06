// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LanguagesAPI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LanguagesAPI",
            targets: ["LanguagesAPI"]
        ),
    ],
    dependencies: [
        // None.
    ],
    targets: [
        .target(
            name: "LanguagesAPI",
            dependencies: []
        ),
        .testTarget(
            name: "LanguagesAPITests",
            dependencies: ["LanguagesAPI"]
        ),
    ]
)
