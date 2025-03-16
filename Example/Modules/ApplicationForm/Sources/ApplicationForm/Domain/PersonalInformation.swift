// PersonalInformation.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:25 GMT.

public struct PersonalInformation {
    public var givenName: String
    public var familyName: String
    public var email: String
    public var phoneNumber: String
    public var address: Address

    public init(givenName: String, familyName: String, email: String, phoneNumber: String, address: Address) {
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
    }
}

#if DEBUG
    extension PersonalInformation {
        static var sample: Self {
            .init(
                givenName: "Daniel",
                familyName: "Moro",
                email: "daniel@moro.dev",
                phoneNumber: "+381612345678",
                address: .sample
            )
        }
    }
#endif
