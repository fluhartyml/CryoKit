// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CryoKit",
    platforms: [
        .iOS(.v18),
        .tvOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CryoKit",
            targets: ["CryoKit"]
        )
    ],
    targets: [
        .target(
            name: "CryoKit",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
