// ApplicationFormModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 10:10 GMT.

import Observation
import QuickForm

@QuickForm(Applicant.self)
public final class ApplicationFormModel {
    public struct Dependencies {
        private let _router: () -> ApplicationFormRouting?
        lazy var router: ApplicationFormRouting? = _router()
        let additionalInfoDependencies: AdditionalInfoModel.Dependencies
        let addressModelDependencies: AddressModel.Dependencies

        public init(
            additionalInfoDependencies: AdditionalInfoModel.Dependencies,
            addressModelDependencies: AddressModel.Dependencies,
            router: @escaping () -> ApplicationFormRouting?
        ) {
            _router = router
            self.additionalInfoDependencies = additionalInfoDependencies
            self.addressModelDependencies = addressModelDependencies
        }
    }

    @Dependency
    var dependencies: Dependencies

    @PropertyEditor(keyPath: \Applicant.personalInformation)
    var personalInformation: PersonalInformationModel
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
    var additionalInfo: AdditionalInfoModel

    func didTapOnEducationInsert(education: Education?) async -> Education? {
        await dependencies.router?.navigateToEducation(education)
    }

    func didTaponNewSkill() async -> ExperienceSkill? {
        await dependencies.router?.navigateToNewSkill()
    }

    @OnInit
    func onInit() {
        additionalInfo = AdditionalInfoModel(
            value: .sample,
            dependencies: dependencies.additionalInfoDependencies
        )
        personalInformation = PersonalInformationModel(value: .sample, dependencies: dependencies.addressModelDependencies)
    }
}
