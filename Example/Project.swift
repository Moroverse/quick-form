// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

import ProjectDescription

let project = Project(
    name: "Example",
    targets: [
        .target(
            name: "Example",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.",
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
            dependencies: [
                .external(name: "QuickForm")
            ]
        ),
        .target(
            name: "ExampleTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.Tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Example")]
        )
    ]
)
