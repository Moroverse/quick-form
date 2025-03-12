// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 19:38 GMT.

import Foundation
import QuickForm
import SwiftUI

protocol ApplicationFormRouting {
    func navigateToNewSkill() async -> ExperienceSkill?
    func navigateToEducation(_ selection: Education?) async -> Education?
}

struct ApplicationFormView: View {
    @Bindable private var model: ApplicationFormModel
    let router: ApplicationFormRouting
    var body: some View {
        Form {
            personalInformationSection()
            professionalDetailsSection()
            experienceSection()
            experienceSkillSection()
            educationSection()
        }
    }

    init(model: ApplicationFormModel, router: ApplicationFormRouting) {
        self.model = model
        self.router = router
    }

    private func personalInformationSection() -> some View {
        Section(header: Text("Personal Information")) {
            FormTextField(model.personalInformation.givenName)
            FormTextField(model.personalInformation.familyName)
            FormTextField(model.personalInformation.emailName)
            FormFormattedTextField(model.personalInformation.phoneNumber, autoMask: .phone)
            AddressView(model: model.personalInformation.address)
        }
    }

    private func professionalDetailsSection() -> some View {
        Section("Professional Details") {
            FormTextField(model.professionalDetails.desiredPosition)
            FormFormattedTextField(model.professionalDetails.desiredSalary)
            FormDatePickerField(
                model.professionalDetails.availabilityDate,
                range: Date() ... Date.distantFuture,
                displayedComponents: [.date],
                style: .automatic
            )
            FormPickerField(
                model.professionalDetails.employmentType,
                pickerStyle: .navigationLink
            )
            FormToggleField(model.professionalDetails.willingToRelocate)
        }
    }

    private func experienceSection() -> some View {
        Section("Experience") {
            FormFormattedTextField(model.experience.years)
            FormTokenSetField(viewModel: model.experience.skills)
        }
    }

    private func experienceSkillSection() -> some View {
        FormCollectionSection(model.experience.skillsWithProficiencis) { $skill in
            HStack {
                Text(skill.name)
                Spacer()
                Slider(value: $skill.level, in: 1 ... 5, step: 1)
                    .frame(maxWidth: 200)
            }
        }
        .configure { model in
            model.onInsert(action: router.navigateToNewSkill)
        }
    }

    private func educationSection() -> some View {
        FormCollectionSection(model.education) { $education in
            HStack {
                Text(education.institution)
                    .font(.headline)
                Spacer()
                Text("(GPA \(education.gpa))")
            }
        }
        .configure { model in
            model.onInsert {
                await router.navigateToEducation(nil)
            }
            model.onSelect(action: router.navigateToEducation)
        }
    }
}

struct MockApplicationFormRouting: ApplicationFormRouting {
    func navigateToEducation(_ selection: Education?) async -> Education? {
        nil
    }

    func navigateToNewSkill() async -> ExperienceSkill? {
        nil
    }
}

struct ApplicationFormView_Previews: PreviewProvider {
    struct ApplicationFormViewWrapper: View {
        @State var model = ApplicationFormModel(value: .sample)
        @State var router = MockApplicationFormRouting()

        var body: some View {
            ApplicationFormView(model: model, router: router)
        }
    }

    static var previews: some View {
        NavigationStack {
            ApplicationFormViewWrapper()
        }
    }
}
