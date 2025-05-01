// PersonSex+Description.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2024-09-09 02:27 GMT.

extension Person.Sex: CustomStringConvertible {
    var description: String {
        switch self {
        case .male:
            "Male"

        case .female:
            "Female"

        case .nonBinary:
            "Non-Binary"

        case .other:
            "Other"
        }
    }
}
