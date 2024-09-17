//
//  UnitDuration+Extensions.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 17.9.24..
//

import Foundation
import QuickForm

extension UnitDuration {
    static let days = UnitDuration(symbol: "days", converter: UnitConverterLinear(coefficient: 3600 * 24))
    static let weeks = UnitDuration(symbol: "weeks", converter: UnitConverterLinear(coefficient: 3600 * 24 * 7))
    static let months = UnitDuration(symbol: "months", converter: UnitConverterLinear(coefficient: 3600 * 24 * 30))
}

extension UnitDuration: @retroactive Identifiable {}

extension UnitDuration: @retroactive AllValues {
    public static var allCases: [UnitDuration] {
        [
            .picoseconds,
            .nanoseconds,
            .milliseconds,
            .microseconds,
            .seconds,
            .minutes,
            .hours,
            .days,
            .weeks,
            .months
        ]
    }
}
