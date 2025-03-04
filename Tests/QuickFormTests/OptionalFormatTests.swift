// OptionalFormatTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 08:27 GMT.

import Foundation
import Numerics
import QuickForm
import Testing

@Suite("OptionalFormat Tests")
struct OptionalFormatTests {
    @Test("Formats non-nil values using the wrapped format")
    func formatsNonNilValues() {
        let locale = Locale(identifier: "en_US")
        // Test with currency format
        let currencyFormat = OptionalFormat(format: .currency(code: "USD").locale(locale))
        let formattedCurrency = currencyFormat.format(1234.56)

        // Assert that currency formatting is applied
        #expect(formattedCurrency == "$1,234.56")

        // Test with number format
        let numberFormat = OptionalFormat(format: .number.precision(.fractionLength(2)).locale(locale))
        let formattedNumber = numberFormat.format(42.5)

        #expect(formattedNumber == "42.50")

        // Test with date format
        let dateFormat = OptionalFormat(format: .dateTime.year().month().day().locale(locale))
        let date = Date(timeIntervalSince1970: 0) // 1970-01-01
        let formattedDate = dateFormat.format(date)

        #expect(formattedDate == "Jan 1, 1970")
    }

    @Test("Formats nil values as empty strings")
    func formatsNilAsEmptyString() {
        // Test with various format types
        let currencyFormat = OptionalFormat(format: .currency(code: "USD"))
        let numberFormat = OptionalFormat(format: .number)
        let dateFormat = OptionalFormat(format: .dateTime)
        let percentFormat = OptionalFormat(format: .percent)
        let stringFormat = OptionalFormat(format: PlainStringFormat())

        #expect(currencyFormat.format(Decimal?.none) == "")
        #expect(numberFormat.format(Decimal?.none) == "")
        #expect(dateFormat.format(Date?.none) == "")
        #expect(percentFormat.format(Decimal?.none) == "")
        #expect(stringFormat.format(String?.none) == "")
    }

    @Test("Parses non-empty strings correctly")
    func parsesNonEmptyStrings() {
        let locale = Locale(identifier: "en_US")
        // Test parsing currency
        let currencyFormat = OptionalFormat(format: .currency(code: "USD").locale(locale))

        do {
            let parsedCurrency = try currencyFormat.parseStrategy.parse("$1,234.56")
            #expect(parsedCurrency != nil)
            #expect(abs(parsedCurrency! - 1234.56) < 0.001)
        } catch {
            Issue.record("Failed to parse currency: \(error)")
        }

        // Test parsing number
        let numberFormat = OptionalFormat(format: .number.locale(locale))

        do {
            let parsedNumber = try numberFormat.parseStrategy.parse("42.5")
            #expect(parsedNumber != nil)
            #expect(parsedNumber! == 42.5)
        } catch {
            Issue.record("Failed to parse number: \(error)")
        }

        // Test parsing plain string
        let stringFormat = OptionalFormat(format: PlainStringFormat())

        do {
            let parsedString = try stringFormat.parseStrategy.parse("Hello World")
            #expect(parsedString != nil)
            #expect(parsedString! == "Hello World")
        } catch {
            Issue.record("Failed to parse string: \(error)")
        }
    }

    @Test("Parses empty strings as nil")
    func parsesEmptyStringAsNil() {
        let currencyFormat = OptionalFormat(format: .currency(code: "USD"))
        let numberFormat = OptionalFormat(format: .number)
        let stringFormat = OptionalFormat(format: PlainStringFormat())

        do {
            let parsedCurrency = try currencyFormat.parseStrategy.parse("")
            #expect(parsedCurrency == nil)

            let parsedNumber = try numberFormat.parseStrategy.parse("")
            #expect(parsedNumber == nil)

            let parsedString = try stringFormat.parseStrategy.parse("")
            #expect(parsedString == nil)
        } catch {
            Issue.record("Failed to parse empty string: \(error)")
        }
    }

    @Test("Parses whitespace-only strings as empty strings (non-nil)")
    func parsesWhitespaceStrings() {
        let stringFormat = OptionalFormat(format: PlainStringFormat())

        do {
            let parsedString = try stringFormat.parseStrategy.parse("   ")
            #expect(parsedString != nil)
            #expect(parsedString! == "   ")
        } catch {
            Issue.record("Failed to parse whitespace string: \(error)")
        }
    }

    @Test("Throws error when parsing invalid format")
    func throwsErrorForInvalidFormat() throws {
        let numberFormat = OptionalFormat(format: .number)
        #expect(throws: (any Error).self) {
            try numberFormat.parseStrategy.parse("not a number")
        }
    }

    @Test("Round-trip formatting and parsing")
    func roundTripFormattingAndParsing() throws {
        let currencyFormat = OptionalFormat(format: .currency(code: "USD"))
        let originalValue: Decimal? = 1234.56

        // Format the value
        let formatted = currencyFormat.format(originalValue)
        let parsedValue = try #require(try currencyFormat.parseStrategy.parse(formatted))
        #expect(abs(parsedValue - originalValue!) < 0.001)
    }
}
