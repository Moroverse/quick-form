// PersonForm.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

@QuickForm(Person.self)
class PersonForm {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = PropertyViewModel(value: "", title: "First Name:", placeholder: "John")

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = PropertyViewModel(value: "", title: "Last Name:", placeholder: "Anderson")

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = PropertyViewModel(value: Date(), title: "Birthday:", placeholder: "1980-01-01")

    var personNameComponents: PersonNameComponents {
        PersonNameComponents(givenName: firstName.value, familyName: lastName.value)
    }
}
