// AdditionalInfoModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 06:15 GMT.

import Factory
import Foundation
import Observation
import QuickForm

struct ExternalValidationRule<T>: ValidationRule {
    let validate: () -> ValidationResult

    func validate(_ value: T) -> ValidationResult {
        validate()
    }
}

@QuickForm(AdditionalInfo.self)
final class AdditionalInfoModel {
    @Injected(\.documentUploader)
    var documentUploader: DocumentUploader

    @Injected(\.documentDeleter)
    var documentDeleter: DocumentDeleter

    @LazyInjected(\.additionalInfoRouting)
    var router: AdditionalInfoRouting?

    @PropertyEditor(keyPath: \AdditionalInfo.resume)
    var resume = FormFieldViewModel(
        type: URL?.self,
        title: "Resume:",
        placeholder: "Tap to upload resume"
    )

    @PropertyEditor(keyPath: \AdditionalInfo.coverLetter)
    var coverLetter = FormFieldViewModel(
        type: String?.self,
        title: "Cover Letter",
        placeholder: "Lorem ipsum dolor sit amet"
    )

    private var uploadErrorMessage: LocalizedStringResource?

    @PostInit
    func configure() {
        resume.validation = .of(ExternalValidationRule(validate: { [weak self] in
            if let uploadErrorMessage = self?.uploadErrorMessage {
                .failure(uploadErrorMessage)
            } else {
                .success
            }
        }))
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
