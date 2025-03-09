// PersonalInformationModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:06 GMT.

//
//  PersonalInformationModel.swift
//  Example
//
//  Created by Daniel Moro on 9.3.25..
//
import Observation
import QuickForm

@QuickForm(PersonalInformation.self)
final class PersonalInformationModel {
    @PropertyEditor(keyPath: \PersonalInformation.givenName)
    var givenName = FormFieldViewModel(
        type: String.self,
        title: "Given Name",
        placeholder: "John",
        isReadOnly: false
    )

    @PropertyEditor(keyPath: \PersonalInformation.familyName)
    var familyName = FormFieldViewModel(
        type: String.self,
        title: "Family Name",
        placeholder: "Doe",
        validation: .of(.notEmpty)
    )
}
