// PersonalInformationModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:35 GMT.

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

    @PropertyEditor(keyPath: \PersonalInformation.email)
    var emailName = FormFieldViewModel(
        type: String.self,
        title: "Email",
        placeholder: "johndoe@example.com",
        validation: .of(.email)
    )

    @PropertyEditor(keyPath: \PersonalInformation.phoneNumber)
    var phoneNumber = FormattedFieldViewModel(
        type: String.self,
        format: .usPhoneNumber(.parentheses),
        title: "Phone Number",
        placeholder: "(123) 456-789"
    )

    @PropertyEditor(keyPath: \PersonalInformation.address)
    var address = AddressModel(value: .sample)
}
