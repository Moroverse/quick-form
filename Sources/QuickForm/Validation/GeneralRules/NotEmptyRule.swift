// NotEmptyRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

public struct NotEmptyRule: ValidationRule {
    public func validate(_ value: String) -> ValidationResult {
        value.isEmpty ? .failure("This field cannot be empty") : .success
    }

    public init() {}
}

public extension ValidationRule where Self == NotEmptyRule {
    static var notEmpty: NotEmptyRule { NotEmptyRule() }
}
