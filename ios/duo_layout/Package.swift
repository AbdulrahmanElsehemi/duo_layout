// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "duo_layout",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "duo-layout", targets: ["duo_layout"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "duo_layout",
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
