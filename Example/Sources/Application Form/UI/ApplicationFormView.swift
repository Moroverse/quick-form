// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-11 05:57 GMT.

import Foundation
import QuickForm
import SwiftUI

protocol ApplicationFormRouting {
    func navigateToNextStep() async -> Experience.Skill?
}

struct ApplicationFormView: View {
    @Bindable private var model: ApplicationFormModel
    let router: ApplicationFormRouting
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                FormTextField(model.personalInformation.givenName)
                FormTextField(model.personalInformation.familyName)
                FormTextField(model.personalInformation.emailName)
                FormFormattedTextField(model.personalInformation.phoneNumber, autoMask: .phone)
                AddressView(model: model.personalInformation.address)
            }

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

            Section("Experience") {
                FormFormattedTextField(model.experience.years)
                FormTokenSetField(viewModel: model.experience.skills)
            }

            FormCollectionSection(model.experience.skillsWithProficiencis) { $skill in
                HStack {
                    Text(skill.name)
                    Spacer()
                    Slider(value: $skill.level, in: 1 ... 5, step: 1)
                        .frame(maxWidth: 200)
                }
            }
            .configure { model in
                model.onInsert(action: router.navigateToNextStep)
            }
        }
    }

    init(model: ApplicationFormModel, router: ApplicationFormRouting) {
        self.model = model
        self.router = router
    }
}

struct MockApplicationFormRouting: ApplicationFormRouting {
    func navigateToNextStep() async -> Experience.Skill? {
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
