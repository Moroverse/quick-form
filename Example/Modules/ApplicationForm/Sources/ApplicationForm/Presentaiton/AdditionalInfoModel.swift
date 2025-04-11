// AdditionalInfoModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:00 GMT.

import Factory
import Foundation
import Observation
import QuickForm

@QuickForm(AdditionalInfo.self)
final class AdditionalInfoModel {
    @Dependency
    var documentUploader: DocumentUploader

    @Injected(\.documentDeleter)
    var documentDeleter: DocumentDeleter

    @LazyInjected(\.additionalInfoRouting)
    var router: AdditionalInfoRouting?

    @PropertyEditor(keyPath: \AdditionalInfo.resume)
    var resume: FormFieldViewModel<URL?>

    @PropertyEditor(keyPath: \AdditionalInfo.coverLetter)
    var coverLetter = FormFieldViewModel(
        type: String?.self,
        title: "Cover Letter",
        placeholder: "Lorem ipsum dolor sit amet",
        validation: .of(OptionalRule.ifPresent(.maxLength(256)))
    )

    @PropertyEditor(keyPath: \AdditionalInfo.howDidYouHear)
    var howDidYouHearAboutUs = OptionalPickerFieldViewModel(
        type: String?.self,
        allValues: ["Facebook", "Coleague", "Referral", "Other"],
        title: "How did you hear about us?"
    )

    @PropertyEditor(keyPath: \AdditionalInfo.additionalNotes)
    var additionalNotes = FormFieldViewModel(
        type: String?.self,
        title: "Additional Notes",
        placeholder: "Any additional notes?"
    )

    @PropertyEditor(keyPath: \AdditionalInfo.consentToBackgroundChecks)
    var consentToBackgroundChecks = FormFieldViewModel(
        type: Bool.self,
        title: "I consent to background checks"
    )

    private var uploadErrorMessage: LocalizedStringResource?

    @OnInit
    func onInit() {
        resume = FormFieldViewModel(
            type: URL?.self,
            title: "Resume:",
            placeholder: "Tap to upload resume"
        )
    }

    @PostInit
    func configure() {
        resume.validation = .of(.custom { [weak self] _ in
            if let uploadErrorMessage = self?.uploadErrorMessage {
                .failure(uploadErrorMessage)
            } else {
                .success
            }
        })
    }

    func uploadResume(from url: URL) async {
        do {
            let url = try await documentUploader.upload(from: url)
            resume.value = url
        } catch {
            uploadErrorMessage = "Upload failed with message: \(error.localizedDescription)"
            resume.revalidate()
        }
    }

    func deleteResume() async {
        guard let value = resume.value else { return }
        do {
            try await documentDeleter.deleteDocument(from: value)
            resume.value = nil
        } catch {
            uploadErrorMessage = "Delete failed with message: \(error.localizedDescription)"
            resume.revalidate()
        }
    }

    func didTapOnAdditionalInformationResume() async {
        if let url = resume.value {
            await router?.navigateToPreview(at: url)
        } else {
            if let url = await router?.navigateToResumeUpload() {
                await uploadResume(from: url)
            }
        }
    }
}
