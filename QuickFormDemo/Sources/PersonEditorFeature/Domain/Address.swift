// Address.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

struct Address: Equatable {
    var line1: String
    var line2: String?
    var city: String
    var zipCode: String
    var country: Country
    var state: CountryState?

    init(
        line1: String,
        line2: String? = nil,
        city: String,
        zipCode: String,
        country: Country,
        state: CountryState? = nil
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.zipCode = zipCode
        self.country = country
        self.state = state
    }
}
