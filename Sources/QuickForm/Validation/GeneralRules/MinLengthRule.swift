// MinLengthRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

public struct MinLengthRule: ValidationRule {
    let minLength: Int

    public func validate(_ value: String) -> ValidationResult {
        value.count < minLength ? .failure("This field must be at least \(minLength) characters long") : .success
    }

    public init(length: Int) {
        minLength = length
    }
}

public extension ValidationRule where Self == MinLengthRule {
    static func minLength(_ length: Int) -> MinLengthRule {
        MinLengthRule(length: length)
    }
}
