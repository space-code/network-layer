// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v7),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "NetworkLayer", targets: ["NetworkLayer"]),
        .library(name: "NetworkLayerInterfaces", targets: ["NetworkLayerInterfaces"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkLayer",
            dependencies: ["NetworkLayerInterfaces"]
        ),
        .target(
            name: "NetworkLayerInterfaces",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkLayerTests",
            dependencies: [
                "NetworkLayer",
            ]
        ),
    ]
)
