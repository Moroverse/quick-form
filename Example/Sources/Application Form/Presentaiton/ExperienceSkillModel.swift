// ExperienceSkillModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 21:30 GMT.

import Observation
import QuickForm

@QuickForm(ExperienceSkill.self)
final class ExperienceSkillModel {
    enum State {
        case cancelled
        case committed(ExperienceSkill)
    }

    @PropertyEditor(keyPath: \ExperienceSkill.name)
    var name = FormFieldViewModel(type: String.self, title: "Name")
    @PropertyEditor(keyPath: \ExperienceSkill.level)
    var level = FormattedFieldViewModel(type: Double.self, format: .number, title: "Level")

    @ObservationIgnored
    var state: State?
}
