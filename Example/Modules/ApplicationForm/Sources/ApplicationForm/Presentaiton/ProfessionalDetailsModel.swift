// ProfessionalDetailsModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import Observation
import QuickForm

extension EmploymentType: CustomStringConvertible {
    var description: String {
        switch self {
        case .fullTime:
            "Full Time"
        case .partTime:
            "Part Time"
        case .contract:
            "Contract"
        }
    }
}

extension EmploymentType: DefaultValueProvider {
    static var defaultValue: EmploymentType {
        .partTime
    }
}

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

    @PropertyEditor(keyPath: \ProfessionalDetails.employmentType)
    var employmentType = MultiPickerFieldViewModel(
        type: EmploymentType.self,
        allValues: EmploymentType.allCases,
        title: "Employment Type"
    )

    @PropertyEditor(keyPath: \ProfessionalDetails.willingToRelocate)
    var willingToRelocate = FormFieldViewModel(type: Bool.self, title: "Willing to Relocate")
}
