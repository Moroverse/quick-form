// ApplicationFormModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:35 GMT.

import Observation
import QuickForm

@QuickForm(Applicant.self)
final class ApplicationFormModel {
    @PropertyEditor(keyPath: \Applicant.personalInformation)
    var personalInformation = PersonalInformationModel(value: .sample)
    @PropertyEditor(keyPath: \Applicant.professionalDetails)
    var professionalDetails = ProfessionalDetailsModel(value: .sample)
    @PropertyEditor(keyPath: \Applicant.experience)
    var experience = ExperienceViewModel(value: .sample)
}
