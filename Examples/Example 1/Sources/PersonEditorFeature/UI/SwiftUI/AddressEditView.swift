// AddressEditView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import QuickForm
import SwiftUI

struct AddressEditView: View {
    @Bindable var quickForm: AddressEditModel

    init(quickForm: AddressEditModel) {
        self.quickForm = quickForm
    }

    var body: some View {
        VStack {
            FormTextField(quickForm.line1, alignment: .leading)
                .padding(.vertical, 4)
            Divider()
            FormOptionalTextField(quickForm.line2, alignment: .leading)
                .padding(.vertical, 4)
            Divider()

            HStack {
                FormTextField(quickForm.city, alignment: .leading)
                Divider()
                FormTextField(quickForm.zipCode, alignment: .leading)
            }

            Divider()

            HStack {
                FormPickerField(quickForm.country)
                    .buttonStyle(.plain)
                if quickForm.country.value.hasStates {
                    Divider()
                    FormOptionalPickerField(quickForm.state, clearValueMode: .always)
                }
            }
        }
    }
}

struct AddressEditView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = AddressEditModel(
            value: Address(
                line1: "",
                line2: nil,
                city: "Belgrade",
                zipCode: "11080",
                country: .australia,
                state: .australia(.newSouthWales)
            )
        )

        var body: some View {
            AddressEditView(quickForm: form)
        }
    }

    static var previews: some View {
        NavigationStack {
            Form {
                PreviewWrapper()
            }
        }
    }
}
