// AddressModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:59 GMT.

import Observation
import QuickForm

@QuickForm(Address.self)
final class AddressModel {
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
        valuesProvider: {
            try await MockCountryLoader().loadCountries(query: $0)
        },
        queryBuilder: { $0 ?? "" }
    )
}
