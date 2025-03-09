// ProfessionalDetails.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:54 GMT.

import Foundation

struct ProfessionalDetails {
    var desiredPosition: String
    var desiredSalary: Decimal
}

#if DEBUG
    extension ProfessionalDetails {
        static var sample: Self {
            .init(
                desiredPosition: "Software Developer",
                desiredSalary: 35000
            )
        }
    }
#endif
