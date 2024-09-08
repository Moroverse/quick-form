// Person.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Foundation

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
    var salary: Double
    var weight: Measurement<UnitMass>
    var isEstablished: Bool

    init(
        givenName: String,
        familyName: String,
        dateOfBirth: Date,
        sex: Sex,
        phone: String? = nil,
        salary: Double = 0,
        weight: Measurement<UnitMass> = .init(value: 0, unit: .kilograms),
        isEstablished: Bool = true
    ) {
        self.givenName = givenName
        self.familyName = familyName
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.phone = phone
        self.salary = salary
        self.weight = weight
        self.isEstablished = isEstablished
    }
}
