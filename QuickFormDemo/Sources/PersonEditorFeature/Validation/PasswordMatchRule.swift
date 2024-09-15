// PasswordMatchRule.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-15 05:19 GMT.

//
//  AgeValidationRule 2.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 15.9.24..
//
import QuickForm

struct PasswordMatchRule: ValidationRule {
    init() {}

    func validate(_ value: Person) -> ValidationResult {
        if value.password != value.passwordReentry {
            return .failure("Passwords must match")
        }

        return .success
    }
}
