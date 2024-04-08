// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShExec",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "shexec",
            targets: ["ShExec"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMajor(from: "0.9.2"))
    ],
    targets: [
        .executableTarget(
            name: "ShExec",
            dependencies: [.product(name: "Commander", package: "Commander")])
    ])
