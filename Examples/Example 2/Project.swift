// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

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
                .external(name: "ApplicationForm"),
                .external(name: "QuickForm"),
                .external(name: "SwiftfulRouting"),
                .external(name: "Factory")
            ],
            settings: .settings(
                base: [
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
                .external(name: "ApplicationForm"),
                .external(name: "QuickForm"),
                .external(name: "Factory")
            ],
            settings: .settings(
                base: [
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
            dependencies: [.target(name: "ApplicationFormExample-SwiftUI")]
        )
    ]
)
