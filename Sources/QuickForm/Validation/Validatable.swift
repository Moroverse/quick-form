// Validatable.swift
// Copyright (c) 2024 Moroverse
// Created by Daniel Moro on 2024-09-10 17:44 GMT.

import Foundation

public protocol Validatable {
    func validate() -> ValidationResult
}

public extension Validatable {
    var isValid: Bool {
        switch validate() {
        case .success:
            true

        case .failure:
            false
        }
    }

    var errorMessage: LocalizedStringResource? {
        switch validate() {
        case .success:
            nil

        case let .failure(message):
            message
        }
    }
}
