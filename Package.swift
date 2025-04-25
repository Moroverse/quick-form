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
        //        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.2"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.0"),
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.10.1")
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
            ],
            plugins: [
                //                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
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
