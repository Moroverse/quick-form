//
//  ValidatableTests.swift
//  quick-form
//
//  Created by Daniel Moro on 4.3.25..
//

import Foundation
import QuickForm
import Testing

/// Test implementation of Validatable for testing purposes
class TestValidatable: Validatable {
    var shouldSucceed: Bool
    var errorMessage: LocalizedStringResource

    init(shouldSucceed: Bool = true, errorMessage: LocalizedStringResource = "Validation failed") {
        self.shouldSucceed = shouldSucceed
        self.errorMessage = errorMessage
    }

    func validate() -> ValidationResult {
        return shouldSucceed ? .success : .failure(errorMessage)
    }
}

@Suite("Validatable Protocol Extensions Tests")
struct ValidatableTests {

    @Test("isValid returns true when validation succeeds")
    func isValidWithSuccess() {
        let sut = TestValidatable(shouldSucceed: true)

        #expect(sut.isValid == true)
    }

    @Test("isValid returns false when validation fails")
    func isValidWithFailure() {
        let sut = TestValidatable(shouldSucceed: false)

        #expect(sut.isValid == false)
    }

    @Test("errorMessage returns nil when validation succeeds")
    func errorMessageWithSuccess() {
        let sut = TestValidatable(shouldSucceed: true)

        #expect(sut.errorMessage == nil)
    }

    @Test("errorMessage returns the failure message when validation fails")
    func errorMessageWithFailure() {
        let customMessage: LocalizedStringResource = "Custom error message"
        let sut = TestValidatable(shouldSucceed: false, errorMessage: customMessage)

        #expect(sut.errorMessage == customMessage)
    }

    @Test("validate and isValid are consistent")
    func consistencyBetweenValidateAndIsValid() {
        let successCase = TestValidatable(shouldSucceed: true)
        let failureCase = TestValidatable(shouldSucceed: false)

        // Success case
        let successResult = successCase.validate()
        if case .success = successResult {
            #expect(successCase.isValid == true)
        } else {
            Issue.record("Expected success result but got \(successResult)")
        }

        // Failure case
        let failureResult = failureCase.validate()
        if case .failure = failureResult {
            #expect(failureCase.isValid == false)
        } else {
            Issue.record("Expected failure result but got \(failureResult)")
        }
    }

    @Test("validate and errorMessage are consistent")
    func consistencyBetweenValidateAndErrorMessage() {
        let customMessage: LocalizedStringResource = "Custom error message"
        let successCase = TestValidatable(shouldSucceed: true)
        let failureCase = TestValidatable(shouldSucceed: false, errorMessage: customMessage)

        // Success case
        let successResult = successCase.validate()
        if case .success = successResult {
            #expect(successCase.errorMessage == nil)
        } else {
            Issue.record("Expected success result but got \(successResult)")
        }

        // Failure case
        let failureResult = failureCase.validate()
        if case .failure(let message) = failureResult {
            #expect(failureCase.errorMessage == message)
            #expect(failureCase.errorMessage == customMessage)
        } else {
            Issue.record("Expected failure result but got \(failureResult)")
        }
    }
}
