// ExperienceViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:29 GMT.

import Observation
import QuickForm

@QuickForm(Experience.self)
final class ExperienceViewModel {
    @PropertyEditor(keyPath: \Experience.years)
    var years = FormattedFieldViewModel(
        type: Int.self,
        format: .number
    )
}
