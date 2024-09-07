// Person.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-07 11:54 GMT.

import Foundation

public struct Person: Equatable {
    public enum Sex: Equatable {
        case male
        case female
        case nonBinary
        case other
    }

    public var givenName: String
    public var familyName: String
    public var dateOfBirth: Date
    public var sex: Sex
    public var phone: String?

    public init(givenName: String, familyName: String, dateOfBirth: Date, sex: Sex, phone: String? = nil) {
        self.givenName = givenName
        self.familyName = familyName
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.phone = phone
    }
}
