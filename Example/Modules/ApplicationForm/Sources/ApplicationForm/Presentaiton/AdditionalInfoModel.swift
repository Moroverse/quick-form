// AdditionalInfoModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 03:00 GMT.

import Foundation
import Observation
import QuickForm

@QuickForm(AdditionalInfo.self)
public final class AdditionalInfoModel {
    public struct Dependencies {
        let documentUploader: DocumentUploader
        let documentDeleter: DocumentDeleter
        let _router: () -> AdditionalInfoRouting?
        lazy var router: AdditionalInfoRouting? = _router()

        public init(documentUploader: DocumentUploader, documentDeleter: DocumentDeleter, router: @escaping () -> AdditionalInfoRouting?) {
            self.documentUploader = documentUploader
            self.documentDeleter = documentDeleter
            _router = router
        }
    }

    @Dependency
    var dependencies: Dependencies

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
            placeholder: "Tap to upload a resume"
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
            let url = try await dependencies.documentUploader.upload(from: url)
            resume.value = url
        } catch {
            uploadErrorMessage = "Upload failed with message: \(error.localizedDescription)"
            resume.revalidate()
        }
    }

    func deleteResume() async {
        guard let value = resume.value else { return }
        do {
            try await dependencies.documentDeleter.deleteDocument(from: value)
            resume.value = nil
        } catch {
            uploadErrorMessage = "Delete failed with message: \(error.localizedDescription)"
            resume.revalidate()
        }
    }

    func didTapOnAdditionalInformationResume() async {
        if let url = resume.value {
            await dependencies.router?.navigateToPreview(at: url)
        } else {
            if let url = await dependencies.router?.navigateToResumeUpload() {
                await uploadResume(from: url)
            }
        }
    }
}
