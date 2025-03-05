// USPhoneNumberFormatStyle.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

import Foundation

public struct USPhoneNumberFormatStyle: Codable, ParseableFormatStyle {
    public enum FormatType: Codable {
        case standard
        case parentheses
    }

    public typealias Strategy = USPhoneNumberParseStrategy

    private let formatType: FormatType

    public var parseStrategy: USPhoneNumberParseStrategy {
        USPhoneNumberParseStrategy()
    }

    public init(_ formatType: FormatType = .standard) {
        self.formatType = formatType
    }

    public func format(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard cleaned.count == 10 else { return value }

        switch formatType {
        case .standard:
            return cleaned.replacingOccurrences(
                of: "(\\d{3})(\\d{3})(\\d+)",
                with: "$1-$2-$3",
                options: .regularExpression
            )

        case .parentheses:
            return cleaned.replacingOccurrences(
                of: "(\\d{3})(\\d{3})(\\d+)",
                with: "($1) $2-$3",
                options: .regularExpression
            )
        }
    }
}

public struct USPhoneNumberParseStrategy: ParseStrategy {
    public func parse(_ value: String) throws -> String {
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

public extension FormatStyle where Self == USPhoneNumberFormatStyle {
    static var usPhoneNumber: USPhoneNumberFormatStyle { USPhoneNumberFormatStyle() }
    static func usPhoneNumber(_ formatType: USPhoneNumberFormatStyle.FormatType) -> USPhoneNumberFormatStyle {
        USPhoneNumberFormatStyle(formatType)
    }
}
