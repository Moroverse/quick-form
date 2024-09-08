// ContentView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

struct ContentView: View {
    @Bindable var quickForm: PersonEditModel

    init(quickForm: PersonEditModel) {
        self.quickForm = quickForm
    }

    @State var info: String = "None"

    var body: some View {
        Form {
            FormTextField(quickForm.firstName)
            FormTextField(quickForm.lastName)
            FormDatePickerField(quickForm.birthday)
            FormPickerField(quickForm.sex)
            FormValueUnitField(quickForm.weight)
            FormFormattedTextField(quickForm.salary)
            FormToggleField(quickForm.isEstablished)
            Section {
                AddressEditView(quickForm: quickForm.address)
            }
            FormCollectionSection(quickForm.careTeam) { personInfo in
                Text(personInfo.name)
            }
            Section {
                TextEditor(text: .constant(info))
                    .frame(height: 300)
                    .disabled(true)
            }
        }
        .navigationTitle(quickForm.personNameComponents.formatted())
        .onChange(of: quickForm.model) {
            info = String(describing: quickForm.model)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = PersonEditModel(
            model: Person(
                givenName: "Angelina",
                familyName: "Jolie",
                dateOfBirth: Date(),
                sex: .female,
                address: .init(
                    line1: "Milana Delica 32",
                    city: "Belgrade",
                    zipCode: "11000",
                    country: .brazil,
                    state: nil
                )
            )
        )

        var body: some View {
            ContentView(quickForm: form)
        }
    }

    static var previews: some View {
        NavigationStack {
            PreviewWrapper()
        }
    }
}
