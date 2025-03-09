// AddressModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:59 GMT.

import Observation
import QuickForm

@QuickForm(Address.self)
final class AddressModel {
    var stateLoader: StateLoader?
    var countryLoader: CountryLoader?

    @PropertyEditor(keyPath: \Address.street)
    var street = FormFieldViewModel(
        type: String.self,
        title: "Street:",
        placeholder: "5th Avenue",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Address.city)
    var city = FormFieldViewModel(
        type: String.self,
        title: "City:",
        placeholder: "New York",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Address.zipCode)
    var zip = FormFieldViewModel(
        type: String.self,
        title: "Postal Code:",
        placeholder: "12345",
        validation: .of(.usZipCode)
    )

    @PropertyEditor(keyPath: \Address.country)
    var country = AsyncPickerFieldViewModel(
        type: String?.self,
        placeholder: "Select Country...",
        validation: .of(.required()),
        valuesProvider: { _ in
            []
        },
        queryBuilder: { $0 ?? "" }
    )

    @PropertyEditor(keyPath: \Address.state)
    var state = AsyncPickerFieldViewModel(
        type: String?.self,
        placeholder: "Select State...",
        validation: .of(.required()),
        valuesProvider: { _ in
            []
        },
        queryBuilder: { $0 ?? "" }
    )

    @PostInit
    func configure() {
        stateLoader = MockStateLoader()
        countryLoader = MockCountryLoader()

        state.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            let result = try await stateLoader?.loadStates(country: query)
            return result ?? []
        }

        country.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            let result = try await countryLoader?.loadCountries(query: query)
            return result ?? []
        }

        country.onValueChanged { [weak self] newValue in
            guard let self else { return }
            state.value = nil
            if let newValue {
                Task { [weak self] in
                    if await self?.stateLoader?.hasStates(country: newValue) == true {
                        self?.state.validation = .of(.required())
                    } else {
                        self?.state.validation = .none
                    }
                    self?.state.queryBuilder = { _ in newValue }
                }
            } else {
                state.validation = .none
                state.queryBuilder = { $0 ?? "" }
            }
        }
    }
}
