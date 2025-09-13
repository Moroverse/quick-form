// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Demo",
    dependencies: [
        //.package(path: "../."),
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulRouting.git", from: "5.3.6"),
        //.package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.3"),
    ]
)
