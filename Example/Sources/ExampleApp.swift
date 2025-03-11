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
    func navigateToNextStep() async -> ExperienceSkill? {
        await withCheckedContinuation { continuation in
            let model = ExperienceSkillModel(value: .sample)
            showScreen(.sheet) {
                continuation.resume(returning: model.value)
            } destination: { _ in
                NewSkillView(model: model)
            }
        }
    }
}
