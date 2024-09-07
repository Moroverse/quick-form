// QuickFormDemoApp.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

@main
struct QuickFormDemoApp: App {
    @State var form: QuickForm = .init(
        model: .init(
            givenName: "Marko",
            familyName: "Grlic",
            dateOfBirth: Date(),
            sex: .male
        )
    )
    var body: some Scene {
        WindowGroup {
            ContentView(quickForm: form)
        }
    }
}
