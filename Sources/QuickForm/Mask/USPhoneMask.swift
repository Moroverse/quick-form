// USPhoneMask.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-04-13 14:09 GMT.

import Foundation

/// A mask for formatting US phone numbers as the user types.
///
/// ``USPhoneMask`` automatically formats input text to match standard US phone number format
/// with parentheses around the area code and proper separators: (XXX) XXX-XXXX.
///
/// ## Features
/// - Formats digits into the standard US phone number pattern
/// - Automatically filters out non-numeric characters
/// - Limits input to 10 digits (standard US phone number length)
/// - Handles partial input gracefully with appropriate formatting
///
/// ## Example
///
/// ```swift
/// // Create a phone number field using the mask
/// @QuickForm(ContactForm.self)
/// class ContactFormModel: Validatable {
///     @PropertyEditor(keyPath: \ContactForm.phoneNumber)
///     var phoneNumber = FormFieldViewModel(
///         type: String.self,
///         title: "Phone:",
///         placeholder: "(555) 555-5555",
///         mask: .usPhone,
///         validation: .of(.usPhoneNumber)
///     )
/// }
/// ```
///
/// ## Format Details
///
/// - 1-3 digits: (123
/// - 4-6 digits: (123) 456
/// - 7-10 digits: (123) 456-7890
///
/// - SeeAlso: ``AutoMask``, ``USPhoneNumberFormatStyle``, ``PatternMask``
public struct USPhoneMask: AutoMask {
    /// Initializes a new US phone number mask.
    public init() {}

    /// Applies formatting to convert raw input into a formatted US phone number.
    ///
    /// - Parameter text: The raw text input to format
    /// - Returns: A formatted US phone number in (XXX) XXX-XXXX format
    ///
    /// This method:
    /// - Extracts only the numeric characters from input
    /// - Groups digits according to US phone number conventions
    /// - Formats partial input appropriately based on available digits
    /// - Limits the total number of digits to 10
    public func apply(to text: String) -> String {
        let digits = text.filter(\.isNumber)

        if digits.isEmpty {
            return ""
        }

        var result = ""
        let digitArray = Array(digits)

        // Area code
        if !digitArray.isEmpty {
            result.append("(")
            result.append(String(digitArray.prefix(min(3, digitArray.count))))

            if digitArray.count > 3 {
                result.append(") ")

                // First three digits after area code
                let nextThree = digitArray[3 ..< min(6, digitArray.count)]
                result.append(String(nextThree))

                if digitArray.count > 6 {
                    result.append("-")

                    // Final four digits
                    let final = digitArray[6 ..< min(10, digitArray.count)]
                    result.append(String(final))
                }
            }
        }

        return result
    }

    /// Determines if a character is allowed to be entered in a US phone number field.
    ///
    /// - Parameter character: The character to check
    /// - Returns: `true` if the character is a digit, `false` otherwise
    public func isAllowed(character: Character) -> Bool {
        character.isNumber
    }
}

/// Extension providing a convenient static accessor for the US phone mask.
public extension AutoMask where Self == USPhoneMask {
    /// Creates a standard US phone number mask in format (XXX) XXX-XXXX.
    ///
    /// This static accessor makes it easy to add US phone number masking to form fields:
    ///
    /// ```swift
    /// FormFieldViewModel(
    ///     type: String.self,
    ///     title: "Phone Number",
    ///     mask: .usPhone,
    ///     validation: .of(.usPhoneNumber)
    /// )
    /// ```
    static var usPhone: USPhoneMask { USPhoneMask() }

    /// Legacy support for the previous name.
    ///
    /// - Note: This property is provided for backward compatibility.
    ///         New code should use ``.usPhone`` instead.
    @available(*, deprecated, renamed: "usPhone", message: "Use `.usPhone` instead for clarity")
    static var phone: USPhoneMask { USPhoneMask() }
}
