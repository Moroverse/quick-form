// Person.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import Foundation

struct PersonInfo: Equatable, Identifiable {
    var id: Int
    var name: String
}

struct Avatar: Identifiable, Equatable {
    var id: Int
    var imageName: String
}

struct Person: Equatable {
    enum Sex: Equatable, CaseIterable {
        case male
        case female
        case nonBinary
        case other
    }

    var givenName: String
    var familyName: String
    var dateOfBirth: Date
    var sex: Sex
    var phone: String?
    var salary: Decimal
    var weight: Measurement<UnitMass>
    var isEstablished: Bool
    var address: Address
    var careTeam: [PersonInfo]
    var password: String
    var passwordReentry: String
    var avatar: Avatar?

    init(
        givenName: String,
        familyName: String,
        dateOfBirth: Date,
        sex: Sex,
        phone: String? = nil,
        salary: Decimal = 0,
        weight: Measurement<UnitMass> = .init(value: 0, unit: .kilograms),
        isEstablished: Bool = true,
        address: Address,
        careTeam: [PersonInfo] = [],
        password: String = "",
        passwordReentry: String = "",
        avatar: Avatar? = nil
    ) {
        self.givenName = givenName
        self.familyName = familyName
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.phone = phone
        self.salary = salary
        self.weight = weight
        self.isEstablished = isEstablished
        self.address = address
        self.careTeam = careTeam
        self.password = password
        self.passwordReentry = passwordReentry
        self.avatar = avatar
    }
}
