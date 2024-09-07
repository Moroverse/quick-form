//
//  Person.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 7.9.24..
//


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
