// ProfessionalDetails.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 10:10 GMT.

import Foundation

public enum EmploymentType: CaseIterable {
    case fullTime
    case partTime
    case contract
}

public struct ProfessionalDetails {
    public var desiredPosition: String
    public var desiredSalary: Decimal
    public var availabilityDate: Date
    public var employmentType: Set<EmploymentType>
    public var willingToRelocate: Bool

    public init(desiredPosition: String, desiredSalary: Decimal, availabilityDate: Date, employmentType: Set<EmploymentType>, willingToRelocate: Bool) {
        self.desiredPosition = desiredPosition
        self.desiredSalary = desiredSalary
        self.availabilityDate = availabilityDate
        self.employmentType = employmentType
        self.willingToRelocate = willingToRelocate
    }
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
