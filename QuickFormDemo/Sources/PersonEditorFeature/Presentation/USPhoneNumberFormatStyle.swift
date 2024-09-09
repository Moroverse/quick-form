// USPhoneNumberFormatStyle.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-08 21:11 GMT.

import Foundation

struct USPhoneNumberFormatStyle: Codable, ParseableFormatStyle {
    enum FormatType: Codable {
        case standard
        case parentheses
    }

    typealias Strategy = USPhoneNumberParseStrategy

    private let formatType: FormatType

    var parseStrategy: USPhoneNumberParseStrategy {
        USPhoneNumberParseStrategy()
    }

    init(_ formatType: FormatType = .standard) {
        self.formatType = formatType
    }

    func format(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleaned.count == 10 else { return value }

        switch formatType {
        case .standard:
            return cleaned.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression)

        case .parentheses:
            return cleaned.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression)
        }
    }
}

struct USPhoneNumberParseStrategy: ParseStrategy {
    func parse(_ value: String) throws -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleaned.count == 10 else {
            throw ParseError.invalidPhoneNumber
        }
        return cleaned
    }
}

enum ParseError: Error {
    case invalidPhoneNumber
}

extension FormatStyle where Self == USPhoneNumberFormatStyle {
    static var usPhoneNumber: USPhoneNumberFormatStyle { USPhoneNumberFormatStyle() }
    static func usPhoneNumber(_ formatType: USPhoneNumberFormatStyle.FormatType) -> USPhoneNumberFormatStyle {
        USPhoneNumberFormatStyle(formatType)
    }
}
