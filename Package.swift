// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v7),
        .tvOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "NetworkLayer", targets: ["NetworkLayer"]),
        .library(name: "NetworkLayerInterfaces", targets: ["NetworkLayerInterfaces"]),
        .library(name: "NetworkLayerMock", targets: ["NetworkLayerMock"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "NetworkLayer", dependencies: ["NetworkLayerInterfaces"]),
        .target(name: "NetworkLayerInterfaces", dependencies: []),
        .target(name: "NetworkLayerMock", dependencies: ["NetworkLayerInterfaces"]),
        .testTarget(name: "NetworkLayerTests", dependencies: ["NetworkLayer"]),
    ]
)
