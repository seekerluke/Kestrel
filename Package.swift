// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Kestrel",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Kestrel",
            targets: ["Kestrel"]
        ),
    ],
    targets: [
        .target(
            name: "Kestrel",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
