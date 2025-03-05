// PatternMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:48 GMT.

import Foundation

/// A custom mask with a pattern like "XXX-XX-XXXX" for social security numbers
public struct PatternMask: AutoMask {
    private let pattern: String
    private let allowedCharacters: CharacterSet

    public init(pattern: String, allowedCharacters: CharacterSet = .decimalDigits) {
        self.pattern = pattern
        self.allowedCharacters = allowedCharacters
    }

    public func apply(to text: String) -> String {
        let filteredText = text.filter { char in
            let unicodeScalars = String(char).unicodeScalars
            return unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        }

        if filteredText.isEmpty {
            return ""
        }

        var result = ""
        var filteredIndex = filteredText.startIndex

        for patternChar in pattern {
            if filteredIndex >= filteredText.endIndex {
                break
            }

            if patternChar == "X" || patternChar == "#" {
                result.append(filteredText[filteredIndex])
                filteredIndex = filteredText.index(after: filteredIndex)
            } else {
                result.append(patternChar)
            }
        }

        return result
    }

    public func isAllowed(character: Character) -> Bool {
        let unicodeScalars = String(character).unicodeScalars
        return unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
}

public extension AutoMask where Self == PatternMask {
    /// Creates a social security number mask in format XXX-XX-XXXX
    static var ssn: PatternMask { PatternMask(pattern: "XXX-XX-XXXX") }

    /// Creates a US ZIP code mask in format XXXXX or XXXXX-XXXX
    static var zipCode: PatternMask {
        PatternMask(pattern: "XXXXX-XXXX", allowedCharacters: .decimalDigits)
    }

    /// Creates a custom mask with the specified pattern and allowed characters
    ///
    /// - Parameters:
    ///   - pattern: The pattern to apply. Use 'X' or '#' as placeholders for user-entered characters
    ///   - allowedCharacters: The set of characters allowed in user input
    /// - Returns: A pattern mask configured with the specified options
    static func pattern(
        _ pattern: String,
        allowedCharacters: CharacterSet = .decimalDigits
    ) -> PatternMask {
        PatternMask(pattern: pattern, allowedCharacters: allowedCharacters)
    }
}
