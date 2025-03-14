// ApplicationFormModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:10 GMT.

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
    @PropertyEditor(keyPath: \Applicant.education)
    var education = FormCollectionViewModel(
        type: Education.self,
        title: "Education",
        insertionTitle: "Add Education"
    )
    @PropertyEditor(keyPath: \Applicant.additionalInfo)
    var additionalInfo = AdditionalInfoModel(value: .sample)
}
