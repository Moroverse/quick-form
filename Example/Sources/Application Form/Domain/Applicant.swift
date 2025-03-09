// Applicant.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:58 GMT.

struct Applicant {
    var personalInformation: PersonalInformation
    var professionalDetails: ProfessionalDetails
}

#if DEBUG
    extension Applicant {
        static var sample: Self {
            .init(personalInformation: .sample, professionalDetails: .sample)
        }
    }
#endif
