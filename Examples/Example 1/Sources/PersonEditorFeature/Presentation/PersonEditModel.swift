// PersonEditModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import Foundation
import Observation
@preconcurrency import QuickForm

extension Person.Sex: DefaultValueProvider {
    public static var defaultValue: Self = .other
}

extension Measurement: @retroactive DefaultValueProvider where UnitType == UnitMass {
    public static var defaultValue: Self = .init(value: 0, unit: .kilograms)
}

// 1. QuickForm macro
@QuickForm(Person.self)
class PersonEditModel: Validatable {
    // 2.Property Editor Macro
    @PropertyEditor(keyPath: \Person.givenName)
    // 3. Out-of box view models
    var firstName = FormFieldViewModel(
        type: String.self,
        title: "First Name:",
        placeholder: "John",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.familyName)
    var lastName = FormFieldViewModel(
        type: String.self,
        title: "Last Name:",
        placeholder: "Anderson",
        validation: .combined(.notEmpty, .minLength(2), .maxLength(50))
    )

    @PropertyEditor(keyPath: \Person.dateOfBirth)
    var birthday = FormFieldViewModel(
        type: Date.self,
        title: "Birthday:",
        placeholder: "1980-01-01"
    )

    @PropertyEditor(keyPath: \Person.sex)
    var sex = PickerFieldViewModel(
        type: Person.Sex.self,
        allValues: Person.Sex.allCases,
        title: "Sex:"
    )

    @PropertyEditor(keyPath: \Person.weight)
    var weight = FormFieldViewModel(
        type: Measurement<UnitMass>.self,
        title: "Weight:",
        placeholder: "70.0"
    )

    @PropertyEditor(keyPath: \Person.salary)
    var salary = FormattedFieldViewModel(
        type: Decimal.self,
        format: .currency(code: "USD"),
        title: "Salary:",
        placeholder: "$100,000"
    )

    @PropertyEditor(keyPath: \Person.isEstablished)
    var isEstablished = FormFieldViewModel(
        type: Bool.self,
        title: "Established:"
    )

    @PropertyEditor(keyPath: \Person.address)
    // 4. Custom view models using ValueEditor Protocol
    var address = AddressEditModel(value: .init(
        line1: "",
        city: "",
        zipCode: "",
        country: .unitedStates,
        state: .unitedStates(.california)
    ))

    @PropertyEditor(keyPath: \Person.careTeam)
    var careTeam = FormCollectionViewModel(
        type: PersonInfo.self,
        title: "Care Team"
    )

    @PropertyEditor(keyPath: \Person.phone)
    var phone = FormattedFieldViewModel(
        type: String?.self,
        format: OptionalFormat(format: .usPhoneNumber(.parentheses)),
        title: "Phone:",
        placeholder: "(123) 456-7890"
    )

    @PropertyEditor(keyPath: \Person.password)
    var password = FormFieldViewModel(
        type: String.self,
        title: "Password:",
        placeholder: "P@$$w0rd",
        validation: .combined(.notEmpty, .minLength(8))
    )

    @PropertyEditor(keyPath: \Person.passwordReentry)
    var passwordReentry = FormFieldViewModel(
        type: String.self,
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
