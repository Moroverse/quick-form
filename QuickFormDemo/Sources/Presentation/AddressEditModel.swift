// AddressEditModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

import Observation
@preconcurrency import QuickForm

@QuickForm(Address.self)
class AddressEditModel {
    @PropertyEditor(keyPath: \Address.line1)
    var line1 = FormFieldViewModel(value: "", title: "Address Line 1")

    @PropertyEditor(keyPath: \Address.line2)
    var line2 = FormFieldViewModel(value: String?.none, title: "Address Line 2")

    @PropertyEditor(keyPath: \Address.city)
    var city = FormFieldViewModel(value: "", title: "City")

    @PropertyEditor(keyPath: \Address.zipCode)
    var zipCode = FormFieldViewModel(value: "", title: "Zip Code")

    @PropertyEditor(keyPath: \Address.country)
    var country = PickerFieldViewModel(value: Country.unitedStates, allValues: Country.allCases, title: "Country")

    @PropertyEditor(keyPath: \Address.state)
    var state = OptionalPickerFieldViewModel(value: CountryState?.some(.unitedStates(.california)), allValues: [], title: "State")

    convenience init(address: Address) {
        self.init(model: address)
        country.onValueChanged {[weak self] newValue in
            self?.state.allValues = newValue.states
        }
    }

}

extension AddressEditModel: ValueEditor {
    var value: Address {
        get {
            model
        }
        set(newValue) {
            model = newValue
            update()
        }
    }
}
