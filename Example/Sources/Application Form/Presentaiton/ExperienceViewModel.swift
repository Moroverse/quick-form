// ExperienceViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:29 GMT.

import Foundation
import Observation
import QuickForm

extension Experience.Skill: CustomStringConvertible {
    var description: String {
        name
    }
}

@QuickForm(Experience.self)
final class ExperienceViewModel {
    @PropertyEditor(keyPath: \Experience.years)
    var years = FormattedFieldViewModel(
        type: Int.self,
        format: .number,
        title: "Years of experience"
    )

    @PropertyEditor(keyPath: \Experience.skills)
    var skills = TokenSetViewModel(
        value: [Experience.Skill](),
        title: "Skills",
        insertionPlaceholder: "Enter a new skill"
    ) { newString in
        Experience.Skill(id: UUID(), name: newString, level: 1)
    }
}
