// ProfessionalDetails.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-09 09:54 GMT.

struct ProfessionalDetails {
    var desiredPosition: String
}

#if DEBUG
    extension ProfessionalDetails {
        static var sample: Self {
            .init(desiredPosition: "Software Developer")
        }
    }
#endif
