// AddressModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 17:46 GMT.

import Factory
import Observation
import QuickForm

@QuickForm(Address.self)
final class AddressModel {
    @Injected(\.stateLoader)
    var stateLoader: StateLoader

    @Injected(\.countryLoader)
    var countryLoader: CountryLoader

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
        validation: .combined(.notEmpty, .minLength(2))
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
        valuesProvider: { _ in
            []
        },
        queryBuilder: { $0 ?? "" }
    )

    var hasStates: Bool = false {
        didSet {
            if hasStates {
                state.validation = .of(.required())
            } else {
                state.validation = .none
            }

            state.queryBuilder = { [weak self] _ in self?.country.value ?? "" }
        }
    }

    @PostInit
    func configure() {
        Task { [weak self] in
            self?.hasStates = await self?.stateLoader.hasStates(country: self?.country.value ?? "") ?? false
        }

        state.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            return try await stateLoader.loadStates(country: query)
        }

        country.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            return try await countryLoader.loadCountries(query: query)
        }

        country.onValueChanged { [weak self] newValue in
            guard let self else { return }
            state.value = nil
            if let newValue {
                Task { [weak self] in
                    self?.hasStates = await self?.stateLoader.hasStates(country: newValue) ?? false
                }
            }
        }
    }
}
