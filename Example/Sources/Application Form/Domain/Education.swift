// Education.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-12 04:28 GMT.

import Foundation

struct Education: Identifiable {
    var id: UUID
    var institution: String
    var startDate: Date
    var endDate: Date
}

#if DEBUG
    extension Education {
        static let sample = Education(id: UUID(), institution: "University of Example", startDate: Date(), endDate: Date())
    }
#endif
