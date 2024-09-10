//
//  Validatable.swift
//  quick-form
//
//  Created by Daniel Moro on 10.9.24..
//

import Foundation

public protocol Validatable {
    func validate() -> ValidationResult
}

public protocol CustomValidatable: Validatable {
    var customValidation: ((ValidationResult) -> ValidationResult)? { get set }
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
