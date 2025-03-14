// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:10 GMT.

import Foundation
import QuickForm
import SwiftUI

protocol ApplicationFormRouting {
    func navigateToNewSkill() async -> ExperienceSkill?
    func navigateToEducation(_ selection: Education?) async -> Education?
    func navigateToResumeUpload() async -> URL?
    @MainActor
    func navigateToPreview(at url: URL)
}

struct ApplicationFormView: View {
    @Bindable private var model: ApplicationFormModel
    let router: ApplicationFormRouting
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

    private func additionalInfoSection() -> some View {
        Section("Additional Information") {
            AsyncButton {
                switch model.additionalInfo.resume.value {
                case .missing:
                    if let url = await router.navigateToResumeUpload() {
                        await model.additionalInfo.uploadResume(from: url)
                    }

                case let .present(url: url):
                    router.navigateToPreview(at: url)

                case .error:
                    // show upload
                    break
                }
            } label: {
                switch model.additionalInfo.resume.value {
                case .missing:
                    Text("No Resume. Tap to upload.")
                case let .present(url: url):
                    Text("Resume uploaded to \(url). Tap to preview.")
                case let .error(error):
                    Text("Resume upload error \(error.localizedDescription). Tap to retry.")
                }
            }
            .swipeActions(edge: .trailing) {
                if case .present = model.additionalInfo.resume.value {
                    Button(role: .destructive) {
                        //
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

struct MockApplicationFormRouting: ApplicationFormRouting {
    func navigateToPreview(at url: URL) {}

    func navigateToResumeUpload() async -> URL? {
        nil
    }

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
