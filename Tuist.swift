// Tuist.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-07 04:59 GMT.

import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: [.upToNextMajor("16")],
        swiftVersion: "6.0"
    )
)
