// ExperienceSkill.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation

public struct ExperienceSkill: Identifiable {
    public var id: UUID
    public var name: String
    public var level: Double
}

#if DEBUG
    extension ExperienceSkill {
        static let sample = ExperienceSkill(id: .init(), name: "Swift", level: 5)
    }
#endif
