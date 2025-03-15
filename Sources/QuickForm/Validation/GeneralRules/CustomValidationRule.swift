// CustomValidationRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:25 GMT.

public struct CustomValidationRule<T>: ValidationRule {
    let validate: (T) -> ValidationResult

    public init(_ validate: @escaping (T) -> ValidationResult) {
        self.validate = validate
    }

    public func validate(_ value: T) -> ValidationResult {
        validate(value)
    }
}

public extension ValidationRule {
    static func custom<T>(_ validate: @escaping (T) -> ValidationResult) -> AnyValidationRule<T> where Self == AnyValidationRule<T> {
        AnyValidationRule<T>(CustomValidationRule<T>(validate))
    }
}
