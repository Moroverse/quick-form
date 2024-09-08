// Country.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.



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

    public var id: Self { self }
}

extension Country {
    public var hasStates: Bool {
        switch self {
        case .unitedStates, .canada, .australia, .india, .brazil:
            return true
        default:
            return false
        }
    }

    public var states: [CountryState] {
        switch self {
        case .unitedStates:
            return USState.allCases.map { CountryState.unitedStates($0) }
        case .canada:
            return CanadaProvince.allCases.map { CountryState.canada($0) }
        case .australia:
            return AustraliaState.allCases.map { CountryState.australia($0) }
        case .india:
            return IndiaState.allCases.map { CountryState.india($0) }
        case .brazil:
            return BrazilState.allCases.map { CountryState.brazil($0) }
        default:
            return []
        }
    }
}
