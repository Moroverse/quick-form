// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-24 06:14 GMT.

import ProjectDescription
import ProjectDescriptionHelpers

let infoPlistUIKitAdditions: [String: Plist.Value] = [
    "UILaunchStoryboardName": "LaunchScreen.storyboard",
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
        "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
                [
                    "UISceneDelegateClassName": "AppFoundationKitDemo.SceneDelegate",
                    "UISceneConfigurationName": "Default Configuration"
                ]
            ]
        ]
    ]
]

let infoPlistSwiftUIAdditions: [String: Plist.Value] = [
    "UILaunchScreen": [
        "UIColorName": "",
        "UIImageName": ""
    ]
]

let project = Project(
    name: "ApplicationFormExample",
    packages: [
        .package(path: "../../."),
        .package(path: "../../Examples/Modules/ApplicationForm"),
        .package(url: "https://github.com/hmlongco/Factory.git", .branch("develop"))
    ],
    targets: [
        .target(
            name: "ApplicationFormExample-SwiftUI",
            destinations: .iOS,
            product: .app,
            bundleId: "com.moroverse.ApplicationFormExample-SwiftUI",
            infoPlist: .extendingDefault(
                with: infoPlistSwiftUIAdditions
            ),
            sources: [.glob("Sources/**", excluding: ["Sources/UIKit/**"])],
            resources: [
                .glob(pattern: "Resources/**", excluding: ["Resources/LaunchScreen.storyboard"])
            ],
            scripts: [
                .pre(
                    script: .formatScript(),
                    name: "Format",
                    basedOnDependencyAnalysis: false
                ),
                .pre(
                    script: .lintScript(),
                    name: "Lint",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .package(product: "ApplicationForm"),
                .package(product: "QuickForm"),
                .external(name: "SwiftfulRouting"),
                .package(product: "FactoryKit")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_STRICT_CONCURRENCY": "Complete",
                    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2"
                ],
                defaultSettings: .recommended(excluding: [])
            )
        ),
        .target(
            name: "ApplicationFormExample-UIKit",
            destinations: .iOS,
            product: .app,
            bundleId: "com.moroverse.ApplicationFormExample-UIKit",
            infoPlist: .extendingDefault(
                with: infoPlistUIKitAdditions
            ),
            sources: [.glob("Sources/**", excluding: ["Sources/SwiftUI/**"])],
            resources: ["Resources/**"],
            scripts: [
                .pre(
                    script: .formatScript(),
                    name: "Format",
                    basedOnDependencyAnalysis: false
                ),
                .pre(
                    script: .lintScript(),
                    name: "Lint",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .package(product: "ApplicationForm"),
                .package(product: "QuickForm"),
                .package(product: "Factory")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_STRICT_CONCURRENCY": "Complete",
                    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2"
                ],
                defaultSettings: .recommended(excluding: [])
            )
        ),
        .target(
            name: "ApplicationFormExample-SwiftUITests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.moroverse.ApplicationFormExample-SwiftUITests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "ApplicationFormExample-SwiftUI")],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_STRICT_CONCURRENCY": "Complete"
                ],
                defaultSettings: .essential(excluding: [])
            )
        )
    ]
)
