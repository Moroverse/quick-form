// PersonEditModel.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

// 1. QuickForm macro
@QuickForm(Person.self)
class PersonEditModel: Validatable {
    // 2.Property Editor Macro
    @PropertyEditor(keyPath: \Person.givenName)
    // 3. Out-of box view models
    var firstName = FormFieldViewModel(
        value: "",
        title: "First Name:",
        placeholder: "John",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = FormFieldViewModel(
        value: "",
        title: "Last Name:",
        placeholder: "Anderson",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(
        value: Date(),
        title: "Birthday:",
        placeholder: "1980-01-01"
    )

    @PropertyEditor(keyPath: \Person.sex)
    var sex = PickerFieldViewModel(
        value: Person.Sex.other,
        allValues: Person.Sex.allCases,
        title: "Sex:"
    )

    @PropertyEditor(keyPath: \Person.weight)
    var weight = FormFieldViewModel(
        value: Measurement<UnitMass>(value: 0, unit: .kilograms),
        title: "Weight:",
        placeholder: "70.0"
    )

    @PropertyEditor(keyPath: \Person.salary)
    var salary = FormattedFieldViewModel(
        value: 0.0,
        format: .currency(code: "USD"),
        title: "Salary:",
        placeholder: "$100,000"
    )

    @PropertyEditor(keyPath: \Person.isEstablished)
    var isEstablished = FormFieldViewModel(
        value: false,
        title: "Established:"
    )

    @PropertyEditor(keyPath: \Person.address)
    // 4. Custom view models using ValueEditor Protocol
    var address = AddressEditModel(model: .init(
        line1: "",
        city: "",
        zipCode: "",
        country: .unitedStates,
        state: .unitedStates(.california)
    ))

    @PropertyEditor(keyPath: \Person.careTeam)
    var careTeam = FormCollectionViewModel(
        value: [PersonInfo](),
        title: "Care Team"
    )

    @PropertyEditor(keyPath: \Person.phone)
    var phone = FormattedFieldViewModel(
        value: "",
        format: OptionalFormat(format: .usPhoneNumber(.parentheses)),
        title: "Phone:",
        placeholder: "(123) 456-7890"
    )

    @PropertyEditor(keyPath: \Person.password)
    var password = FormFieldViewModel(
        value: "",
        title: "Password:",
        placeholder: "P@$$w0rd",
        validation: .combined(.notEmpty, .minLength(8))
    )

    @PropertyEditor(keyPath: \Person.passwordReentry)
    var passwordReentry = FormFieldViewModel(
        value: "",
        title: "Password Again:",
        placeholder: "P@$$w0rd"
    )

    @PropertyEditor(keyPath: \Person.avatar)
    var avatar = AsyncPickerFieldViewModel(value: nil, title: "Avatar:") { query in
        try await AvatarFetcher.shared.fetchAvatar(query: query)
    } queryBuilder: { text in
        text ?? ""
    }

    // 5. decorations in the class
    var personNameComponents: PersonNameComponents {
        PersonNameComponents(givenName: firstName.value, familyName: lastName.value)
    }

    @PostInit
    func configure() {
        addCustomValidationRule(AgeValidationRule())
        addCustomValidationRule(PasswordMatchRule())
    }
}
