// EducationModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 04:46 GMT.

import Foundation
import Observation
import QuickForm

@QuickForm(Education.self)
final class EducationModel: Validatable {
    enum State {
        case cancelled
        case committed(Education)
    }

    @PropertyEditor(keyPath: \Education.institution)
    var institution = FormFieldViewModel(
        type: String.self,
        title: "Institution",
        placeholder: "Oxford University",
        validation: .of(.notEmpty)
    )

    @ObservationIgnored
    var state: State?
}
