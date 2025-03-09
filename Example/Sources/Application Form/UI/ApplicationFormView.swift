// ApplicationFormView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:13 GMT.

import QuickForm
import SwiftUI

struct ApplicationFormView: View {
    @Bindable private var model: PersonalInformationModel
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                FormTextField(model.givenName)
                FormTextField(model.familyName)
                FormTextField(model.emailName)
                FormFormattedTextField(model.phoneNumber, autoMask: .phone)
                AddressView(model: model.address)
            }
        }
    }

    init(model: PersonalInformationModel) {
        self.model = model
    }
}

struct ApplicationFormView_Previews: PreviewProvider {
    struct ApplicationFormViewWrapper: View {
        @State var model = PersonalInformationModel(value: .sample)

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
