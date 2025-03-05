// USZipCodeRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 19:45 GMT.

import Foundation
import QuickForm

public struct USZipCodeRule: ValidationRule {
    public func validate(_ value: String) -> ValidationResult {
        let zipCodeRegex = #"^\d{5}(-\d{4})?$"#
        let zipCodePredicate = NSPredicate(format: "SELF MATCHES %@", zipCodeRegex)

        return zipCodePredicate.evaluate(with: value)
            ? .success
            : .failure("Please enter a valid US ZIP code (e.g., 12345 or 12345-6789)")
    }

    public init() {}
}

public extension ValidationRule where Self == USZipCodeRule {
    static var usZipCode: USZipCodeRule { USZipCodeRule() }
}
