// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LanguagesUI",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LanguagesUI",
            targets: ["LanguagesUI"]
        ),
    ],
    dependencies: [
        // None.
    ],
    targets: [
        .target(
            name: "LanguagesUI",
            dependencies: []
        ),
        .testTarget(
            name: "LanguagesUITests",
            dependencies: ["LanguagesUI"]
        ),
    ]
)
