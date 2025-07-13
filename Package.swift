// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "quick-form",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "QuickForm",
            targets: ["QuickForm"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.3"),
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.10.2")
    ],
    targets: [
        .macro(
            name: "QuickFormMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "QuickForm",
            dependencies: [
                "QuickFormMacros"
            ]
        ),
        .testTarget(
            name: "QuickFormTests",
            dependencies: [
                "QuickForm",
                "QuickFormMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "ViewInspector", package: "viewinspector")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
