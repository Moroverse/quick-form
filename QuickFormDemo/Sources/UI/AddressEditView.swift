// AddressEditView.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 08:55 GMT.

import QuickForm
import SwiftUI

struct AddressEditView: View {
    @Bindable var quickForm: AddressEditModel

    init(quickForm: AddressEditModel) {
        self.quickForm = quickForm
    }

    func info() -> String {
        let country = quickForm.country.value
        let state = quickForm.state.value

        return "\(country.description) \(state?.description ?? "")"
    }

    var body: some View {
        Grid {
            GridRow {
                FormTextField(quickForm.line1)
                    .gridCellColumns(2)
            }

            Divider()

            GridRow {
                FormOptionalTextField(quickForm.line2)
                    .gridCellColumns(2)
            }

            Divider()

            GridRow {
                FormTextField(quickForm.city)
                Rectangle()
                    .foregroundStyle(.tertiary)
                    .frame(width: 1)
                    .gridCellUnsizedAxes([.horizontal, .vertical])
                FormTextField(quickForm.zipCode)
            }

            Divider()

            GridRow {
                safeCountryColumns(content: FormPickerField(quickForm.country))
                if quickForm.country.value.hasStates {
                    Rectangle()
                        .foregroundStyle(.tertiary)
                        .frame(width: 1)
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    FormOptionalPickerField(quickForm.state)
                }
            }
        }
        .navigationTitle(info())
    }

    private func safeCountryColumns(content: some View) -> some View {
        if quickForm.country.value.hasStates {
            content
                .gridCellColumns(2)
        } else {
            content
                .gridCellColumns(1)
        }
    }
}

struct AddressEditView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var form = AddressEditModel(
            address: Address(
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
