// Applicant.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 20:35 GMT.

struct Applicant {
    var personalInformation: PersonalInformation
    var professionalDetails: ProfessionalDetails
    var experience: Experience
}

#if DEBUG
    extension Applicant {
        static var sample: Self {
            .init(
                personalInformation: .sample,
                professionalDetails: .sample,
                experience: .sample
            )
        }
    }
#endif
