// PersonForm.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Observation
@preconcurrency import QuickForm

@QuickForm(Person.self)
class PersonForm {
    @PropertyEditor(keyPath: \Person.givenName)
    var firstName = PropertyViewModel(value: "", title: "First Name:", placeholder: "John")

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = PropertyViewModel(value: "", title: "Last Name:", placeholder: "Anderson")

//    public convenience init(model2: Person) {
//        self.init(model: model2)  // Calls the macro-generated initializer
//    }
}
