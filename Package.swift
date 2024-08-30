// swift-tools-version:5.7
//
// The MIT License (MIT)
//
// Copyright (c) 2022 Kosei Haruyama.
//

import PackageDescription

let package = Package(
    name: "PencakeUtils",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
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
            name: "PencakeSerializer",
            targets: ["PencakeSerializer"]
        ),
        .executable(
            name: "pencake",
            targets: ["PencakeCLI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.1.1"
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
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .target(
            name: "PencakeSerializer",
            dependencies: [
                "PencakeCore",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .target(
            name: "PencakeEPUBConverter",
            dependencies: [
                "PencakeParser",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        ),
        .executableTarget(
            name: "PencakeCLI",
            dependencies: [
                "PencakeParser",
                "PencakeSerializer",
                "PencakeEPUBConverter",
                .product(name:"ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "PencakeUtils",
            dependencies: ["PencakeCore", "PencakeParser", "PencakeSerializer", "PencakeEPUBConverter"]
        ),
        //MARK: - Test Targets
        .testTarget(
            name: "PencakeParserTests",
            dependencies: ["PencakeParser"]
        ),
        .testTarget(
            name: "PencakeSerializerTests",
            dependencies: ["PencakeSerializer"]
        )
    ]
)
