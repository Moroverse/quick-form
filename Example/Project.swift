// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Example",
    targets: [
        .target(
            name: "Example-SwiftUI",
            destinations: .iOS,
            product: .app,
            bundleId: "io.moroverse.job-example",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ]
                ]
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
            name: "Example-UIKit",
            destinations: .iOS,
            product: .app,
            bundleId: "io.moroverse.job-example",
            infoPlist: .default,
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
            name: "Example-SwiftUITests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.Tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Example-SwiftUI")]
        )
    ]
)
