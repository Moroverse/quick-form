// Config.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import ProjectDescription

let config = Config(
    compatibleXcodeVersions: ["16.0"],
    swiftVersion: "5.10",
    generationOptions: .options(enforceExplicitDependencies: true)
)
