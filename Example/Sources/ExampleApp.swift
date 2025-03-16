// ExampleApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

import Factory
import SwiftfulRouting
import SwiftUI

@main
struct ExampleApp: App {
    @State var model = ApplicationFormModel(value: .sample)
    var body: some Scene {
        WindowGroup {
            RouterView(addNavigationView: true) { router in
                setup(router: router)
            }
        }
    }

    func setup(router: AnyRouter) -> some View {
        Container.shared.anyRouter.register { router }
        return ApplicationFormComposer.compose(with: model)
    }
}
