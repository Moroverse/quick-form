// Country+Description.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-08 08:55 GMT.

extension Country: CustomStringConvertible {
    var description: String {
        switch self {
        case .unitedStates: "United States"
        case .canada: "Canada"
        case .unitedKingdom: "United Kingdom"
        case .australia: "Australia"
        case .germany: "Germany"
        case .france: "France"
        case .japan: "Japan"
        case .china: "China"
        case .india: "India"
        case .brazil: "Brazil"
        }
    }
}
