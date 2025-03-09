// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:31 GMT.

import Foundation
import QuickForm
import SwiftUI

struct ApplicationFormView: View {
    @Bindable private var model: ApplicationFormModel
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                FormTextField(model.personalInformation.givenName)
                FormTextField(model.personalInformation.familyName)
                FormTextField(model.personalInformation.emailName)
                FormFormattedTextField(model.personalInformation.phoneNumber, autoMask: .phone)
                AddressView(model: model.personalInformation.address)
            }

            Section("Professional Details") {
                FormTextField(model.professionalDetails.desiredPosition)
                FormFormattedTextField(model.professionalDetails.desiredSalary)
                FormDatePickerField(
                    model.professionalDetails.availabilityDate,
                    range: Date() ... Date.distantFuture,
                    displayedComponents: [.date],
                    style: .automatic
                )
            }
        }
    }

    init(model: ApplicationFormModel) {
        self.model = model
    }
}

struct ApplicationFormView_Previews: PreviewProvider {
    struct ApplicationFormViewWrapper: View {
        @State var model = ApplicationFormModel(value: .sample)

        var body: some View {
            ApplicationFormView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            ApplicationFormViewWrapper()
        }
    }
}
