// ProfessionalDetailsModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:55 GMT.

import Foundation
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

    @PropertyEditor(keyPath: \ProfessionalDetails.desiredSalary)
    var desiredSalary = FormattedFieldViewModel(
        type: Decimal.self,
        format: .currency(code: "USD"),
        title: "Desied Salary",
        placeholder: "3 000 000"
    )

    @PropertyEditor(keyPath: \ProfessionalDetails.availabilityDate)
    var availabilityDate = FormFieldViewModel(type: Date.self, title: "Availability Date")
}

extension ProfessionalDetailsModel: ValueEditor {}
