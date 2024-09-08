// swift-tools-version: 5.10
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
        .package(url: "https://github.com/pointfreeco/swift-navigation.git", from: "2.2.0")
    ]
)
