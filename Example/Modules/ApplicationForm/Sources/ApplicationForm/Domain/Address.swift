// Address.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

struct Address {
    var street: String
    var city: String
    var zipCode: String
    var country: String?
    var state: String?
}

#if DEBUG
    extension Address {
        static var sample: Address {
            .init(
                street: "123 Main St",
                city: "Anytown",
                zipCode: "12345",
                country: "Tonga",
                state: nil
            )
        }
    }
#endif
