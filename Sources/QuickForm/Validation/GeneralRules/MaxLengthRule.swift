// MaxLengthRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

public struct MaxLengthRule: ValidationRule {
    let maxLength: Int

    public func validate(_ value: String) -> ValidationResult {
        value.count > maxLength ? .failure("This field must not exceed \(maxLength) characters") : .success
    }

    public init(length: Int) {
        maxLength = length
    }
}

public extension ValidationRule where Self == MaxLengthRule {
    static func maxLength(_ length: Int) -> MaxLengthRule {
        MaxLengthRule(length: length)
    }
}
