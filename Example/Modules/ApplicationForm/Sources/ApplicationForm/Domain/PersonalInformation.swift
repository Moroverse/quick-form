// PersonalInformation.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

struct PersonalInformation {
    var givenName: String
    var familyName: String
    var email: String
    var phoneNumber: String
    var address: Address
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
