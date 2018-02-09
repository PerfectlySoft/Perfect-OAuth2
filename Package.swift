// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "OAuth2",
    products: [
        .library(
            name: "OAuth2",
            targets: ["OAuth2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-Session.git", from: "3.1.3"),
    ],
    targets: [
        .target(
            name: "OAuth2",
            dependencies: ["PerfectSession"]),
        .testTarget(
            name: "OAuth2Tests",
            dependencies: ["OAuth2"]),
    ]
)
