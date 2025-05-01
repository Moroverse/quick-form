// Experience.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:37 GMT.

import Foundation

public struct Experience {
    public var years: Int
    public var skills: [ExperienceSkill]

    public init(years: Int, skills: [ExperienceSkill]) {
        self.years = years
        self.skills = skills
    }
}

#if DEBUG
    extension Experience {
        static var sample: Experience {
            .init(
                years: 1,
                skills: [
                    .init(id: UUID(), name: "swift", level: 2),
                    .init(id: UUID(), name: "SwiftUI", level: 1)
                ]
            )
        }
    }
#endif
