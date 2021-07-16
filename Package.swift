// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-NIO-LIFX-Impl",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "Swift-NIO-LIFX-Impl",
            targets: ["Swift-NIO-LIFX-Impl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(name: "swift-nio-lifx", url: "https://github.com/PSchmiedmayer/Swift-NIO-LIFX.git", .branch("develop"))
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Swift-NIO-LIFX-Impl",
            dependencies: [
                .product(name: "NIOLIFX", package: "swift-nio-lifx"),
                .product(name: "Logging", package: "swift-log")
            ]
        )
    ]
)
