// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWLocationManager",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "WWLocationManager", targets: ["WWLocationManager"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWLocationManager", dependencies: []),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
