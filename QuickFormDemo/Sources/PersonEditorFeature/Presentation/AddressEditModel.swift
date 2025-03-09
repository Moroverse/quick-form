// AddressEditModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

extension Country: DefaultValueProvider {
    public static var defaultValue: Self { .unitedStates }
}

extension CountryState: DefaultValueProvider {
    public static var defaultValue: Self { .unitedStates(.california) }
}

@QuickForm(Address.self)
class AddressEditModel: Validatable {
    @PropertyEditor(keyPath: \Address.line1)
    var line1 = FormFieldViewModel(
        type: String.self,
        placeholder: "Address Line 1",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Address.line2)
    var line2 = FormFieldViewModel(
        type: String?.self,
        placeholder: "Address Line 2"
    )

    @PropertyEditor(keyPath: \Address.city)
    var city = FormFieldViewModel(
        type: String.self,
        placeholder: "City",
        validation: .of(.notEmpty)
    )

    @PropertyEditor(keyPath: \Address.zipCode)
    var zipCode = FormFieldViewModel(
        type: String.self,
        placeholder: "ZIP",
        validation: .combined(.notEmpty, .usZipCode)
    )

    @PropertyEditor(keyPath: \Address.country)
    var country = PickerFieldViewModel(
        type: Country.self,
        allValues: Country.allCases,
        title: ""
    )

    @PropertyEditor(keyPath: \Address.state)
    var state = OptionalPickerFieldViewModel(
        type: CountryState?.self,
        allValues: [],
        title: "",
        placeholder: "State"
    )

    @PostInit
    func configure() {
        country.onValueChanged { [weak self] newValue in
            self?.state.allValues = newValue.states
            self?.state.value = nil
            // Set conditional validation
            if self?.state.allValues.isEmpty == true {
                self?.state.validation = nil
            } else {
                self?.state.validation = .of(.required())
            }
        }
    }
}

// extension AddressEditModel: ValueEditor {}
