// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-nio-lifx-impl",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "swift-lifx-discovery",
            targets: ["swift-lifx-discovery"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(name: "swift-nio-lifx", url: "https://github.com/PSchmiedmayer/Swift-NIO-LIFX.git", .branch("develop")),
        .package(name: "swift-device-discovery", url: "https://github.com/hendesi/SwiftDeviceDiscovery.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "swift-lifx-discovery",
            dependencies: [
                .product(name: "NIOLIFX", package: "swift-nio-lifx"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
