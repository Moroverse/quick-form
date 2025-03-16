// Address.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 05:25 GMT.

public struct Address {
    public var street: String
    public var city: String
    public var zipCode: String
    public var country: String?
    public var state: String?

    public init(street: String, city: String, zipCode: String, country: String? = nil, state: String? = nil) {
        self.street = street
        self.city = city
        self.zipCode = zipCode
        self.country = country
        self.state = state
    }
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
