// Experience.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:28 GMT.

import Foundation

struct Experience {
    struct Skill: Identifiable {
        var id: UUID
        var name: String
        var level: Double
    }

    var years: Int
    var skills: [Skill]
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
