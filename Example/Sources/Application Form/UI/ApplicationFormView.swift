// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation
import QuickForm
import SwiftUI

public enum ApplicationFormComposer {
    public static func compose(with model: ApplicationFormModel) -> some View {
        ApplicationFormView(model: model)
    }
}

struct ApplicationFormView: View {
    @Bindable private var model: ApplicationFormModel
    var body: some View {
        Form {
            personalInformationSection()
            professionalDetailsSection()
            FormMultiPickerSection(model.professionalDetails.employmentType)
            experienceSection()
            experienceSkillSection()
            educationSection()
            additionalInfoSection()
        }
    }

    init(model: ApplicationFormModel) {
        self.model = model
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
            model.onInsert(action: self.model.didTaponNewSkill)
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
                await self.model.didTapOnEducationInsert(education: nil)
            }
            model.onSelect(action: self.model.didTapOnEducationInsert)
        }
    }

    private func additionalInfoSection() -> some View {
        Section("Additional Information") {
            FormAsyncActionField(
                viewModel: model.additionalInfo.resume) {
                    await model.additionalInfo.didTapOnAdditionalInformationResume()
                } label: { resume in
                    if let resume {
                        Text(resume.absoluteString)
                    }
                }
                .swipeActions(edge: .trailing) {
                    // if model.additionalInfo.resume.value != nil {
                    Button {
                        Task {
                            await model.additionalInfo.deleteResume()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    // }
                }
            FormTextEditor(viewModel: model.additionalInfo.coverLetter)
            FormOptionalPickerField(model.additionalInfo.howDidYouHearAboutUs)
            FormTextEditor(viewModel: model.additionalInfo.additionalNotes)
            FormToggleField(model.additionalInfo.consentToBackgroundChecks)
        }
    }
}

struct ApplicationFormView_Previews: PreviewProvider {
    struct ApplicationFormViewWrapper: View {
        @State var model = ApplicationFormModel(value: .sample)

        var body: some View {
            ApplicationFormView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            ApplicationFormViewWrapper()
        }
    }
}
