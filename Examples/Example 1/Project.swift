// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "PersonAndMedicationExample",
    targets: [
        .target(
            name: "PersonAndMedicationExample",
            destinations: [.iPad, .iPhone, .macCatalyst],
            product: .app,
            bundleId: "com.moroverse.PersonAndMedicationExample",
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
                    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1,2"
                ],
                defaultSettings: .recommended(excluding: [])
            )
        )
    ]
)
