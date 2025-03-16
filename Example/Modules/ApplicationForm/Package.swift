// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApplicationForm",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ApplicationForm",
            targets: ["ApplicationForm"]
        )
    ],
    dependencies: [
        .package(path: "../../../."),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ApplicationForm",
            dependencies: [
                "Factory",
                .product(name: "QuickForm", package: "quick-form")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
