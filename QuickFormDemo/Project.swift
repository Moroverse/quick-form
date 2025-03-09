// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "QuickFormDemo",
    targets: [
        .target(
            name: "QuickFormDemo",
            destinations: [.iPad, .iPhone, .macCatalyst],
            product: .app,
            bundleId: "com.moroverse.quick-form",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": ""
                    ]
                ]
            ),
            sources: ["Sources/**"],
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
                .external(name: "QuickForm")
            ],
            settings: .settings(
                base: [
                    //                    "SWIFT_STRICT_CONCURRENCY": "complete",
                    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2"
                ],
                defaultSettings: .recommended(excluding: [])
            )
        )
    ]
)
