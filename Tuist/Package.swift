// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    @preconcurrency import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Demo",
    dependencies: [
        .package(path: "../."),
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulRouting.git", from: "5.3.6")
    ]
)
