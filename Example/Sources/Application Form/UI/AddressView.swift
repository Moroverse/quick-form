// AddressView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 06:01 GMT.

import QuickForm
import SwiftUI

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct AddressView: View {
    @Bindable private var model: AddressModel
    var body: some View {
        FormTextField(model.street)
        FormTextField(model.city)
        FormTextField(model.zip)

        FormAsyncPickerField(
            model.country,
            clearValueMode: .always,
            pickerStyle: .popover,
            allowSearch: true
        ) {
            let placeholder = model.country.placeholder ?? ""
            Text($0 ?? String(localized: placeholder))
        } pickerContent: {
            Text($0)
        }

        if let value = model.country.value, value.isEmpty == false {
            FormAsyncPickerField(
                model.state,
                clearValueMode: .always,
                pickerStyle: .sheet,
                allowSearch: false
            ) {
                let placeholder = model.state.placeholder ?? ""
                Text($0 ?? String(localized: placeholder))
            } pickerContent: {
                Text($0)
            }
        }
    }

    init(model: AddressModel) {
        self.model = model
    }
}

struct AddressView_Previews: PreviewProvider {
    struct AddressViewWrapper: View {
        @State var model = AddressModel(value: .sample)

        var body: some View {
            AddressView(model: model)
        }
    }

    static var previews: some View {
        NavigationStack {
            Form {
                AddressViewWrapper()
            }
        }
    }
}
