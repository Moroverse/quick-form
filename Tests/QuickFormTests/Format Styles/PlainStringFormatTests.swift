// PlainStringFormatTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-04 09:22 GMT.

import Foundation
import QuickForm
import Testing

@Suite("PlainStringFormat Tests")
struct PlainStringFormatTests {
    @Test("Formats values without modification")
    func formatsWithoutModification() {
        let format = PlainStringFormat()

        // Test with regular strings
        #expect(format.format("Hello World") == "Hello World")
        #expect(format.format("") == "")
        #expect(format.format("12345") == "12345")

        // Test with special characters
        #expect(format.format("!@#$%^&*()") == "!@#$%^&*()")

        // Test with whitespace
        #expect(format.format("   ") == "   ")
        #expect(format.format(" Hello ") == " Hello ")

        // Test with newlines and tabs
        #expect(format.format("Line 1\nLine 2") == "Line 1\nLine 2")
        #expect(format.format("Tab\tCharacter") == "Tab\tCharacter")
    }

    @Test("Parses strings without modification")
    func parsesWithoutModification() throws {
        let format = PlainStringFormat()
        let strategy = format.parseStrategy

        // Test with regular strings
        #expect(try strategy.parse("Hello World") == "Hello World")
        #expect(try strategy.parse("") == "")
        #expect(try strategy.parse("12345") == "12345")

        // Test with special characters
        #expect(try strategy.parse("!@#$%^&*()") == "!@#$%^&*()")

        // Test with whitespace
        #expect(try strategy.parse("   ") == "   ")
        #expect(try strategy.parse(" Hello ") == " Hello ")

        // Test with newlines and tabs
        #expect(try strategy.parse("Line 1\nLine 2") == "Line 1\nLine 2")
        #expect(try strategy.parse("Tab\tCharacter") == "Tab\tCharacter")
    }

    @Test("Round-trip formatting and parsing")
    func roundTripFormattingAndParsing() throws {
        let format = PlainStringFormat()
        let originalValue = "Sample Text 123"

        // Format the original value
        let formatted = format.format(originalValue)
        let parsed = try format.parseStrategy.parse(formatted)
        #expect(parsed == originalValue)
    }
}
