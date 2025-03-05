// AutoMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:31 GMT.

import Foundation

/// A protocol that defines how text should be automatically formatted while being edited
public protocol AutoMask {
    /// Applies the mask to the input text
    /// - Parameter text: The raw text entered by the user
    /// - Returns: The formatted text according to the mask
    func apply(to text: String) -> String

    /// Determines if a character is allowed by the mask
    /// - Parameter character: The character to check
    /// - Returns: Whether the character is allowed
    func isAllowed(character: Character) -> Bool
}
