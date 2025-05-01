// CountryState+Description.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

extension CountryState: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unitedStates(state):
            state.description

        case let .canada(state):
            state.description

        case let .australia(state):
            state.description

        case let .india(state):
            state.description

        case let .brazil(state):
            state.description
        }
    }
}

extension USState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .newYork: "New York"
        case .california: "California"
        case .texas: "Texas"
        }
    }
}

extension CanadaProvince: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ontario: "Ontario"
        case .quebec: "Quebec"
        case .britishColumbia: "British Columbia"
        }
    }
}

extension AustraliaState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .newSouthWales: "New South Wales"
        case .victoria: "Victoria"
        case .queensland: "Queensland"
        }
    }
}

extension IndiaState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .maharashtra: "Maharashtra"
        case .delhi: "Delhi"
        case .karnataka: "Karnataka"
        }
    }
}

extension BrazilState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .saoPaulo: "São Paulo"
        case .rioDeJaneiro: "Rio de Janeiro"
        case .minasGerais: "Minas Gerais"
        }
    }
}
