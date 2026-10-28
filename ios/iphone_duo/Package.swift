// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iphone_duo",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "iphone-duo", targets: ["iphone_duo"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "iphone_duo",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // It declares nothing: the plugin tracks nothing, collects
                // nothing, and calls none of the APIs Apple asks reasons for.
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
