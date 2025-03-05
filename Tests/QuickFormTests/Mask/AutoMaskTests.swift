// AutoMaskTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 05:30 GMT.

import Foundation
import QuickForm
import Testing

@Suite("AutoMask Tests")
struct AutoMaskTests {

    // MARK: - Phone Mask Tests

    @Test("PhoneMask.apply formats phone number correctly")
    func phoneMaskFormatsCorrectly() {
        let mask = PhoneMask()

        // Test empty string
        #expect(mask.apply(to: "") == "")

        // Test partial inputs
        #expect(mask.apply(to: "1") == "(1")
        #expect(mask.apply(to: "12") == "(12")
        #expect(mask.apply(to: "123") == "(123")
        #expect(mask.apply(to: "1234") == "(123) 4")
        #expect(mask.apply(to: "12345") == "(123) 45")
        #expect(mask.apply(to: "123456") == "(123) 456")
        #expect(mask.apply(to: "1234567") == "(123) 456-7")
        #expect(mask.apply(to: "12345678") == "(123) 456-78")
        #expect(mask.apply(to: "123456789") == "(123) 456-789")
        #expect(mask.apply(to: "1234567890") == "(123) 456-7890")

        // Test with extra digits (should truncate)
        #expect(mask.apply(to: "12345678901") == "(123) 456-7890")

        // Test with non-digit characters (should filter them out)
        #expect(mask.apply(to: "abc123def456ghi7890") == "(123) 456-7890")
        #expect(mask.apply(to: "(123) 456-7890") == "(123) 456-7890")
    }

    @Test("PhoneMask.isAllowed filters non-digits")
    func phoneMaskFiltersNonDigits() {
        let mask = PhoneMask()

        // Digits should be allowed
        for digit in "0123456789" {
            #expect(mask.isAllowed(character: digit), "Digit \(digit) should be allowed")
        }

        // Non-digits should not be allowed
        for char in "abcdefABCDEF!@#$%^&*()_+-= " {
            #expect(!mask.isAllowed(character: char), "Character \(char) should not be allowed")
        }
    }

    // MARK: - Credit Card Mask Tests

    @Test("CreditCardMask.apply formats credit card number correctly")
    func creditCardMaskFormatsCorrectly() {
        let mask = CreditCardMask()

        // Test empty string
        #expect(mask.apply(to: "") == "")

        // Test partial inputs
        #expect(mask.apply(to: "1") == "1")
        #expect(mask.apply(to: "1234") == "1234")
        #expect(mask.apply(to: "12345") == "1234 5")
        #expect(mask.apply(to: "12345678") == "1234 5678")
        #expect(mask.apply(to: "123456789") == "1234 5678 9")

        // Test complete number
        #expect(mask.apply(to: "1234567890123456") == "1234 5678 9012 3456")

        // Test with extra digits
        #expect(mask.apply(to: "12345678901234567890") == "1234 5678 9012 3456 789")

        // Test with non-digit characters
        #expect(mask.apply(to: "1234-5678-9012-3456") == "1234 5678 9012 3456")
        #expect(mask.apply(to: "1234 ABCD 9012 WXYZ") == "1234 9012")
    }

    @Test("CreditCardMask.isAllowed filters non-digits")
    func creditCardMaskFiltersNonDigits() {
        let mask = CreditCardMask()

        // Digits should be allowed
        for digit in "0123456789" {
            #expect(mask.isAllowed(character: digit), "Digit \(digit) should be allowed")
        }

        // Non-digits should not be allowed
        for char in "abcdefABCDEF!@#$%^&*()_+-= " {
            #expect(!mask.isAllowed(character: char), "Character \(char) should not be allowed")
        }
    }

    // MARK: - Pattern Mask Tests

    @Test("PatternMask.apply formats text according to pattern")
    func patternMaskFormatsCorrectly() {
        // SSN pattern: XXX-XX-XXXX
        let ssnMask = PatternMask(pattern: "XXX-XX-XXXX")

        // Test empty string
        #expect(ssnMask.apply(to: "") == "")

        // Test partial inputs
        #expect(ssnMask.apply(to: "1") == "1")
        #expect(ssnMask.apply(to: "123") == "123")
        #expect(ssnMask.apply(to: "1234") == "123-4")
        #expect(ssnMask.apply(to: "12345") == "123-45")
        #expect(ssnMask.apply(to: "123456") == "123-45-6")
        #expect(ssnMask.apply(to: "123456789") == "123-45-6789")

        // Test with extra digits (should follow pattern length)
        #expect(ssnMask.apply(to: "1234567890") == "123-45-6789")

        // Test with non-digit characters
        #expect(ssnMask.apply(to: "abc123def45ghi6789") == "123-45-6789")

        // Test custom pattern with alphanumerics
        let licenseMask = PatternMask(pattern: "AB-###-XXX", allowedCharacters: .alphanumerics)
        #expect(licenseMask.apply(to: "123XYZ") == "AB-123-XYZ")
        #expect(licenseMask.apply(to: "!@#123$%^XYZ") == "AB-123-XYZ")
    }

    @Test("PatternMask.isAllowed enforces allowed characters")
    func patternMaskFiltersCharacters() {
        // Default mask only allows digits
        let defaultMask = PatternMask(pattern: "XXX-XX-XXXX")

        // Digits should be allowed
        for digit in "0123456789" {
            #expect(defaultMask.isAllowed(character: digit), "Digit \(digit) should be allowed")
        }

        // Non-digits should not be allowed
        for char in "abcdefABCDEF!@#$%^&*()_+-= " {
            #expect(!defaultMask.isAllowed(character: char), "Character \(char) should not be allowed")
        }

        // Custom mask with alphanumerics
        let alphaMask = PatternMask(pattern: "XX-###-XXX", allowedCharacters: .alphanumerics)

        // Alphanumerics should be allowed
        for char in "abcdefABCDEF0123456789" {
            #expect(alphaMask.isAllowed(character: char), "Alphanumeric \(char) should be allowed")
        }

        // Symbols should not be allowed
        for char in "!@#$%^&*()_+-= " {
            #expect(!alphaMask.isAllowed(character: char), "Symbol \(char) should not be allowed")
        }
    }

    // MARK: - Integration Tests

    @Test("Mask formatting is idempotent")
    func maskFormattingIsIdempotent() {
        // Applying the same mask multiple times should yield the same result
        let phoneMask = PhoneMask()
        let input = "1234567890"

        let firstApply = phoneMask.apply(to: input)
        let secondApply = phoneMask.apply(to: firstApply)

        #expect(firstApply == "(123) 456-7890")
        #expect(secondApply == "(123) 456-7890")

        let licenseMask = PatternMask(pattern: "AB-###-XXX", allowedCharacters: .alphanumerics)
        let licenseInput = "123XYZ"

        let firstLicenseApply = licenseMask.apply(to: licenseInput)
        let secondLicenseApply = licenseMask.apply(to: firstLicenseApply)

        #expect(firstLicenseApply == "AB-123-XYZ")
        #expect(secondLicenseApply == "AB-123-XYZ")
    }

    @Test("Mask handles international format")
    func maskHandlesInternationalFormat() {
        // Create a custom international phone mask
        let intlPhoneMask = PatternMask(pattern: "+X (XXX) XXX-XX-XX")

        #expect(intlPhoneMask.apply(to: "71234567890") == "+7 (123) 456-78-90")
        #expect(intlPhoneMask.apply(to: "+7(123)456-78-90") == "+7 (123) 456-78-90")
    }
}
