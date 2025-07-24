// ExperienceSkill.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 21:40 GMT.

import Foundation

public struct ExperienceSkill: Identifiable {
    nonisolated public var id: UUID
    public var name: String
    public var level: Double

    public init(id: UUID, name: String, level: Double) {
        self.id = id
        self.name = name
        self.level = level
    }
}

#if DEBUG
    extension ExperienceSkill {
        static let sample = ExperienceSkill(id: .init(), name: "Swift", level: 5)
    }
#endif
