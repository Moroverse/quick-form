// ProfessionalDetails.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation

enum EmploymentType: CaseIterable {
    case fullTime
    case partTime
    case contract
}

struct ProfessionalDetails {
    var desiredPosition: String
    var desiredSalary: Decimal
    var availabilityDate: Date
    var employmentType: Set<EmploymentType>
    var willingToRelocate: Bool
}

#if DEBUG
    extension ProfessionalDetails {
        static var sample: Self {
            .init(
                desiredPosition: "Software Developer",
                desiredSalary: 35000,
                availabilityDate: Date(),
                employmentType: [.partTime],
                willingToRelocate: true
            )
        }
    }
#endif
