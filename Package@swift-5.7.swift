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
    dependencies: [
        .package(url: "https://github.com/space-code/atomic", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/space-code/typhoon", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/WeTransfer/Mocker", .upToNextMajor(from: "3.0.1")),
    ],
    targets: [
        .target(
            name: "NetworkLayer",
            dependencies: [
                "NetworkLayerInterfaces",
                .product(name: "Atomic", package: "atomic"),
                .product(name: "Typhoon", package: "typhoon"),
            ]
        ),
        .target(
            name: "NetworkLayerInterfaces",
            dependencies: [
                .product(name: "Typhoon", package: "typhoon"),
            ]
        ),
        .testTarget(
            name: "NetworkLayerTests",
            dependencies: [
                "NetworkLayer",
                .product(name: "Mocker", package: "Mocker"),
                .product(name: "Typhoon", package: "typhoon"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
