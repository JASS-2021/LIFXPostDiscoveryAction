// swift-tools-version:5.5

//
// This source file is part of the Apodini Template open source project
//
// SPDX-FileCopyrightText: 2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import PackageDescription

let package = Package(
    name: "swift-nio-lifx-impl",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "swift-lifx-discovery",
            targets: ["swift-lifx-discovery"]),
        .library(name: "LifxDiscoveryActions", targets: ["LifxDiscoveryActions"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(name: "swift-nio-lifx", url: "https://github.com/PSchmiedmayer/Swift-NIO-LIFX.git", .upToNextMinor(from: "0.1.2")),
        .package(name: "swift-device-discovery", url: "https://github.com/Apodini/SwiftDeviceDiscovery.git", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "swift-lifx-discovery",
            dependencies: [
                .product(name: "NIOLIFX", package: "swift-nio-lifx"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "LifxDiscoveryCommon")
            ]
        ),
        .target(
            name: "LifxDiscoveryActions",
            dependencies: [
                .product(name: "SwiftDeviceDiscovery", package: "swift-device-discovery"),
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
