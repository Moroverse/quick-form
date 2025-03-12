// ExampleApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

import SwiftfulRouting
import SwiftUI

@main
struct ExampleApp: App {
    @State var model = ApplicationFormModel(value: .sample)
    var body: some Scene {
        WindowGroup {
            RouterView(addNavigationView: true) { router in
                ApplicationFormView(model: model, router: router)
            }
        }
    }
}

@MainActor
extension AnyRouter: ApplicationFormRouting {
    func navigateToEducation(_ selection: Education?) async -> Education? {
        await withCheckedContinuation { continuation in
            let model = EducationModel(
                value: selection ?? Education(
                    id: UUID(),
                    institution: "",
                    startDate: Date(),
                    endDate: Date(),
                    degree: ""
                )
            )
            showScreen(.sheet) {
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }
            } destination: { _ in
                EducationFormView(model: model)
            }
        }
    }

    func navigateToNewSkill() async -> ExperienceSkill? {
        await withCheckedContinuation { continuation in
            let model = ExperienceSkillModel(value: .init(id: UUID(), name: "", level: 0))
            showScreen(.sheet) {
                if case let .committed(newValue) = model.state {
                    continuation.resume(returning: newValue)
                } else {
                    continuation.resume(returning: nil)
                }
            } destination: { _ in
                NewSkillView(model: model)
            }
        }
    }
}
