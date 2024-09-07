// ContentView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 07:45 GMT.

import QuickForm
import SwiftUI

struct ContentView: View {
    @Bindable var quickForm: PersonForm

    init(quickForm: PersonForm) {
        self.quickForm = quickForm
    }

    var body: some View {
        Form {
            FormTextField(quickForm.firstName)
            FormTextField(quickForm.lastName)
            FormDatePickerField(quickForm.birthday)
            FormPickerField(quickForm.sex)
            FormValueUnitField(quickForm.weight)
            FormFormattedTextField(quickForm.salary)
            FormToggleField(quickForm.isEstablished)
        }
        .navigationTitle(quickForm.personNameComponents.formatted())
    }
}

struct ContentView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = PersonForm(
            model: Person(
                givenName: "Angelina",
                familyName: "Jolie",
                dateOfBirth: Date(),
                sex: .female
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
