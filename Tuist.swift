// Tuist.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-02-27 05:41 GMT.

import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: [.upToNextMajor("26")],
        swiftVersion: "6.1"
    )
)
