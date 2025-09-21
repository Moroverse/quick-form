// DefaultRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-09-13 08:03 GMT.

import ApplicationForm
import FactoryKit
import Foundation
import SwiftfulRouting

extension Container {
    var anyRouter: Factory<AnyRouter?> { promised() }
}

@MainActor
extension AnyRouter: @retroactive ApplicationFormRouting, @retroactive AdditionalInfoRouting {
    public func navigateToPreview(at url: URL) {
        showScreen(.sheet) { _ in
            PreviewComposer.compose(with: url)
        }
    }

    public func navigateToResumeUpload() async -> URL? {
        let model = DocumentBrowserModel()
        return await withCheckedContinuation { continuation in
            model.didComplete = {
                continuation.resume(returning: model.urls.first)
            }

            showScreen(.sheet) { _ in
                DocumentBrowserComposer.compose(with: model)
            }
        }
    }

    public func navigateToEducation(_ selection: Education?) async -> Education? {
        await withCheckedContinuation { continuation in
            let model = EducationModel(
                value: selection ?? Education(
                    id: UUID(),
                    institution: "",
                    startDate: Date(),
                    endDate: Date(),
                    degree: "",
                    fieldOfStudy: "",
                    gpa: 5
                )
            )
            showScreen(.sheet) {
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }
            } destination: { _ in
                EducationFormComposer.compose(with: model)
            }
        }
    }

    public func navigateToNewSkill() async -> ExperienceSkill? {
        await withCheckedContinuation { continuation in
            let model = ExperienceSkillModel(value: .init(id: UUID(), name: "", level: 0))
            showScreen(.sheet) {
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }
            } destination: { _ in
                NewSkillFormComposer.compose(with: model)
            }
        }
    }
}
