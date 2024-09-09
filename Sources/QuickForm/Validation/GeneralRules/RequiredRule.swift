//
//  RequiredRule.swift
//  quick-form
//
//  Created by Daniel Moro on 9.9.24..
//


public struct RequiredRule<T>: ValidationRule {
    public func validate(_ value: T?) -> ValidationResult {
        value != nil ? .success : .failure("This field is required")
    }

    public init() {}
}
