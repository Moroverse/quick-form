// Education.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 05:07 GMT.

import Foundation

public struct Education: Identifiable {
    public var id: UUID
    public var institution: String
    public var startDate: Date
    public var endDate: Date
    public var degree: String
    public var fieldOfStudy: String
    public var gpa: Int

    public init(id: UUID, institution: String, startDate: Date, endDate: Date, degree: String, fieldOfStudy: String, gpa: Int) {
        self.id = id
        self.institution = institution
        self.startDate = startDate
        self.endDate = endDate
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.gpa = gpa
    }
}

#if DEBUG
    extension Education {
        static let sample = Education(
            id: UUID(),
            institution: "University of Example",
            startDate: Date(),
            endDate: Date(),
            degree: "Bachelor of Example",
            fieldOfStudy: "Example Studies",
            gpa: 5
        )
    }
#endif
