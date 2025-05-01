// AgeValidationRule.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-10 19:44 GMT.

import Foundation
import QuickForm

struct AgeValidationRule: ValidationRule {
    let minimumAge: Int
    let calendar: Calendar

    init(minimumAge: Int = 18, calendar: Calendar = Calendar.current) {
        self.minimumAge = minimumAge
        self.calendar = calendar
    }

    func validate(_ value: Person) -> ValidationResult {
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: value.dateOfBirth, to: now)

        guard let age = ageComponents.year else {
            return .failure("Unable to calculate age")
        }

        if age < minimumAge {
            return .failure("Person must be at least \(minimumAge) years old")
        }
        return .success
    }
}
