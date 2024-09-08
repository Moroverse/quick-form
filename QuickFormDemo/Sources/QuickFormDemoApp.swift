// QuickFormDemoApp.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

let fakePerson = Person(
    givenName: "Olivia",
    familyName: "Chen",
    dateOfBirth: Date(timeIntervalSince1970: 707_443_200), // September 3, 1992
    sex: .female,
    phone: "+1 (555) 123-4567",
    salary: 75000.00,
    weight: Measurement(value: 58.5, unit: UnitMass.kilograms),
    isEstablished: true,
    address: Address(
        line1: "742 Evergreen Terrace",
        line2: "Apartment 3B",
        city: "Springfield",
        zipCode: "12345",
        country: .unitedStates,
        state: .unitedStates(.california)
    )
)

@main
struct QuickFormDemoApp: App {
    @State var form: PersonEditModel = .init(model: fakePerson)
    var body: some Scene {
        WindowGroup {
            ContentView(quickForm: form)
        }
    }
}
