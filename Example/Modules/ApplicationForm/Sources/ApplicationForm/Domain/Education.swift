// Education.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-15 14:12 GMT.

import Foundation

public struct Education: Identifiable {
    public var id: UUID
    public var institution: String
    public var startDate: Date
    public var endDate: Date
    public var degree: String
    public var fieldOfStudy: String
    public var gpa: Int
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
