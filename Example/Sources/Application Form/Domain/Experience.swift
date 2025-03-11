// Experience.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 20:31 GMT.

import Foundation

struct Experience {
    var years: Int
    var skills: [ExperienceSkill]
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
