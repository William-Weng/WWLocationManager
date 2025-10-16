// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWLocationManager",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "WWLocationManager", targets: ["WWLocationManager"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWLocationManager", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
