// RequiredRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 19:08 GMT.

public struct RequiredRule<T>: ValidationRule {
    public func validate(_ value: T?) -> ValidationResult {
        value != nil ? .success : .failure("This field is required")
    }

    public init() {}
}
