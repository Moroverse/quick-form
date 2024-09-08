// Country.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 04:33 GMT.

struct CountryState: Identifiable, Equatable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

enum Country: String, CaseIterable, Identifiable {
    case unitedStates = "United States"
    case canada = "Canada"
    case unitedKingdom = "United Kingdom"
    case australia = "Australia"
    case germany = "Germany"
    case france = "France"
    case japan = "Japan"
    case china = "China"
    case india = "India"
    case brazil = "Brazil"
    // Add more countries as needed

    var id: String { rawValue }

    var hasStates: Bool {
        switch self {
        case .unitedStates, .canada, .australia, .india, .brazil:
            true
        default:
            false
        }
    }

    var states: [CountryState] {
        switch self {
        case .unitedStates:
            [
                CountryState(id: "NY", name: "New York"),
                CountryState(id: "CA", name: "California"),
                CountryState(id: "TX", name: "Texas")
                // Add more states...
            ]

        case .canada:
            [
                CountryState(id: "ON", name: "Ontario"),
                CountryState(id: "QC", name: "Quebec"),
                CountryState(id: "BC", name: "British Columbia")
                // Add more provinces...
            ]

        case .australia:
            [
                CountryState(id: "NSW", name: "New South Wales"),
                CountryState(id: "VIC", name: "Victoria"),
                CountryState(id: "QLD", name: "Queensland")
                // Add more states...
            ]

        case .india:
            [
                CountryState(id: "MH", name: "Maharashtra"),
                CountryState(id: "DL", name: "Delhi"),
                CountryState(id: "KA", name: "Karnataka")
                // Add more states...
            ]

        case .brazil:
            [
                CountryState(id: "SP", name: "São Paulo"),
                CountryState(id: "RJ", name: "Rio de Janeiro"),
                CountryState(id: "MG", name: "Minas Gerais")
                // Add more states...
            ]

        default:
            []
        }
    }
}
