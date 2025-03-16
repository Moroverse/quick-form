// AddressView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import QuickForm
import SwiftUI
import Factory

extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct AddressView: View {
    @Bindable private var model: AddressModel
    var body: some View {
        FormTextField(model.street)
        HStack {
            FormTextField(model.city)
            Divider()
            FormTextField(model.zip)
        }

        HStack {
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

            if model.hasStates {
                Divider()
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
    }

    init(model: AddressModel) {
        self.model = model
    }
}



struct AddressView_Previews: PreviewProvider {
    struct MockCountryLoader: CountryLoader {
        func loadCountries(query: String) async throws -> [String] {
            ["Country #1", "Country #2", "Country #3"]
        }
    }

    struct MockStateLoader: StateLoader {
        func loadStates(country: String) async throws -> [String] {
            ["State #1", "State #2", "State #3"]
        }
        
        func hasStates(country: String) async -> Bool {
            true
        }
    }


    struct AddressViewWrapper: View {
        @State var model: AddressModel

        var body: some View {
            AddressView(model: model)
        }
    }

    static var previews: some View {
        let _ = Container.shared.countryLoader.register { Container.DummyCountryLoader() }
        let _ = Container.shared.stateLoader.register { Container.DummyStateLoader() }
        NavigationStack {
            Form {
                AddressViewWrapper(model: AddressModel(value: .sample))
            }
        }

        let _ = Container.shared.countryLoader.register { MockCountryLoader() }
        let _ = Container.shared.stateLoader.register { MockStateLoader() }
        NavigationStack {
            Form {
                AddressViewWrapper(
                    model: AddressModel(
                        value: .init(
                            street: "Street",
                            city: "Citi",
                            zipCode: "",
                            country: "Country #1",
                            state: nil
                        )
                    )
                )
            }
        }
    }
}
