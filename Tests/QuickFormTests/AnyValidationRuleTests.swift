//
//  AnyValidationRuleTests.swift
//  quick-form
//
//  Created by Daniel Moro on 4.3.25..
//

import Foundation
import QuickForm
import Testing

// Test validation rules for testing AnyValidationRule
struct MinValueRule: ValidationRule {
    let minimumValue: Int

    init(minimumValue: Int) {
        self.minimumValue = minimumValue
    }

    func validate(_ value: Int) -> ValidationResult {
        return value >= minimumValue ? .success : .failure("Value must be at least \(minimumValue)")
    }
}

struct MaxValueRule: ValidationRule {
    let maximumValue: Int

    init(maximumValue: Int) {
        self.maximumValue = maximumValue
    }

    func validate(_ value: Int) -> ValidationResult {
        return value <= maximumValue ? .success : .failure("Value must not exceed \(maximumValue)")
    }
}

struct EvenNumberRule: ValidationRule {
    func validate(_ value: Int) -> ValidationResult {
        return value % 2 == 0 ? .success : .failure("Value must be an even number")
    }
}

@Suite("AnyValidationRule Tests")
struct AnyValidationRuleTests {

    @Test("Type-erases validation rules correctly")
    func typeErases() {
        let minRule = MinValueRule(minimumValue: 5)
        let anyRule = AnyValidationRule(minRule)

        // Test both rules behave the same
        #expect(minRule.validate(10).isSuccessful)
        #expect(anyRule.validate(10).isSuccessful)

        #expect(!minRule.validate(3).isSuccessful)
        #expect(!anyRule.validate(3).isSuccessful)

        // Test error messages are preserved
        var minErrorMessage: LocalizedStringResource?
        if case .failure(let message) = minRule.validate(3) {
            minErrorMessage = message
        }

        var anyErrorMessage: LocalizedStringResource?
        if case .failure(let message) = anyRule.validate(3) {
            anyErrorMessage = message
        }

        #expect(minErrorMessage == anyErrorMessage)
    }

    @Test("Creates rule with static 'of' method")
    func staticOfMethod() {
        let minRule = MinValueRule(minimumValue: 5)
        let anyRule = AnyValidationRule.of(minRule)

        #expect(anyRule.validate(10).isSuccessful)
        #expect(!anyRule.validate(3).isSuccessful)
    }

    @Test("Combines multiple rules correctly")
    func combinesRules() {
        let combinedRule = AnyValidationRule<Int>.combined(
            MinValueRule(minimumValue: 5),
            MaxValueRule(maximumValue: 10),
            EvenNumberRule()
        )

        // Valid: 6, 8, 10
        #expect(combinedRule.validate(6).isSuccessful)
        #expect(combinedRule.validate(8).isSuccessful)
        #expect(combinedRule.validate(10).isSuccessful)

        // Invalid: too small
        #expect(!combinedRule.validate(4).isSuccessful)

        // Invalid: too large
        #expect(!combinedRule.validate(11).isSuccessful)

        // Invalid: not even
        #expect(!combinedRule.validate(7).isSuccessful)
    }

    @Test("Combined rule returns first failure")
    func returnsFirstFailure() {
        let combinedRule = AnyValidationRule<Int>.combined(
            MinValueRule(minimumValue: 5),
            MaxValueRule(maximumValue: 10),
            EvenNumberRule()
        )

        // Test failure messages in order
        let tooSmallResult = combinedRule.validate(3)
        if case .failure(var message) = tooSmallResult {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "Value must be at least 5")
        } else {
            Issue.record("Expected failure for too small value")
        }

        let oddNumberResult = combinedRule.validate(7)
        if case .failure(var message) = oddNumberResult {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "Value must be an even number")
        } else {
            Issue.record("Expected failure for odd number")
        }

        let tooLargeResult = combinedRule.validate(11)
        if case .failure(var message) = tooLargeResult {
            message.locale = Locale(identifier: "en_US")
            #expect(String(localized: message) == "Value must not exceed 10")
        } else {
            Issue.record("Expected failure for too large value")
        }
    }

    @Test("Handles empty combined rules")
    func handlesCombinedEmpty() {
        // Empty combined rule should always succeed
        let emptyRule = AnyValidationRule<String>.combined()

        #expect(emptyRule.validate("anything").isSuccessful)
        #expect(emptyRule.validate("").isSuccessful)
    }
}

// Helper extension to make testing more readable
extension ValidationResult {
    var isSuccessful: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
