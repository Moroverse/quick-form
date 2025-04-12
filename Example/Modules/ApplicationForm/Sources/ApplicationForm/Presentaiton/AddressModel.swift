// AddressModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 06:05 GMT.

import Observation
import QuickForm

@QuickForm(Address.self)
public final class AddressModel {
    public struct Dependencies {
        let stateLoader: StateLoader
        let countryLoader: CountryLoader

        public init(stateLoader: StateLoader, countryLoader: CountryLoader) {
            self.stateLoader = stateLoader
            self.countryLoader = countryLoader
        }
    }

    @Dependency
    let dependencies: Dependencies

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
            self?.hasStates = await self?.dependencies.stateLoader.hasStates(country: self?.country.value ?? "") ?? false
        }

        state.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            return try await dependencies.stateLoader.loadStates(country: query)
        }

        country.valuesProvider = { [weak self] query in
            guard let self else { return [] }
            return try await dependencies.countryLoader.loadCountries(query: query)
        }

        country.onValueChanged { [weak self] newValue in
            guard let self else { return }
            state.value = nil
            if let newValue {
                Task { [weak self] in
                    self?.hasStates = await self?.dependencies.stateLoader.hasStates(country: newValue) ?? false
                }
            }
        }
    }
}
