// ValidationRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

public protocol ValidationRule<Value> {
    associatedtype Value
    func validate(_ value: Value) -> ValidationResult
}

public enum ValidationResult {
    case success
    case failure(LocalizedStringResource)
}
