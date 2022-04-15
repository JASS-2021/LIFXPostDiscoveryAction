// swift-tools-version:5.5

//
// This source file is part of the JASS open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the JASS project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import PackageDescription

let package = Package(
    name: "LIFXPostDiscoveryAction",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "swift-lifx-discovery",
            targets: ["swift-lifx-discovery"]
        ),
        .library(name: "LifxDiscoveryActions", targets: ["LifxDiscoveryActions"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(url: "https://github.com/PSchmiedmayer/Swift-NIO-LIFX.git", .upToNextMinor(from: "0.1.2")),
        .package(url: "https://github.com/Apodini/SwiftDeviceDiscovery.git", .upToNextMinor(from: "0.1.3"))
    ],
    targets: [
        .executableTarget(
            name: "swift-lifx-discovery",
            dependencies: [
                .product(name: "NIOLIFX", package: "Swift-NIO-LIFX"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "LifxDiscoveryCommon")
            ]
        ),
        .target(
            name: "LifxDiscoveryActions",
            dependencies: [
                .product(name: "SwiftDeviceDiscovery", package: "SwiftDeviceDiscovery"),
                .target(name: "LifxDiscoveryCommon")
            ],
            resources: [
                .copy("Resources/setup-script")
            ]
        ),
        .target(
            name: "LifxDiscoveryCommon",
            dependencies: [
                .product(name: "NIOLIFX", package: "swift-nio-lifx")
            ]
        )
    ]
)
