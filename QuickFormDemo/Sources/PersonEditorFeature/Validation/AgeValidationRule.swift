//
//  AgeValidationRule.swift
//  QuickFormDemo
//
//  Created by Daniel Moro on 10.9.24..
//

import QuickForm
import Foundation

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
