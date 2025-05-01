// SpyValidationRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-30 18:03 GMT.

//
//  AgeValidationRule.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 30.9.24..
//
import QuickForm

struct SpyValidationRule: ValidationRule {
    var onValidation: ((String) -> Void)?

    init(onValidation: @escaping (String) -> Void) {
        self.onValidation = onValidation
    }

    func validate(_ value: PrescriptionComponents) -> ValidationResult {
        if let onValidation {
            onValidation(value.debugDescription)
        }

        return .success
    }
}
