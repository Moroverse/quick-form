// ExampleApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:00 GMT.

import SwiftUI

@main
struct ExampleApp: App {
    @State var model = ApplicationFormModel(value: .sample)
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ApplicationFormView(model: model)
            }
        }
    }
}
