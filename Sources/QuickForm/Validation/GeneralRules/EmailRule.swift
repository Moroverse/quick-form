// EmailRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 05:25 GMT.

import Foundation

 public struct EmailRule: ValidationRule {
    public func validate(_ value: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: value) ? .success : .failure("Please enter a valid email address")
    }

    public init() {}
 }

 public extension ValidationRule where Self == EmailRule {
    static var email: EmailRule { EmailRule() }
 }
