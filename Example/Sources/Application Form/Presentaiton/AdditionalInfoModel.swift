// AdditionalInfoModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:17 GMT.

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

    func deleteResume() async throws {}

    @PostInit
    func configure() {}
}
