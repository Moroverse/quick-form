// AdditionalInfoModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-14 06:15 GMT.

import Factory
import Foundation
import Observation
import QuickForm

extension Resume: DefaultValueProvider {
    static var defaultValue: Resume {
        .missing
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
    var resume = FormFieldViewModel(type: Resume.self)

    func uploadResume(from url: URL) async {
        do {
            let url = try await documentUploader.upload(from: url)
            resume.value = .present(url: url)
        } catch {
            resume.value = .error(error)
        }
    }

    func deleteResume() async {
        guard case let .present(url) = resume.value else { return }
        do {
            try await documentDeleter.deleteDocument(from: url)
            resume.value = .missing
        } catch {
            resume.value = .error(error)
        }
    }

    @PostInit
    func configure() {
        resume.title = resume.value.title

        resume.onValueChanged { [weak resume] newValue in
            resume?.title = newValue.title
        }
    }

    func didTapOnAdditionalInformationResume() async {
        switch resume.value {
        case .missing:
            if let url = await router?.navigateToResumeUpload() {
                await uploadResume(from: url)
            }

        case let .present(url: url):
            await router?.navigateToPreview(at: url)

        case .error:
            // show upload
            break
        }
    }
}

extension Resume {
    var title: LocalizedStringResource {
        switch self {
        case .missing:
            "No Resume."
        case .present:
            "Resume uploaded."
        case let .error(error):
            "Resume upload error \(error.localizedDescription)"
        }
    }
}
