// ExampleApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-16 15:44 GMT.

import ApplicationForm
import Factory
import SwiftfulRouting
import SwiftUI

@main
struct ExampleApp: App {
    @State var model = ApplicationFormModel(
        value: .init(
            personalInformation: .init(
                givenName: "",
                familyName: "",
                email: "",
                phoneNumber: "",
                address: .init(
                    street: "",
                    city: "",
                    zipCode: ""
                )
            ),
            professionalDetails: .init(
                desiredPosition: "",
                desiredSalary: 0,
                availabilityDate: .distantPast,
                employmentType: [],
                willingToRelocate: false
            ),
            experience: .init(
                years: 0,
                skills: []
            ),
            education: [],
            additionalInfo: .init(consentToBackgroundChecks: false)
        )
    )
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
