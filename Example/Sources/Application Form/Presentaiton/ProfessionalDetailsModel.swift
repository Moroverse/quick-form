// ProfessionalDetailsModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:55 GMT.

import Observation
import QuickForm

@QuickForm(ProfessionalDetails.self)
final class ProfessionalDetailsModel {
    @PropertyEditor(keyPath: \ProfessionalDetails.desiredPosition)
    var desiredPosition = FormFieldViewModel(
        type: String.self,
        title: "Desired Position",
        placeholder: "Manager",
        validation: .of(
            .notEmpty
        )
    )
}

extension ProfessionalDetailsModel: ValueEditor {}
