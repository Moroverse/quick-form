// CountryState.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 08:55 GMT.

enum CountryState: Identifiable, Hashable, Equatable {
    case unitedStates(USState)
    case canada(CanadaProvince)
    case australia(AustraliaState)
    case india(IndiaState)
    case brazil(BrazilState)

    var id: Self { self }
}

enum USState: CaseIterable {
    case newYork
    case california
    case texas
    // Add more states...
}

enum CanadaProvince: CaseIterable {
    case ontario
    case quebec
    case britishColumbia
    // Add more provinces...
}

enum AustraliaState: CaseIterable {
    case newSouthWales
    case victoria
    case queensland
    // Add more states...
}

enum IndiaState: CaseIterable {
    case maharashtra
    case delhi
    case karnataka
    // Add more states...
}

enum BrazilState: CaseIterable {
    case saoPaulo
    case rioDeJaneiro
    case minasGerais
    // Add more states...
}
