// ExperienceViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-10 04:37 GMT.

import Foundation
import Observation
import QuickForm

struct MinValueValidation<T: Comparable>: ValidationRule {
    var minValue: T

    func validate(_ value: T) -> ValidationResult {
        if value < minValue {
            return .failure("Value must be at least \(String(describing: minValue))")
        }

        return .success
    }
}

struct MaxValueValidation<T: Comparable>: ValidationRule {
    var maxValue: T

    func validate(_ value: T) -> ValidationResult {
        if value > maxValue {
            return .failure("Value must be less than \(String(describing: maxValue))")
        }

        return .success
    }
}

struct MinOptionalValueValidation<T: Comparable>: ValidationRule {
    var minValue: T

    func validate(_ value: T?) -> ValidationResult {
        if let value, value >= minValue {
            return .success
        }

        return .failure("Value must be at least \(String(describing: minValue))")
    }
}

extension ValidationRule {
    static func minValue<T: Comparable>(_ minValue: T) -> MinValueValidation<T> where Self == MinValueValidation<T> {
        MinValueValidation(minValue: minValue)
    }

    static func maxValue<T: Comparable>(_ maxValue: T) -> MaxValueValidation<T> where Self == MaxValueValidation<T> {
        MaxValueValidation(maxValue: maxValue)
    }

    static func minValue<T: Comparable>(
        _ minValue: T
    ) -> MinOptionalValueValidation<T> where Self == MinOptionalValueValidation<T> {
        MinOptionalValueValidation(minValue: minValue)
    }
}

extension ExperienceSkill: CustomStringConvertible {
    public var description: String {
        name
    }
}

@QuickForm(Experience.self)
final class ExperienceViewModel {
    @PropertyEditor(keyPath: \Experience.years)
    var years = FormattedFieldViewModel(
        type: Int.self,
        format: .number,
        title: "Years of experience",
        validation: .of(.minValue(4))
    )

    @PropertyEditor(keyPath: \Experience.skills)
    var skills = TokenSetViewModel(
        value: [ExperienceSkill](),
        title: "Skills",
        insertionPlaceholder: "Enter a new skill"
    ) { newString in
        ExperienceSkill(id: UUID(), name: newString, level: 1)
    }

    @PropertyEditor(keyPath: \Experience.skills)
    var skillsWithProficiencis = FormCollectionViewModel(
        value: [ExperienceSkill](),
        title: "Skills",
        insertionTitle: "New Skill"
    )
}
