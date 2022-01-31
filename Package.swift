// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PencakeParser",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PencakeParserCore",
            targets: ["PencakeParserCore"]
        ),
        .executable(
            name: "pencakeparser",
            targets: ["PencakeParser"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/crossroadlabs/Regex",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.2"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PencakeParserCore",
            dependencies: ["Regex"]
        ),
        .executableTarget(
            name: "PencakeParser",
            dependencies: [
                "PencakeParserCore",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser",
                    condition: nil
                )
            ]
        ),
        .testTarget(
            name: "PencakeParserTests",
            dependencies: ["PencakeParser"]
        ),
        .testTarget(
            name: "PencakeParserCoreTests",
            dependencies: ["PencakeParserCore"]
        )
    ]
)
