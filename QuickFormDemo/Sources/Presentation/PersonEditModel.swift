// PersonEditModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(Person.self)
class PersonEditModel {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = FormFieldViewModel(value: "", title: "First Name:", placeholder: "John")

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = FormFieldViewModel(value: "", title: "Last Name:", placeholder: "Anderson")

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(value: Date(), title: "Birthday:", placeholder: "1980-01-01")

    @PropertyEditor(keyPath: \Person.sex)
    var sex = PickerFieldViewModel(value: Person.Sex.other, allValues: Person.Sex.allCases, title: "Sex:")

    @PropertyEditor(keyPath: \Person.weight)
    var weight = FormFieldViewModel(value: Measurement<UnitMass>(value: 0, unit: .kilograms), title: "Weight:", placeholder: "70.0")

    @PropertyEditor(keyPath: \Person.salary)
    var salary = FormattedFieldViewModel(value: 0.0, format: .currency(code: "USD"), title: "Salary:", placeholder: "$100,000")

    @PropertyEditor(keyPath: \Person.isEstablished)
    var isEstablished = FormFieldViewModel(value: false, title: "Established:")

    var personNameComponents: PersonNameComponents {
        PersonNameComponents(givenName: firstName.value, familyName: lastName.value)
    }
}
