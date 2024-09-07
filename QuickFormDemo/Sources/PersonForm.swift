//
//  PersonForm.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 7.9.24..
//

@preconcurrency import QuickForm
import Observation

@QuickForm(Person.self)
class PersonForm {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = PropertyViewModel(value: "", title: "First Name:", placeholder: "John")

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = PropertyViewModel(value: "", title: "Last Name:", placeholder: "Anderson")
}
