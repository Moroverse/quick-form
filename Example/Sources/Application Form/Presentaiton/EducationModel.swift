// EducationModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 06:06 GMT.

import Foundation
import Observation
import QuickForm

struct EducationRangeValidation: ValidationRule {
    func validate(_ value: Education) -> ValidationResult {
        if value.startDate > value.endDate {
            .failure("Start date cannot be later than end date")
        } else {
            .success
        }
    }
}

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

    @PropertyEditor(keyPath: \Education.startDate)
    var startDate = FormFieldViewModel(type: Date.self, title: "Start Date")

    @PropertyEditor(keyPath: \Education.endDate)
    var endDate = FormFieldViewModel(type: Date.self, title: "End Date")

    @PropertyEditor(keyPath: \Education.degree)
    var degree = FormFieldViewModel(
        type: String.self,
        title: "Degree",
        placeholder: "Bachelor of Science",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Education.fieldOfStudy)
    var fieldOfStudy = FormFieldViewModel(
        type: String.self,
        title: "Field of Study",
        placeholder: "Computer Science",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Education.gpa)
    var gpa = FormFieldViewModel(
        type: Int.self,
        title: "GPA",
        validation: .of(.minValue(5))
    )

    @ObservationIgnored
    var state: State?

    @PostInit
    func configure() {
        addCustomValidationRule(EducationRangeValidation())
    }
}
