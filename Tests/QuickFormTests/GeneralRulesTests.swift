//
//  GeneralRulesTests.swift
//  quick-form
//
//  Created by Daniel Moro on 4.3.25..
//

import Foundation
import QuickForm
import Testing

@Suite("General Validation Rules Tests")
struct GeneralRulesTests {

    // MARK: - NotEmptyRule Tests

    @Test("NotEmptyRule validates non-empty strings as valid")
    func notEmptyRule_ValidatesNonEmptyStrings() {
        let rule = NotEmptyRule()

        #expect(rule.validate("Hello").isSuccessful)
        #expect(rule.validate("A").isSuccessful)
        #expect(rule.validate(" ").isSuccessful) // Space is not empty
        #expect(rule.validate("\n").isSuccessful) // Newline is not empty
    }

    @Test("NotEmptyRule validates empty strings as invalid")
    func notEmptyRule_ValidatesEmptyStringsAsInvalid() {
        let rule = NotEmptyRule()

        let result = rule.validate("")
        #expect(!result.isSuccessful)

        if case .failure(let message) = result {
            #expect(String(localized: message) == "This field cannot be empty")
        } else {
            Issue.record("Expected failure message")
        }
    }

    @Test("NotEmptyRule static property creates a valid rule")
    func notEmptyRule_StaticProperty() {
        let rule: NotEmptyRule = .notEmpty

        #expect(rule.validate("Hello").isSuccessful)
        #expect(!rule.validate("").isSuccessful)
    }

    // MARK: - MaxLengthRule Tests

    @Test("MaxLengthRule validates strings under maximum length as valid")
    func maxLengthRule_ValidatesStringsUnderMaximumLength() {
        let rule = MaxLengthRule(length: 5)

        #expect(rule.validate("").isSuccessful)
        #expect(rule.validate("A").isSuccessful)
        #expect(rule.validate("Hello").isSuccessful) // Exactly 5 characters
    }

    @Test("MaxLengthRule validates strings over maximum length as invalid")
    func maxLengthRule_ValidatesStringsOverMaximumLengthAsInvalid() {
        let rule: MaxLengthRule = .maxLength(5)

        let result = rule.validate("Hello World")
        #expect(!result.isSuccessful)

        if case .failure(var message) = result {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "This field must not exceed 5 characters")
        } else {
            Issue.record("Expected failure message")
        }
    }

    @Test("MaxLengthRule static factory method creates a valid rule")
    func maxLengthRule_StaticFactoryMethod() {
        let rule: MaxLengthRule = .maxLength(5)

        #expect(rule.validate("Hello").isSuccessful)
        #expect(!rule.validate("Hello World").isSuccessful)
    }

    // MARK: - MinLengthRule Tests

    @Test("MinLengthRule validates strings over minimum length as valid")
    func minLengthRule_ValidatesStringsOverMinimumLength() {
        let rule = MinLengthRule(length: 5)

        #expect(rule.validate("Hello").isSuccessful) // Exactly 5 characters
        #expect(rule.validate("Hello World").isSuccessful)
    }

    @Test("MinLengthRule validates strings under minimum length as invalid")
    func minLengthRule_ValidatesStringsUnderMinimumLengthAsInvalid() {
        let rule: MinLengthRule = .minLength(5)

        let result = rule.validate("Hi")
        #expect(!result.isSuccessful)

        if case .failure(let message) = result {
            #expect(String(localized: message).contains("must be at least 5 characters"))
        } else {
            Issue.record("Expected failure message")
        }
    }

    @Test("MinLengthRule static factory method creates a valid rule")
    func minLengthRule_StaticFactoryMethod() {
        let rule: MinLengthRule = .minLength(5)

        #expect(rule.validate("Hello").isSuccessful)
        #expect(!rule.validate("Hi").isSuccessful)
    }

    // MARK: - RequiredRule Tests

    @Test("RequiredRule validates non-nil values as valid")
    func requiredRule_ValidatesNonNilValues() {
        let rule = RequiredRule<String>()

        #expect(rule.validate("Hello").isSuccessful)
        #expect(rule.validate("").isSuccessful) // Empty string is not nil
    }

    @Test("RequiredRule validates nil values as invalid")
    func requiredRule_ValidatesNilValuesAsInvalid() {
        let rule = RequiredRule<String>()

        let result = rule.validate(nil)
        #expect(!result.isSuccessful)

        if case .failure(let message) = result {
            #expect(String(localized: message) == "This field is required")
        } else {
            Issue.record("Expected failure message")
        }
    }

    @Test("RequiredRule factory method creates a valid rule")
    func requiredRule_FactoryMethod() {
        let rule: AnyValidationRule<String?> = .required()

        #expect(rule.validate("Hello").isSuccessful)
        #expect(!rule.validate(nil).isSuccessful)
    }

    // MARK: - Combining Rules Tests

    @Test("Combined rules all pass when conditions are met")
    func combinedRules_AllPass() {
        let combinedRule = AnyValidationRule<String>.combined(
            .notEmpty,
            .minLength(3),
            .maxLength(10)
        )

        #expect(combinedRule.validate("Hello").isSuccessful)
        #expect(combinedRule.validate("ABC").isSuccessful)
        #expect(combinedRule.validate("HelloWorld").isSuccessful)
    }

    @Test("Combined rules fail with first failure")
    func combinedRules_FailWithFirstFailure() {
        let combinedRule = AnyValidationRule<String>.combined(
            .notEmpty,
            .minLength(3),
            .maxLength(10)
        )

        let emptyResult = combinedRule.validate("")
        #expect(!emptyResult.isSuccessful)
        if case .failure(let message) = emptyResult {
            #expect(String(localized: message) == "This field cannot be empty")
        }

        let shortResult = combinedRule.validate("A")
        #expect(!shortResult.isSuccessful)
        if case .failure(var message) = shortResult {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "This field must be at least 3 characters long")
        }

        let longResult = combinedRule.validate("This string is too long for the max length")
        #expect(!longResult.isSuccessful)
        if case .failure(var message) = longResult {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "This field must not exceed 10 characters")
        }
    }
}
