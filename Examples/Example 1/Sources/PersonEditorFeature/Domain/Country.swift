// Country.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

enum Country: String, CaseIterable, Identifiable {
    case unitedStates
    case canada
    case unitedKingdom
    case australia
    case germany
    case france
    case japan
    case china
    case india
    case brazil
    // Add more countries as needed

    var id: Self { self }
}

extension Country {
    public var hasStates: Bool {
        switch self {
        case .unitedStates, .canada, .australia, .india, .brazil:
            true

        default:
            false
        }
    }

    public var states: [CountryState] {
        switch self {
        case .unitedStates:
            USState.allCases.map { CountryState.unitedStates($0) }

        case .canada:
            CanadaProvince.allCases.map { CountryState.canada($0) }

        case .australia:
            AustraliaState.allCases.map { CountryState.australia($0) }

        case .india:
            IndiaState.allCases.map { CountryState.india($0) }

        case .brazil:
            BrazilState.allCases.map { CountryState.brazil($0) }

        default:
            []
        }
    }
}
