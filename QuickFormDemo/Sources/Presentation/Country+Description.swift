//
//  Country+Description.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 8.9.24..
//

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
