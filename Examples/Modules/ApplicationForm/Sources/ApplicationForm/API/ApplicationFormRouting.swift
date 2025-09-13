// ApplicationFormRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 07:42 GMT.

import FactoryKit

public protocol ApplicationFormRouting {
    func navigateToNewSkill() async -> ExperienceSkill?
    func navigateToEducation(_ selection: Education?) async -> Education?
}

public extension Container {
    var applicationFormRouting: Factory<ApplicationFormRouting?> { promised() }
}
