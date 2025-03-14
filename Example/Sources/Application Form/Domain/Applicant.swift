// Applicant.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-13 16:10 GMT.

struct Applicant {
    var personalInformation: PersonalInformation
    var professionalDetails: ProfessionalDetails
    var experience: Experience
    var education: [Education]
    var additionalInfo: AdditionalInfo
}

#if DEBUG
    extension Applicant {
        static var sample: Self {
            .init(
                personalInformation: .sample,
                professionalDetails: .sample,
                experience: .sample,
                education: [.sample],
                additionalInfo: .sample
            )
        }
    }
#endif
