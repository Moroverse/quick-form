// PatternMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-05 04:59 GMT.

import Foundation

/// A mask that formats text according to a specified pattern.
///
/// `PatternMask` allows you to define a template pattern where special characters
/// ('X' or '#') act as placeholders for user input, while other characters are treated
/// as literals that are automatically inserted into the formatted string.
///
/// ## Features
/// - Supports custom patterns with 'X' or '#' as placeholders for user characters
/// - Automatically inserts delimiter characters (like hyphens) at specified positions
/// - Filters input to ensure only allowed characters are used
/// - Comes with predefined masks for common formats (SSN, ZIP codes)
///
/// ## How It Works
///
/// The pattern string defines the format where:
/// - 'X' or '#' represent a position where a user-entered character should appear
/// - Any other character is treated as a literal that gets inserted automatically
///
/// ## Example
///
/// ```swift
/// // Creating a custom phone number mask
/// let phoneMask = PatternMask(pattern: "(XXX) XXX-XXXX")
///
/// // Applying the mask to raw input
/// phoneMask.apply(to: "5551234567") // Returns "(555) 123-4567"
///
/// // Usage in a form field
/// @QuickForm(ContactForm.self)
/// class ContactFormModel: Validatable {
///     @PropertyEditor(keyPath: \ContactForm.ssn)
///     var ssn = FormFieldViewModel(
///         type: String.self,
///         title: "SSN:",
///         placeholder: "XXX-XX-XXXX"
///     )
/// }
///
/// // Usage in SwiftUI view
/// FormFormattedTextField(model.ssn, autoMask: .ssn)
/// ```
///
/// - SeeAlso: `AutoMask`, `CreditCardMask`, `FormFieldViewModel`
public struct PatternMask: AutoMask {
    /// The pattern template that defines how the text should be formatted.
    ///
    /// Use 'X' or '#' as placeholders for user-entered characters.
    /// All other characters in the pattern are treated as literals.
    private let pattern: String

    /// The set of characters allowed in user input.
    ///
    /// Characters not in this set will be filtered out during formatting.
    /// Default is `.decimalDigits` which allows only numbers 0-9.
    private let allowedCharacters: CharacterSet

    /// Initializes a new pattern mask with the specified format.
    ///
    /// - Parameters:
    ///   - pattern: The pattern string where 'X' or '#' represent positions for user characters
    ///   - allowedCharacters: The set of characters allowed in user input, defaults to decimal digits
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a date mask for MM/DD/YYYY format
    /// let dateMask = PatternMask(pattern: "XX/XX/XXXX")
    ///
    /// // Create a license key mask with letters and numbers
    /// let keyMask = PatternMask(
    ///     pattern: "XXXX-XXXX-XXXX-XXXX",
    ///     allowedCharacters: .alphanumerics
    /// )
    /// ```
    public init(pattern: String, allowedCharacters: CharacterSet = .decimalDigits) {
        self.pattern = pattern
        self.allowedCharacters = allowedCharacters
    }

    /// Applies the pattern mask to format the input text.
    ///
    /// - Parameter text: The raw text input to format
    /// - Returns: A formatted string according to the pattern
    ///
    /// This method:
    /// - Filters out characters not in the allowed set
    /// - Applies the pattern, inserting literal characters as needed
    /// - Preserves only as much input as the pattern can accommodate
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ssnMask = PatternMask(pattern: "XXX-XX-XXXX")
    /// ssnMask.apply(to: "123456789") // "123-45-6789"
    /// ssnMask.apply(to: "12345") // "123-45"
    /// ```
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
                if filteredText[filteredIndex] == patternChar {
                    filteredIndex = filteredText.index(after: filteredIndex)
                }
            }
        }

        return result
    }

    /// Determines if a character is allowed to be entered in a field using this mask.
    ///
    /// - Parameter character: The character to check
    /// - Returns: `true` if the character is in the allowed character set, `false` otherwise
    ///
    /// This method checks whether a given character is contained in the `allowedCharacters` set
    /// that was defined when the mask was created.
    public func isAllowed(character: Character) -> Bool {
        let unicodeScalars = String(character).unicodeScalars
        return unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
}

/// Extension providing convenient static accessors for common pattern masks.
public extension AutoMask where Self == PatternMask {
    /// Creates a social security number mask in format XXX-XX-XXXX.
    ///
    /// Use this mask for formatting U.S. Social Security Numbers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Usage with autoMask parameter
    /// FormFormattedTextField(model.ssn, autoMask: .ssn)
    ///
    /// // Or when creating the field model
    /// FormFieldViewModel(
    ///     type: String.self,
    ///     title: "Social Security Number:",
    ///     mask: .ssn
    /// )
    /// ```
    static var ssn: PatternMask { PatternMask(pattern: "XXX-XX-XXXX") }

    /// Creates a US ZIP code mask in format XXXXX or XXXXX-XXXX.
    ///
    /// Use this mask for formatting U.S. postal codes, supporting both
    /// the standard 5-digit format and the extended 9-digit format (ZIP+4).
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Usage with autoMask parameter
    /// FormFormattedTextField(model.zipCode, autoMask: .zipCode)
    ///
    /// // Or when creating the field model
    /// FormFieldViewModel(
    ///     type: String.self,
    ///     title: "ZIP Code:",
    ///     mask: .zipCode
    /// )
    /// ```
    static var zipCode: PatternMask {
        PatternMask(pattern: "XXXXX-XXXX", allowedCharacters: .decimalDigits)
    }

    /// Creates a custom mask with the specified pattern and allowed characters.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to apply. Use 'X' or '#' as placeholders for user-entered characters
    ///   - allowedCharacters: The set of characters allowed in user input, defaults to decimal digits
    /// - Returns: A pattern mask configured with the specified options
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Phone number with area code
    /// let phoneMask = AutoMask.pattern("(XXX) XXX-XXXX")
    ///
    /// // Date format (MM/DD/YYYY)
    /// let dateMask = AutoMask.pattern("XX/XX/XXXX")
    ///
    /// // Product key with letters and numbers
    /// let keyMask = AutoMask.pattern(
    ///     "XXXX-XXXX-XXXX-XXXX",
    ///     allowedCharacters: .alphanumerics
    /// )
    /// ```
    static func pattern(
        _ pattern: String,
        allowedCharacters: CharacterSet = .decimalDigits
    ) -> PatternMask {
        PatternMask(pattern: pattern, allowedCharacters: allowedCharacters)
    }
}
