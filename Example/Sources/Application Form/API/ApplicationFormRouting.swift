// ApplicationFormRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 04:23 GMT.

protocol ApplicationFormRouting {
    func navigateToNewSkill() async -> ExperienceSkill?
    func navigateToEducation(_ selection: Education?) async -> Education?
}
