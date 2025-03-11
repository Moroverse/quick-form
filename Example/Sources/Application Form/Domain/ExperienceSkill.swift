// ExperienceSkill.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 21:29 GMT.

import Foundation

struct ExperienceSkill: Identifiable {
    var id: UUID
    var name: String
    var level: Double
}

#if DEBUG
    extension ExperienceSkill {
        static let sample = ExperienceSkill(id: .init(), name: "Swift", level: 5)
    }
#endif
