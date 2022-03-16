// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PencakeUtils",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PencakeUtils",
            targets: ["PencakeUtils"]
        ),
        .library(
            name: "PencakeParser",
            targets: ["PencakeParser"]
        ),
        .library(
            name: "PencakeBuilder",
            targets: ["PencakeBuilder"]
        ),
        .executable(
            name: "pencake",
            targets: ["PencakeCLI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/crossroadlabs/Regex",
            from: "1.2.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.2"
        ),
        .package(
            url: "https://github.com/weichsel/ZIPFoundation",
            from: "0.9.14"
        )
    ],
    targets: [
        .target(
            name: "PencakeCore"
        ),
        .target(
            name: "PencakeParser",
            dependencies: [
                "PencakeCore",
                .product(name: "Regex", package: "Regex"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .target(
            name: "PencakeBuilder",
            dependencies: [
                "PencakeCore",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .executableTarget(
            name: "PencakeCLI",
            dependencies: [
                "PencakeParser",
                "PencakeBuilder",
                .product(name:"ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "PencakeUtils",
            dependencies: ["PencakeCore", "PencakeParser", "PencakeBuilder"]
        ),
        //MARK: - Test Targets
        .testTarget(
            name: "PencakeParserTests",
            dependencies: ["PencakeParser"]
        ),
        .testTarget(
            name: "PencakeBuilderTests",
            dependencies: ["PencakeBuilder"]
        )
    ]
)
