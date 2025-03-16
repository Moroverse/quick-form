// Applicant.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 10:10 GMT.

public struct Applicant {
    var personalInformation: PersonalInformation
    var professionalDetails: ProfessionalDetails
    var experience: Experience
    var education: [Education]
    var additionalInfo: AdditionalInfo

    public init(
        personalInformation: PersonalInformation,
        professionalDetails: ProfessionalDetails,
        experience: Experience,
        education: [Education],
        additionalInfo: AdditionalInfo
    ) {
        self.personalInformation = personalInformation
        self.professionalDetails = professionalDetails
        self.experience = experience
        self.education = education
        self.additionalInfo = additionalInfo
    }
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
