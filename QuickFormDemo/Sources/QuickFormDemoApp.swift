// QuickFormDemoApp.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

@main
struct QuickFormDemoApp: App {
    @State var form: PersonEditModel = .init(
        model: .init(
            givenName: "Marko",
            familyName: "Grlic",
            dateOfBirth: Date(),
            sex: .male,
            address: .init(
                line1: "Milana Delica 32",
                city: "Belgrade",
                zipCode: "11000",
                country: .brazil,
                state: nil
            )
        )
    )
    var body: some Scene {
        WindowGroup {
            ContentView(quickForm: form)
        }
    }
}
